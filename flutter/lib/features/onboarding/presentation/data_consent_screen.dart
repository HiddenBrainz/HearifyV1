import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/consent_controller.dart';

/// Port of HearifyV1/Views/DataConsentView.swift.
/// Shows one card per ConsentType with a toggle; required consents are
/// pre-enabled and non-revokable (matching the Swift behavior).
class DataConsentScreen extends ConsumerWidget {
  const DataConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consentControllerProvider);
    final ctl = ref.read(consentControllerProvider.notifier);
    final b = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Data & Privacy'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _header(b),
                  const SizedBox(height: AppTheme.spacingL),
                  ...ConsentType.values.map((t) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingM),
                        child: _consentCard(
                          type: t,
                          granted: state.isGranted(t),
                          onChanged: (v) => v
                              ? ctl.grant(t)
                              : ctl.revoke(t),
                          b: b,
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => ctl.completeFlow(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppTheme.primaryBlue(b),
                ),
                child: const Text('Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(Brightness b) => Column(
        children: [
          Icon(Icons.privacy_tip_outlined,
              size: 56, color: AppTheme.primaryBlue(b)),
          const SizedBox(height: 12),
          Text('Your Data, Your Choice',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(b),
              )),
          const SizedBox(height: 6),
          Text(
            'Choose which data you want to share. Required items keep core '
            'features working; optional items help us improve and support '
            'research. You can change these any time in Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary(b),
            ),
          ),
        ],
      );

  Widget _consentCard({
    required ConsentType type,
    required bool granted,
    required ValueChanged<bool> onChanged,
    required Brightness b,
  }) =>
      ModernCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(type.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(b),
                          )),
                      if (type.required) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue(b)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('REQUIRED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlue(b),
                              )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(type.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary(b),
                        height: 1.4,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: granted,
              onChanged: type.required ? null : onChanged,
            ),
          ],
        ),
      );
}
