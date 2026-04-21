import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/auth_design_system.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';
import 'fill_in_blank_exercise_screen.dart';
import 'multiple_choice_exercise_screen.dart';
import 'open_set_sentence_exercise_screen.dart';

/// Sentence Comprehension level chooser — three tiles stacked:
/// Level 1 closed-set MC, Level 2 fill-in-the-blank, Level 3 open-set
/// speak-back. Styling mirrors the Matched Pairs + Word Recognition
/// level chooser screens.
class SentenceComprehensionLevelScreen extends ConsumerWidget {
  const SentenceComprehensionLevelScreen({super.key});

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
            'Sentence Comprehension',
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
                  _LevelSection(
                    title: SentenceComprehensionLevel.closedSet.levelLabel,
                    subtitle: 'Pick the sentence you heard.',
                    level: SentenceComprehensionLevel.closedSet,
                    onTap: () => _launchClosed(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _LevelSection(
                    title:
                        SentenceComprehensionLevel.fillInTheBlank.levelLabel,
                    subtitle: 'Fill in the missing word.',
                    level: SentenceComprehensionLevel.fillInTheBlank,
                    onTap: () => _launchFillInBlank(context),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _LevelSection(
                    title: SentenceComprehensionLevel.openSet.levelLabel,
                    subtitle: 'Speak the full sentence back.',
                    level: SentenceComprehensionLevel.openSet,
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
          category: ClassicExerciseCategory.sentenceComprehension,
          loader: repo.loadSentenceComprehension,
        ),
      ),
    );
  }

  void _launchFillInBlank(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FillInBlankExerciseScreen(),
      ),
    );
  }

  void _launchOpen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OpenSetSentenceExerciseScreen(),
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final SentenceComprehensionLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        const SizedBox(height: AppSpacing.l),
        _LevelTile(level: level, onTap: onTap),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.level, required this.onTap});

  final SentenceComprehensionLevel level;
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
