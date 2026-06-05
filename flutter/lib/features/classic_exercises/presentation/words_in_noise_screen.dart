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

/// Word Recognition — Level 3 (Words in Noise / WIN). Plays each word
/// at a fixed SNR (descending +24 → 0 dB in 4-dB steps, 5 words per
/// step), the user speaks it back, the screen scores correct words.
/// At session end reports `SNR-50 = 26 − total_correct`.
class WordsInNoiseScreen extends ConsumerStatefulWidget {
  const WordsInNoiseScreen({super.key});

  @override
  ConsumerState<WordsInNoiseScreen> createState() =>
      _WordsInNoiseScreenState();
}

class _WordsInNoiseScreenState extends ConsumerState<WordsInNoiseScreen> {
  /// WIN constant — SNR-50 = K − words_correct.
  static const double _snr50K = 26.0;
  static const double _passSimilarity = 0.75;

  final _rand = math.Random();
  List<String> _availableLists = const [];
  String? _listId;
  List<WordInNoiseItem> _session = const [];
  int _index = 0;
  int _correct = 0;
  bool _loading = true;
  bool _revealed = false;
  String? _lastHeard;
  bool _lastPassed = false;
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
    Map<String, List<WordInNoiseItem>> groups;
    try {
      groups = await ref.read(exerciseRepositoryProvider).loadWinByList();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError =
            'Couldn\'t load WINData.csv. If you just added the data, do '
            'a full Flutter restart (not hot-reload) so it gets bundled. '
            'Details: $e';
      });
      return;
    }
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
        _loadError = 'WINData.csv parsed to zero items. Check the file.';
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
    _sessionStart = DateTime.now();
    unawaited(_setNoiseForCurrent());
    unawaited(_playCurrent());
  }

  WordInNoiseItem? get _current =>
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
      if (kDebugMode) debugPrint('Background noise failed: $e');
    }
  }

  Future<void> _playCurrent() async {
    final c = _current;
    if (c == null) return;
    await ref.read(audioServiceProvider).speak(c.word);
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
      await stt.startRecording(expectedText: c.word);
    }
  }

  void _scoreAttempt(WordInNoiseItem c, String heard) {
    final sim = pronunciationSimilarity(c.word, heard);
    final passed = sim >= _passSimilarity;
    setState(() {
      _revealed = true;
      _lastHeard = heard;
      _lastPassed = passed;
      if (passed) _correct++;
    });
    final attempt = PracticeAttempt(
      target: c.word,
      heard: heard,
      score: sim,
      timestamp: DateTime.now(),
      exerciseType: ExerciseType.wordsInNoise,
      categoryTag: PhoneticCategory.wordNoise,
      snrDb: c.snrDb.toDouble(),
    );
    _sessionAttempts.add(attempt);
    ref.read(practiceHistoryProvider.notifier).add(attempt);
    _autoAdvance?.cancel();
    _autoAdvance = Timer(const Duration(milliseconds: 900), () {
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
      _lastPassed = false;
    });
    await _setNoiseForCurrent();
    _playCurrent();
  }

  Future<void> _startNewSession() async {
    _autoAdvance?.cancel();
    if (_availableLists.isEmpty) return;
    final pool = _availableLists.where((l) => l != _listId).toList();
    final pick = pool.isEmpty
        ? _availableLists[_rand.nextInt(_availableLists.length)]
        : pool[_rand.nextInt(pool.length)];
    final groups =
        await ref.read(exerciseRepositoryProvider).loadWinByList();
    if (!mounted) return;
    _sessionAttempts.clear();
    _sessionStart = DateTime.now();
    setState(() {
      _listId = pick;
      _session = groups[pick] ?? const [];
      _index = 0;
      _correct = 0;
      _revealed = false;
      _lastHeard = null;
      _lastPassed = false;
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
          '${_session.length} words. SNR-50 needs the full list to be '
          'meaningful.',
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
    final snr50 = _snr50K - _correct;
    unawaited(
      ref.read(sessionWriterProvider).writeSession(
            exerciseType: ExerciseType.wordsInNoise,
            attempts: List<PracticeAttempt>.unmodifiable(_sessionAttempts),
            duration: DateTime.now().difference(_sessionStart),
            snr50: snr50,
          ),
    );
    if (!mounted) return;
    final b = Theme.of(context).brightness;
    final pct = _session.isEmpty ? 0.0 : _correct / _session.length;
    final action = await showDialog<_SummaryAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text('WIN List ${_listId ?? ''} — complete'),
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
                color: snr50 <= 6
                    ? AppTheme.success(b)
                    : snr50 <= 14
                        ? AppTheme.warning(b)
                        : AppTheme.error(b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_correct / ${_session.length} words · '
              '${(pct * 100).round()}%',
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
    final accent = WordRecognitionLevel.wordsInNoise.color(b);
    final audio = ref.watch(audioServiceProvider);
    final stt = ref.watch(sttServiceProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Words in Noise'),
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
                            'No WIN data found. Check that WINData.csv '
                                'is bundled.',
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
                '$_correct correct',
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '+${c.snrDb} dB SNR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
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
                      ? 'Listening — say the word back'
                      : _revealed
                          ? 'Auto-advancing…'
                          : 'Listen, then speak the word back',
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
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        _lastPassed ? Icons.check_circle : Icons.cancel,
                        color: _lastPassed
                            ? AppTheme.success(b)
                            : AppTheme.error(b),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _lastPassed ? 'Got it!' : 'Missed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _lastPassed
                              ? AppTheme.success(b)
                              : AppTheme.error(b),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: ${c.word}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary(b),
                    ),
                  ),
                  Text(
                    'You said: ${_lastHeard?.isNotEmpty == true ? _lastHeard : '—'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary(b),
                    ),
                  ),
                ],
              ),
            ),
        ],
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

enum _SummaryAction { done, another }
