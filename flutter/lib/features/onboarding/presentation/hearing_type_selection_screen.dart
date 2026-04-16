import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/hearing_profile_controller.dart';

/// Port of HearifyV1/Views/HearingTypeSelectionView.swift.
/// Lets the user pick one of three training paths. Customizes the Module 1
/// content downstream.
class HearingTypeSelectionScreen extends ConsumerWidget {
  const HearingTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    final ctl = ref.read(hearingProfileProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Icon(Icons.hearing,
                  size: 56, color: AppTheme.primaryBlue(b)),
              const SizedBox(height: 12),
              Text('What brings you here?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(b),
                  )),
              const SizedBox(height: 6),
              Text(
                'Pick the training path that best matches your needs. You '
                'can change this later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary(b),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              Expanded(
                child: ListView.separated(
                  itemCount: TrainingModuleType.values.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacingM),
                  itemBuilder: (_, i) {
                    final t = TrainingModuleType.values[i];
                    return _typeCard(
                      type: t,
                      onTap: () => ctl.setType(t),
                      b: b,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeCard({
    required TrainingModuleType type,
    required VoidCallback onTap,
    required Brightness b,
  }) =>
      Material(
        color: AppTheme.cardBackground(b),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        elevation: 2,
        shadowColor: Colors.black.withValues(
          alpha: b == Brightness.dark ? 0.3 : 0.12,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: type.color(b).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(type.icon, color: type.color(b), size: 32),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.displayName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(b),
                          )),
                      const SizedBox(height: 4),
                      Text(type.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary(b),
                          )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textSecondary(b)),
              ],
            ),
          ),
        ),
      );
}
