import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';

/// Port of HearifyV1/Models/TestModels.swift `TrainingCategory`.
enum ClassicExerciseCategory {
  matchedPairs('Matched Pairs', Icons.view_list,
      'Distinguish pairs of similar-sounding words'),
  wordRecognition('Word Recognition', Icons.title,
      'Identify single spoken words'),
  sentenceComprehension('Sentence Comprehension', Icons.chat_bubble_outline,
      'Understand full sentences in a quiet setting'),
  sentencesInNoise('Sentences in Noise', Icons.graphic_eq,
      'Comprehend speech with background noise mixed in'),
  diagnosticTest('Diagnostic Test', Icons.medical_services,
      'Mixed word + sentence battery for a baseline check'),
  customPractice('Custom Practice', Icons.edit_note,
      'Practice with your own sentences and words');

  const ClassicExerciseCategory(this.displayName, this.icon, this.description);

  final String displayName;
  final IconData icon;
  final String description;

  Color color(Brightness b) => switch (this) {
        ClassicExerciseCategory.matchedPairs => AppTheme.primaryBlue(b),
        ClassicExerciseCategory.wordRecognition => AppTheme.success(b),
        ClassicExerciseCategory.sentenceComprehension =>
          AppTheme.accentOrange(b),
        ClassicExerciseCategory.sentencesInNoise => AppTheme.warning(b),
        ClassicExerciseCategory.diagnosticTest => AppTheme.error(b),
        // Brand violet from the auth CTA gradient — keeps Custom Practice
        // in sync with the Practice Insights featured card.
        ClassicExerciseCategory.customPractice => AppColors.gradientPurple,
      };
}

/// One multiple-choice question. Used by Word Recognition, Sentence
/// Comprehension, Sentences in Noise, and Diagnostic Test.
class MultipleChoiceItem {
  const MultipleChoiceItem({
    required this.prompt,
    required this.correctAnswer,
    required this.choices,
    this.difficulty = 'medium',
    this.type = 'word',
  });

  final String prompt;
  final String correctAnswer;
  final List<String> choices;
  final String difficulty;
  final String type; // "word" | "sentence"
}

/// Matched-pair practice item: two similarly-pronounced words grouped by
/// category (syllables, vowels, consonants, etc.). The app plays one and
/// the user picks which they heard.
class MatchedPair {
  const MatchedPair({
    required this.first,
    required this.second,
    required this.category,
  });
  final String first;
  final String second;
  final String category;
}

/// Difficulty tier for Matched Pairs sub-exercises. Mirrors the iOS
/// legacy "Auditory Hierarchy" grouping in ContentView.swift at
/// L4305 (Beginner → Level 1) and L4433 (Intermediate/Advanced → Level 2).
enum MatchedPairsTier {
  beginner('Level 1'),
  intermediateAdvanced('Level 2');

  const MatchedPairsTier(this.displayName);
  final String displayName;
}

/// Every Matched Pairs sub-exercise offered on the Auditory Hierarchy
/// chooser. Each entry points at a bundled CSV (stem only — the loader
/// in `CsvLoader.load` fills in the `.csv` suffix and the
/// `assets/csv/` prefix) and carries its own brand accent + icon so
/// the chooser tiles feel consistent with the home grid.
enum MatchedPairsSubcategory {
  syllables(
    'Different by Syllables',
    'Compare words with different syllable counts',
    MatchedPairsTier.beginner,
    'SyllablesData',
    Icons.format_size_rounded,
  ),
  phonetics(
    'Different Phonetics',
    'Common phonetically distinct pairs',
    MatchedPairsTier.beginner,
    'PDData',
    Icons.record_voice_over_rounded,
  ),
  vowels(
    'Different Vowels',
    'Contrasting vowel sounds',
    MatchedPairsTier.beginner,
    'Vowels',
    Icons.text_format_rounded,
  ),
  initialConsonants(
    'Different Initial Consonants',
    'Words that differ at the start',
    MatchedPairsTier.intermediateAdvanced,
    'Consonants',
    Icons.first_page_rounded,
  ),
  finalConsonants(
    'Final Consonants',
    'Words that differ at the end',
    MatchedPairsTier.intermediateAdvanced,
    'FinalConsonants',
    Icons.last_page_rounded,
  );

  const MatchedPairsSubcategory(
    this.displayName,
    this.description,
    this.tier,
    this.csvName,
    this.icon,
  );

  final String displayName;
  final String description;
  final MatchedPairsTier tier;
  final String csvName;
  final IconData icon;

  Color color(Brightness b) => switch (this) {
        MatchedPairsSubcategory.syllables => AppTheme.primaryBlue(b),
        MatchedPairsSubcategory.phonetics => AppTheme.primaryCyan(b),
        MatchedPairsSubcategory.vowels => AppTheme.success(b),
        MatchedPairsSubcategory.initialConsonants => AppTheme.accentOrange(b),
        MatchedPairsSubcategory.finalConsonants => AppColors.gradientPurple,
      };
}

