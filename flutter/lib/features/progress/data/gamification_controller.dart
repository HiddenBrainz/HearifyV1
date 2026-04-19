import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/data/practice_history.dart';

/// Slim port of HearifyV1/Managers/GamificationManager.swift. Tracks
/// streak, level, total XP, and simple counters. The Swift version also
/// computes badges/achievements; we expose a similar derived list below.
class GamificationState {
  const GamificationState({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXP,
    required this.level,
    required this.perfectScores,
    required this.totalAttempts,
    required this.lastPracticeDate,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalXP;
  final int level;
  final int perfectScores;
  final int totalAttempts;
  final DateTime? lastPracticeDate;

  static const empty = GamificationState(
    currentStreak: 0,
    longestStreak: 0,
    totalXP: 0,
    level: 1,
    perfectScores: 0,
    totalAttempts: 0,
    lastPracticeDate: null,
  );

  /// 100 XP per level — matches HearifyV1 defaults.
  int get xpTowardNextLevel => totalXP % 100;
  double get progressToNext => xpTowardNextLevel / 100.0;

  GamificationState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalXP,
    int? level,
    int? perfectScores,
    int? totalAttempts,
    DateTime? lastPracticeDate,
    bool clearLastPractice = false,
  }) =>
      GamificationState(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        totalXP: totalXP ?? this.totalXP,
        level: level ?? this.level,
        perfectScores: perfectScores ?? this.perfectScores,
        totalAttempts: totalAttempts ?? this.totalAttempts,
        lastPracticeDate:
            clearLastPractice ? null : (lastPracticeDate ?? this.lastPracticeDate),
      );

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalXP': totalXP,
        'level': level,
        'perfectScores': perfectScores,
        'totalAttempts': totalAttempts,
        'lastPracticeDate': lastPracticeDate?.toIso8601String(),
      };

  factory GamificationState.fromJson(Map<String, dynamic> j) => GamificationState(
        currentStreak: j['currentStreak'] as int? ?? 0,
        longestStreak: j['longestStreak'] as int? ?? 0,
        totalXP: j['totalXP'] as int? ?? 0,
        level: j['level'] as int? ?? 1,
        perfectScores: j['perfectScores'] as int? ?? 0,
        totalAttempts: j['totalAttempts'] as int? ?? 0,
        lastPracticeDate: j['lastPracticeDate'] == null
            ? null
            : DateTime.parse(j['lastPracticeDate'] as String),
      );
}

class GamificationController extends StateNotifier<GamificationState> {
  GamificationController(this._ref) : super(GamificationState.empty) {
    _load();
    // Recompute when practice history updates so stats stay in sync.
    _ref.listen<List<PracticeAttempt>>(
        practiceHistoryProvider, (_, n) => _recomputeFromHistory(n));
  }

  final Ref _ref;
  static const _key = 'gamification.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      _recomputeFromHistory(_ref.read(practiceHistoryProvider));
      return;
    }
    try {
      state = GamificationState.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {/* fall through */}
    _recomputeFromHistory(_ref.read(practiceHistoryProvider));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  /// Rebuilds gamification state from the full attempt log so that adding
  /// history through any code path (speaking, classic exercises, etc.)
  /// yields consistent stats without every caller having to remember to
  /// poke gamification.
  void _recomputeFromHistory(List<PracticeAttempt> attempts) {
    if (attempts.isEmpty) {
      state = GamificationState.empty;
      _persist();
      return;
    }
    final total = attempts.length;
    final perfect = attempts.where((a) => a.score >= 0.99).length;
    // XP: 10 for an attempt, +20 bonus for perfect.
    final xp =
        attempts.fold<int>(0, (v, a) => v + 10 + (a.score >= 0.99 ? 20 : 0));
    final level = 1 + xp ~/ 100;

    // Streak: consecutive distinct days with at least one attempt up to today.
    final daysWithPractice = {
      for (final a in attempts)
        DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day),
    };
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    int streak = 0;
    var cursor = todayDay;
    while (daysWithPractice.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    final longest =
        streak > state.longestStreak ? streak : state.longestStreak;
    final last = attempts.first.timestamp;
    state = GamificationState(
      currentStreak: streak,
      longestStreak: longest,
      totalXP: xp,
      level: level,
      perfectScores: perfect,
      totalAttempts: total,
      lastPracticeDate: last,
    );
    _persist();
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationController, GamificationState>((ref) {
  return GamificationController(ref);
});

/// Simple achievement DTO derived from state.
class Achievement {
  const Achievement(this.title, this.description, this.earned);
  final String title;
  final String description;
  final bool earned;
}

List<Achievement> deriveAchievements(GamificationState s) => [
      Achievement('First Steps',
          'Complete your first practice attempt', s.totalAttempts >= 1),
      Achievement('Getting Warm', 'Reach a 3-day streak', s.currentStreak >= 3),
      Achievement('On a Roll', 'Reach a 7-day streak', s.currentStreak >= 7),
      Achievement('Perfectionist', 'Get 10 perfect scores', s.perfectScores >= 10),
      Achievement('Dedicated Learner',
          'Reach level 5', s.level >= 5),
      Achievement('Century Club', 'Complete 100 attempts', s.totalAttempts >= 100),
    ];
