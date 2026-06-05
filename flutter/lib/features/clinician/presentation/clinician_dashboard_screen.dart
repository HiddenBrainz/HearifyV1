import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/presentation/widgets/gradient_primary_button.dart';
import '../data/clinician_repository.dart';
import 'link_patient_screen.dart';
import 'patient_detail_screen.dart';

/// Port of HearifyPro/Views/PatientListView.swift. Roster of linked
/// patients, summary metrics, filter/search, tap-through to the
/// detail screen. Styled to match the rest of the premium dark app.
class ClinicianDashboardScreen extends ConsumerStatefulWidget {
  const ClinicianDashboardScreen({super.key});

  @override
  ConsumerState<ClinicianDashboardScreen> createState() =>
      _ClinicianDashboardScreenState();
}

class _ClinicianDashboardScreenState
    extends ConsumerState<ClinicianDashboardScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientsStreamProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bgPrimary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  onLinkPatient: _openLinkPatient,
                  onSignOut: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                ),
                Expanded(
                  child: patients.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => _ErrorView(message: e.toString()),
                    data: (list) {
                      final filtered = _applyFilter(list, _query);
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.l,
                          0,
                          AppSpacing.l,
                          AppSpacing.xxl,
                        ),
                        children: [
                          _SummaryStrip(patients: list),
                          const SizedBox(height: AppSpacing.l),
                          _SearchField(
                            controller: _search,
                            onChanged: (v) =>
                                setState(() => _query = v.trim().toLowerCase()),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          if (list.isEmpty)
                            _EmptyState(onLinkPatient: _openLinkPatient)
                          else if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xxl,
                              ),
                              child: Text(
                                'No patients match "${_search.text}".',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.subtitle,
                              ),
                            )
                          else
                            for (final p in filtered) ...[
                              _PatientRow(
                                patient: p,
                                onTap: () => _openPatient(p),
                              ),
                              const SizedBox(height: AppSpacing.m),
                            ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLinkPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LinkPatientScreen()),
    );
  }

  void _openPatient(LinkedPatient p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(uid: p.uid),
      ),
    );
  }

  List<LinkedPatient> _applyFilter(List<LinkedPatient> all, String q) {
    final sorted = [...all]..sort((a, b) {
        final la = a.lastActive?.millisecondsSinceEpoch ?? 0;
        final lb = b.lastActive?.millisecondsSinceEpoch ?? 0;
        return lb.compareTo(la);
      });
    if (q.isEmpty) return sorted;
    return sorted
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.email.toLowerCase().contains(q))
        .toList();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onLinkPatient, required this.onSignOut});

  final VoidCallback onLinkPatient;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.m,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Patients',
                    style: AppTextStyles.title.copyWith(fontSize: 30)),
                const SizedBox(height: 2),
                Text(
                  'Your audiologist roster',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          _IconPill(
            icon: Icons.person_add_alt_1_rounded,
            tooltip: 'Link patient',
            onTap: onLinkPatient,
          ),
          const SizedBox(width: AppSpacing.s),
          _IconPill(
            icon: Icons.logout_rounded,
            tooltip: 'Sign out',
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  const _IconPill({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.authCardTop,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.hairline, width: 0.5),
      ),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.patients});
  final List<LinkedPatient> patients;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final total = patients.length;
    final engaged = patients
        .where((p) => p.riskLevel == RiskLevel.engaged)
        .length;
    final atRisk = patients
        .where((p) =>
            p.riskLevel == RiskLevel.atRisk ||
            p.riskLevel == RiskLevel.critical)
        .length;
    final avg = patients.isEmpty
        ? 0.0
        : patients.map((p) => p.averagePerformance).reduce((a, b) => a + b) /
            patients.length;
    return Row(
      children: [
        _SummaryTile(
          icon: Icons.people_alt_rounded,
          label: 'Patients',
          value: '$total',
          color: AppTheme.primaryBlue(b),
        ),
        const SizedBox(width: AppSpacing.m),
        _SummaryTile(
          icon: Icons.local_fire_department_rounded,
          label: 'Engaged',
          value: '$engaged',
          color: AppTheme.success(b),
        ),
        const SizedBox(width: AppSpacing.m),
        _SummaryTile(
          icon: Icons.warning_amber_rounded,
          label: 'At risk',
          value: '$atRisk',
          color: AppTheme.warning(b),
        ),
        const SizedBox(width: AppSpacing.m),
        _SummaryTile(
          icon: Icons.query_stats_rounded,
          label: 'Avg acc.',
          value: '${(avg * 100).round()}%',
          color: AppColors.gradientPurple,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.authCard,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border:
              Border.all(color: color.withValues(alpha: 0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.14),
              blurRadius: 18,
              spreadRadius: -8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.m,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: AppSpacing.s),
              Text(value,
                  style: AppTextStyles.title.copyWith(fontSize: 20)),
              Text(
                label,
                style: AppTextStyles.inputLabel.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.linkBlue,
        style: AppTextStyles.inputText,
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textInactive,
          ),
          hintText: 'Search patients',
          hintStyle: AppTextStyles.placeholder,
        ),
      ),
    );
  }
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.patient, required this.onTap});

  final LinkedPatient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = _riskColor(patient.riskLevel, b);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 22,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
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
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(name: patient.name, accent: accent),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: AppTextStyles.ctaLabel.copyWith(
                                fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            patient.email.isEmpty
                                ? 'No email on file'
                                : patient.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.inputLabel.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _lastActiveLabel(patient.lastActive),
                            style: AppTextStyles.inputLabel.copyWith(
                              color: AppColors.textPlaceholder,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textInactive),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                Row(
                  children: [
                    _Chip(
                      icon: Icons.check_circle_rounded,
                      label: '${patient.totalSessions}',
                      sub: 'sessions',
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _Chip(
                      icon: Icons.local_fire_department_rounded,
                      label: '${patient.streakDays}d',
                      sub: 'streak',
                      accent: patient.streakDays > 0
                          ? AppTheme.accentOrange(b)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _Chip(
                      icon: Icons.query_stats_rounded,
                      label:
                          '${(patient.averagePerformance * 100).round()}%',
                      sub: 'avg',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                _AccuracyRow(
                  label: 'Word Recognition',
                  value: patient.currentWordRecognition,
                  color: AppTheme.success(b),
                ),
                const SizedBox(height: AppSpacing.s),
                _AccuracyRow(
                  label: 'Sentence Comprehension',
                  value: patient.currentSentenceComprehension,
                  color: AppTheme.accentOrange(b),
                ),
                const SizedBox(height: AppSpacing.s),
                _AccuracyRow(
                  label: 'Noise Performance',
                  value: patient.currentNoisePerformance,
                  color: AppTheme.warning(b),
                ),
              ],
            ),
          ),
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
      width: 44,
      height: 44,
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
        style: AppTextStyles.ctaLabel.copyWith(fontSize: 16),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.sub,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final color = accent ?? AppTheme.primaryBlue(b);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      AppTextStyles.ctaLabel.copyWith(fontSize: 13, color: color),
                ),
                Text(
                  sub,
                  style: AppTextStyles.inputLabel.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
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

class _AccuracyRow extends StatelessWidget {
  const _AccuracyRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: AppTextStyles.inputLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 6,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        SizedBox(
          width: 36,
          child: Text(
            '${(clamped * 100).round()}%',
            textAlign: TextAlign.right,
            style: AppTextStyles.ctaLabel.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onLinkPatient});
  final VoidCallback onLinkPatient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        border: Border.all(
          color: AppColors.hairline,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.logoCircle,
                boxShadow: AppShadows.logoCircle,
              ),
              child: const Icon(
                Icons.group_add_rounded,
                color: AppColors.textPrimary,
                size: 44,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('No patients linked yet',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(fontSize: 22)),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Ask your patient to open Settings → Share with Clinician '
              'and read you the 6-digit code.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientPrimaryButton(
              label: 'Link Patient',
              leadingIcon: Icons.person_add_alt_1_rounded,
              onPressed: onLinkPatient,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Text(message,
          textAlign: TextAlign.center, style: AppTextStyles.error),
    );
  }
}

String _lastActiveLabel(DateTime? t) {
  if (t == null) return 'Never active';
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'Active just now';
  if (diff.inHours < 1) return 'Active ${diff.inMinutes} min ago';
  if (diff.inDays < 1) return 'Active ${diff.inHours} h ago';
  if (diff.inDays < 7) return 'Active ${diff.inDays} d ago';
  return 'Last active ${DateFormat('MMM d').format(t)}';
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

/// `.autoDispose` is critical here — without it the StreamProvider
/// caches the stream subscription across navigation. When the
/// audiologist signs OUT, Firebase tears down the auth context and the
/// still-listening `clinicians/{uid}.snapshots()` errors with
/// `permission-denied`, parking this provider in `AsyncError`. When
/// they sign back IN, the dashboard reads the same cached provider
/// and re-displays the stale error before any retry can fire.
/// AutoDispose forces a brand-new subscription each time the
/// dashboard mounts, which is fired AFTER signIn has propagated the
/// new auth token to Firestore.
final patientsStreamProvider =
    StreamProvider.autoDispose<List<LinkedPatient>>((ref) {
  return ref.read(clinicianRepositoryProvider).watchMyPatients();
});
