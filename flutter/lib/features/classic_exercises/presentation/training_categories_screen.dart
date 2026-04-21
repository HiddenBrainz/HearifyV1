import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../auth/presentation/widgets/gradient_primary_button.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';
import 'custom_practice_screen.dart';
import 'matched_pairs_subcategory_screen.dart';
import 'multiple_choice_exercise_screen.dart';
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
    final b = Theme.of(context).brightness;
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(onSettings: () => context.push('/settings')),
                  const SizedBox(height: AppSpacing.xl),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.l,
                      crossAxisSpacing: AppSpacing.l,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (_, i) => CategoryCard(
                      category: categories[i],
                      onTap: () => _launch(context, ref, categories[i]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FeaturedInsightsCard(
                    title: 'Practice Insights',
                    subtitle:
                        'View practice patterns and ideas to discuss with your audiologist',
                    icon: Icons.psychology_outlined,
                    onTap: () => context.push('/progress'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GradientPrimaryButton(
                    label: 'My Practice List (0 items)',
                    leadingIcon: Icons.bookmark_outline,
                    gradient: AppTheme.accentGradient(b),
                    onPressed: () => context.push('/practice-list'),
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
            builder: (_) => MultipleChoiceExerciseScreen(
              category: c,
              loader: repo.loadSentenceComprehension,
            ),
          ),
        );
      case ClassicExerciseCategory.sentencesInNoise:
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => MultipleChoiceExerciseScreen(
              category: c,
              loader: repo.loadSentencesInNoise,
              backgroundNoiseVolume: 0.4,
            ),
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
