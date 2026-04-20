import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../auth/presentation/widgets/gradient_primary_button.dart';
import '../data/clinician_repository.dart';

/// Port of HearifyV1/Views/ClinicianLinkingView.swift.
/// Patient-facing screen: generate a 6-digit code to share with their
/// clinician. Styled to match the rest of the gear-menu surfaces —
/// gradient navy background, transparent top bar, auth-card interior.
class ClinicianLinkingScreen extends ConsumerStatefulWidget {
  const ClinicianLinkingScreen({super.key});

  @override
  ConsumerState<ClinicianLinkingScreen> createState() =>
      _ClinicianLinkingScreenState();
}

class _ClinicianLinkingScreenState
    extends ConsumerState<ClinicianLinkingScreen> {
  String? _code;
  bool _busy = false;
  String? _error;

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = await ref
          .read(clinicianRepositoryProvider)
          .generateLinkingCode();
      setState(() => _code = code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    final c = _code;
    if (c == null) return;
    await Clipboard.setData(ClipboardData(text: c));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied')),
    );
  }

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
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            'Share with Clinician',
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
                AppSpacing.xxl,
                AppSpacing.l,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CodeCard(
                    accent: accent,
                    code: _code,
                    busy: _busy,
                    error: _error,
                    onGenerate: _generate,
                    onCopy: _copy,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.accent,
    required this.code,
    required this.busy,
    required this.error,
    required this.onGenerate,
    required this.onCopy,
  });

  final Color accent;
  final String? code;
  final bool busy;
  final String? error;
  final VoidCallback onGenerate;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.link_rounded, color: accent, size: 30),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'One-time link code',
              textAlign: TextAlign.center,
              style: AppTextStyles.ctaLabel,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Share this 6-digit code with your audiologist. They enter '
              'it once to link your progress. Code expires in 24 hours.',
              textAlign: TextAlign.center,
              style: AppTextStyles.inputLabel.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (code != null) ...[
              _CodeDisplay(code: code!, accent: accent),
              const SizedBox(height: AppSpacing.xl),
              _PillButton(
                label: 'Copy',
                leadingIcon: Icons.copy_rounded,
                onTap: onCopy,
                accent: accent,
              ),
            ] else
              GradientPrimaryButton(
                label: busy ? 'Generating…' : 'Generate Code',
                leadingIcon: Icons.bolt_rounded,
                loading: busy,
                onPressed: busy ? null : onGenerate,
              ),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.l),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.error,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeDisplay extends StatelessWidget {
  const _CodeDisplay({required this.code, required this.accent});

  final String code;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.hairline, width: 0.5),
      ),
      child: SelectableText(
        code,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
          color: accent,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.leadingIcon,
    required this.onTap,
    required this.accent,
  });

  final String label;
  final IconData leadingIcon;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.m,
          ),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: accent.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(leadingIcon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.s),
              Text(
                label,
                style: AppTextStyles.ctaLabel.copyWith(
                  fontSize: 15,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
