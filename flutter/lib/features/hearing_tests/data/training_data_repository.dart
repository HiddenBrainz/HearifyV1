import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/csv_loader.dart';
import '../../onboarding/data/hearing_profile_controller.dart';

/// Port of HearifyV1/Managers/TrainingDataManager.swift.
/// Reads the training CSVs bundled under `assets/csv/` and projects rows to
/// `TrainingSentence`. Pure static data — no network.
class TrainingSentence {
  const TrainingSentence({
    required this.text,
    required this.difficulty,
    required this.category,
  });
  final String text;
  final String difficulty;
  final String category;
}

class TrainingDataRepository {
  TrainingDataRepository();

  static const _files = {
    TrainingModuleType.hearingLoss: 'HearingLossTrainingData',
    TrainingModuleType.hearingAids: 'HearingAidsTrainingData',
    TrainingModuleType.cochlearImplants: 'CochlearImplantsTrainingData',
  };

  final Map<TrainingModuleType, List<TrainingSentence>> _cache = {};

  Future<List<TrainingSentence>> load(TrainingModuleType type) async {
    final cached = _cache[type];
    if (cached != null) return cached;
    final file = _files[type]!;
    final rows = await CsvLoader.load(file);
    final sentences = <TrainingSentence>[];
    for (final row in rows) {
      if (row.isEmpty) continue;
      final text = row[0];
      if (text.isEmpty) continue;
      final difficulty = row.length > 1 ? row[1] : 'Medium';
      final category = row.length > 2 ? row[2] : 'General';
      sentences.add(TrainingSentence(
        text: text,
        difficulty: difficulty,
        category: category,
      ));
    }
    _cache[type] = sentences;
    return sentences;
  }

  Future<List<TrainingSentence>> filter({
    required TrainingModuleType type,
    String? difficulty,
  }) async {
    final all = await load(type);
    if (difficulty == null) return all;
    return all
        .where((s) => s.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }
}

final trainingDataRepositoryProvider = Provider((ref) => TrainingDataRepository());
