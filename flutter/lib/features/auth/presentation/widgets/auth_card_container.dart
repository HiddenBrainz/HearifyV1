import 'package:flutter/material.dart';

import '../../../../core/theme/auth_design_system.dart';

/// Large rounded dark card that anchors the auth form. Uses a very
/// subtle vertical gradient so it reads as an elevated surface rather
/// than a pure black cutout.
class AuthCardContainer extends StatelessWidget {
  const AuthCardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xxl,
      AppSpacing.xxxl,
      AppSpacing.xxl,
      AppSpacing.xxl,
    ),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        border: Border.all(color: AppColors.hairline, width: 0.5),
        boxShadow: AppShadows.authCard,
      ),
      padding: padding,
      child: child,
    );
  }
}
