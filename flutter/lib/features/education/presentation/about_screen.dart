import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';

/// Port of HearifyV1/Views/AboutScreenView.swift. Styled to match the
/// rest of the gear-menu surfaces — deep navy gradient background,
/// luminous indigo-violet logo circle, auth-card tiles for navigable
/// and external destinations.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _version = 'Version 1.0 (Build 1)';
  static const _copyrightYears = '2025-2026';

  @override
  Widget build(BuildContext context) {
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
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            'About Hearify',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
          centerTitle: true,
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
                AppSpacing.huge,
              ),
              child: Column(
                children: [
                  const _BrandBlock(),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    _version,
                    style: AppTextStyles.inputLabel.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Built for iOS 17.0+ / Android 8.0+',
                    style: AppTextStyles.inputLabel.copyWith(
                      color: AppColors.textPlaceholder,
                      fontSize: 12,
                    ),
                  ),
                  const _SectionDivider(),
                  _Section(
                    title: 'Copyright',
                    icon: Icons.copyright,
                    accent: AppTheme.primaryBlue(b),
                    children: [
                      _centered(
                        'Copyright © $_copyrightYears Hearify, Inc.',
                        weight: FontWeight.w600,
                      ),
                      _centered('All Rights Reserved', secondary: true),
                      const SizedBox(height: AppSpacing.s),
                      const _Fineprint(
                        'This software and associated documentation files are the '
                        'proprietary and confidential information of Hearify, Inc. '
                        'Unauthorized copying, distribution, or use is strictly prohibited.',
                      ),
                    ],
                  ),
                  const _SectionDivider(),
                  _Section(
                    title: 'Trademarks',
                    icon: Icons.verified_outlined,
                    accent: AppTheme.primaryBlue(b),
                    children: [
                      _centered(
                        'Hearify™, HearifyV1™, and HearifyPro™',
                        weight: FontWeight.w600,
                      ),
                      _centered(
                        'are trademarks of Hearify, Inc.',
                        secondary: true,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      const _Fineprint(
                        'All other trademarks are the property of their respective owners.',
                      ),
                    ],
                  ),
                  const _SectionDivider(),
                  _Section(
                    title: 'Patents',
                    icon: Icons.description_outlined,
                    accent: AppTheme.primaryBlue(b),
                    children: [
                      _PatentBadge(accent: AppTheme.accentOrange(b)),
                      const SizedBox(height: AppSpacing.s),
                      const _Fineprint(
                        'Protected by U.S. and international patent laws. This '
                        'application contains proprietary technology and innovative features.',
                      ),
                    ],
                  ),
                  const _SectionDivider(),
                  _Section(
                    title: 'About This App',
                    icon: Icons.info_outline,
                    accent: AppTheme.primaryBlue(b),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                        ),
                        child: Text(
                          'Hearify is a comprehensive auditory rehabilitation platform '
                          'designed to help individuals with hearing challenges improve '
                          'their listening and speaking abilities through evidence-based '
                          'exercises, real-time feedback, and engaging gamification.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.inputLabel.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.warning(b),
                            size: 14,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Medical Disclaimer',
                            style: AppTextStyles.inputLabel.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const _Fineprint(
                        'Hearify is not a medical device and is not intended to diagnose, '
                        'treat, cure, or prevent any disease. It is designed as a '
                        'supplementary tool for auditory training and should not replace '
                        'professional medical care or advice from your audiologist or physician.',
                      ),
                    ],
                  ),
                  const _SectionDivider(),
                  _Section(
                    title: 'Legal',
                    icon: Icons.article_outlined,
                    accent: AppTheme.primaryBlue(b),
                    children: [
                      _ActionTile(
                        accent: AppTheme.primaryBlue(b),
                        icon: Icons.gavel_rounded,
                        label: 'Terms of Service',
                        trailing: Icons.chevron_right,
                        onTap: () => context.push('/about/terms'),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _ActionTile(
                        accent: AppTheme.primaryBlue(b),
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        trailing: Icons.chevron_right,
                        onTap: () => context.push('/about/privacy'),
                      ),
                    ],
                  ),
                  const _SectionDivider(),
                  _Section(
                    title: 'Contact',
                    icon: Icons.email_outlined,
                    accent: AppTheme.primaryBlue(b),
                    children: [
                      _ActionTile(
                        accent: AppTheme.primaryBlue(b),
                        icon: Icons.email_rounded,
                        label: 'Contact Us',
                        subtitle: 'contact@hearifyapp.com',
                        trailing: Icons.north_east_rounded,
                        onTap: () =>
                            launchUrl(Uri.parse('mailto:contact@hearifyapp.com')),
                      ),
                    ],
                  ),
                  const _SectionDivider(),
                  _Section(
                    title: 'Credits',
                    icon: Icons.person_outline,
                    accent: AppTheme.primaryBlue(b),
                    children: [
                      _centered('Developed by', secondary: true),
                      _centered('Hearify, Inc.',
                          weight: FontWeight.w700, fontSize: 18),
                      _centered('Founded by Veer Chopra',
                          weight: FontWeight.w500, secondary: true),
                    ],
                  ),
                  const _SectionDivider(),
                  _Section(
                    title: 'Acknowledgments',
                    icon: Icons.favorite_border,
                    accent: AppTheme.primaryBlue(b),
                    children: [
                      _AckRow('Firebase',
                          'Cloud infrastructure and authentication',
                          accent: AppTheme.success(b)),
                      _AckRow('Apple Speech Recognition',
                          'Real-time speech processing',
                          accent: AppTheme.success(b)),
                      _AckRow('Flutter', 'Cross-platform UI framework',
                          accent: AppTheme.success(b)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _centered(
    String text, {
    FontWeight weight = FontWeight.w400,
    double fontSize = 14,
    bool secondary = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: weight,
            color: secondary
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
      );
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 108,
          height: 108,
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
                Icons.hearing_rounded,
                size: 58,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Hearify™',
          style: AppTextStyles.title.copyWith(fontSize: 32),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Auditory Rehabilitation Made Simple',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.accent,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.s),
              Text(
                title,
                style: AppTextStyles.ctaLabel.copyWith(
                  fontSize: 16,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          ...children,
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.l,
      ),
      child: Container(
        height: 0.6,
        color: AppColors.hairline,
      ),
    );
  }
}

class _Fineprint extends StatelessWidget {
  const _Fineprint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.inputLabel.copyWith(
          fontSize: 11,
          color: AppColors.textPlaceholder,
          height: 1.5,
        ),
      ),
    );
  }
}

class _PatentBadge extends StatelessWidget {
  const _PatentBadge({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        'Patent Pending',
        style: AppTextStyles.ctaLabel.copyWith(
          fontSize: 13,
          color: accent,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.accent,
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.subtitle,
  });

  final Color accent;
  final IconData icon;
  final String label;
  final IconData trailing;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.button),
          splashColor: accent.withValues(alpha: 0.14),
          highlightColor: accent.withValues(alpha: 0.08),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: accent),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.ctaLabel.copyWith(fontSize: 15),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.inputLabel.copyWith(
                            color: accent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(trailing, size: 18, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AckRow extends StatelessWidget {
  const _AckRow(this.name, this.purpose, {required this.accent});
  final String name;
  final String purpose;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 14, color: accent),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.ctaLabel.copyWith(fontSize: 13),
                ),
                Text(
                  purpose,
                  style: AppTextStyles.inputLabel.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
