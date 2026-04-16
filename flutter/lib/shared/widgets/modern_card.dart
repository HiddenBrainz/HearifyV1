import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Thin wrapper providing the "ModernCard" look from HearifyV1's Swift UI —
/// rounded corners, subtle elevation, and theme-aware background.
class ModernCard extends StatelessWidget {
  const ModernCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground(b),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: b == Brightness.dark ? 0.3 : 0.12,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
      child: child,
    );
  }
}