/// Difficulty levels for Word Recognition. Mirrors the iOS legacy flow
/// where the closed-set is multiple-choice (four options per word) and
/// the open-set plays a word and asks the user to speak it back.
enum WordRecognitionLevel {
  closedSet(
    'Level 1',
    'Closed Set',
    'Listen and pick the word from four choices',
    Icons.checklist_rounded,
  ),
  openSet(
    'Level 2',
    'Open Set',
    'Listen and speak the word back',
    Icons.mic_rounded,
  ),
  wordsInNoise(
    'Level 3',
    'Words in Noise',
    'Speak each word back as the noise gets louder (WIN, SNR-50)',
    Icons.graphic_eq_rounded,
  );

  const WordRecognitionLevel(
    this.levelLabel,
    this.displayName,
    this.description,
    this.icon,
  );

  final String levelLabel;
  final String displayName;
  final String description;
  final IconData icon;

  Color color(Brightness b) => switch (this) {
        WordRecognitionLevel.closedSet => AppTheme.success(b),
        WordRecognitionLevel.openSet => AppColors.gradientPurple,
        WordRecognitionLevel.wordsInNoise => AppTheme.warning(b),
      };
}

/// Sentences in Noise levels. Level 1 is the existing fixed-noise
/// closed-set drill; Level 2 is the BKB-SIN-style adaptive open-set
/// drill that outputs an SNR-50 metric.
enum SentencesInNoiseLevel {
  fixedNoise(
    'Level 1',
    'Fixed Noise',
    'Pick the sentence you heard with adjustable background noise',
    Icons.checklist_rounded,
  ),
  adaptiveSnr50(
    'Level 2',
    'Adaptive SNR-50',
    'Speak each sentence back as the noise gets louder',
    Icons.trending_down_rounded,
  );

  const SentencesInNoiseLevel(
    this.levelLabel,
    this.displayName,
    this.description,
    this.icon,
  );

  final String levelLabel;
  final String displayName;
  final String description;
  final IconData icon;

  Color color(Brightness b) => switch (this) {
        SentencesInNoiseLevel.fixedNoise => AppTheme.success(b),
        SentencesInNoiseLevel.adaptiveSnr50 => AppColors.gradientPurple,
      };
}

/// One BKB-SIN-style sentence presented at a fixed SNR. The drill
/// schedules these in descending SNR order (+21 → 0 dB) and computes
/// SNR-50 from the total key words correct.
class AdaptiveSentenceItem {
  const AdaptiveSentenceItem({
    required this.sentence,
    required this.keyWords,
    required this.snrDb,
    required this.listId,
  });

  final String sentence;
  final int keyWords;
  final int snrDb;
  final String listId;
}

/// One Words-in-Noise (WIN) word presented at a fixed SNR. The drill
/// schedules them in 4-dB descending steps (+24 → 0 dB) with five
/// words per step.
class WordInNoiseItem {
  const WordInNoiseItem({
    required this.word,
    required this.snrDb,
    required this.listId,
  });

  final String word;
  final int snrDb;
  final String listId;
}

/// Open-set sentence with key-word annotation (AzBio paradigm).
class OpenSetSentenceItem {
  const OpenSetSentenceItem({
    required this.sentence,
    required this.keyWords,
    required this.listId,
  });

  final String sentence;
  final int keyWords;
  final String listId;
}

/// Difficulty levels for Sentence Comprehension. Progresses from
/// closed-set multiple choice (Level 1) through cloze / fill-in-the-blank
/// (Level 2) to full open-set speak-back (Level 3).
enum SentenceComprehensionLevel {
  closedSet(
    'Level 1',
    'Closed Set',
    'Listen to the sentence and pick the match from four choices',
    Icons.checklist_rounded,
  ),
  fillInTheBlank(
    'Level 2',
    'Fill in the Blank',
    'Listen, then type the missing word',
    Icons.edit_note_rounded,
  ),
  openSet(
    'Level 3',
    'Open Set',
    'Listen to the sentence and speak it back completely',
    Icons.mic_rounded,
  );

  const SentenceComprehensionLevel(
    this.levelLabel,
    this.displayName,
    this.description,
    this.icon,
  );

  final String levelLabel;
  final String displayName;
  final String description;
  final IconData icon;

  Color color(Brightness b) => switch (this) {
        SentenceComprehensionLevel.closedSet => AppTheme.success(b),
        SentenceComprehensionLevel.fillInTheBlank =>
          AppTheme.accentOrange(b),
        SentenceComprehensionLevel.openSet => AppColors.gradientPurple,
      };
}
