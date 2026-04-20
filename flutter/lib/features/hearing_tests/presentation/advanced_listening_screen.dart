import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../domain/advanced_listening_exercise.dart';
import '../domain/common_models.dart';

/// Port of HearifyV1/Views/AdvancedListeningView.swift.
/// Displays a filterable grid of listening exercises. Tapping an exercise
/// opens a sheet that runs the exercise: TTS plays the target audio, user
/// answers the questions, score is revealed.
class AdvancedListeningScreen extends ConsumerStatefulWidget {
  const AdvancedListeningScreen({super.key});

  @override
  ConsumerState<AdvancedListeningScreen> createState() =>
      _AdvancedListeningScreenState();
}

class _AdvancedListeningScreenState
    extends ConsumerState<AdvancedListeningScreen> {
  DifficultyLevel? _difficultyFilter;
  AdvancedExerciseType? _typeFilter;

  List<AdvancedListeningExercise> get _filtered => sampleExercises
      .where((e) =>
          (_difficultyFilter == null || e.difficulty == _difficultyFilter) &&
          (_typeFilter == null || e.type == _typeFilter))
      .toList();

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Advanced Listening')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            _headerCard(b),
            const SizedBox(height: AppTheme.spacingM),
            _difficultyFilterRow(b),
            const SizedBox(height: AppTheme.spacingS),
            _typeFilterRow(b),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              '${_filtered.length} exercise${_filtered.length == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(b),
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            ..._filtered.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: _exerciseCard(e, b),
                )),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(Brightness b) => ModernCard(
        child: Row(
          children: [
            Icon(Icons.headphones,
                size: 40, color: AppTheme.primaryBlue(b)),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Listening practice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary(b),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    'Train with varied exercise types and noise levels. '
                    'Tap an exercise to begin.',
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

  Widget _difficultyFilterRow(Brightness b) => _chipRow(
        label: 'Difficulty',
        b: b,
        chips: [
          _filterChip('All', _difficultyFilter == null,
              () => setState(() => _difficultyFilter = null), b),
          ...DifficultyLevel.values.map((d) => _filterChip(
                d.displayName,
                _difficultyFilter == d,
                () => setState(() => _difficultyFilter = d),
                b,
                color: d.color(b),
              )),
        ],
      );

  Widget _typeFilterRow(Brightness b) => _chipRow(
        label: 'Type',
        b: b,
        chips: [
          _filterChip('All', _typeFilter == null,
              () => setState(() => _typeFilter = null), b),
          ...AdvancedExerciseType.values.map((t) => _filterChip(
                t.displayName,
                _typeFilter == t,
                () => setState(() => _typeFilter = t),
                b,
              )),
        ],
      );

  Widget _chipRow(
      {required String label,
      required List<Widget> chips,
      required Brightness b}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary(b),
            )),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in chips) ...[
                c,
                const SizedBox(width: 8),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(
    String text,
    bool selected,
    VoidCallback onTap,
    Brightness b, {
    Color? color,
  }) {
    final resolved = color ?? AppTheme.primaryBlue(b);
    return FilterChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppTheme.cardBackground(b),
      selectedColor: resolved.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: selected ? resolved : AppTheme.textPrimary(b),
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? resolved : AppTheme.textTertiary(b),
        ),
      ),
    );
  }

  Widget _exerciseCard(AdvancedListeningExercise ex, Brightness b) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      onTap: () => _runExercise(ex),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ex.difficulty.color(b).withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(ex.type.icon, color: ex.difficulty.color(b)),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(b),
                          )),
                      Text(ex.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary(b),
                          )),
                    ],
                  ),
                ),
                _pill(ex.difficulty.displayName, ex.difficulty.color(b)),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(ex.instructions,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary(b),
                )),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Icon(ex.backgroundNoiseLevel.icon,
                    size: 14, color: AppTheme.textTertiary(b)),
                const SizedBox(width: 4),
                Text(ex.backgroundNoiseLevel.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary(b),
                    )),
                const SizedBox(width: 12),
                Icon(Icons.help_outline,
                    size: 14, color: AppTheme.textTertiary(b)),
                const SizedBox(width: 4),
                Text(
                    '${ex.questions.length} question${ex.questions.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary(b),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            )),
      );

  void _runExercise(AdvancedListeningExercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ExerciseRunner(exercise: exercise),
    );
  }
}

class _ExerciseRunner extends ConsumerStatefulWidget {
  const _ExerciseRunner({required this.exercise});
  final AdvancedListeningExercise exercise;

  @override
  ConsumerState<_ExerciseRunner> createState() => _ExerciseRunnerState();
}

