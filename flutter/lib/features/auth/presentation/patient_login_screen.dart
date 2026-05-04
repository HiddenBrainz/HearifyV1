import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/theme/auth_design_system.dart';
import '../data/auth_controller.dart';
import 'widgets/auth_card_container.dart';
import 'widgets/auth_segmented_toggle.dart';
import 'widgets/branding_header.dart';
import 'widgets/gradient_primary_button.dart';
import 'widgets/hearify_text_field.dart';

/// Premium dark auth screen: branded header, segmented Sign In / Sign Up,
/// email + password form, gradient CTA. Retains the original Firebase
/// auth wiring and debug guest shortcut.
class PatientLoginScreen extends ConsumerStatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  ConsumerState<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends ConsumerState<PatientLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();

  int _roleSegment = 0; // 0 = patient, 1 = clinician
  int _segment = 0; // 0 = sign in, 1 = sign up
  bool _busy = false;
  String? _error;

  bool get _isSignUp => _segment == 1;
  UserRole get _role =>
      _roleSegment == 0 ? UserRole.patient : UserRole.clinician;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bgPrimary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        // Resize so when the keyboard appears, the form lifts above it
        // — but the unfocused layout is sized to fit on a single screen
        // (no scroll bar, no clipped CTA).
        resizeToAvoidBottomInset: true,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            // Plain SingleChildScrollView: when the content fits (it does,
            // after the padding + logo trims below), the screen looks
            // un-scrolled; when the keyboard pops up the scroll view lifts
            // the focused field above it. No IntrinsicHeight gymnastics —
            // some children (segmented toggle, text fields) don't expose
            // intrinsic dimensions and explode that path on iOS.
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.l,
                AppSpacing.xxl,
                AppSpacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BrandingHeader(
                    title: 'Hearify',
                    subtitle: _role == UserRole.clinician
                        ? 'Audiologist Dashboard'
                        : 'Auditory Rehabilitation',
                    mark: _role == UserRole.clinician
                        ? Icons.medical_services_rounded
                        : Icons.hearing_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _AuthForm(
                    roleSegment: _roleSegment,
                    segment: _segment,
                    isSignUp: _isSignUp,
                    isClinician: _role == UserRole.clinician,
                    email: _email,
                    password: _password,
                    name: _name,
                    busy: _busy,
                    error: _error,
                    onRoleChanged: (i) => setState(() {
                      _roleSegment = i;
                      _error = null;
                    }),
                    onSegmentChanged: (i) => setState(() {
                      _segment = i;
                      _error = null;
                    }),
                    onSubmit: _submit,
                    onHelperLinkTap: () => setState(() {
                      _segment = _isSignUp ? 0 : 1;
                      _error = null;
                    }),
                    onGuest: (kDebugMode && !FirebaseBootstrap.initialized)
                        ? () => ref
                            .read(authControllerProvider.notifier)
                            .debugSignInAsGuest(role: _role)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final auth = ref.read(authControllerProvider.notifier);
      if (_isSignUp) {
        await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          name: _name.text.trim(),
          role: _role,
        );
      } else {
        await auth.signIn(
          email: _email.text.trim(),
          password: _password.text,
          expectedRole: _role,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? e.code);
    } on StateError catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.roleSegment,
    required this.segment,
    required this.isSignUp,
    required this.isClinician,
    required this.email,
    required this.password,
    required this.name,
    required this.busy,
    required this.error,
    required this.onRoleChanged,
    required this.onSegmentChanged,
    required this.onSubmit,
    required this.onHelperLinkTap,
    required this.onGuest,
  });

  final int roleSegment;
  final int segment;
  final bool isSignUp;
  final bool isClinician;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController name;
  final bool busy;
  final String? error;
  final ValueChanged<int> onRoleChanged;
  final ValueChanged<int> onSegmentChanged;
  final VoidCallback onSubmit;
  final VoidCallback onHelperLinkTap;
  final VoidCallback? onGuest;

  @override
  Widget build(BuildContext context) {
    return AuthCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthSegmentedToggle(
            labels: const ['Patient', 'Audiologist'],
            selectedIndex: roleSegment,
            onChanged: onRoleChanged,
          ),
          const SizedBox(height: AppSpacing.m),
          AuthSegmentedToggle(
            labels: const ['Sign In', 'Sign Up'],
            selectedIndex: segment,
            onChanged: onSegmentChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (isSignUp) ...[
            HearifyTextField(
              label: 'Full Name',
              controller: name,
              placeholder: isClinician ? 'Dr. Jane Smith' : 'Jane Doe',
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          HearifyTextField(
            label: 'Email',
            controller: email,
            placeholder: 'email@example.com',
            placeholderStyle: AppTextStyles.emailPlaceholder,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          ),
          const SizedBox(height: AppSpacing.l),
          HearifyTextField(
            label: 'Password',
            controller: password,
            placeholder: '••••••••',
            obscureText: true,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => onSubmit(),
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(error!, style: AppTextStyles.error),
          ],
          const SizedBox(height: AppSpacing.xl),
          GradientPrimaryButton(
            label: isSignUp ? 'Create Account' : 'Sign In',
            leadingIcon: isSignUp
                ? Icons.person_add_alt_1_rounded
                : Icons.lock_open_rounded,
            loading: busy,
            onPressed: busy ? null : onSubmit,
          ),
          const SizedBox(height: AppSpacing.m),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onHelperLinkTap,
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.helperLink.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                    ),
                    TextSpan(
                      text: isSignUp ? 'Sign In' : 'Sign Up',
                      style: AppTextStyles.helperLink,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onGuest != null) ...[
            const SizedBox(height: AppSpacing.l),
            Center(
              child: TextButton.icon(
                onPressed: onGuest,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textInactive,
                ),
                icon: const Icon(Icons.developer_mode_rounded, size: 18),
                label: const Text('Continue as guest (Dev)'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Firebase not configured — debug builds only.',
                textAlign: TextAlign.center,
                style: AppTextStyles.inputLabel.copyWith(
                  fontSize: 11,
                  color: AppColors.textPlaceholder,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
