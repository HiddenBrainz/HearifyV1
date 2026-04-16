import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../speaking_practice/data/practice_history.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    ref.read(audioServiceProvider).stop();
    ref.read(audioServiceProvider).stopBackgroundNoise();
    super.dispose();
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
    ref.read(practiceHistoryProvider.notifier).add(
          PracticeAttempt(
            target: c.correctAnswer,
            heard: choice,
            score: isCorrect ? 1 : 0,
            timestamp: DateTime.now(),
          ),
        );
  }

  void _next() {
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
                if (widget.backgroundNoiseVolume != null) ...[
                  const SizedBox(height: 4),
                  Text(
                      'Background noise is on at ${(widget.backgroundNoiseVolume! * 100).round()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.warning(b),
                      )),
                ],
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed:
                      audio.isSpeaking ? null : _playCurrent,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
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
