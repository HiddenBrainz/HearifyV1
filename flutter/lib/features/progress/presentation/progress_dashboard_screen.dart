import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../../shared/data/phonetic_taxonomy.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/data/practice_history.dart';
import '../data/gamification_controller.dart';

/// Port of HearifyV1/Views/ProgressDashboardView.swift +
/// EnhancedProgressDashboardView.swift — consolidated into one screen.
/// Shows streak / XP / level up top, then a 7-day accuracy chart, plus
/// achievements.
class ProgressDashboardScreen extends ConsumerWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    final gam = ref.watch(gamificationProvider);
    final history = ref.watch(practiceHistoryProvider);
    final achievements = deriveAchievements(gam);

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Progress')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            _statsRow(gam, b),
            const SizedBox(height: AppTheme.spacingM),
            _levelCard(gam, b),
            const SizedBox(height: AppTheme.spacingM),
            _WeakestFeatureCard(history: history),
            const SizedBox(height: AppTheme.spacingM),
            _accuracyChartCard(history, b),
            const SizedBox(height: AppTheme.spacingM),
            _achievementsCard(achievements, b),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(GamificationState s, Brightness b) => Row(
        children: [
          Expanded(child: _statTile('Streak', '${s.currentStreak}', '🔥', b)),
          const SizedBox(width: 12),
          Expanded(child: _statTile('Level', '${s.level}', '⭐️', b)),
          const SizedBox(width: 12),
          Expanded(
              child: _statTile('Attempts', '${s.totalAttempts}', '🎯', b)),
        ],
      );

  Widget _statTile(String label, String value, String emoji, Brightness b) =>
      ModernCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(b),
                )),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary(b),
                )),
          ],
        ),
      );

  Widget _levelCard(GamificationState s, Brightness b) => ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Level ${s.level}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(b),
                    )),
                const Spacer(),
                Text('${s.totalXP} XP',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary(b),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: s.progressToNext,
                minHeight: 10,
                color: AppTheme.primaryBlue(b),
                backgroundColor:
                    AppTheme.primaryBlue(b).withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 4),
            Text('${s.xpTowardNextLevel} / 100 XP to next level',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(b),
                )),
          ],
        ),
      );

  Widget _accuracyChartCard(List<PracticeAttempt> history, Brightness b) {
    final byDay = <DateTime, List<double>>{};
    for (final a in history) {
      final day =
          DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day);
      byDay.putIfAbsent(day, () => []).add(a.score);
    }
    final today = DateTime.now();
    final days = List<DateTime>.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });
    final spots = <FlSpot>[];
    for (var i = 0; i < days.length; i++) {
      final scores = byDay[days[i]];
      final avg = scores == null || scores.isEmpty
          ? 0.0
          : scores.reduce((x, y) => x + y) / scores.length;
      spots.add(FlSpot(i.toDouble(), (avg * 100).roundToDouble()));
    }
    final labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIdx = today.weekday - 1;
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Accuracy — last 7 days',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(b),
              )),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary(b),
                          )),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final labelIdx = (todayIdx - (6 - i)) % 7;
                        return Text(
                          labels[labelIdx < 0 ? labelIdx + 7 : labelIdx],
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary(b),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryBlue(b),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color:
                          AppTheme.primaryBlue(b).withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementsCard(List<Achievement> all, Brightness b) => ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(b),
                )),
            const SizedBox(height: 8),
            for (final a in all)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      a.earned
                          ? Icons.emoji_events
                          : Icons.emoji_events_outlined,
                      color: a.earned
                          ? AppTheme.accentOrange(b)
                          : AppTheme.textTertiary(b),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: a.earned
                                    ? AppTheme.textPrimary(b)
                                    : AppTheme.textSecondary(b),
                              )),
                          Text(a.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary(b),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

/// Surfaces the lowest-accuracy phoneme bucket from the patient's
/// recent practice (the same `byCategory` data the audiologist sees on
/// their dashboard, just trimmed to one line + an action). Hidden when
/// nothing useful has been collected yet (forward-only — old attempts
/// have no `categoryTag`).
class _WeakestFeatureCard extends StatelessWidget {
  const _WeakestFeatureCard({required this.history});

  final List<PracticeAttempt> history;

  @override
  Widget build(BuildContext context) {
    final sums = history.accuracyByCategory(
      keepOnly: PhoneticCategory.heatmapOrder.toSet(),
    );
    if (sums.isEmpty) return const SizedBox.shrink();

    // Need at least 6 attempts in a bucket to call it out — otherwise
    // a single miss looks catastrophic.
    final candidates = sums.entries
        .where((e) => e.value.total >= 6)
        .map((e) => (
              tag: e.key,
              acc: e.value.correct / e.value.total,
              total: e.value.total,
            ))
        .toList()
      ..sort((a, b) => a.acc.compareTo(b.acc));
    if (candidates.isEmpty) return const SizedBox.shrink();

    final weakest = candidates.first;
    // Only nudge when the bucket is actually weak (<80%) — a patient
    // crushing every drill doesn't need a "your weakest is X" message.
    if (weakest.acc >= 0.8) return const SizedBox.shrink();

    final pct = (weakest.acc * 100).round();
    final label = PhoneticCategory.displayName(weakest.tag);
    final accent = AppColors.gradientPurple;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Icon(Icons.center_focus_strong_rounded,
                size: 28, color: accent),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Today\'s focus: $label',
                    style: AppTextStyles.ctaLabel.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'You\'re at $pct% on $label across your last '
                    '${weakest.total} attempts. A short focused drill '
                    'helps close the gap.',
                    style: AppTextStyles.inputLabel.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
