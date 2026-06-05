import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../data/clinician_repository.dart';
import 'widgets/clinical_metrics_panel.dart';

/// Port of HearifyPro/Views/PatientDetailView.swift. Header, three
/// metric cards (with improvement deltas), an accuracy-over-time line
/// chart, and the session history.
class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(patientProfileProvider(uid));
    final sessions = ref.watch(patientSessionsProvider(uid));
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
            profile.whenOrNull(data: (p) => p?.name) ?? 'Patient',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: profile.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    'Couldn\'t load this patient. $e',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.error,
                  ),
                ),
              ),
              data: (p) {
                if (p == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Text(
                        'Patient profile not found. The account may have '
                        'been deleted.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                      ),
                    ),
                  );
                }
                return _DetailBody(profile: p, sessions: sessions);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.profile, required this.sessions});

  final PatientProfile profile;
  final AsyncValue<List<PatientSession>> sessions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderCard(profile: profile),
          const SizedBox(height: AppSpacing.xl),
          // The clinical-metrics panel replaces the previous single
          // accuracy line. Five views layered top-down by clinical
          // impact. Each view handles its own "no data yet" copy when
          // the session list is short.
          sessions.when(
            loading: () => const _CardShell(
              child: SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => _CardShell(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Text('Couldn\'t load sessions. $e',
                    style: AppTextStyles.error),
              ),
            ),
            data: (list) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EngagementStrip(sessions: list),
                const SizedBox(height: AppSpacing.l),
                Snr50TrendChart(sessions: list),
                const SizedBox(height: AppSpacing.l),
                InitialVsFinalCard(sessions: list),
                const SizedBox(height: AppSpacing.l),
                FeatureAccuracyHeatmap(sessions: list),
                const SizedBox(height: AppSpacing.l),
                TopConfusionsTable(sessions: list),
                const SizedBox(height: AppSpacing.xl),
                const _SectionLabel('Current performance'),
                const SizedBox(height: AppSpacing.m),
                _MetricRow(profile: profile),
                const SizedBox(height: AppSpacing.xl),
                const _SectionLabel('Accuracy over time'),
                const SizedBox(height: AppSpacing.m),
                _ProgressChartCard(sessions: list),
                const SizedBox(height: AppSpacing.xl),
                const _SectionLabel('Session history'),
                const SizedBox(height: AppSpacing.m),
                _SessionsList(sessions: list),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.inputLabel.copyWith(
          fontSize: 12,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});
  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = _riskColor(profile.riskLevel, b);
    return _CardShell(
      accent: accent,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            Row(
              children: [
                _Avatar(name: profile.name, accent: accent),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name,
                          style:
                              AppTextStyles.title.copyWith(fontSize: 22)),
                      const SizedBox(height: AppSpacing.xs),
                      if (profile.email.isNotEmpty)
                        Text(
                          profile.email,
                          style: AppTextStyles.inputLabel.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      _RiskPill(level: profile.riskLevel, color: accent),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: _QuickFact(
                    icon: Icons.calendar_month_rounded,
                    label: 'Enrolled',
                    value: profile.daysSinceEnrollment == null
                        ? '—'
                        : '${profile.daysSinceEnrollment} d ago',
                  ),
                ),
                Expanded(
                  child: _QuickFact(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Streak',
                    value: '${profile.streakDays} d',
                    accent: profile.streakDays > 0
                        ? AppTheme.accentOrange(b)
                        : null,
                  ),
                ),
                Expanded(
                  child: _QuickFact(
                    icon: Icons.check_circle_rounded,
                    label: 'Sessions',
                    value: '${profile.totalSessions}',
                  ),
                ),
                Expanded(
                  child: _QuickFact(
                    icon: Icons.schedule_rounded,
                    label: 'Practice',
                    value: _formatMinutes(profile.totalPracticeMinutes),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.accent});
  final String name;
  final Color accent;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.9),
            accent.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Text(
        _initials,
        style: AppTextStyles.title.copyWith(fontSize: 22),
      ),
    );
  }
}

