import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/practice_history.dart';

/// Port of HearifyV1/Views/RecordingHistoryView.swift.
/// The Swift version plays back the user's saved `.m4a` recordings;
/// storing those through `record` + `flutter_soloud` is a Phase 6+ concern.
/// This port shows the transcript + score + "speak target" replay instead.
class RecordingHistoryScreen extends ConsumerWidget {
  const RecordingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    final history = ref.watch(practiceHistoryProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Recording History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear history?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton.tonal(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(practiceHistoryProvider.notifier).clear();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: history.isEmpty
            ? _empty(b)
            : ListView.separated(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                itemCount: history.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppTheme.spacingM),
                itemBuilder: (_, i) => _tile(context, ref, history[i], b),
              ),
      ),
    );
  }

  Widget _empty(Brightness b) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_off,
                size: 72, color: AppTheme.textTertiary(b)),
            const SizedBox(height: 12),
            Text('No attempts yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary(b),
                )),
            Text('Complete a practice session to see it here.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textTertiary(b),
                )),
          ],
        ),
      );

  Widget _tile(BuildContext context, WidgetRef ref, PracticeAttempt a,
          Brightness b) =>
      ModernCard(
        child: Row(
          children: [
            _scoreBubble(a.score, b),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.target,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary(b),
                      )),
                  const SizedBox(height: 2),
                  Text('Heard: ${a.heard.isEmpty ? "—" : a.heard}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(b),
                      )),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d · h:mm a').format(a.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary(b),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.volume_up, color: AppTheme.primaryBlue(b)),
              onPressed: () =>
                  ref.read(audioServiceProvider).speak(a.target),
            ),
          ],
        ),
      );

  Widget _scoreBubble(double score, Brightness b) {
    final c = score >= 0.9
        ? AppTheme.success(b)
        : score >= 0.7
            ? AppTheme.warning(b)
            : AppTheme.error(b);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text('${(score * 100).round()}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: c,
          )),
    );
  }
}
