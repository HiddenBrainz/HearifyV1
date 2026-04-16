import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted record of a single pronunciation attempt.
/// Simplified from HearifyV1's `UserPracticeSession` — enough to power
/// RecordingHistoryView. Full session analytics are a Phase 6 concern.
class PracticeAttempt {
  const PracticeAttempt({
    required this.target,
    required this.heard,
    required this.score,
    required this.timestamp,
  });

  final String target;
  final String heard;
  final double score;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'target': target,
        'heard': heard,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PracticeAttempt.fromJson(Map<String, dynamic> j) => PracticeAttempt(
        target: j['target'] as String,
        heard: j['heard'] as String,
        score: (j['score'] as num).toDouble(),
        timestamp: DateTime.parse(j['timestamp'] as String),
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