class _RiskPill extends StatelessWidget {
  const _RiskPill({required this.level, required this.color});
  final RiskLevel level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.8),
      ),
      child: Text(
        _riskLabel(level),
        style: AppTextStyles.ctaLabel.copyWith(
          fontSize: 11,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _QuickFact extends StatelessWidget {
  const _QuickFact({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final color = accent ?? AppTheme.primaryBlue(b);
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.ctaLabel.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 2),
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

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.profile});
  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Column(
      children: [
        _MetricCard(
          label: 'Word Recognition',
          value: profile.currentWordRecognition,
          delta: profile.improvementWordRecognition,
          color: AppTheme.success(b),
          icon: Icons.title_rounded,
        ),
        const SizedBox(height: AppSpacing.m),
        _MetricCard(
          label: 'Sentence Comprehension',
          value: profile.currentSentenceComprehension,
          delta: profile.improvementSentenceComprehension,
          color: AppTheme.accentOrange(b),
          icon: Icons.chat_bubble_rounded,
        ),
        const SizedBox(height: AppSpacing.m),
        _MetricCard(
          label: 'Noise Performance',
          value: profile.currentNoisePerformance,
          delta: profile.improvementNoisePerformance,
          color: AppTheme.warning(b),
          icon: Icons.graphic_eq_rounded,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final double? delta;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      accent: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.ctaLabel.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    'Current ${(value * 100).round()}%',
                    style: AppTextStyles.inputLabel.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _DeltaChip(delta: delta, color: color),
          ],
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta, required this.color});
  final double? delta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (delta == null) {
      return Text(
        'No baseline',
        style: AppTextStyles.inputLabel.copyWith(
          color: AppColors.textPlaceholder,
        ),
      );
    }
    final positive = delta! >= 0;
    final pct = (delta! * 100).abs().toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${positive ? '+' : '-'}$pct%',
            style: AppTextStyles.ctaLabel.copyWith(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}

class _ProgressChartCard extends StatelessWidget {
  const _ProgressChartCard({required this.sessions});
  final List<PatientSession> sessions;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    if (sessions.isEmpty) {
      return const _CardShell(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: Text(
              'No sessions yet — the chart lights up once this patient '
              'completes their first drill.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
          ),
        ),
      );
    }

    // Ascending by date for plotting.
    final asc = [...sessions]
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));
    final spots = <String, List<FlSpot>>{
      'Word Recognition': [],
      'Sentence Comprehension': [],
      'Sentences in Noise': [],
    };
    for (var i = 0; i < asc.length; i++) {
      final s = asc[i];
      final x = i.toDouble();
      final y = (s.accuracy * 100).clamp(0.0, 100.0);
      if (s.exerciseType.toLowerCase().contains('word')) {
        spots['Word Recognition']!.add(FlSpot(x, y));
      } else if (s.exerciseType.toLowerCase().contains('noise')) {
        spots['Sentences in Noise']!.add(FlSpot(x, y));
      } else if (s.exerciseType.toLowerCase().contains('sentence')) {
        spots['Sentence Comprehension']!.add(FlSpot(x, y));
      } else {
        // Fallback bucket so unknown types aren't lost.
        spots['Word Recognition']!.add(FlSpot(x, y));
      }
    }
    final seriesColors = {
      'Word Recognition': AppTheme.success(b),
      'Sentence Comprehension': AppTheme.accentOrange(b),
      'Sentences in Noise': AppTheme.warning(b),
    };

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
            Wrap(
              spacing: AppSpacing.l,
              runSpacing: 4,
              children: [
                for (final entry in seriesColors.entries)
                  _LegendChip(color: entry.value, label: entry.key),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (v) => const FlLine(
                      color: AppColors.hairline,
                      strokeWidth: 0.6,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) => Text(
                          '${v.round()}',
                          style: AppTextStyles.inputLabel.copyWith(
                            fontSize: 10,
                            color: AppColors.textPlaceholder,
                          ),
                        ),
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.authCardBase,
                      getTooltipItems: (spots) => spots.map((sp) {
                        final color = sp.bar.color ?? AppColors.textPrimary;
                        return LineTooltipItem(
                          '${sp.y.round()}%',
                          AppTextStyles.ctaLabel.copyWith(
                            fontSize: 12,
                            color: color,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    for (final entry in spots.entries)
                      if (entry.value.isNotEmpty)
                        LineChartBarData(
                          spots: entry.value,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: seriesColors[entry.key],
                          barWidth: 2.4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: seriesColors[entry.key]!
                                .withValues(alpha: 0.08),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.inputLabel.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _SessionsList extends StatelessWidget {
  const _SessionsList({required this.sessions});
  final List<PatientSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const _CardShell(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: Text(
              'Session history will populate here once the patient practices.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final s in sessions) ...[
          _SessionRow(session: s),
          const SizedBox(height: AppSpacing.s),
        ],
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final PatientSession session;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final acc = session.accuracy;
    final color = acc >= 0.85
        ? AppTheme.success(b)
        : acc >= 0.65
            ? AppTheme.warning(b)
            : AppTheme.error(b);
    return _CardShell(
      accent: color,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.button),
          splashColor: color.withValues(alpha: 0.1),
          onTap: () => _openDrillDown(context, session),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadii.input),
                  ),
                  child: Text(
                    '${(acc * 100).round()}%',
                    style: AppTextStyles.ctaLabel.copyWith(
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.exerciseType,
                        style: AppTextStyles.ctaLabel.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _sessionSubtitle(session),
                        style: AppTextStyles.inputLabel.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('MMM d').format(session.sessionDate),
                  style: AppTextStyles.inputLabel.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDrillDown(BuildContext context, PatientSession s) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.authCardBase,
      showDragHandle: true,
      builder: (_) => _SessionDrillDownSheet(session: s),
    );
  }
}

/// Audiologist drill-down: every per-attempt detail logged for a
/// single session. Lazy-loaded — Firestore reads only fire when the
/// audiologist actually taps a session, so the dashboard stays cheap.
class _SessionDrillDownSheet extends ConsumerWidget {
  const _SessionDrillDownSheet({required this.session});
  final PatientSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    final attempts = ref.watch(sessionAttemptsProvider(session.id));
    final size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size.height * 0.85),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              session.exerciseType,
              style: AppTextStyles.ctaLabel.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 2),
            Text(
              '${DateFormat('MMM d, h:mm a').format(session.sessionDate)}'
              '   ·   ${(session.accuracy * 100).round()}%'
              '   ·   ${session.itemsCorrect}/${session.itemsAttempted} correct'
              '${session.snr50 != null ? "   ·   SNR-50 ${session.snr50!.toStringAsFixed(1)} dB" : ""}',
              style: AppTextStyles.inputLabel.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Flexible(
              child: attempts.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Text(
                    "Couldn't load this session's attempts. $e",
                    style: AppTextStyles.error,
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      child: Text(
                        'No per-attempt detail logged for this session. '
                        'Older sessions only have aggregate metrics.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppColors.hairline,
                    ),
                    itemBuilder: (_, i) =>
                        _AttemptRow(attempt: list[i], brightness: b),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptRow extends StatelessWidget {
  const _AttemptRow({required this.attempt, required this.brightness});
  final PatientAttempt attempt;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final correctColor = attempt.correct
        ? AppTheme.success(brightness)
        : AppTheme.error(brightness);
    final detailParts = <String>[];
    if (attempt.snrDb != null) {
      detailParts.add('${attempt.snrDb!.toStringAsFixed(0)} dB SNR');
    }
    if (attempt.responseTimeMs != null) {
      detailParts.add('${attempt.responseTimeMs} ms');
    }
    if (attempt.categoryTag != null) {
      detailParts.add(attempt.categoryTag!);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Icon(
              attempt.correct
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              size: 18,
              color: correctColor,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.ctaLabel.copyWith(fontSize: 14),
                    children: [
                      TextSpan(text: attempt.target),
                      TextSpan(
                        text: '   →   ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text:
                            attempt.heard.isEmpty ? '(no response)' : attempt.heard,
                        style: TextStyle(color: correctColor),
                      ),
                    ],
                  ),
                ),
                if (detailParts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detailParts.join('  ·  '),
                    style: AppTextStyles.inputLabel.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _sessionSubtitle(PatientSession s) {
  final parts = <String>[];
  if (s.itemsAttempted > 0) {
    parts.add('${s.itemsCorrect}/${s.itemsAttempted} correct');
  }
  if (s.durationSeconds > 0) {
    parts.add('${(s.durationSeconds / 60).toStringAsFixed(1)} min');
  }
  if (s.backgroundNoiseLevel > 0) {
    parts.add('${(s.backgroundNoiseLevel * 100).round()}% noise');
  }
  return parts.isEmpty ? 'Session logged' : parts.join(' · ');
}

String _formatMinutes(double minutes) {
  if (minutes < 60) return '${minutes.round()} m';
  final h = minutes / 60;
  return '${h.toStringAsFixed(1)} h';
}

Color _riskColor(RiskLevel level, Brightness b) {
  switch (level) {
    case RiskLevel.engaged:
      return AppTheme.success(b);
    case RiskLevel.moderate:
      return AppTheme.primaryBlue(b);
    case RiskLevel.atRisk:
      return AppTheme.warning(b);
    case RiskLevel.critical:
      return AppTheme.error(b);
  }
}

String _riskLabel(RiskLevel level) {
  switch (level) {
    case RiskLevel.engaged:
      return 'Engaged';
    case RiskLevel.moderate:
      return 'Moderate';
    case RiskLevel.atRisk:
      return 'At risk';
    case RiskLevel.critical:
      return 'Critical';
  }
}
