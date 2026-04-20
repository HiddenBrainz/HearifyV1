import 'package:flutter/material.dart';

import '../../../../core/theme/auth_design_system.dart';

/// Wide pill CTA painted with the neon blue→purple→magenta gradient.
/// Supports a leading icon, a loading state, and a disabled state
/// (which desaturates the gradient and suppresses shadow glow).
class GradientPrimaryButton extends StatelessWidget {
  const GradientPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.loading = false,
    this.height = 58,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final bool loading;
  final double height;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _enabled ? 1 : 0.6,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: AppGradients.primaryCta,
          borderRadius: BorderRadius.circular(AppRadii.button),
          boxShadow: _enabled ? AppShadows.ctaButton : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.button),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.button),
            onTap: _enabled ? onPressed : null,
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leadingIcon != null) ...[
                          Icon(leadingIcon,
                              size: 20, color: AppColors.textPrimary),
                          const SizedBox(width: AppSpacing.m),
                        ],
                        Text(label, style: AppTextStyles.ctaLabel),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
