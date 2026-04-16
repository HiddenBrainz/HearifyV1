import 'phoneme.dart';

/// Minimal "speakable" target for the pronunciation loop.
/// Ported from the inline `SpeakingPracticeItem` in SpeakingPracticeView.swift.
class SpeakingPracticeItem {
  const SpeakingPracticeItem({
    required this.text,
    required this.difficulty,
    this.category = '',
    this.phonemeFocus,
  });

  final String text;
  final Difficulty difficulty;
  final String category;
  final Phoneme? phonemeFocus;
}

/// Seed set — kept small so it fits on screen. The Swift source has 30+
/// hardcoded items; additional content will come from CSVs in Phase 6.
const List<SpeakingPracticeItem> defaultPracticeItems = [
  SpeakingPracticeItem(
      text: 'red', difficulty: Difficulty.easy, category: 'Colors'),
  SpeakingPracticeItem(
      text: 'blue', difficulty: Difficulty.easy, category: 'Colors'),
  SpeakingPracticeItem(
      text: 'yellow', difficulty: Difficulty.easy, category: 'Colors'),
  SpeakingPracticeItem(
      text: 'water', difficulty: Difficulty.easy, category: 'Common words'),
  SpeakingPracticeItem(
      text: 'weather', difficulty: Difficulty.medium, category: 'Common words'),
  SpeakingPracticeItem(
      text: 'thought', difficulty: Difficulty.hard, category: 'Th sounds'),
  SpeakingPracticeItem(
      text: 'through', difficulty: Difficulty.hard, category: 'Th sounds'),
  SpeakingPracticeItem(
      text: 'rural', difficulty: Difficulty.hard, category: 'R sounds'),
  SpeakingPracticeItem(
      text: 'library', difficulty: Difficulty.medium, category: 'R sounds'),
  SpeakingPracticeItem(
      text: 'The weather is nice today',
      difficulty: Difficulty.medium,
      category: 'Sentences'),
  SpeakingPracticeItem(
      text: 'She sells seashells by the seashore',
      difficulty: Difficulty.hard,
      category: 'Tongue twisters'),
  SpeakingPracticeItem(
      text: 'Peter Piper picked a peck of pickled peppers',
      difficulty: Difficulty.hard,
      category: 'Tongue twisters'),
];
