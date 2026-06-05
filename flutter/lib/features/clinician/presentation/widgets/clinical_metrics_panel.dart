import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/auth_design_system.dart';
import '../../../../shared/data/phonetic_taxonomy.dart';
import '../../data/clinician_repository.dart';

/// Five clinical views layered into the audiologist's Patient Detail
/// screen. Each component is a self-contained widget so `patient_detail_screen`
/// can compose them in any order. They all read from the same
/// `List<PatientSession>` but compute independent aggregates.
///
/// Surfaces in order of clinical impact:
///   1. EngagementStrip       — sessions/week, streak, avg duration
///   2. Snr50TrendChart       — SNR-50 over time (BKB-SIN + WIN)
///   3. InitialVsFinalCard    — start-vs-end-of-word accuracy gap
///   4. FeatureAccuracyHeatmap— phoneme-bucket bar chart
///   5. TopConfusionsTable    — top missed (target → heard) pairs

// ── Shared helpers ────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.accent});
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final color = accent ?? AppTheme.primaryBlue(b);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

TextStyle _sectionLabelStyle() => AppTextStyles.inputLabel.copyWith(
      fontSize: 11,
      letterSpacing: 1.2,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

TextStyle _bigNumberStyle(Color c) => AppTextStyles.title.copyWith(
      fontSize: 28,
      color: c,
      letterSpacing: -0.5,
    );

/// Stacked sum of a per-category aggregate across many sessions.
class _CategorySums {
  final Map<String, ({int correct, int total})> byCategory = {};
  void add(Map<String, ({int correct, int total})> sessionMap) {
    sessionMap.forEach((tag, v) {
      final cur = byCategory[tag] ?? (correct: 0, total: 0);
      byCategory[tag] = (
        correct: cur.correct + v.correct,
        total: cur.total + v.total,
      );
    });
  }

  double? accuracyFor(String tag) {
    final v = byCategory[tag];
    if (v == null || v.total == 0) return null;
    return v.correct / v.total;
  }
}

_CategorySums _sumCategories(List<PatientSession> sessions) {
  final out = _CategorySums();
  for (final s in sessions) {
    out.add(s.byCategory);
  }
  return out;
}

// ─────────────────────────────────────────────────────────────────────
// 1) Engagement strip — three tiny tiles at the very top of the panel.
// ─────────────────────────────────────────────────────────────────────

class EngagementStrip extends StatelessWidget {
  const EngagementStrip({super.key, required this.sessions});

  final List<PatientSession> sessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek =
        sessions.where((s) => s.sessionDate.isAfter(weekAgo)).length;

    final dates = sessions
        .map((s) => DateTime(
              s.sessionDate.year,
              s.sessionDate.month,
              s.sessionDate.day,
            ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    var cursor = DateTime(now.year, now.month, now.day);
    for (final d in dates) {
      if (d == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (d.isBefore(cursor)) {
        break;
      }
    }

    final totalSeconds =
        sessions.fold<double>(0, (sum, s) => sum + s.durationSeconds);
    final avgMin = sessions.isEmpty
        ? 0.0
        : (totalSeconds / sessions.length) / 60;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.calendar_today_rounded,
            label: 'This week',
            value: '$thisWeek',
            unit: thisWeek == 1 ? 'session' : 'sessions',
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _StatTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '$streak',
            unit: streak == 1 ? 'day' : 'days',
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _StatTile(
            icon: Icons.timer_outlined,
            label: 'Avg session',
            value: avgMin == 0 ? '—' : avgMin.toStringAsFixed(1),
            unit: 'min',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryBlue(b)),
            const SizedBox(height: AppSpacing.s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: _bigNumberStyle(AppColors.textPrimary)),
                const SizedBox(width: 4),
                Text(unit, style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
              ],
            ),
            Text(label, style: _sectionLabelStyle().copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// 2) SNR-50 trend chart — only sessions that recorded an snr50.
// ─────────────────────────────────────────────────────────────────────

class Snr50TrendChart extends StatelessWidget {
  const Snr50TrendChart({super.key, required this.sessions});

  final List<PatientSession> sessions;

  @override
  Widget build(BuildContext context) {
    // Filter + group by exercise type so we can plot two series.
    final bkb = sessions
        .where((s) =>
            s.snr50 != null && s.exerciseType == ExerciseType.bkbSin)
        .toList()
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));
    final win = sessions
        .where((s) =>
            s.snr50 != null && s.exerciseType == ExerciseType.wordsInNoise)
        .toList()
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));

    if (bkb.isEmpty && win.isEmpty) {
      return _CardShell(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SNR-50 over time', style: _sectionLabelStyle()),
              const SizedBox(height: AppSpacing.m),
              Text(
                'No noise tests yet. Have the patient run BKB-SIN or '
                'Words-in-Noise to populate this chart.',
                style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Combined min/max for the Y axis (lower is better; we don't flip
    // the axis but the band shading makes "good = bottom" visually
    // clear).
    final allValues = [...bkb, ...win].map((s) => s.snr50!).toList();
    final yMin = (allValues.reduce((a, b) => a < b ? a : b) - 2)
        .clamp(-5.0, 30.0);
    final yMax = (allValues.reduce((a, b) => a > b ? a : b) + 2)
        .clamp(0.0, 30.0);

    FlSpot toSpot(PatientSession s) =>
        FlSpot(s.sessionDate.millisecondsSinceEpoch.toDouble(), s.snr50!);

    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('SNR-50 over time', style: _sectionLabelStyle()),
                const Spacer(),
                _Legend(color: AppColors.gradientBlue, label: 'BKB-SIN'),
                const SizedBox(width: AppSpacing.m),
                _Legend(color: AppColors.gradientPurple, label: 'WIN'),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: yMin,
                  maxY: yMax,
                  gridData: const FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 4,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 4,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}',
                          style: AppTextStyles.inputLabel.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    if (bkb.isNotEmpty)
                      LineChartBarData(
                        spots: bkb.map(toSpot).toList(),
                        color: AppColors.gradientBlue,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: true),
                      ),
                    if (win.isNotEmpty)
                      LineChartBarData(
                        spots: win.map(toSpot).toList(),
                        color: AppColors.gradientPurple,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: true),
                      ),
                  ],
                  // Clinical norm bands as horizontal lines at 2/7/15 dB.
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      _normLine(2, 'Normal ≤2 dB'),
                      _normLine(7, 'Mild ≤7'),
                      _normLine(15, 'Moderate ≤15'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Lower dB = better noise tolerance. Normal hearing ≤ 2 dB.',
              style: AppTextStyles.inputLabel.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  HorizontalLine _normLine(double y, String label) => HorizontalLine(
        y: y,
        color: AppColors.hairline,
        strokeWidth: 1,
        dashArray: const [4, 4],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 4, bottom: 2),
          style: AppTextStyles.inputLabel.copyWith(
            fontSize: 9,
            color: AppColors.textPlaceholder,
          ),
          labelResolver: (_) => label,
        ),
      );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.inputLabel.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// 3) Initial vs Final consonant gap — the "start vs end of words" view.
// ─────────────────────────────────────────────────────────────────────

class InitialVsFinalCard extends StatelessWidget {
  const InitialVsFinalCard({super.key, required this.sessions});

  final List<PatientSession> sessions;

  @override
  Widget build(BuildContext context) {
    final sums = _sumCategories(sessions);
    final initial = sums.accuracyFor(PhoneticCategory.initialConsonant);
    final fin = sums.accuracyFor(PhoneticCategory.finalConsonant);

    final Color accent;
    final String body;
    final String note;
    if (initial == null && fin == null) {
      accent = AppColors.textSecondary;
      body = 'No matched-pair consonant data yet.';
      note = 'Have the patient run Initial Consonants and Final '
          'Consonants drills to populate this card.';
    } else {
      final gap = ((initial ?? 0) - (fin ?? 0)) * 100;
      if (initial != null && fin != null && gap >= 20) {
        accent = AppColors.errorText;
        body = 'Initial: ${(initial * 100).round()}%   ·   '
            'Final: ${(fin * 100).round()}%';
        note = '${gap.round()} pt gap — classic high-frequency loss '
            'pattern. Final-position cues are short and high-pitch '
            'and the first to degrade.';
      } else if (initial != null && fin != null && gap >= 10) {
        accent = AppTheme.warningDark;
        body = 'Initial: ${(initial * 100).round()}%   ·   '
            'Final: ${(fin * 100).round()}%';
        note = '${gap.round()} pt gap — moderate end-of-word weakness. '
            'Worth tracking.';
      } else if (initial != null && fin != null) {
        accent = AppTheme.successDark;
        body = 'Initial: ${(initial * 100).round()}%   ·   '
            'Final: ${(fin * 100).round()}%';
        note = 'Balanced — initial and final consonant accuracy are '
            'close to each other.';
      } else {
        accent = AppColors.textSecondary;
        body = initial != null
            ? 'Initial: ${(initial * 100).round()}%   ·   Final: —'
            : 'Initial: —   ·   Final: ${(fin! * 100).round()}%';
        note = 'Need both Initial and Final Consonants drills for a '
            'gap measurement.';
      }
    }

    return _CardShell(
      accent: accent,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Initial vs final consonants', style: _sectionLabelStyle()),
            const SizedBox(height: AppSpacing.m),
            Text(
              body,
              style: AppTextStyles.title.copyWith(
                fontSize: 22,
                color: accent,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              note,
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// 4) Phoneme bucket heatmap — bars across the canonical features.
// ─────────────────────────────────────────────────────────────────────

class FeatureAccuracyHeatmap extends StatelessWidget {
  const FeatureAccuracyHeatmap({super.key, required this.sessions});

  final List<PatientSession> sessions;

  @override
  Widget build(BuildContext context) {
    final sums = _sumCategories(sessions);
    final hasAny = PhoneticCategory.heatmapOrder
        .any((t) => sums.byCategory[t]?.total != null);

    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phoneme accuracy', style: _sectionLabelStyle()),
            const SizedBox(height: AppSpacing.m),
            if (!hasAny)
              Text(
                'No phoneme drills yet. Matched Pairs sessions populate '
                'these bars.',
                style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              )
            else
              Column(
                children: [
                  for (final tag in PhoneticCategory.heatmapOrder)
                    _HeatmapBar(
                      label: PhoneticCategory.shortName(tag),
                      data: sums.byCategory[tag],
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                _LegendDot(color: AppTheme.errorDark, label: '< 70%'),
                const SizedBox(width: AppSpacing.m),
                _LegendDot(color: AppTheme.warningDark, label: '70–85%'),
                const SizedBox(width: AppSpacing.m),
                _LegendDot(color: AppTheme.successDark, label: '≥ 85%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapBar extends StatelessWidget {
  const _HeatmapBar({required this.label, required this.data});
  final String label;
  final ({int correct, int total})? data;

  @override
  Widget build(BuildContext context) {
    final acc = (data == null || data!.total == 0)
        ? null
        : data!.correct / data!.total;
    final Color color;
    if (acc == null) {
      color = AppColors.textPlaceholder;
    } else if (acc < 0.7) {
      color = AppTheme.errorDark;
    } else if (acc < 0.85) {
      color = AppTheme.warningDark;
    } else {
      color = AppTheme.successDark;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTextStyles.inputLabel.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    color: AppColors.hairline,
                  ),
                  if (acc != null)
                    FractionallySizedBox(
                      widthFactor: acc.clamp(0.0, 1.0).toDouble(),
                      child: Container(height: 10, color: color),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          SizedBox(
            width: 56,
            child: Text(
              data == null
                  ? '—'
                  : '${(acc! * 100).round()}%   ${data!.total}',
              textAlign: TextAlign.right,
              style: AppTextStyles.inputLabel.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.inputLabel.copyWith(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// 5) Top confused (target → heard) pairs across all sessions.
// ─────────────────────────────────────────────────────────────────────

class TopConfusionsTable extends StatelessWidget {
  const TopConfusionsTable({super.key, required this.sessions});

  final List<PatientSession> sessions;

  @override
  Widget build(BuildContext context) {
    // Sum across every session into a {target|heard: count} map.
    final tally = <String, ({String target, String heard, int count})>{};
    for (final s in sessions) {
      for (final c in s.topConfusions) {
        final key = '${c.target}|||${c.heard}';
        final cur = tally[key];
        tally[key] = cur == null
            ? c
            : (target: c.target, heard: c.heard, count: cur.count + c.count);
      }
    }
    final top = tally.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final shown = top.take(5).toList();

    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Most confused pairs', style: _sectionLabelStyle()),
            const SizedBox(height: AppSpacing.m),
            if (shown.isEmpty)
              Text(
                'No confusions logged yet — patient hasn\'t missed enough '
                'closed-set items to surface a pattern.',
                style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              )
            else ...[
              for (final c in shown) _ConfusionRow(confusion: c),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfusionRow extends StatelessWidget {
  const _ConfusionRow({required this.confusion});
  final ({String target, String heard, int count}) confusion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  confusion.target,
                  style: AppTextStyles.ctaLabel.copyWith(fontSize: 14),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_right_alt_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                Flexible(
                  child: Text(
                    confusion.heard,
                    style: AppTextStyles.ctaLabel.copyWith(
                      fontSize: 14,
                      color: AppTheme.errorDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Text(
            '${confusion.count}×',
            style: AppTextStyles.inputLabel.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
