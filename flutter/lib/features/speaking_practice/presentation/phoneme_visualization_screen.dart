import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/phoneme_database.dart';
import '../domain/phoneme.dart';

/// Port of HearifyV1/Views/PhonemeVisualizationView.swift.
/// Swift version includes a 2-D tongue diagram (Canvas with paths) to show
/// articulation positions; that's deferred to avoid a large Canvas port in
/// this pass. The list view + examples + TTS preview are functional.
class PhonemeVisualizationScreen extends ConsumerStatefulWidget {
  const PhonemeVisualizationScreen({super.key});

  @override
  ConsumerState<PhonemeVisualizationScreen> createState() =>
      _PhonemeVisualizationScreenState();
}

class _PhonemeVisualizationScreenState
    extends ConsumerState<PhonemeVisualizationScreen> {
  PhonemeCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final all = PhonemeDatabase.all;
    final filtered =
        _filter == null ? all : all.where((p) => p.category == _filter!).toList();
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Phonemes')),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM),
                children: [
                  _categoryChip(null, 'All', AppTheme.primaryBlue(b), b),
                  ...PhonemeCategory.values.map((c) =>
                      _categoryChip(c, c.displayName, c.color(b), b)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                itemBuilder: (_, i) => _phonemeTile(filtered[i], b),
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppTheme.spacingM),
                itemCount: filtered.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(
          PhonemeCategory? c, String label, Color color, Brightness b) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(label),
          selected: _filter == c,
          onSelected: (_) => setState(() => _filter = c),
          backgroundColor: AppTheme.cardBackground(b),
          selectedColor: color.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: _filter == c ? color : AppTheme.textPrimary(b),
            fontWeight: _filter == c ? FontWeight.w600 : FontWeight.w400,
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: _filter == c ? color : AppTheme.textTertiary(b),
            ),
          ),
        ),
      );

  Widget _phonemeTile(Phoneme p, Brightness b) => ModernCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: p.category.color(b).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              alignment: Alignment.center,
              child: Text(p.symbol,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: p.category.color(b),
                  )),
            ),
            const SizedBox(width: AppTheme.spacingM),
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
                  const SizedBox(height: 2),
                  Text('e.g. ${p.examplesString}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(b),
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _tag(p.difficulty.displayName, p.category.color(b)),
                      const SizedBox(width: 6),
                      _tag(
                        p.voicing == Voicing.voiced ? 'voiced' : 'voiceless',
                        AppTheme.textSecondary(b),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => ref.read(audioServiceProvider).speak(
                    p.examples.isNotEmpty ? p.examples.first : p.symbol,
                  ),
              icon: Icon(Icons.volume_up, color: AppTheme.primaryBlue(b)),
            ),
          ],
        ),
      );

  Widget _tag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            )),
      );
}
