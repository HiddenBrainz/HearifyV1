import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/practice_history.dart';

/// Port of HearifyV1/Views/SpeakingPracticeHubView.swift.
/// A router screen with four tiles: standard practice, targeted practice
/// (phoneme pairs), phoneme visualization, and recording history.
class SpeakingPracticeHubScreen extends ConsumerWidget {
  const SpeakingPracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    final history = ref.watch(practiceHistoryProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Speaking Practice')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            _statsCard(history.length, _averageScore(history), b),
            const SizedBox(height: AppTheme.spacingL),
            _tile(
              context,
              icon: Icons.record_voice_over,
              title: 'Standard Practice',
              subtitle: 'Words, phrases, and tongue twisters',
              route: '/speaking/practice',
              b: b,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _tile(
              context,
              icon: Icons.compare_arrows,
              title: 'Targeted Practice',
              subtitle: 'Distinguish tricky phoneme pairs (r/l, θ/ð, v/w, ...)',
              route: '/speaking/targeted',
              b: b,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _tile(
              context,
              icon: Icons.phonelink,
              title: 'Phoneme Visualization',
              subtitle: 'Browse the IPA catalog with examples',
              route: '/speaking/phonemes',
              b: b,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _tile(
              context,
              icon: Icons.history,
              title: 'Recording History',
              subtitle:
                  history.isEmpty ? 'No attempts yet' : '${history.length} attempts',
              route: '/speaking/history',
              b: b,
            ),
          ],
        ),
      ),
    );
  }

  double _averageScore(List<PracticeAttempt> history) {
    if (history.isEmpty) return 0;
    return history.map((a) => a.score).reduce((a, b) => a + b) / history.length;
  }

  Widget _statsCard(int count, double avg, Brightness b) => ModernCard(
        child: Row(
          children: [
            Expanded(
              child: _statBlock('Attempts', '$count', b),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppTheme.textTertiary(b).withValues(alpha: 0.3),
            ),
            Expanded(
              child: _statBlock(
                  'Average', '${(avg * 100).round()}%', b,
                  accent: AppTheme.success(b)),
            ),
          ],
        ),
      );

  Widget _statBlock(String label, String value, Brightness b, {Color? accent}) =>
      Column(
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: accent ?? AppTheme.textPrimary(b),
              )),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary(b),
              )),
        ],
      );

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Brightness b,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        onTap: () => context.push(route),
        child: ModernCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue(b).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue(b)),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(b),
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(b),
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary(b)),
            ],
          ),
        ),
      );
}
