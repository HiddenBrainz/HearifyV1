import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted record of a single pronunciation attempt.
///
/// `target` / `heard` / `score` / `timestamp` are the original v1
/// fields that the gamification controller reads. The remaining fields
/// were added to power the audiologist clinical dashboard:
///
/// - [exerciseType] — stable runtime tag (see `ExerciseType` constants)
/// - [categoryTag]  — phoneme bucket (see `PhoneticCategory` constants)
/// - [snrDb]        — SNR for noise tests (BKB-SIN, WIN, Sentences in Noise)
/// - [responseTimeMs] — tap latency from prompt-finish to response
/// - [wrongChoice]  — the distractor the patient picked when score==0
///                    in a closed-set multiple-choice exercise
///
/// All five new fields are optional so existing 200-attempt logs on
/// disk continue to deserialize cleanly. Forward-only: old records
/// still appear in patient streak/level math, but contribute no data
/// to the new clinical charts (they have null buckets and get filtered
/// out at chart-build time).
class PracticeAttempt {
  const PracticeAttempt({
    required this.target,
    required this.heard,
    required this.score,
    required this.timestamp,
    this.exerciseType,
    this.categoryTag,
    this.snrDb,
    this.responseTimeMs,
    this.wrongChoice,
  });

  final String target;
  final String heard;
  final double score;
  final DateTime timestamp;

  // Optional clinical-dashboard fields. Null on records logged before
  // the schema upgrade.
  final String? exerciseType;
  final String? categoryTag;
  final double? snrDb;
  final int? responseTimeMs;
  final String? wrongChoice;

  Map<String, dynamic> toJson() => {
        'target': target,
        'heard': heard,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
        if (exerciseType != null) 'exerciseType': exerciseType,
        if (categoryTag != null) 'categoryTag': categoryTag,
        if (snrDb != null) 'snrDb': snrDb,
        if (responseTimeMs != null) 'responseTimeMs': responseTimeMs,
        if (wrongChoice != null) 'wrongChoice': wrongChoice,
      };

  factory PracticeAttempt.fromJson(Map<String, dynamic> j) => PracticeAttempt(
        target: j['target'] as String,
        heard: j['heard'] as String,
        score: (j['score'] as num).toDouble(),
        timestamp: DateTime.parse(j['timestamp'] as String),
        exerciseType: j['exerciseType'] as String?,
        categoryTag: j['categoryTag'] as String?,
        snrDb: (j['snrDb'] as num?)?.toDouble(),
        responseTimeMs: (j['responseTimeMs'] as num?)?.toInt(),
        wrongChoice: j['wrongChoice'] as String?,
      );
}

class PracticeHistoryController extends StateNotifier<List<PracticeAttempt>> {
  PracticeHistoryController() : super(const []) {
    _load();
  }

  static const _key = 'practiceHistory.v1';
  static const _limit = 200;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(PracticeAttempt.fromJson)
          .toList();
      state = list;
    } catch (_) {/* leave empty */}
  }

  Future<void> add(PracticeAttempt a) async {
    final next = [a, ...state];
    state = next.length > _limit ? next.sublist(0, _limit) : next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final practiceHistoryProvider =
    StateNotifierProvider<PracticeHistoryController, List<PracticeAttempt>>(
        (ref) => PracticeHistoryController());

/// Helpers used by the patient-facing "weakest sound" callout. Operate
/// on the in-memory list (already capped at 200 entries).
extension PracticeHistoryAggregates on List<PracticeAttempt> {
  /// Returns category → (correct, total) sums for entries that have a
  /// `categoryTag`. Old (untagged) attempts and attempts in
  /// non-phoneme buckets (sentence/noise/etc.) are filtered out by
  /// passing `keepOnly`.
  Map<String, ({int correct, int total})> accuracyByCategory({
    Set<String>? keepOnly,
  }) {
    final out = <String, ({int correct, int total})>{};
    for (final a in this) {
      final tag = a.categoryTag;
      if (tag == null) continue;
      if (keepOnly != null && !keepOnly.contains(tag)) continue;
      final cur = out[tag] ?? (correct: 0, total: 0);
      out[tag] = (
        correct: cur.correct + (a.score >= 0.5 ? 1 : 0),
        total: cur.total + 1,
      );
    }
    return out;
  }
}
