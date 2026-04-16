import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/clinician_repository.dart';

/// Port of HearifyV1/Views/ClinicianDashboardView.swift.
/// Clinician-facing: enter a patient's 6-digit code to link them, then
/// browse the roster + each patient's progress stats.
class ClinicianDashboardScreen extends ConsumerStatefulWidget {
  const ClinicianDashboardScreen({super.key});

  @override
  ConsumerState<ClinicianDashboardScreen> createState() =>
      _ClinicianDashboardScreenState();
}

class _ClinicianDashboardScreenState
    extends ConsumerState<ClinicianDashboardScreen> {
  final _codeInput = TextEditingController();
  String? _feedback;
  bool _busy = false;

  @override
  void dispose() {
    _codeInput.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final code = _codeInput.text.trim();
    if (code.length != 6) {
      setState(() => _feedback = 'Code must be 6 digits.');
      return;
    }
    setState(() {
      _busy = true;
      _feedback = null;
    });
    try {
      await ref.read(clinicianRepositoryProvider).linkPatient(code: code);
      _codeInput.clear();
      setState(() => _feedback = 'Patient linked.');
    } catch (e) {
      setState(() => _feedback = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final patients = ref.watch(patientsStreamProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Clinician Dashboard')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            _linkCard(b),
            const SizedBox(height: AppTheme.spacingM),
            Text('Linked patients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(b),
                )),
            const SizedBox(height: 8),
            patients.when(
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )),
              error: (e, _) => Text(e.toString(),
                  style: TextStyle(color: AppTheme.error(b))),
              data: (list) => list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No patients linked yet. Ask your patient to open '
                        '"Share with clinician" in the app and read you the code.',
                        style: TextStyle(
                          color: AppTheme.textSecondary(b),
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (final p in list) ...[
                          _patientCard(p, b),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkCard(Brightness b) => ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Link a new patient',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(b),
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _codeInput,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '6-digit code',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                backgroundColor: AppTheme.primaryBlue(b),
              ),
              onPressed: _busy ? null : _link,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.link),
              label: const Text('Link patient'),
            ),
            if (_feedback != null) ...[
              const SizedBox(height: 8),
              Text(_feedback!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _feedback!.startsWith('Patient')
                        ? AppTheme.success(b)
                        : AppTheme.error(b),
                  )),
            ],
          ],
        ),
      );

  Widget _patientCard(LinkedPatient p, Brightness b) => ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      AppTheme.primaryBlue(b).withValues(alpha: 0.15),
                  child: Icon(Icons.person,
                      color: AppTheme.primaryBlue(b)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(b),
                          )),
                      if (p.email.isNotEmpty)
                        Text(p.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary(b),
                            )),
                      if (p.lastActive != null)
                        Text(
                          'Last active ${DateFormat('MMM d · h:mm a').format(p.lastActive!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary(b),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _metric('Sessions', '${p.totalSessions}', b)),
                Expanded(child: _metric('Streak', '${p.streakDays}d', b)),
              ],
            ),
            const SizedBox(height: 8),
            _accuracyRow('Word recognition', p.currentWordRecognition, b),
            _accuracyRow(
                'Sentence comprehension', p.currentSentenceComprehension, b),
            _accuracyRow('Noise performance', p.currentNoisePerformance, b),
          ],
        ),
      );

  Widget _metric(String label, String value, Brightness b) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(b),
              )),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary(b),
              )),
        ],
      );

  Widget _accuracyRow(String label, double v, Brightness b) {
    final clamped = v.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(b),
                    )),
              ),
              Text('${(clamped * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(b),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 6,
              color: AppTheme.primaryBlue(b),
              backgroundColor:
                  AppTheme.primaryBlue(b).withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

final patientsStreamProvider = StreamProvider<List<LinkedPatient>>((ref) {
  return ref.read(clinicianRepositoryProvider).watchMyPatients();
});
