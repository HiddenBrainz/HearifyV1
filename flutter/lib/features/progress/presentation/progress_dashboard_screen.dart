import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
