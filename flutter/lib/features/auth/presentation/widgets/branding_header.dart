import 'package:flutter/material.dart';

import '../../../../core/theme/auth_design_system.dart';

/// Centered brand block: a luminous indigo-violet circle with a
/// gradient-painted glyph inside, plus the app title and tagline.
class BrandingHeader extends StatelessWidget {
  const BrandingHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.mark = Icons.hearing_rounded,
  });

  final String title;
  final String subtitle;
  final IconData mark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoCircle(mark: mark),
        const SizedBox(height: AppSpacing.xxl),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.m),
        Text(subtitle,
            textAlign: TextAlign.center, style: AppTextStyles.subtitle),
      ],
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({required this.mark});

  final IconData mark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.logoCircle,
        boxShadow: AppShadows.logoCircle,
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (rect) => AppGradients.logoMark.createShader(rect),
          blendMode: BlendMode.srcIn,
          child: Icon(mark, size: 72, color: Colors.white),
        ),
      ),
    );
  }
}
