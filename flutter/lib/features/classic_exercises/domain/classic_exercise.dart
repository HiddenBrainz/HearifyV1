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
