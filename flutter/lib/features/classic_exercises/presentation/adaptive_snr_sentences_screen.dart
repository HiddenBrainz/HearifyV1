import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../../services/audio_service.dart';
import '../../../services/speech_recognition_service.dart';
import '../../../shared/data/practice_history.dart';
import '../../../shared/data/phonetic_taxonomy.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../clinician/data/session_writer.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';

/// Sentences in Noise — Level 2 (BKB-SIN style adaptive SNR-50). Plays
/// each sentence at a fixed SNR (descending +21 → 0 dB), the user
/// speaks the sentence back, the screen tallies key words correct, and
/// at session end reports `SNR-50 = 23.5 − total_keywords_correct`.
///
/// One session = one BKB-SIN list (8 sentences). Successive sessions
/// rotate through the bundled list IDs (9A, 9B, 10A, 10B, …).
class AdaptiveSnrSentencesScreen extends ConsumerStatefulWidget {
  const AdaptiveSnrSentencesScreen({super.key});

  @override
  ConsumerState<AdaptiveSnrSentencesScreen> createState() =>
      _AdaptiveSnrSentencesScreenState();
}

class _AdaptiveSnrSentencesScreenState
    extends ConsumerState<AdaptiveSnrSentencesScreen> {
  /// BKB-SIN constant — SNR-50 = K − keywords_correct.
  static const double _snr50K = 23.5;

  final _rand = math.Random();
  List<String> _availableLists = const [];
  String? _listId;
  List<AdaptiveSentenceItem> _session = const [];
  int _index = 0;
  int _keyWordsCorrect = 0;
  bool _loading = true;
  bool _revealed = false;
  String? _lastHeard;
  int? _lastMatched;
  String? _loadError;
  Timer? _autoAdvance;

  // Per-session attempts captured for the clinical-dashboard aggregate.
  final List<PracticeAttempt> _sessionAttempts = [];
  DateTime _sessionStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void deactivate() {
    _autoAdvance?.cancel();
    final audio = ref.read(audioServiceProvider);
    audio.stop();
    audio.stopBackgroundNoise();
    ref.read(sttServiceProvider).cancel();
    super.deactivate();
  }

  Future<void> _load() async {
    Map<String, List<AdaptiveSentenceItem>> groups;
    try {
      groups =
          await ref.read(exerciseRepositoryProvider).loadBkbSinByList();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError =
            'Couldn\'t load BKBSINData.csv. If you just added the data, '
            'do a full Flutter restart (not hot-reload) so it gets '
            'bundled. Details: $e';
      });
      return;
    }
    // STT permission is best-effort; if the user denies, the mic just
    // won't capture but the rest of the drill still runs.
    try {
      await ref.read(sttServiceProvider).requestAuthorization();
    } catch (e) {
      if (kDebugMode) debugPrint('STT auth failed: $e');
    }
    if (!mounted) return;
    final lists = groups.keys.toList()..sort();
    if (lists.isEmpty) {
      setState(() {
        _loading = false;
        _loadError = 'BKBSINData.csv parsed to zero items. Check the file.';
      });
      return;
    }
    final pickedList = lists[_rand.nextInt(lists.length)];
    setState(() {
      _availableLists = lists;
      _listId = pickedList;
      _session = groups[pickedList]!;
      _loading = false;
    });
    // Background noise + initial speech are best-effort — if either
    // fails (permission, missing asset, web autoplay) the user can
    // still tap Play and the screen survives.
    _sessionStart = DateTime.now();
    unawaited(_setNoiseForCurrent());
    unawaited(_playCurrent());
  }

  AdaptiveSentenceItem? get _current =>
      _session.isEmpty ? null : _session[_index.clamp(0, _session.length - 1)];

  Future<void> _setNoiseForCurrent() async {
    final c = _current;
    if (c == null) return;
    final volume = noiseVolumeForSnrDb(c.snrDb);
    final audio = ref.read(audioServiceProvider);
    try {
      if (audio.isPlayingBackgroundNoise) {
        await audio.setBackgroundNoiseVolume(volume);
      } else {
        await audio.startBackgroundNoise(volume: volume);
      }
    } catch (e) {
      // Web autoplay policy or missing BackgroundNoise.mp3 — the drill
      // still runs without the noise stem.
      if (kDebugMode) debugPrint('Background noise failed: $e');
    }
  }

  Future<void> _playCurrent() async {
    final c = _current;
    if (c == null) return;
    await ref.read(audioServiceProvider).speak(c.sentence);
  }

  Future<void> _toggleMic() async {
    final stt = ref.read(sttServiceProvider);
    final c = _current;
    if (c == null) return;
    if (stt.isRecording) {
      final r = await stt.stopRecording();
      if (r != null) _scoreAttempt(c, r.words);
    } else {
      await ref.read(audioServiceProvider).stop();
      await stt.startRecording(expectedText: c.sentence);
    }
  }

  void _scoreAttempt(AdaptiveSentenceItem c, String heard) {
    final matched = keyWordsMatched(
      target: c.sentence,
      heard: heard,
      cap: c.keyWords,
    );
    setState(() {
      _revealed = true;
      _lastHeard = heard;
      _lastMatched = matched;
      _keyWordsCorrect += matched;
    });
    final attempt = PracticeAttempt(
      target: c.sentence,
      heard: heard,
      score: c.keyWords == 0 ? 0 : matched / c.keyWords,
      timestamp: DateTime.now(),
      exerciseType: ExerciseType.bkbSin,
      categoryTag: PhoneticCategory.sentenceNoise,
      snrDb: c.snrDb.toDouble(),
    );
    _sessionAttempts.add(attempt);
    ref.read(practiceHistoryProvider.notifier).add(attempt);
    // Always auto-advance — adaptive lists must be heard end-to-end so
    // the SNR-50 sum is meaningful.
    _autoAdvance?.cancel();
    _autoAdvance = Timer(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      _next();
    });
  }

  Future<void> _next() async {
    _autoAdvance?.cancel();
    if (_index >= _session.length - 1) {
      _showSummary();
      return;
    }
    setState(() {
      _index++;
      _revealed = false;
      _lastHeard = null;
      _lastMatched = null;
    });
    await _setNoiseForCurrent();
    _playCurrent();
  }

  Future<void> _startNewSession() async {
    _autoAdvance?.cancel();
    if (_availableLists.isEmpty) return;
    // Rotate to a different list when possible.
    final pool = _availableLists.where((l) => l != _listId).toList();
    final pick = pool.isEmpty
        ? _availableLists[_rand.nextInt(_availableLists.length)]
        : pool[_rand.nextInt(pool.length)];
    final groups =
        await ref.read(exerciseRepositoryProvider).loadBkbSinByList();
    if (!mounted) return;
    _sessionAttempts.clear();
    _sessionStart = DateTime.now();
    setState(() {
      _listId = pick;
      _session = groups[pick] ?? const [];
      _index = 0;
      _keyWordsCorrect = 0;
      _revealed = false;
      _lastHeard = null;
      _lastMatched = null;
    });
    await _setNoiseForCurrent();
    _playCurrent();
  }

  Future<void> _endEarly() async {
    _autoAdvance?.cancel();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End session?'),
        content: Text(
          "You've completed ${_revealed ? _index + 1 : _index} of "
          '${_session.length} sentences. SNR-50 needs the full list to '
          'be meaningful.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (confirm == true) _showSummary();
  }

  Future<void> _showSummary() async {
    await ref.read(audioServiceProvider).stop();
    await ref.read(audioServiceProvider).stopBackgroundNoise();
    await ref.read(sttServiceProvider).cancel();
    final snr50 = _snr50K - _keyWordsCorrect;
    unawaited(
      ref.read(sessionWriterProvider).writeSession(
            exerciseType: ExerciseType.bkbSin,
            attempts: List<PracticeAttempt>.unmodifiable(_sessionAttempts),
            duration: DateTime.now().difference(_sessionStart),
            snr50: snr50,
          ),
    );
    if (!mounted) return;
    final totalKeyWords =
        _session.fold<int>(0, (a, b) => a + b.keyWords);
    final b = Theme.of(context).brightness;
    final pct = totalKeyWords == 0
        ? 0.0
        : _keyWordsCorrect / totalKeyWords;
    final action = await showDialog<_SummaryAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text('BKB-SIN ${_listId ?? ''} — complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'SNR-50',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(b),
              ),
            ),
            Text(
              '${snr50.toStringAsFixed(1)} dB',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: snr50 <= 7
                    ? AppTheme.success(b)
                    : snr50 <= 13
                        ? AppTheme.warning(b)
                        : AppTheme.error(b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_keyWordsCorrect / $totalKeyWords key words '
              '· ${(pct * 100).round()}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(b),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_SummaryAction.done),
            child: const Text('Done'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_SummaryAction.another),
            child: const Text('Another list'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == _SummaryAction.another) {
      _startNewSession();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = SentencesInNoiseLevel.adaptiveSnr50.color(b);
    final audio = ref.watch(audioServiceProvider);
    final stt = ref.watch(sttServiceProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Adaptive SNR-50'),
        actions: [
          if (!_loading && _session.isNotEmpty)
            IconButton(
              tooltip: 'End session',
              icon: const Icon(Icons.close),
              onPressed: _endEarly,
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _current == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _loadError ??
                            'No BKB-SIN data found. Check that '
                                'BKBSINData.csv is bundled.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary(b),
                        ),
                      ),
                    ),
                  )
                : _body(accent, audio, stt, b),
      ),
    );
  }

  Widget _body(
    Color accent,
    AudioService audio,
    SpeechRecognitionService stt,
    Brightness b,
  ) {
    final c = _current!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${_index + 1} / ${_session.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(b),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_index + 1) / _session.length,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$_keyWordsCorrect KW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.success(b),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'List ${_listId ?? ''}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary(b),
                ),
              ),
              _SnrChip(snrDb: c.snrDb, accent: accent),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ModernCard(
            child: Column(
              children: [
                Icon(
                  audio.isSpeaking ? Icons.graphic_eq : Icons.headphones,
                  size: 40,
                  color: accent,
                ),
                const SizedBox(height: 8),
                Text(
                  stt.isRecording
                      ? 'Listening — say the sentence back'
                      : _revealed
                          ? 'Auto-advancing…'
                          : 'Listen, then speak the sentence back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(b),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: audio.isSpeaking ? null : _playCurrent,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Center(
            child: _MicCircle(
              accent: accent,
              recording: stt.isRecording,
              enabled: !_revealed && !audio.isSpeaking,
              onTap: _toggleMic,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          if (_revealed)
            _RevealCard(
              target: c.sentence,
              heard: _lastHeard ?? '',
              matched: _lastMatched ?? 0,
              keyWords: c.keyWords,
              brightness: b,
            ),
        ],
      ),
    );
  }
}

class _SnrChip extends StatelessWidget {
  const _SnrChip({required this.snrDb, required this.accent});
  final int snrDb;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        '${snrDb >= 0 ? '+' : ''}$snrDb dB SNR',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}

class _MicCircle extends StatelessWidget {
  const _MicCircle({
    required this.accent,
    required this.recording,
    required this.enabled,
    required this.onTap,
  });

  final Color accent;
  final bool recording;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = recording ? AppColors.errorText : accent;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: activeColor.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Icon(
              recording ? Icons.stop_rounded : Icons.mic_rounded,
              color: activeColor,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({
    required this.target,
    required this.heard,
    required this.matched,
    required this.keyWords,
    required this.brightness,
  });

  final String target;
  final String heard;
  final int matched;
  final int keyWords;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final b = brightness;
    final passed = keyWords > 0 && matched / keyWords >= 0.5;
    final color = passed ? AppTheme.success(b) : AppTheme.warning(b);
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.info_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                '$matched / $keyWords key words',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Target: $target',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary(b),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You said: ${heard.isEmpty ? '—' : heard}',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary(b),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SummaryAction { done, another }
