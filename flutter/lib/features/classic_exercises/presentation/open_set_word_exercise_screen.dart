import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../../services/audio_service.dart';
import '../../../services/speech_recognition_service.dart';
import '../../../shared/data/practice_history.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';
import '../domain/session_config.dart';

/// Word Recognition — Level 2 (Open Set). Plays a word via TTS, the
/// user speaks it back, we score the transcription via
/// [pronunciationSimilarity]. Auto-advances when the score clears a
/// pass threshold; otherwise shows the revealed state so the user can
/// see what they said vs. the target before tapping Next.
class OpenSetWordExerciseScreen extends ConsumerStatefulWidget {
  const OpenSetWordExerciseScreen({super.key});

  @override
  ConsumerState<OpenSetWordExerciseScreen> createState() =>
      _OpenSetWordExerciseScreenState();
}

class _OpenSetWordExerciseScreenState
    extends ConsumerState<OpenSetWordExerciseScreen> {
  static const double _passThreshold = 0.75;

  final _rand = math.Random();
  List<MultipleChoiceItem> _pool = const [];
  List<MultipleChoiceItem> _session = const [];
  int _index = 0;
  int _correct = 0;
  bool _loading = true;
  bool _revealed = false;
  double? _lastScore;
  String? _lastHeard;
  Timer? _autoAdvance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void deactivate() {
    _autoAdvance?.cancel();
    ref.read(audioServiceProvider).stop();
    ref.read(sttServiceProvider).cancel();
    super.deactivate();
  }

  Future<void> _load() async {
    final pool = await ref
        .read(exerciseRepositoryProvider)
        .loadWordRecognition();
    // Prime STT permissions early so the first mic tap is responsive.
    await ref.read(sttServiceProvider).requestAuthorization();
    if (!mounted) return;
    setState(() {
      _pool = pool;
      _session = _drawSession(pool);
      _loading = false;
    });
    _playCurrent();
  }

  List<MultipleChoiceItem> _drawSession(List<MultipleChoiceItem> pool) {
    if (pool.isEmpty) return const [];
    final shuffled = [...pool]..shuffle(_rand);
    final n = math.min(SessionConfig.itemsPerSession, shuffled.length);
    return shuffled.sublist(0, n);
  }

  MultipleChoiceItem? get _current =>
      _session.isEmpty ? null : _session[_index.clamp(0, _session.length - 1)];

  Future<void> _playCurrent() async {
    final c = _current;
    if (c == null) return;
    await ref.read(audioServiceProvider).speak(c.prompt);
  }

  Future<void> _toggleMic() async {
    final stt = ref.read(sttServiceProvider);
    final target = _current?.prompt;
    if (target == null) return;
    if (stt.isRecording) {
      final r = await stt.stopRecording();
      if (r != null) _scoreAttempt(target, r.words);
    } else {
      // Make sure the word isn't still playing when they start speaking.
      await ref.read(audioServiceProvider).stop();
      await stt.startRecording(expectedText: target);
    }
  }

  void _scoreAttempt(String target, String heard) {
    final score = pronunciationSimilarity(target, heard);
    final passed = score >= _passThreshold;
    setState(() {
      _revealed = true;
      _lastScore = score;
      _lastHeard = heard;
      if (passed) _correct++;
    });
    ref.read(practiceHistoryProvider.notifier).add(
          PracticeAttempt(
            target: target,
            heard: heard,
            score: score,
            timestamp: DateTime.now(),
          ),
        );
    if (passed) {
      _autoAdvance?.cancel();
      _autoAdvance = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _next();
      });
    }
  }

  void _next() {
    _autoAdvance?.cancel();
    if (_index >= _session.length - 1) {
      _showSummary();
      return;
    }
    setState(() {
      _index++;
      _revealed = false;
      _lastScore = null;
      _lastHeard = null;
    });
    _playCurrent();
  }

  void _startNewSession() {
    _autoAdvance?.cancel();
    setState(() {
      _session = _drawSession(_pool);
      _index = 0;
      _correct = 0;
      _revealed = false;
      _lastScore = null;
      _lastHeard = null;
    });
    _playCurrent();
  }

  Future<void> _endEarly() async {
    _autoAdvance?.cancel();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End session?'),
        content: Text(
          'You\'ve answered ${_revealed ? _index + 1 : _index} of '
          '${_session.length}. Your score so far will be saved.',
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
    await ref.read(sttServiceProvider).cancel();
    if (!mounted) return;
    final answered = _revealed ? _index + 1 : _index;
    final pct = answered == 0 ? 0.0 : _correct / answered;
    final b = Theme.of(context).brightness;
    final action = await showDialog<_SummaryAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: const Text('Open Set — session complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(pct * 100).round()}%',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: pct >= 0.75
                    ? AppTheme.success(b)
                    : pct >= 0.5
                        ? AppTheme.warning(b)
                        : AppTheme.error(b),
              ),
            ),
            Text(
              '$_correct of $answered correct',
              style: TextStyle(
                fontSize: 14,
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
            child: Text('Another ${SessionConfig.itemsPerSession}'),
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
    final accent = WordRecognitionLevel.openSet.color(b);
    final audio = ref.watch(audioServiceProvider);
    final stt = ref.watch(sttServiceProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Open Set'),
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
                    child: Text(
                      'No words found. Check that WordRecognitionData.csv is '
                      'bundled under assets/csv.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary(b)),
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
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
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
                  fontWeight: FontWeight.w500,
                  color: AppTheme.success(b),
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
                      ? 'Listening — say the word'
                      : _revealed
                          ? 'Tap play to hear it again'
                          : 'Tap play, then speak the word back',
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
          _MicButton(
            accent: accent,
            recording: stt.isRecording,
            enabled: !_revealed && !audio.isSpeaking,
            onTap: _toggleMic,
          ),
          const SizedBox(height: AppTheme.spacingM),
          if (_revealed) _RevealPanel(
            target: c.prompt,
            heard: _lastHeard ?? '',
            score: _lastScore ?? 0,
            passed: (_lastScore ?? 0) >= _passThreshold,
            brightness: b,
          ),
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: accent,
            ),
            onPressed: _revealed ? _next : null,
            child: Text(_index >= _session.length - 1 ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
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

class _RevealPanel extends StatelessWidget {
  const _RevealPanel({
    required this.target,
    required this.heard,
    required this.score,
    required this.passed,
    required this.brightness,
  });

  final String target;
  final String heard;
  final double score;
  final bool passed;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final b = brightness;
    final resultColor = passed
        ? AppTheme.success(b)
        : score >= 0.5
            ? AppTheme.warning(b)
            : AppTheme.error(b);
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.replay_circle_filled,
                color: resultColor,
              ),
              const SizedBox(width: 8),
              Text(
                passed ? 'Nice!' : 'Try again next time',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(b),
                ),
              ),
              const Spacer(),
              Text(
                '${(score * 100).round()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: resultColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _KVRow(label: 'Target', value: target),
          const SizedBox(height: 6),
          _KVRow(label: 'You said', value: heard.isEmpty ? '—' : heard),
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(b),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary(b),
            ),
          ),
        ),
      ],
    );
  }
}

enum _SummaryAction { done, another }
