import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/auth_design_system.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';
import 'multiple_choice_exercise_screen.dart';
import 'open_set_word_exercise_screen.dart';

/// Word Recognition level chooser — two-tier layout mirroring the
/// Matched Pairs sub-category screen. Level 1 drops into the existing
/// closed-set multiple-choice drill; Level 2 routes to the open-set
/// speak-back drill.
class WordRecognitionLevelScreen extends ConsumerWidget {
  const WordRecognitionLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bgPrimary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            'Word Recognition',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.xl,
                AppSpacing.l,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LevelHeader(
                    title: 'Level 1',
                    subtitle: 'Start with four options.',
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _LevelTile(
                    level: WordRecognitionLevel.closedSet,
                    onTap: () => _launchClosed(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const _LevelHeader(
                    title: 'Level 2',
                    subtitle: 'Step it up — speak the word back.',
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _LevelTile(
                    level: WordRecognitionLevel.openSet,
                    onTap: () => _launchOpen(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchClosed(BuildContext context, WidgetRef ref) {
    final repo = ref.read(exerciseRepositoryProvider);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultipleChoiceExerciseScreen(
          category: ClassicExerciseCategory.wordRecognition,
          loader: repo.loadWordRecognition,
        ),
      ),
    );
  }

  void _launchOpen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OpenSetWordExerciseScreen(),
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title.copyWith(fontSize: 22)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.level, required this.onTap});

  final WordRecognitionLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = level.color(b);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 22,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.button),
          splashColor: accent.withValues(alpha: 0.14),
          highlightColor: accent.withValues(alpha: 0.08),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.l,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadii.input),
                  ),
                  child: Icon(level.icon, color: accent, size: 22),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.displayName,
                        style: AppTextStyles.ctaLabel.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        level.description,
                        style: AppTextStyles.inputLabel.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textInactive,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
