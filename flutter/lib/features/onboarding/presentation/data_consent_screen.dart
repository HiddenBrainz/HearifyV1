import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../auth/presentation/widgets/gradient_primary_button.dart';
import '../data/consent_controller.dart';

/// Port of HearifyV1/Views/DataConsentView.swift. Redesigned in the
/// premium dark aesthetic. One tile per `ConsentType`; required
/// consents keep their disabled toggle and the "REQUIRED" pill.
class DataConsentScreen extends ConsumerWidget {
  const DataConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consentControllerProvider);
    final ctl = ref.read(consentControllerProvider.notifier);
    final b = Theme.of(context).brightness;

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
          automaticallyImplyLeading: false,
          title: Text(
            'Data & Privacy',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      AppSpacing.xl,
                      AppSpacing.l,
                      AppSpacing.l,
                    ),
                    children: [
                      const _Header(),
                      const SizedBox(height: AppSpacing.xxl),
                      for (final t in ConsentType.values)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.m),
                          child: _ConsentTile(
                            type: t,
                            granted: state.isGranted(t),
                            accent: t.required
                                ? AppTheme.error(b)
                                : AppTheme.accentPurple(b),
                            onChanged: (v) =>
                                v ? ctl.grant(t) : ctl.revoke(t),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.s,
                    AppSpacing.l,
                    AppSpacing.m,
                  ),
                  child: GradientPrimaryButton(
                    label: 'Continue',
                    leadingIcon: Icons.arrow_forward_rounded,
                    onPressed: () => ctl.completeFlow(),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.logoCircle,
            boxShadow: AppShadows.logoCircle,
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (rect) =>
                  AppGradients.logoMark.createShader(rect),
              blendMode: BlendMode.srcIn,
              child: const Icon(
                Icons.privacy_tip_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Your Data, Your Choice',
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(fontSize: 26),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Choose which data you want to share. Required items keep core '
          'features working; optional items help us improve and support '
          'research. You can change these any time in Settings.',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.type,
    required this.granted,
    required this.accent,
    required this.onChanged,
  });

  final ConsentType type;
  final bool granted;
  final Color accent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 20,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          type.title,
                          style: AppTextStyles.ctaLabel.copyWith(fontSize: 16),
                        ),
                      ),
                      if (type.required) ...[
                        const SizedBox(width: AppSpacing.s),
                        _RequiredBadge(accent: accent),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    type.description,
                    style: AppTextStyles.inputLabel.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Switch(
              value: granted,
              onChanged: type.required ? null : onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: accent,
              inactiveThumbColor: AppColors.textInactive,
              inactiveTrackColor: AppColors.inputBackground,
              trackOutlineColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? accent
                    : AppColors.hairline,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Text(
        'REQUIRED',
        style: AppTextStyles.ctaLabel.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
