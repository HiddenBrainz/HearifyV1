import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';

/// Port of HearifyV1/Views/AboutScreenView.swift.
/// Displays app version, copyright, trademark, patent, contact, and
/// acknowledgments. Terms of Service and Privacy Policy sub-screens are
/// navigable routes.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _version = 'Version 1.0 (Build 1)';
  static const _copyrightYears = '2025-2026';

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('About Hearify'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            _appHeader(b),
            const SizedBox(height: 24),
            _version.isNotEmpty
                ? Text(_version,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary(b),
                    ))
                : const SizedBox.shrink(),
            const SizedBox(height: 4),
            Text('Built for iOS 17.0+ / Android 8.0+',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary(b),
                )),
            _divider(b),
            _section(
              title: 'Copyright',
              icon: Icons.copyright,
              b: b,
              children: [
                _centered('Copyright © $_copyrightYears Hearify, Inc.', 14,
                    weight: FontWeight.w500, b: b),
                _centered('All Rights Reserved', 13, b: b, secondary: true),
                const SizedBox(height: 8),
                _fineprint(
                    'This software and associated documentation files are the '
                    'proprietary and confidential information of Hearify, Inc. '
                    'Unauthorized copying, distribution, or use is strictly prohibited.',
                    b),
              ],
            ),
            _divider(b),
            _section(
              title: 'Trademarks',
              icon: Icons.verified_outlined,
              b: b,
              children: [
                _centered('Hearify™, HearifyV1™, and HearifyPro™', 13,
                    weight: FontWeight.w500, b: b),
                _centered('are trademarks of Hearify, Inc.', 12, b: b,
                    secondary: true),
                const SizedBox(height: 8),
                _fineprint(
                    'All other trademarks are the property of their respective owners.',
                    b),
              ],
            ),
            _divider(b),
            _section(
              title: 'Patents',
              icon: Icons.description_outlined,
              b: b,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange(b).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Patent Pending',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentOrange(b),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _fineprint(
                    'Protected by U.S. and international patent laws. This '
                    'application contains proprietary technology and innovative features.',
                    b),
              ],
            ),
            _divider(b),
            _section(
              title: 'About This App',
              icon: Icons.info_outline,
              b: b,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Hearify is a comprehensive auditory rehabilitation platform '
                    'designed to help individuals with hearing challenges improve '
                    'their listening and speaking abilities through evidence-based '
                    'exercises, real-time feedback, and engaging gamification.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textPrimary(b),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppTheme.warning(b), size: 14),
                    const SizedBox(width: 6),
                    Text('Medical Disclaimer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(b),
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                _fineprint(
                    'Hearify is not a medical device and is not intended to diagnose, '
                    'treat, cure, or prevent any disease. It is designed as a '
                    'supplementary tool for auditory training and should not replace '
                    'professional medical care or advice from your audiologist or physician.',
                    b),
              ],
            ),
            _divider(b),
            _section(
              title: 'Legal',
              icon: Icons.article_outlined,
              b: b,
              children: [
                _legalTile(context, 'Terms of Service', '/about/terms', b),
                const SizedBox(height: 8),
                _legalTile(context, 'Privacy Policy', '/about/privacy', b),
              ],
            ),
            _divider(b),
            _section(
              title: 'Contact',
              icon: Icons.email_outlined,
              b: b,
              children: [
                _contactTile('contact@hearifyapp.com', b),
              ],
            ),
            _divider(b),
            _section(
              title: 'Credits',
              icon: Icons.person_outline,
              b: b,
              children: [
                _centered('Developed by', 12, b: b, secondary: true),
                _centered('Hearify, Inc.', 16,
                    weight: FontWeight.w600, b: b),
                _centered('Founded by Veer Chopra', 13,
                    weight: FontWeight.w500, b: b, secondary: true),
              ],
            ),
            _divider(b),
            _section(
              title: 'Acknowledgments',
              icon: Icons.favorite_border,
              b: b,
              children: const [
                _AckRow('Firebase',
                    'Cloud infrastructure and authentication'),
                _AckRow('Apple Speech Recognition',
                    'Real-time speech processing'),
                _AckRow('Flutter', 'Cross-platform UI framework'),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _appHeader(Brightness b) => Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(b),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.hearing,
                size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('Hearify™',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(b),
              )),
          Text('Auditory Rehabilitation Made Simple',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary(b),
              )),
        ],
      );

  Widget _section({
    required String title,
    required IconData icon,
    required Brightness b,
    required List<Widget> children,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryBlue(b)),
                const SizedBox(width: 6),
                Text(title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue(b),
                    )),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _centered(String text, double size,
          {FontWeight weight = FontWeight.w400,
          required Brightness b,
          bool secondary = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            fontWeight: weight,
            color: secondary
                ? AppTheme.textSecondary(b)
                : AppTheme.textPrimary(b),
          ),
        ),
      );

  Widget _fineprint(String text, Brightness b) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textTertiary(b),
            height: 1.4,
          ),
        ),
      );

  Widget _divider(Brightness b) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Divider(color: AppTheme.textTertiary(b).withValues(alpha: 0.3)),
      );

  Widget _legalTile(BuildContext context, String label, String route,
          Brightness b) =>
      Material(
        color: AppTheme.cardBackground(b),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).pushNamed(route),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryBlue(b),
                    )),
                const Spacer(),
                Icon(Icons.chevron_right,
                    size: 18, color: AppTheme.primaryBlue(b)),
              ],
            ),
          ),
        ),
      );

  Widget _contactTile(String email, Brightness b) => Material(
        color: AppTheme.cardBackground(b),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => launchUrl(Uri.parse('mailto:$email')),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.email,
                    size: 14, color: AppTheme.primaryBlue(b)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact Us',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary(b),
                          )),
                      Text(email,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryBlue(b),
                          )),
                    ],
                  ),
                ),
                Icon(Icons.north_east,
                    size: 14, color: AppTheme.textTertiary(b)),
              ],
            ),
          ),
        ),
      );
}

class _AckRow extends StatelessWidget {
  const _AckRow(this.name, this.purpose);
  final String name;
  final String purpose;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppTheme.success(b)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary(b),
                    )),
                Text(purpose,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary(b),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
