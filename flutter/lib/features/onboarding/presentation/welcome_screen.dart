import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../auth/presentation/widgets/gradient_primary_button.dart';
import '../data/hearing_profile_controller.dart';
import 'widgets/confetti_overlay.dart';

/// Final onboarding beat: short celebratory landing before the user
/// drops into the Training Categories home. Tapping Continue marks the
/// hearing-profile flag complete via [HearingProfileController.markCompletedWithoutType],
/// which lets the router redirect to `/`.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bgPrimary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Stack(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppGradients.screenBackground,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      const _LogoMark(),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Welcome to Hearify',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        "We're so glad you're here. Let's start building "
                        'your listening skills.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(flex: 3),
                      GradientPrimaryButton(
                        label: "Let's Go",
                        leadingIcon: Icons.arrow_forward_rounded,
                        gradient: AppTheme.accentGradient(b),
                        onPressed: () => ref
                            .read(hearingProfileProvider.notifier)
                            .markCompletedWithoutType(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
            const ConfettiOverlay(),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

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
          child: const Icon(
            Icons.celebration_rounded,
            size: 72,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
