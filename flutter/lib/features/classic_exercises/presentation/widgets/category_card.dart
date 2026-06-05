import 'package:flutter/material.dart';

import '../../../../core/theme/auth_design_system.dart';
import '../../domain/classic_exercise.dart';

/// Square tile for the Training Categories grid. Carries the login
/// screen's premium dark aesthetic: dark auth-card surface, a tinted
/// outline and soft glow in the category's semantic color, a
/// gradient-painted icon, and a white title. Each card keeps its
/// per-category color for visual dynamicity while the recipe stays
/// uniform across all six tiles.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final ClassicExerciseCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = category.color(b);
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
            color: accent.withValues(alpha: 0.22),
            blurRadius: 22,
            spreadRadius: -6,
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
          // No FittedBox — it gave the inner Text unbounded width so a
          // long label like "Sentence Comprehension" rendered on one
          // very-wide line and got scaled DOWN to fit, while shorter
          // labels rendered at full size. The result was inconsistent
          // typography across the six cards. Letting the Column lay
          // out within the cell's bounded width forces the long label
          // to wrap to two lines at the same font size as everyone
          // else.
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category.icon, size: 40, color: accent),
                const SizedBox(height: AppSpacing.s),
                Text(
                  category.displayName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.ctaLabel.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
