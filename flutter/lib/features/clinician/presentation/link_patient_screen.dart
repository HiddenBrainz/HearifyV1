import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../auth/presentation/widgets/gradient_primary_button.dart';
import '../data/clinician_repository.dart';

/// Port of HearifyPro/Views/LinkPatientView.swift. Clinician enters the
/// 6-digit code their patient generated from Settings → Share with
/// Clinician and taps **Link Patient**. Shows a success state on
/// completion so the clinician can either close or link another.
class LinkPatientScreen extends ConsumerStatefulWidget {
  const LinkPatientScreen({super.key});

  @override
  ConsumerState<LinkPatientScreen> createState() => _LinkPatientScreenState();
}

class _LinkPatientScreenState extends ConsumerState<LinkPatientScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(clinicianRepositoryProvider)
          .linkPatient(code: _code.text.trim());
      setState(() => _success = true);
    } catch (e) {
      setState(() => _error = e is StateError ? e.message : e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reset() {
    setState(() {
      _success = false;
      _error = null;
      _code.clear();
    });
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
            'Link Patient',
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
              child: _success ? _SuccessCard(onDone: _reset) : _linkCard(accent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _linkCard(Color accent) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.1),
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
              child:
                  Icon(Icons.person_add_alt_1_rounded, color: accent, size: 30),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Link a new patient',
              textAlign: TextAlign.center,
              style: AppTextStyles.ctaLabel,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Enter the 6-digit code your patient generated from their app '
              '(Settings → Share with Clinician).',
              textAlign: TextAlign.center,
              style: AppTextStyles.inputLabel.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _CodeField(controller: _code, accent: accent, onSubmit: _link),
            const SizedBox(height: AppSpacing.xl),
            GradientPrimaryButton(
              label: _busy ? 'Linking…' : 'Link Patient',
              leadingIcon: Icons.link_rounded,
              loading: _busy,
              onPressed: _busy || _code.text.trim().length != 6 ? null : _link,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.l),
              Text(_error!,
                  textAlign: TextAlign.center, style: AppTextStyles.error),
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.accent,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final Color accent;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.hairline, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => onSubmit(),
        onChanged: (_) => (context as Element).markNeedsBuild(),
        style: TextStyle(
          fontSize: 32,
          letterSpacing: 8,
          fontWeight: FontWeight.w700,
          color: accent,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        decoration: const InputDecoration(
          counterText: '',
          hintText: '──────',
          hintStyle: TextStyle(
            fontSize: 32,
            letterSpacing: 8,
            color: AppColors.textPlaceholder,
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = AppTheme.success(b);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.1),
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: accent, size: 44),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('Patient linked!',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(fontSize: 24)),
            const SizedBox(height: AppSpacing.s),
            Text(
              'They\'ll show up on your patient list momentarily.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(fontSize: 15),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientPrimaryButton(
              label: 'Link Another',
              leadingIcon: Icons.add_rounded,
              onPressed: onDone,
            ),
          ],
        ),
      ),
    );
  }
}
