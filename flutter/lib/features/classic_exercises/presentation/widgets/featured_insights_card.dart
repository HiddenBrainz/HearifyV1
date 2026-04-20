import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/auth_design_system.dart';

/// Full-width featured card shown below the category grid. Uses the
/// same dark auth-surface + outlined-glow recipe as the grid tiles
/// but sized wider and tinted with the accent purple so it reads as a
/// distinct, stronger-weight destination.
class FeaturedInsightsCard extends StatelessWidget {
  const FeaturedInsightsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = AppTheme.accentPurple(b);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(
          color: accent.withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.24),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 12),
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
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 44, color: accent),
                const SizedBox(height: AppSpacing.m),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.ctaLabel,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTextStyles.inputLabel.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
