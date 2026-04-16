import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/clinician_repository.dart';

/// Port of HearifyV1/Views/ClinicianLinkingView.swift.
/// Patient-facing screen: generate a 6-digit code to share with their
/// clinician. Replaces the CloudKit share-URL flow with a Firestore
/// document.
class ClinicianLinkingScreen extends ConsumerStatefulWidget {
  const ClinicianLinkingScreen({super.key});

  @override
  ConsumerState<ClinicianLinkingScreen> createState() =>
      _ClinicianLinkingScreenState();
}

class _ClinicianLinkingScreenState
    extends ConsumerState<ClinicianLinkingScreen> {
  String? _code;
  bool _busy = false;
  String? _error;

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = await ref
          .read(clinicianRepositoryProvider)
          .generateLinkingCode();
      setState(() => _code = code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Share with Clinician')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModernCard(
                child: Column(
                  children: [
                    Icon(Icons.link,
                        size: 40, color: AppTheme.primaryBlue(b)),
                    const SizedBox(height: 12),
                    Text('One-time link code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(b),
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Share this 6-digit code with your audiologist. They '
                      'enter it once to link your progress. Code expires in 24 hours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(b),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_code != null) ...[
                      SelectableText(
                        _code!,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: AppTheme.primaryBlue(b),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: _code!));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copied')),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                      ),
                    ] else
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppTheme.primaryBlue(b),
                        ),
                        onPressed: _busy ? null : _generate,
                        icon: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.bolt),
                        label: const Text('Generate Code'),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(
                            color: AppTheme.error(b),
                            fontSize: 12,
                          )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
