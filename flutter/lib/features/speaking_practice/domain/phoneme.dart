import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Port of HearifyV1/Models/PhonemeVisual.swift + ArticulationModels.swift
/// (the enums needed to categorize phonemes). The Swift file defines many
/// more display helpers; this Dart port captures the subset used by the
/// ported screens.
enum PhonemeCategory {
  stops('Stops'),
  fricatives('Fricatives'),
  affricates('Affricates'),
  nasals('Nasals'),
  liquids('Liquids'),
  glides('Glides'),
  frontVowels('Front Vowels'),
  backVowels('Back Vowels'),
  centralVowels('Central Vowels'),
  diphthongs('Diphthongs');

  const PhonemeCategory(this.displayName);
  final String displayName;

  Color color(Brightness b) => switch (this) {
        PhonemeCategory.stops => AppTheme.primaryBlue(b),
        PhonemeCategory.fricatives => AppTheme.accentOrange(b),
        PhonemeCategory.affricates => AppTheme.accentPurple(b),
        PhonemeCategory.nasals => AppTheme.success(b),
        PhonemeCategory.liquids => AppTheme.primaryCyan(b),
        PhonemeCategory.glides => AppTheme.warning(b),
        PhonemeCategory.frontVowels => AppTheme.primaryBlue(b),
        PhonemeCategory.backVowels => AppTheme.accentPurple(b),
        PhonemeCategory.centralVowels => AppTheme.accentOrange(b),
        PhonemeCategory.diphthongs => AppTheme.success(b),
      };

  bool get isVowel => {
        PhonemeCategory.frontVowels,
        PhonemeCategory.backVowels,
        PhonemeCategory.centralVowels,
        PhonemeCategory.diphthongs,
      }.contains(this);
}

enum Voicing { voiced, voiceless }

enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const Difficulty(this.displayName);
  final String displayName;
}

class Phoneme {
  const Phoneme({
    required this.symbol,
    required this.name,
    required this.examples,
    required this.category,
    required this.voicing,
    required this.difficulty,
    this.description = '',
  });

  final String symbol;
  final String name;
  final List<String> examples;
  final PhonemeCategory category;
  final Voicing voicing;
  final Difficulty difficulty;
  final String description;

  String get displayName => '$symbol — $name';
  String get examplesString => examples.join(', ');
}

/// Phoneme pair used by the targeted practice's "distinguish these two
/// sounds" mini-drill. From PhonemeDatabase.getComparisonPairs().
class PhonemePair {
  const PhonemePair({
    required this.a,
    required this.b,
    required this.title,
    required this.description,
  });

  final Phoneme a;
  final Phoneme b;
  final String title;
  final String description;
}
