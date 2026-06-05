import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../shared/data/practice_history.dart';
import '../../auth/data/auth_controller.dart';

/// Writes a per-session record into Firestore at session close.
///
/// Two tiers in a single atomic batch:
///
/// **Tier 1 — `/sessions/{auto-id}`**: aggregate that the audiologist
/// dashboard reads in bulk. SNR-50, byCategory, topConfusions,
/// avgResponseTimeMs, accuracy, duration. ~one read per chart.
///
/// **Tier 2 — `/sessions/{auto-id}/attempts/{n}`**: per-attempt
/// detail (target, heard, score, snrDb, responseTimeMs, wrongChoice,
/// timestamp, position-in-session). The audiologist drill-down view
/// loads these on demand for one specific session at a time, so the
/// hot dashboard path never reads them.
///
/// Both are committed in one `WriteBatch` so the dashboard never sees
/// an aggregate without its underlying attempts (or vice-versa).
/// Firestore allows up to 500 ops per batch; a clinical session is
/// rarely more than ~30 items, so we have plenty of headroom.
class SessionWriter {
  SessionWriter(this._ref);

  final Ref _ref;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Builds the aggregate + attempt subcollection writes and commits
  /// them atomically. Silent no-op when the user is signed out,
  /// Firebase isn't initialized, or the attempt list is empty —
  /// failures are logged and swallowed so they never block the
  /// session-summary dialog.
  Future<void> writeSession({
    required String exerciseType,
    required List<PracticeAttempt> attempts,
    required Duration duration,
    double? backgroundNoiseLevel,
    double? snr50,
  }) async {
    if (attempts.isEmpty) return;
    if (!FirebaseBootstrap.initialized) return;
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn || auth.uid == null) return;
    if (auth.role != UserRole.patient) return;

    try {
      final aggregate = _aggregate(attempts);
      final sessionRef = _db.collection('sessions').doc(); // pre-allocated id
      final batch = _db.batch();

      // Tier 1: dashboard aggregate.
      batch.set(sessionRef, {
        'patientUID': auth.uid,
        'sessionDate': Timestamp.now(),
        'exerciseType': exerciseType,
        'duration': duration.inSeconds.toDouble(),
        'itemsAttempted': attempts.length,
        'itemsCorrect': aggregate.itemsCorrect,
        'accuracy': aggregate.accuracy,
        'backgroundNoiseLevel': backgroundNoiseLevel ?? 0.0,
        if (snr50 != null) 'snr50': snr50,
        if (aggregate.byCategory.isNotEmpty)
          'byCategory': {
            for (final entry in aggregate.byCategory.entries)
              entry.key: {
                'n': entry.value.total,
                'correct': entry.value.correct,
              },
          },
        if (aggregate.topConfusions.isNotEmpty)
          'topConfusions': [
            for (final c in aggregate.topConfusions)
              {'target': c.target, 'heard': c.heard, 'count': c.count},
          ],
        if (aggregate.avgResponseTimeMs != null)
          'avgResponseTimeMs': aggregate.avgResponseTimeMs,
      });

      // Tier 2: per-attempt drill-down detail. Doc id = position in
      // session padded for natural ordering ('000', '001', …).
      for (var i = 0; i < attempts.length; i++) {
        final a = attempts[i];
        final attemptRef = sessionRef
            .collection('attempts')
            .doc(i.toString().padLeft(3, '0'));
        batch.set(attemptRef, {
          'index': i,
          'patientUID': auth.uid, // duplicated for collection-group queries
          'target': a.target,
          'heard': a.heard,
          'score': a.score,
          'correct': a.score >= 0.5,
          'timestamp': Timestamp.fromDate(a.timestamp),
          if (a.exerciseType != null) 'exerciseType': a.exerciseType,
          if (a.categoryTag != null) 'categoryTag': a.categoryTag,
          if (a.snrDb != null) 'snrDb': a.snrDb,
          if (a.responseTimeMs != null) 'responseTimeMs': a.responseTimeMs,
          if (a.wrongChoice != null) 'wrongChoice': a.wrongChoice,
        });
      }

      await batch.commit();
    } catch (e) {
      // Networking issue, rules denial, or schema mismatch — log and
      // move on. The session summary still shows on-device.
      if (kDebugMode) debugPrint('[SessionWriter] write failed: $e');
    }
  }

  _SessionAggregate _aggregate(List<PracticeAttempt> attempts) {
    var itemsCorrect = 0;
    final byCategory = <String, _Counter>{};
    final confusions = <String, int>{};
    var rtSum = 0;
    var rtCount = 0;

    for (final a in attempts) {
      final correct = a.score >= 0.5;
      if (correct) itemsCorrect++;

      final tag = a.categoryTag;
      if (tag != null) {
        final c = byCategory[tag] ?? _Counter();
        c.total++;
        if (correct) c.correct++;
        byCategory[tag] = c;
      }

      if (!correct) {
        // Use the actual user response (heard) — for closed-set MC
        // wrongChoice is the same string but it's nice to keep the
        // fallback for adaptive flows that don't fill that field.
        final heard = (a.wrongChoice?.isNotEmpty ?? false)
            ? a.wrongChoice!
            : a.heard;
        if (heard.trim().isNotEmpty && heard != a.target) {
          final key = '${a.target}|||$heard';
          confusions[key] = (confusions[key] ?? 0) + 1;
        }
      }

      final rt = a.responseTimeMs;
      if (rt != null && rt > 0) {
        rtSum += rt;
        rtCount++;
      }
    }

    // Top 5 confusions, descending by count.
    final topPairs = confusions.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    final top = topPairs.take(5).map((e) {
      final parts = e.key.split('|||');
      return (target: parts[0], heard: parts[1], count: e.value);
    }).toList();

    return _SessionAggregate(
      itemsCorrect: itemsCorrect,
      accuracy: attempts.isEmpty ? 0 : itemsCorrect / attempts.length,
      byCategory: {
        for (final entry in byCategory.entries)
          entry.key: (correct: entry.value.correct, total: entry.value.total),
      },
      topConfusions: top,
      avgResponseTimeMs: rtCount == 0 ? null : (rtSum / rtCount).round(),
    );
  }
}

class _Counter {
  int correct = 0;
  int total = 0;
}

class _SessionAggregate {
  _SessionAggregate({
    required this.itemsCorrect,
    required this.accuracy,
    required this.byCategory,
    required this.topConfusions,
    required this.avgResponseTimeMs,
  });

  final int itemsCorrect;
  final double accuracy;
  final Map<String, ({int correct, int total})> byCategory;
  final List<({String target, String heard, int count})> topConfusions;
  final int? avgResponseTimeMs;
}

final sessionWriterProvider = Provider<SessionWriter>(SessionWriter.new);
