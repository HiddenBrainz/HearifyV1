import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../education/presentation/legal_documents_screens.dart';
import '../data/consent_controller.dart';

/// Port of HearifyV1/Views/LegalAgreementView.swift.
/// Requires the user to accept Terms of Service + Privacy Policy before
/// continuing to data-consent selections.
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Legal Agreement'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.gavel_outlined,
                  color: AppTheme.primaryBlue(b), size: 56),
              const SizedBox(height: 16),
              Text('Before you continue',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(b),
                  )),
              const SizedBox(height: 8),
              Text(
                'Please review and accept the Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary(b),
                ),
              ),
              const SizedBox(height: 32),
              _acceptRow(
                label: 'I have read and agree to the Terms of Service',
                value: _acceptTerms,
                onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const TermsOfServiceScreen()),
                ),
                b: b,
              ),
              const SizedBox(height: 12),
              _acceptRow(
                label: 'I have read and agree to the Privacy Policy',
                value: _acceptPrivacy,
                onChanged: (v) => setState(() => _acceptPrivacy = v ?? false),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen()),
                ),
                b: b,
              ),
              const Spacer(),
              FilledButton(
                onPressed: _canContinue
                    ? () async {
                        await ref
                            .read(legalAcceptanceProvider.notifier)
                            .accept();
                      }
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppTheme.primaryBlue(b),
                ),
                child: const Text('Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _acceptRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onTap,
    required Brightness b,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground(b),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: onChanged),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary(b),
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: AppTheme.primaryBlue(b)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
