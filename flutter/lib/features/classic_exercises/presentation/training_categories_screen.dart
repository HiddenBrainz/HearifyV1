import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/auth_design_system.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';
import 'custom_practice_screen.dart';
import 'matched_pairs_subcategory_screen.dart';
import 'multiple_choice_exercise_screen.dart';
import 'sentence_comprehension_level_screen.dart';
import 'sentences_in_noise_level_screen.dart';
import 'widgets/category_card.dart';
import 'widgets/featured_insights_card.dart';
import 'word_recognition_level_screen.dart';

/// Post-login landing: a 2×3 grid of the six Classic Exercise categories,
/// a featured Practice Insights card, and a bottom Practice List CTA.
/// Inherits the login screen's premium dark aesthetic — gradient
/// navy background, transparent top bar, neon accent CTA — while each
/// tile stays dynamic via its per-category color.
class TrainingCategoriesScreen extends ConsumerWidget {
  const TrainingCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ClassicExerciseCategory.values;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bgPrimary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(onSettings: () => context.push('/settings')),
                  const SizedBox(height: AppSpacing.l),
                  // Cards stay square via AspectRatio. The grid is only
                  // as tall as it needs to be; the Spacer below absorbs
                  // any leftover vertical space so we don't end up with
                  // huge gaps between rows on tall phones.
                  _CategoriesGrid(
                    categories: categories,
                    onTap: (c) => _launch(context, ref, c),
                  ),
                  const Spacer(),
                  FeaturedInsightsCard(
                    title: 'Practice Insights',
                    subtitle:
                        'View practice patterns and ideas to discuss with your audiologist',
                    icon: Icons.psychology_outlined,
                    onTap: () => context.push('/progress'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launch(BuildContext ctx, WidgetRef ref, ClassicExerciseCategory c) {
    final repo = ref.read(exerciseRepositoryProvider);
    switch (c) {
      case ClassicExerciseCategory.wordRecognition:
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const WordRecognitionLevelScreen(),
          ),
        );
      case ClassicExerciseCategory.sentenceComprehension:
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const SentenceComprehensionLevelScreen(),
          ),
        );
      case ClassicExerciseCategory.sentencesInNoise:
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const SentencesInNoiseLevelScreen(),
          ),
        );
      case ClassicExerciseCategory.diagnosticTest:
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => MultipleChoiceExerciseScreen(
              category: c,
              loader: repo.loadDiagnosticTest,
            ),
          ),
        );
      case ClassicExerciseCategory.matchedPairs:
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const MatchedPairsSubcategoryScreen(),
          ),
        );
      case ClassicExerciseCategory.customPractice:
        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const CustomPracticeScreen()),
        );
    }
  }
}

/// 2 × 3 grid of category cards. Each card stays square via
/// `AspectRatio`, so the grid takes only the height it needs and the
/// surrounding Column's `Spacer` absorbs any leftover space — no more
/// rows that stretch into airy rectangles on tall phones.
class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.categories, required this.onTap});

  final List<ClassicExerciseCategory> categories;
  final ValueChanged<ClassicExerciseCategory> onTap;

  @override
  Widget build(BuildContext context) {
    Widget row(int a, int b) => Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: CategoryCard(
                  category: categories[a],
                  onTap: () => onTap(categories[a]),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: CategoryCard(
                  category: categories[b],
                  onTap: () => onTap(categories[b]),
                ),
              ),
            ),
          ],
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row(0, 1),
        const SizedBox(height: AppSpacing.m),
        row(2, 3),
        const SizedBox(height: AppSpacing.m),
        row(4, 5),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Training Categories',
            style: AppTextStyles.title.copyWith(fontSize: 30),
          ),
        ),
        _SettingsIconButton(onTap: onSettings),
      ],
    );
  }
}

class _SettingsIconButton extends StatelessWidget {
  const _SettingsIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.authCardTop,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.hairline, width: 0.5),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.m),
          child: Icon(
            Icons.settings_outlined,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
