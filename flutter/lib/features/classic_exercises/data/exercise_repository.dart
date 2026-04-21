import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/csv_loader.dart';
import '../domain/classic_exercise.dart';

/// Loads classic-exercise content from bundled CSVs (schemas documented in
/// HearifyV1/DATA_FILES_GUIDE.md). Shapes rows into the Dart domain models.
class ExerciseRepository {
  ExerciseRepository();

  /// `word,choice1,choice2,choice3,choice4,category` — first row is header.
  Future<List<MultipleChoiceItem>> loadWordRecognition() async {
    final rows = await CsvLoader.load('WordRecognitionData');
    return _parseMultipleChoice(rows, type: 'word');
  }

  /// Same schema as word recognition but sentences.
  Future<List<MultipleChoiceItem>> loadSentenceComprehension() async {
    final rows = await CsvLoader.load('SentenceComprehensionData');
    return _parseMultipleChoice(rows, type: 'sentence');
  }

  Future<List<MultipleChoiceItem>> loadSentencesInNoise() async {
    final rows = await CsvLoader.load('SentencesInNoiseData');
    return _parseMultipleChoice(rows, type: 'sentence');
  }

  /// `content,type,difficulty,choice1,choice2,choice3,choice4` — mixed.
  Future<List<MultipleChoiceItem>> loadDiagnosticTest() async {
    final rows = await CsvLoader.load('DiagnosticTestData');
    final out = <MultipleChoiceItem>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (i == 0 && r.isNotEmpty && r.first.toLowerCase() == 'content') continue;
      if (r.length < 7) continue;
      out.add(MultipleChoiceItem(
        prompt: r[0],
        type: r[1],
        difficulty: r[2],
        correctAnswer: r[3],
        choices: r.sublist(3, 7),
      ));
    }
    return out;
  }

  /// `firstWord,lastWord,category` — used by the matched-pairs listening
  /// discrimination drill.
  Future<List<MatchedPair>> loadMatchedPairs() async {
    final rows = await CsvLoader.load('MatchedPairsData');
    return _parseMatchedPairRows(rows);
  }

  /// Loads the CSV bundled for [sub]. Mirrors the iOS
  /// `auditoryHierarchyScreenContent` dispatch in ContentView.swift.
  Future<List<MatchedPair>> loadMatchedPairsFor(
    MatchedPairsSubcategory sub,
  ) async {
    final rows = await CsvLoader.load(sub.csvName);
    return _parseMatchedPairRows(rows);
  }

  List<MatchedPair> _parseMatchedPairRows(List<List<String>> rows) {
    final out = <MatchedPair>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (i == 0 &&
          r.length >= 2 &&
          r[0].toLowerCase().contains('first') &&
          r[1].toLowerCase().contains('last')) {
        continue;
      }
      if (r.length < 2) continue;
      out.add(MatchedPair(
        first: r[0],
        second: r[1],
        category: r.length > 2 ? r[2] : 'general',
      ));
    }
    return out;
  }

  List<MultipleChoiceItem> _parseMultipleChoice(
    List<List<String>> rows, {
    required String type,
  }) {
    final out = <MultipleChoiceItem>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      // Skip header row (heuristic: first column is "word" or "sentence")
      if (i == 0 &&
          r.isNotEmpty &&
          ['word', 'sentence'].contains(r.first.toLowerCase())) {
        continue;
      }
      if (r.length < 5) continue;
      out.add(MultipleChoiceItem(
        prompt: r[0],
        correctAnswer: r[1],
        choices: r.sublist(1, 5),
        type: type,
      ));
    }
    return out;
  }
}

final exerciseRepositoryProvider =
    Provider<ExerciseRepository>((ref) => ExerciseRepository());
