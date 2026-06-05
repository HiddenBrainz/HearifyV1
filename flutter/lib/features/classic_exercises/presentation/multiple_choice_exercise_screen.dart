import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/data/practice_history.dart';
import '../../../shared/data/phonetic_taxonomy.dart';
import '../../clinician/data/session_writer.dart';
import '../domain/classic_exercise.dart';
import '../domain/session_config.dart';

typedef ItemLoader = Future<List<MultipleChoiceItem>> Function();

/// Shared runner for Word Recognition, Sentence Comprehension, Sentences in
/// Noise, and Diagnostic Test.
///
/// Each run is a bounded session: `SessionConfig.itemsPerSession` items are
/// sampled at random from the full CSV, presented one at a time, and the
/// summary dialog at the end lets the user finish or pull another batch.
class MultipleChoiceExerciseScreen extends ConsumerStatefulWidget {
  const MultipleChoiceExerciseScreen({
    super.key,
    required this.category,
    required this.loader,
    this.backgroundNoiseVolume,
  });

  final ClassicExerciseCategory category;
  final ItemLoader loader;
  final double? backgroundNoiseVolume;

  @override
  ConsumerState<MultipleChoiceExerciseScreen> createState() =>
      _MultipleChoiceExerciseScreenState();
}

class _MultipleChoiceExerciseScreenState
    extends ConsumerState<MultipleChoiceExerciseScreen> {
  final _rand = math.Random();
  List<MultipleChoiceItem> _pool = const [];
  List<MultipleChoiceItem> _session = const [];
  int _index = 0;
  int _correct = 0;
  bool _loading = true;
  String? _selected;
  bool _revealed = false;
  List<String> _shuffledChoices = const [];
  Timer? _autoAdvance;

  // ── Clinical metrics capture ─────────────────────────────────────
  // Track per-session attempts so we can ship a single Firestore
  // aggregate at session close instead of writing per-item.
  final List<PracticeAttempt> _sessionAttempts = [];
  DateTime _sessionStart = DateTime.now();
  DateTime? _promptFinishedAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void deactivate() {
    // `ref` is invalid once `dispose()` runs, so tear down audio here
    // while the element is still mounted.
    _autoAdvance?.cancel();
    final audio = ref.read(audioServiceProvider);
    audio.stop();
    audio.stopBackgroundNoise();
    super.deactivate();
  }

  Future<void> _load() async {
    final pool = await widget.loader();
    if (!mounted) return;
    setState(() {
      _pool = pool;
      _session = _drawSession(pool);
      _loading = false;
      _shuffledChoices =
          _shuffleFor(_session.isNotEmpty ? _session.first : null);
    });
    if (widget.backgroundNoiseVolume != null) {
      await ref
          .read(audioServiceProvider)
          .startBackgroundNoise(volume: widget.backgroundNoiseVolume!);
    }
    _sessionStart = DateTime.now();
    _playCurrent();
  }

  List<MultipleChoiceItem> _drawSession(List<MultipleChoiceItem> pool) {
    if (pool.isEmpty) return const [];
    final shuffled = [...pool]..shuffle(_rand);
    final n = math.min(SessionConfig.itemsPerSession, shuffled.length);
    return shuffled.sublist(0, n);
  }

  List<String> _shuffleFor(MultipleChoiceItem? item) {
    if (item == null) return const [];
    final c = [...item.choices]..shuffle(_rand);
    return c;
  }

  MultipleChoiceItem? get _current =>
      _session.isEmpty ? null : _session[_index.clamp(0, _session.length - 1)];

  Future<void> _playCurrent() async {
    final c = _current;
    if (c == null) return;
    await ref.read(audioServiceProvider).speak(c.prompt);
    // Time-to-respond is measured from the moment the prompt finishes
    // playing (not from screen show), so we don't penalize patients
    // for slow TTS.
    _promptFinishedAt = DateTime.now();
  }

  void _pick(String choice) {
    if (_revealed) return;
    final c = _current!;
    final isCorrect =
        choice.toLowerCase() == c.correctAnswer.toLowerCase();
    setState(() {
      _selected = choice;
      _revealed = true;
      if (isCorrect) _correct++;
    });
    final responseTimeMs = _promptFinishedAt == null
        ? null
        : DateTime.now().difference(_promptFinishedAt!).inMilliseconds;
    final attempt = PracticeAttempt(
      target: c.correctAnswer,
      heard: choice,
      score: isCorrect ? 1 : 0,
      timestamp: DateTime.now(),
      exerciseType: classicExerciseExerciseType(widget.category),
      categoryTag: classicExerciseCategoryTag(widget.category),
      responseTimeMs: responseTimeMs,
      wrongChoice: isCorrect ? null : choice,
    );
    _sessionAttempts.add(attempt);
    ref.read(practiceHistoryProvider.notifier).add(attempt);
    if (isCorrect) {
      // Let the green check read for a beat, then move on automatically.
      _autoAdvance?.cancel();
      _autoAdvance = Timer(const Duration(milliseconds: 800), () {
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
      _selected = null;
      _revealed = false;
      _shuffledChoices = _shuffleFor(_current);
    });
    _playCurrent();
  }

  void _startNewSession() {
    _autoAdvance?.cancel();
    _sessionAttempts.clear();
    _sessionStart = DateTime.now();
    setState(() {
      _session = _drawSession(_pool);
      _index = 0;
      _correct = 0;
      _selected = null;
      _revealed = false;
      _shuffledChoices = _shuffleFor(_current);
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
          'You\'ve answered ${_revealed ? _index + 1 : _index} of ${_session.length}. '
          'Your score so far will be saved.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep going')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('End')),
        ],
      ),
    );
    if (confirm == true) _showSummary();
  }

  Future<void> _showSummary() async {
    await ref.read(audioServiceProvider).stop();
    await ref.read(audioServiceProvider).stopBackgroundNoise();
    // Persist a per-session aggregate to Firestore for the audiologist
    // dashboard. Fire-and-forget — failures are swallowed inside the
    // writer so they never block the summary dialog.
    unawaited(
      ref.read(sessionWriterProvider).writeSession(
            exerciseType: classicExerciseExerciseType(widget.category),
            attempts: List<PracticeAttempt>.unmodifiable(_sessionAttempts),
            duration: DateTime.now().difference(_sessionStart),
            backgroundNoiseLevel: widget.backgroundNoiseVolume,
          ),
    );
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
        title: Text('${widget.category.displayName} complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${(pct * 100).round()}%',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: pct >= 0.75
                      ? AppTheme.success(b)
                      : pct >= 0.5
                          ? AppTheme.warning(b)
                          : AppTheme.error(b),
                )),
            Text('$_correct of $answered correct',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary(b),
                )),
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
            child: Text(
                'Another ${SessionConfig.itemsPerSession}'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == _SummaryAction.another) {
      if (widget.backgroundNoiseVolume != null) {
        await ref
            .read(audioServiceProvider)
            .startBackgroundNoise(volume: widget.backgroundNoiseVolume!);
      }
      _startNewSession();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final audio = ref.watch(audioServiceProvider);
    final color = widget.category.color(b);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: Text(widget.category.displayName),
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
            : _session.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No exercises found for this category. Check that the '
                        'relevant CSV is bundled under assets/csv.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary(b)),
                      ),
                    ),
                  )
                : _body(audio, color, b),
      ),
    );
  }

  Widget _body(AudioService audio, Color color, Brightness b) {
    final c = _current!;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          Row(
            children: [
              Text('${_index + 1} / ${_session.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(b),
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_index + 1) / _session.length,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text('$_correct correct',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.success(b),
                  )),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ModernCard(
            child: Column(
              children: [
                Icon(audio.isSpeaking ? Icons.graphic_eq : Icons.headphones,
                    size: 40, color: color),
                const SizedBox(height: 8),
                Text('Tap play to hear the ${c.type}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary(b),
                    )),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed:
                      audio.isSpeaking ? null : _playCurrent,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                if (widget.backgroundNoiseVolume != null) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  _NoiseSlider(audio: audio, accent: color),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Expanded(
            child: ListView.separated(
              itemCount: _shuffledChoices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _choiceTile(_shuffledChoices[i], c, b),
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: color,
            ),
            onPressed: _revealed ? _next : null,
            child: Text(_index >= _session.length - 1 ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _choiceTile(String choice, MultipleChoiceItem q, Brightness b) {
    final correct = _revealed &&
        choice.toLowerCase() == q.correctAnswer.toLowerCase();
    final wrongSelected =
        _revealed && _selected == choice && !correct;
    final tileColor = correct
        ? AppTheme.success(b).withValues(alpha: 0.2)
        : wrongSelected
            ? AppTheme.error(b).withValues(alpha: 0.2)
            : _selected == choice
                ? AppTheme.primaryBlue(b).withValues(alpha: 0.1)
                : AppTheme.cardBackground(b);
    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: _revealed ? null : () => _pick(choice),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle
                    : wrongSelected
                        ? Icons.cancel
                        : Icons.radio_button_unchecked,
                color: correct
                    ? AppTheme.success(b)
                    : wrongSelected
                        ? AppTheme.error(b)
                        : AppTheme.textTertiary(b),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(choice,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textPrimary(b),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SummaryAction { done, another }

class _NoiseSlider extends StatelessWidget {
  const _NoiseSlider({required this.audio, required this.accent});

  final AudioService audio;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final pct = (audio.backgroundNoiseVolume * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.graphic_eq_rounded,
                size: 16, color: AppTheme.warning(b)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Background noise',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary(b),
                ),
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.warning(b),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.warning(b),
            inactiveTrackColor: AppTheme.warning(b).withValues(alpha: 0.2),
            thumbColor: AppTheme.warning(b),
            overlayColor: AppTheme.warning(b).withValues(alpha: 0.2),
            trackHeight: 3,
          ),
          child: Slider(
            value: audio.backgroundNoiseVolume.clamp(0.0, 1.0),
            min: 0.0,
            max: 1.0,
            divisions: 20,
            label: '$pct%',
            onChanged: (v) => audio.setBackgroundNoiseVolume(v),
          ),
        ),
      ],
    );
  }
}
