/// Phonetic taxonomy for the new clinical metrics.
///
/// Each `PracticeAttempt` carries an optional `categoryTag` (a stable
/// string like `'finalConsonant'`) so the dashboard can group misses
/// into clinically meaningful buckets — initial vs final consonants,
/// vowels, place of articulation, syllable count, etc.
///
/// The taxonomy is deliberately small in v1: just the buckets we can
/// derive cleanly from the existing matched-pair CSVs without doing
/// per-pair IPA feature extraction. Voicing/manner sub-buckets can be
/// added later by parsing the (target, heard) word forms.
library;

import '../../features/classic_exercises/domain/classic_exercise.dart';

/// Category bucket strings stored on `PracticeAttempt.categoryTag` and
/// rolled up into per-session aggregates. Keep these stable — they end
/// up as Firestore document keys.
class PhoneticCategory {
  PhoneticCategory._();

  static const String initialConsonant = 'initialConsonant';
  static const String finalConsonant = 'finalConsonant';
  static const String vowel = 'vowel';
  static const String place = 'place';
  static const String syllableCount = 'syllableCount';

  /// Sentence-level buckets — used by Word/Sentence Comprehension and
  /// the noise tests. Not part of the phoneme heatmap, but the rolling
  /// accuracy + SNR-50 trend charts pull on them.
  static const String sentenceQuiet = 'sentenceQuiet';
  static const String sentenceNoise = 'sentenceNoise';
  static const String wordQuiet = 'wordQuiet';
  static const String wordNoise = 'wordNoise';
  static const String diagnostic = 'diagnostic';
  static const String customPractice = 'customPractice';

  /// Buckets that show up in the clinician's phoneme heatmap. The bar
  /// chart iterates this list in display order; missing categories
  /// render as a faded "no data" bar.
  static const List<String> heatmapOrder = [
    initialConsonant,
    finalConsonant,
    vowel,
    place,
    syllableCount,
  ];

  /// Human-readable label for a category tag — used as bar labels and
  /// in copy throughout the dashboards.
  static String displayName(String tag) {
    switch (tag) {
      case initialConsonant:
        return 'Initial Consonants';
      case finalConsonant:
        return 'Final Consonants';
      case vowel:
        return 'Vowels';
      case place:
        return 'Place of Articulation';
      case syllableCount:
        return 'Syllable Count';
      case sentenceQuiet:
        return 'Sentences in Quiet';
      case sentenceNoise:
        return 'Sentences in Noise';
      case wordQuiet:
        return 'Words in Quiet';
      case wordNoise:
        return 'Words in Noise';
      case diagnostic:
        return 'Diagnostic';
      case customPractice:
        return 'Custom Practice';
      default:
        return tag;
    }
  }

  /// Short tag used on cards / chips when space is tight.
  static String shortName(String tag) {
    switch (tag) {
      case initialConsonant:
        return 'Initial';
      case finalConsonant:
        return 'Final';
      case vowel:
        return 'Vowel';
      case place:
        return 'Place';
      case syllableCount:
        return 'Syllables';
      default:
        return displayName(tag);
    }
  }
}

/// Stable identifiers for the runtime exercise type. Stored on
/// `PracticeAttempt.exerciseType` and on the per-session Firestore
/// aggregate's `exerciseType` field.
class ExerciseType {
  ExerciseType._();

  static const String wordRecognition = 'wordRecognition';
  static const String sentenceComprehension = 'sentenceComprehension';
  static const String sentencesInNoise = 'sentencesInNoise';
  static const String diagnosticTest = 'diagnosticTest';
  static const String wordsInNoise = 'wordsInNoise';
  static const String bkbSin = 'bkbSin';
  static const String matchedPairs = 'matchedPairs';
  static const String customPractice = 'customPractice';

  /// Display label for the audiologist's session list.
  static String displayName(String tag) {
    switch (tag) {
      case wordRecognition:
        return 'Word Recognition';
      case sentenceComprehension:
        return 'Sentence Comprehension';
      case sentencesInNoise:
        return 'Sentences in Noise';
      case diagnosticTest:
        return 'Diagnostic Test';
      case wordsInNoise:
        return 'Words in Noise';
      case bkbSin:
        return 'BKB-SIN';
      case matchedPairs:
        return 'Matched Pairs';
      case customPractice:
        return 'Custom Practice';
      default:
        return tag;
    }
  }
}

/// Maps a `MatchedPairsSubcategory` (each tied to a single CSV) onto
/// the canonical phoneme bucket the misses should land in. Used by
/// `matched_pairs_screen.dart` when it builds a `PracticeAttempt`.
String matchedPairsCategoryTag(MatchedPairsSubcategory s) {
  switch (s) {
    case MatchedPairsSubcategory.syllables:
      return PhoneticCategory.syllableCount;
    case MatchedPairsSubcategory.phonetics:
      // PDData.csv emphasizes place-of-articulation contrasts.
      return PhoneticCategory.place;
    case MatchedPairsSubcategory.vowels:
      return PhoneticCategory.vowel;
    case MatchedPairsSubcategory.initialConsonants:
      return PhoneticCategory.initialConsonant;
    case MatchedPairsSubcategory.finalConsonants:
      return PhoneticCategory.finalConsonant;
  }
}

/// Maps a `ClassicExerciseCategory` (the home-grid tile that launched a
/// multiple-choice session) onto a phoneme bucket. Sentence and
/// noise-mode exercises don't sit on the phoneme heatmap, so they
/// get their own sentence/noise tags.
String classicExerciseCategoryTag(ClassicExerciseCategory c) {
  switch (c) {
    case ClassicExerciseCategory.wordRecognition:
      return PhoneticCategory.wordQuiet;
    case ClassicExerciseCategory.sentenceComprehension:
      return PhoneticCategory.sentenceQuiet;
    case ClassicExerciseCategory.sentencesInNoise:
      return PhoneticCategory.sentenceNoise;
    case ClassicExerciseCategory.diagnosticTest:
      return PhoneticCategory.diagnostic;
    case ClassicExerciseCategory.matchedPairs:
      // Caller should use `matchedPairsCategoryTag` instead — this is a
      // safe fallback if the matched-pairs runner ever loses its
      // subcategory context.
      return PhoneticCategory.initialConsonant;
    case ClassicExerciseCategory.customPractice:
      return PhoneticCategory.customPractice;
  }
}

/// Maps the same `ClassicExerciseCategory` onto the runtime
/// `ExerciseType` tag that gets written to the Firestore session doc.
String classicExerciseExerciseType(ClassicExerciseCategory c) {
  switch (c) {
    case ClassicExerciseCategory.wordRecognition:
      return ExerciseType.wordRecognition;
    case ClassicExerciseCategory.sentenceComprehension:
      return ExerciseType.sentenceComprehension;
    case ClassicExerciseCategory.sentencesInNoise:
      return ExerciseType.sentencesInNoise;
    case ClassicExerciseCategory.diagnosticTest:
      return ExerciseType.diagnosticTest;
    case ClassicExerciseCategory.matchedPairs:
      return ExerciseType.matchedPairs;
    case ClassicExerciseCategory.customPractice:
      return ExerciseType.customPractice;
  }
}
