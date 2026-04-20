import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/auth_design_system.dart';

/// Placeholder screen for the user's saved practice items. Populated
/// when the practice-list feature ships; for now shows an empty state
/// styled to match the login / home premium dark aesthetic.
class PracticeListScreen extends StatelessWidget {
  const PracticeListScreen({super.key});

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            'My Practice List',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.logoCircle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x335B5FEF),
                            offset: Offset(0, 16),
                            blurRadius: 32,
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        size: 44,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'No items yet',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Save practice items from exercises to build your list.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
