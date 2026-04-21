import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/auth_design_system.dart';
import '../domain/classic_exercise.dart';
import 'matched_pairs_screen.dart';

/// Matched Pairs sub-category chooser — ports the iOS
/// `auditoryHierarchyScreenContent` two-tier layout (Beginner +
/// Intermediate/Advanced) in ContentView.swift L4271. Each row picks
/// which CSV the drill screen loads.
class MatchedPairsSubcategoryScreen extends StatelessWidget {
  const MatchedPairsSubcategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final beginner = MatchedPairsSubcategory.values
        .where((s) => s.tier == MatchedPairsTier.beginner);
    final advanced = MatchedPairsSubcategory.values
        .where((s) => s.tier == MatchedPairsTier.intermediateAdvanced);

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
            'Matched Pairs',
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
                  const _TierHeader(
                    title: 'Beginner',
                    subtitle: 'Start here — clear, easy-to-tell-apart pairs.',
                  ),
                  const SizedBox(height: AppSpacing.l),
                  for (final sub in beginner) ...[
                    _SubcategoryTile(sub: sub),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  const _TierHeader(
                    title: 'Intermediate/Advanced',
                    subtitle: 'Step it up — subtler consonant contrasts.',
                  ),
                  const SizedBox(height: AppSpacing.l),
                  for (final sub in advanced) ...[
                    _SubcategoryTile(sub: sub),
                    const SizedBox(height: AppSpacing.m),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TierHeader extends StatelessWidget {
  const _TierHeader({required this.title, required this.subtitle});

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

class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile({required this.sub});

  final MatchedPairsSubcategory sub;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = sub.color(b);
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MatchedPairsScreen(subcategory: sub),
            ),
          ),
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
                  child: Icon(sub.icon, color: accent, size: 22),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.displayName,
                        style: AppTextStyles.ctaLabel.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        sub.description,
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
