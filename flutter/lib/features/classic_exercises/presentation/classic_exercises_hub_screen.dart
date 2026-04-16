import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';
import 'custom_practice_screen.dart';
import 'matched_pairs_screen.dart';
import 'multiple_choice_exercise_screen.dart';

/// Landing screen listing all classic Module-1 categories.
/// Matches the Swift app's `TrainingCategory` enum order.
class ClassicExercisesHubScreen extends ConsumerWidget {
  const ClassicExercisesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Module 1 — Classic Exercises')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            for (final c in ClassicExerciseCategory.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: _tile(context, ref, c, b),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx, WidgetRef ref, ClassicExerciseCategory c,
      Brightness b) {
    final color = c.color(b);
    return Material(
      color: AppTheme.cardBackground(b),
      elevation: 2,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        onTap: () => _launch(ctx, ref, c),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(c.icon, color: color, size: 28),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(b),
                        )),
                    const SizedBox(height: 2),
                    Text(c.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(b),
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary(b)),
            ],
          ),
        ),
      ),
    );
  }

  void _launch(BuildContext ctx, WidgetRef ref, ClassicExerciseCategory c) {
    final repo = ref.read(exerciseRepositoryProvider);
    switch (c) {
      case ClassicExerciseCategory.wordRecognition:
        Navigator.push(ctx, MaterialPageRoute(
          builder: (_) => MultipleChoiceExerciseScreen(
            category: c,
            loader: repo.loadWordRecognition,
          ),
        ));
      case ClassicExerciseCategory.sentenceComprehension:
        Navigator.push(ctx, MaterialPageRoute(
          builder: (_) => MultipleChoiceExerciseScreen(
            category: c,
            loader: repo.loadSentenceComprehension,
          ),
        ));
      case ClassicExerciseCategory.sentencesInNoise:
        Navigator.push(ctx, MaterialPageRoute(
          builder: (_) => MultipleChoiceExerciseScreen(
            category: c,
            loader: repo.loadSentencesInNoise,
            backgroundNoiseVolume: 0.4,
          ),
        ));
      case ClassicExerciseCategory.diagnosticTest:
        Navigator.push(ctx, MaterialPageRoute(
          builder: (_) => MultipleChoiceExerciseScreen(
            category: c,
            loader: repo.loadDiagnosticTest,
          ),
        ));
      case ClassicExerciseCategory.matchedPairs:
        Navigator.push(ctx, MaterialPageRoute(
          builder: (_) => const MatchedPairsScreen(),
        ));
      case ClassicExerciseCategory.customPractice:
        Navigator.push(ctx, MaterialPageRoute(
          builder: (_) => const CustomPracticeScreen(),
        ));
    }
  }
}

