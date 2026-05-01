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

  /// BKB-SIN sentences with key-word counts and per-item SNR.
  /// Schema: `sentence,keyWords,snrDb,listId` (header row).
  Future<Map<String, List<AdaptiveSentenceItem>>> loadBkbSinByList() async {
    final rows = await CsvLoader.load('BKBSINData');
    final groups = <String, List<AdaptiveSentenceItem>>{};
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (i == 0 &&
          r.isNotEmpty &&
          r.first.toLowerCase() == 'sentence') {
        continue;
      }
      if (r.length < 4) continue;
      final item = AdaptiveSentenceItem(
        sentence: r[0],
        keyWords: int.tryParse(r[1]) ?? 0,
        snrDb: int.tryParse(r[2]) ?? 0,
        listId: r[3],
      );
      groups.putIfAbsent(item.listId, () => []).add(item);
    }
    // Sort each list by descending SNR so the session plays from
    // easiest to hardest.
    for (final list in groups.values) {
      list.sort((a, b) => b.snrDb.compareTo(a.snrDb));
    }
    return groups;
  }

  /// Words-in-Noise items grouped by list.
  /// Schema: `word,snrDb,listId` (header row).
  Future<Map<String, List<WordInNoiseItem>>> loadWinByList() async {
    final rows = await CsvLoader.load('WINData');
    final groups = <String, List<WordInNoiseItem>>{};
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (i == 0 &&
          r.isNotEmpty &&
          r.first.toLowerCase() == 'word') {
        continue;
      }
      if (r.length < 3) continue;
      final item = WordInNoiseItem(
        word: r[0],
        snrDb: int.tryParse(r[1]) ?? 0,
        listId: r[2],
      );
      groups.putIfAbsent(item.listId, () => []).add(item);
    }
    for (final list in groups.values) {
      list.sort((a, b) => b.snrDb.compareTo(a.snrDb));
    }
    return groups;
  }

  /// AzBio sentences grouped by list. Schema:
  /// `sentence,keyWords,listId` (header row).
  Future<Map<String, List<OpenSetSentenceItem>>> loadAzBioByList() async {
    final rows = await CsvLoader.load('AzBioData');
    final groups = <String, List<OpenSetSentenceItem>>{};
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (i == 0 &&
          r.isNotEmpty &&
          r.first.toLowerCase() == 'sentence') {
        continue;
      }
      if (r.length < 3) continue;
      final item = OpenSetSentenceItem(
        sentence: r[0],
        keyWords: int.tryParse(r[1]) ?? 0,
        listId: r[2],
      );
      groups.putIfAbsent(item.listId, () => []).add(item);
    }
    return groups;
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