class _ExerciseRunnerState extends ConsumerState<_ExerciseRunner> {
  int _questionIndex = 0;
  final Map<int, String> _answers = {};
  final _shortAnswerController = TextEditingController();
  bool _playedOnce = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playAudio());
  }

  @override
  void deactivate() {
    // `ref` is invalid once `dispose()` runs, so tear down audio here
    // while the element is still mounted.
    final audio = ref.read(audioServiceProvider);
    audio.stop();
    audio.stopBackgroundNoise();
    super.deactivate();
  }

  @override
  void dispose() {
    _shortAnswerController.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    final audio = ref.read(audioServiceProvider);
    await audio.setPlaybackSpeed(widget.exercise.audioContent.speed.multiplier);
    if (widget.exercise.backgroundNoiseLevel != BackgroundNoiseLevel.none &&
        !_playedOnce) {
      await audio.startBackgroundNoise(
          volume: 1 - widget.exercise.backgroundNoiseLevel.snrDb / 100);
    }
    _playedOnce = true;
    setState(() {});
    await audio.speak(widget.exercise.audioContent.text);
  }

  int _computeScore() {
    int correct = 0;
    for (var i = 0; i < widget.exercise.questions.length; i++) {
      final q = widget.exercise.questions[i];
      final a = _answers[i]?.trim().toLowerCase() ?? '';
      if (a == q.correctAnswer.toLowerCase()) correct++;
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final q = widget.exercise.questions[_questionIndex];
    final audio = ref.watch(audioServiceProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary(b),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _submitted ? _resultView(b) : _questionView(q, audio, b),
    );
  }

  Widget _questionView(ListeningQuestion q, AudioService audio, Brightness b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(widget.exercise.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(b),
                  )),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        LinearProgressIndicator(
          value:
              (_questionIndex + 1) / widget.exercise.questions.length,
        ),
        const SizedBox(height: AppTheme.spacingM),
        ModernCard(
          child: Column(
            children: [
              Icon(audio.isSpeaking ? Icons.graphic_eq : Icons.volume_up,
                  size: 40, color: AppTheme.primaryBlue(b)),
              const SizedBox(height: AppTheme.spacingS),
              Text('Tap to replay',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(b),
                  )),
              const SizedBox(height: AppTheme.spacingS),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: audio.isSpeaking ? null : _playAudio,
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Replay'),
                  ),
                  if (widget.exercise.audioContent.speed != AudioSpeed.slow)
                    OutlinedButton.icon(
                      onPressed: audio.isSpeaking
                          ? null
                          : () async {
                              await audio.setPlaybackSpeed(AudioSpeed.slow.multiplier);
                              await audio.speak(widget.exercise.audioContent.text);
                            },
                      icon: const Icon(Icons.slow_motion_video, size: 18),
                      label: const Text('Slow'),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(q.prompt,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(b),
            )),
        const SizedBox(height: AppTheme.spacingS),
        if (q.hint.isNotEmpty)
          Text('Hint: ${q.hint}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary(b),
              )),
        const SizedBox(height: AppTheme.spacingM),
        Expanded(child: _answerUi(q, b)),
        const SizedBox(height: AppTheme.spacingM),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: AppTheme.primaryBlue(b),
          ),
          onPressed: _currentAnswer(q).isEmpty ? null : _advance,
          child: Text(_questionIndex < widget.exercise.questions.length - 1
              ? 'Next'
              : 'Submit'),
        ),
      ],
    );
  }

  String _currentAnswer(ListeningQuestion q) {
    if (q.questionType == QuestionType.shortAnswer ||
        q.questionType == QuestionType.fillInBlank) {
      return _shortAnswerController.text.trim();
    }
    return _answers[_questionIndex] ?? '';
  }

  Widget _answerUi(ListeningQuestion q, Brightness b) {
    if (q.questionType == QuestionType.multipleChoice ||
        q.questionType == QuestionType.trueFalse) {
      return ListView.separated(
        itemBuilder: (_, i) => _optionTile(q.options[i], b),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: q.options.length,
      );
    }
    return TextField(
      controller: _shortAnswerController,
      onChanged: (_) => setState(() {}),
      maxLines: q.questionType == QuestionType.shortAnswer ? 3 : 1,
      decoration: const InputDecoration(
        labelText: 'Your answer',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _optionTile(String option, Brightness b) {
    final selected = _answers[_questionIndex] == option;
    return Material(
      color: selected
          ? AppTheme.primaryBlue(b).withValues(alpha: 0.1)
          : AppTheme.cardBackground(b),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: () => setState(() => _answers[_questionIndex] = option),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppTheme.primaryBlue(b)
                    : AppTheme.textTertiary(b),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(option,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary(b),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _advance() async {
    final q = widget.exercise.questions[_questionIndex];
    if (q.questionType == QuestionType.shortAnswer ||
        q.questionType == QuestionType.fillInBlank) {
      _answers[_questionIndex] = _shortAnswerController.text.trim();
    }
    if (_questionIndex < widget.exercise.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _shortAnswerController.clear();
      });
      return;
    }
    await ref.read(audioServiceProvider).stop();
    await ref.read(audioServiceProvider).stopBackgroundNoise();
    setState(() => _submitted = true);
  }

  Widget _resultView(Brightness b) {
    final correct = _computeScore();
    final total = widget.exercise.questions.length;
    final pct = correct / total;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pct >= 0.8
                ? Icons.star
                : pct >= 0.5
                    ? Icons.thumb_up
                    : Icons.refresh,
            color: pct >= 0.5 ? AppTheme.success(b) : AppTheme.warning(b),
            size: 80,
          ),
          const SizedBox(height: 16),
          Text('${(pct * 100).round()}%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(b),
              )),
          Text('$correct of $total correct',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary(b),
              )),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
