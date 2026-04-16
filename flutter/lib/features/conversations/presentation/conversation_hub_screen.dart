import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../hearing_tests/domain/common_models.dart';
import '../domain/conversation_scenario.dart';
import 'conversation_scenario_screen.dart';

/// Port of HearifyV1/Views/ConversationPracticeView.swift — the hub listing
/// all scenarios by category/difficulty.
class ConversationHubScreen extends ConsumerStatefulWidget {
  const ConversationHubScreen({super.key});

  @override
  ConsumerState<ConversationHubScreen> createState() =>
      _ConversationHubScreenState();
}

class _ConversationHubScreenState extends ConsumerState<ConversationHubScreen> {
  DifficultyLevel? _difficulty;
  ScenarioCategory? _category;

  List<ConversationScenario> get _filtered => sampleScenarios
      .where((s) =>
          (_difficulty == null || s.difficulty == _difficulty) &&
          (_category == null || s.category == _category))
      .toList();

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Conversation Practice')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            _filters(b),
            const SizedBox(height: AppTheme.spacingM),
            for (final s in _filtered) ...[
              _scenarioCard(s, b),
              const SizedBox(height: AppTheme.spacingM),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filters(Brightness b) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Difficulty',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary(b),
              )),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _chip('All', _difficulty == null,
                  () => setState(() => _difficulty = null), b),
              ...DifficultyLevel.values.map((d) => _chip(
                    d.displayName,
                    _difficulty == d,
                    () => setState(() => _difficulty = d),
                    b,
                    color: d.color(b),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Text('Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary(b),
              )),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip('All', _category == null,
                  () => setState(() => _category = null), b),
              ...ScenarioCategory.values.map((c) => _chip(
                    c.displayName,
                    _category == c,
                    () => setState(() => _category = c),
                    b,
                    color: c.color(b),
                  )),
            ],
          ),
        ],
      );

  Widget _chip(String label, bool selected, VoidCallback onTap, Brightness b,
      {Color? color}) {
    final resolved = color ?? AppTheme.primaryBlue(b);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: resolved.withValues(alpha: 0.2),
      backgroundColor: AppTheme.cardBackground(b),
      labelStyle: TextStyle(
        color: selected ? resolved : AppTheme.textPrimary(b),
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: selected ? resolved : AppTheme.textTertiary(b)),
      ),
    );
  }

  Widget _scenarioCard(ConversationScenario s, Brightness b) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ConversationScenarioScreen(scenario: s),
      )),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: s.category.color(b).withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(s.category.icon,
                      color: s.category.color(b), size: 26),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(b),
                          )),
                      Text(s.category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary(b),
                          )),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: s.difficulty.color(b).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(s.difficulty.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: s.difficulty.color(b),
                      )),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(s.description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary(b),
                )),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.forum_outlined,
                    size: 14, color: AppTheme.textTertiary(b)),
                const SizedBox(width: 4),
                Text(
                    '${s.turns.length} turn${s.turns.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary(b),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
