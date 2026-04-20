import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../auth/presentation/widgets/gradient_primary_button.dart';
import '../data/consent_controller.dart';

/// Port of HearifyV1/Views/LegalAgreementView.swift. Redesigned in the
/// premium dark aesthetic: gradient navy background, indigo-violet logo
/// circle, auth-card tiles for each acceptance, neon CTA.
///
/// Gating unchanged — both checkboxes required, Continue calls
/// `legalAcceptanceProvider.accept()`.
class LegalAgreementScreen extends ConsumerStatefulWidget {
  const LegalAgreementScreen({super.key});

  @override
  ConsumerState<LegalAgreementScreen> createState() =>
      _LegalAgreementScreenState();
}

class _LegalAgreementScreenState extends ConsumerState<LegalAgreementScreen> {
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;

  bool get _canContinue => _acceptTerms && _acceptPrivacy;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = AppTheme.primaryBlue(b);
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
            'Legal Agreement',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.xl,
                AppSpacing.l,
                AppSpacing.l,
              ),
              child: Column(
                children: [
                  const _LogoMark(icon: Icons.gavel_rounded),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Before you continue',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Please review and accept the Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _LegalTile(
                    accent: accent,
                    label: 'I have read and agree to the Terms of Service',
                    checked: _acceptTerms,
                    onToggle: (v) => setState(() => _acceptTerms = v),
                    onOpen: () => context.push('/about/terms'),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _LegalTile(
                    accent: accent,
                    label: 'I have read and agree to the Privacy Policy',
                    checked: _acceptPrivacy,
                    onToggle: (v) => setState(() => _acceptPrivacy = v),
                    onOpen: () => context.push('/about/privacy'),
                  ),
                  const Spacer(),
                  GradientPrimaryButton(
                    label: 'Continue',
                    leadingIcon: Icons.arrow_forward_rounded,
                    onPressed: _canContinue
                        ? () => ref
                            .read(legalAcceptanceProvider.notifier)
                            .accept()
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.logoCircle,
        boxShadow: AppShadows.logoCircle,
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (rect) => AppGradients.logoMark.createShader(rect),
          blendMode: BlendMode.srcIn,
          child: Icon(icon, size: 48, color: Colors.white),
        ),
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.accent,
    required this.label,
    required this.checked,
    required this.onToggle,
    required this.onOpen,
  });

  final Color accent;
  final String label;
  final bool checked;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

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
            color: accent.withValues(alpha: 0.18),
            blurRadius: 20,
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
          splashColor: accent.withValues(alpha: 0.12),
          highlightColor: accent.withValues(alpha: 0.06),
          onTap: () => onToggle(!checked),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: checked,
                  onChanged: (v) => onToggle(v ?? false),
                  activeColor: accent,
                  checkColor: Colors.white,
                  side: BorderSide(
                    color: accent.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.ctaLabel.copyWith(fontSize: 14),
                  ),
                ),
                IconButton(
                  onPressed: onOpen,
                  icon: Icon(Icons.chevron_right, color: accent),
                  tooltip: 'Open document',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
