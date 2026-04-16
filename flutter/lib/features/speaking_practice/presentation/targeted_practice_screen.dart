import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/phoneme_database.dart';
import '../domain/phoneme.dart';
import '../domain/practice_item.dart';
import 'speaking_practice_screen.dart';

/// Port of HearifyV1/Views/TargetedPracticeView.swift.
/// Lists classic phoneme-contrast pairs (r/l, θ/ð, v/w, ...). Tapping a pair
/// opens the speaking-practice loop with items pre-seeded from that pair.
class TargetedPracticeScreen extends ConsumerWidget {
  const TargetedPracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    final pairs = PhonemeDatabase.shared.getComparisonPairs();
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Targeted Practice')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: pairs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppTheme.spacingM),
          itemBuilder: (_, i) => _pairCard(context, ref, pairs[i], b),
        ),
      ),
    );
  }

  Widget _pairCard(BuildContext context, WidgetRef ref, PhonemePair pair,
          Brightness b) =>
      InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        onTap: () {
          final items = _itemsForPair(pair);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SpeakingPracticeScreen(items: items),
          ));
        },
        child: ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _phonemeBadge(pair.a, b),
                  const SizedBox(width: 8),
                  Text('vs',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary(b),
                      )),
                  const SizedBox(width: 8),
                  _phonemeBadge(pair.b, b),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.play_circle_fill,
                        color: AppTheme.primaryBlue(b)),
                    onPressed: () async {
                      final audio = ref.read(audioServiceProvider);
                      await audio.speak(pair.a.examples.first);
                      await Future<void>.delayed(
                          const Duration(milliseconds: 400));
                      await audio.speak(pair.b.examples.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(pair.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(b),
                  )),
              Text(pair.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(b),
                  )),
            ],
          ),
        ),
      );

  Widget _phonemeBadge(Phoneme p, Brightness b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: p.category.color(b).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(p.symbol,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: p.category.color(b),
            )),
      );

  List<SpeakingPracticeItem> _itemsForPair(PhonemePair pair) {
    return [
      ...pair.a.examples.map((t) => SpeakingPracticeItem(
            text: t,
            difficulty: Difficulty.medium,
            category: 'Pair · ${pair.title}',
            phonemeFocus: pair.a,
          )),
      ...pair.b.examples.map((t) => SpeakingPracticeItem(
            text: t,
            difficulty: Difficulty.medium,
            category: 'Pair · ${pair.title}',
            phonemeFocus: pair.b,
          )),
    ];
  }
}
