import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Displays long-form Terms of Service and Privacy Policy.
/// Ported from the inline `TermsOfServiceView` and `PrivacyPolicyView` in
/// AboutScreenView.swift.
class _LegalDocPage extends StatelessWidget {
  const _LegalDocPage({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(b))),
            const SizedBox(height: 4),
            Text(lastUpdated,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(b),
                )),
            const Divider(height: 24),
            ...sections.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$1,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(b),
                          )),
                      const SizedBox(height: 4),
                      Text(s.$2,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppTheme.textSecondary(b),
                          )),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Text('© 2025-2026 Hearify, Inc. All rights reserved.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textTertiary(b),
                )),
          ],
        ),
      ),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _LegalDocPage(
      title: 'Terms of Service',
      lastUpdated: 'Last Updated: January 28, 2026',
      sections: const [
        ('1. Acceptance of Terms',
            'By accessing or using Hearify™ ("the App"), you agree to be bound by '
                'these Terms of Service. If you do not agree to these terms, please '
                'do not use the App.'),
        ('2. Medical Disclaimer',
            'Hearify is NOT a medical device and is NOT intended to diagnose, treat, '
                'cure, or prevent any disease or medical condition.'),
        ('3. License Grant',
            'Subject to your compliance with these Terms, Hearify, Inc. grants you a '
                'limited, non-exclusive, non-transferable, revocable license to use '
                'the App for your personal, non-commercial use.'),
        ('4. Intellectual Property',
            'All content, features, and functionality of the App are owned by Hearify, '
                'Inc. and are protected by copyright, trademark, patent, and other '
                'intellectual property laws.'),
        ('5. User Data and Privacy',
            'Your use of the App is subject to our Privacy Policy. We collect and '
                'process health-related data in compliance with HIPAA regulations.'),
        ('6. Patient-Clinician Linking',
            'If you choose to link your account with a clinician, you authorize the '
                'sharing of your practice data, progress reports, and analytics with '
                'that clinician. You may revoke this authorization at any time.'),
        ('7. Prohibited Activities',
            'You agree not to reverse engineer or decompile the App, use it for any '
                'illegal purpose, share account credentials, or interfere with its operation.'),
        ('8. Limitation of Liability',
            'TO THE MAXIMUM EXTENT PERMITTED BY LAW, HEARIFY, INC. SHALL NOT BE LIABLE '
                'FOR ANY INDIRECT, INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES.'),
        ('9. Disclaimer of Warranties',
            'THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND.'),
        ('10. Subscription and Fees',
            'HearifyPro™ features may require a paid subscription. All fees are '
                'non-refundable except as required by law.'),
        ('11. Termination',
            'We reserve the right to suspend or terminate your access to the App at '
                'any time for violation of these Terms.'),
        ('12. Changes to Terms',
            'We may modify these Terms at any time. Continued use of the App after '
                'changes constitutes acceptance of the modified Terms.'),
        ('13. Governing Law',
            'These Terms are governed by the laws of the United States and the State '
                'of Delaware.'),
        ('14. Contact Information',
            'For questions about these Terms, contact us at: contact@hearifyapp.com'),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _LegalDocPage(
      title: 'Privacy Policy',
      lastUpdated: 'Last Updated: January 28, 2026',
      sections: const [
        ('1. Information We Collect',
            'We collect information you provide directly (name, email, health data), '
                'automatically (usage data, device information), and from clinicians '
                '(if you authorize linking).'),
        ('2. How We Use Your Information',
            'We use your information to provide and improve the App, track your '
                'progress, generate analytics, enable clinician collaboration, and '
                'ensure HIPAA compliance.'),
        ('3. HIPAA Compliance',
            'Hearify processes Protected Health Information (PHI) in compliance with '
                'HIPAA regulations, including encryption, access controls, and audit logs.'),
        ('4. Data Sharing and Disclosure',
            'We do NOT sell your personal information. We may share data with '
                'authorized clinicians you have linked with, service providers bound '
                'by confidentiality agreements, and legal authorities when required.'),
        ('5. Your Rights',
            'You have the right to access your data, request corrections, delete your '
                'account, revoke clinician authorization, opt-out of analytics, and '
                'receive a copy of your health records.'),
        ('6. Data Security',
            'We implement industry-standard security measures including end-to-end '
                'encryption, secure cloud storage, regular security audits, and '
                'multi-factor authentication options.'),
        ('7. Data Retention',
            'We retain your data for as long as your account is active. You may '
                'request deletion at any time.'),
        ('8. Children\'s Privacy',
            'Hearify is not intended for children under 13.'),
        ('9. International Users',
            'Your data may be transferred to and processed in the United States.'),
        ('10. California Privacy Rights (CCPA)',
            'California residents have additional rights including the right to know '
                'what data is collected and the right to delete personal information.'),
        ('11. European Users (GDPR)',
            'European users have rights under GDPR including data portability, right '
                'to erasure, and right to object to processing.'),
        ('12. Cookies and Tracking',
            'We use essential cookies for authentication and functionality. We do not '
                'use advertising or tracking cookies.'),
        ('13. Changes to Privacy Policy',
            'We may update this Privacy Policy. We will notify you of material changes '
                'via email or in-app notification.'),
        ('14. Contact Us',
            'For privacy questions or to exercise your rights, contact us at: '
                'contact@hearifyapp.com'),
      ],
    );
  }
}
