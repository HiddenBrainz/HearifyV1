import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/auth_controller.dart';

/// Cross-platform rewrite of HearifyV1/Managers/CloudKitManager.swift on
/// Firestore. CloudKit isn't available on Android, so this replaces the
/// linking-code handshake with a Firestore collection at
/// `/linkingCodes/{code}` pointing to a patient UID, and
/// `/clinicians/{uid}/patients/{patientUid}` for the clinician-side roster.
///
/// Security rules (documented here for ops — apply them in Firebase console):
/// - anyone authenticated can create a linking code for their own UID
/// - anyone authenticated can read a linking code by its 6-digit ID (so the
///   clinician can consume it) but only the clinician who linked can list
///   their own patients subcollection
class ClinicianRepository {
  ClinicianRepository(this._ref);
  final Ref _ref;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Generates a new 6-digit code and writes it to `/linkingCodes/{code}`.
  /// The document expires 24 hours after creation (Firestore TTL rule).
  Future<String> generateLinkingCode() async {
    _requireFirebase();
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn) throw StateError('Sign in required');
    final code = (100000 + math.Random().nextInt(900000)).toString();
    await _db.collection('linkingCodes').doc(code).set({
      'code': code,
      'patientUID': auth.uid,
      'createdDate': Timestamp.now(),
      'expiryDate':
          Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
      'isUsed': false,
    });
    return code;
  }

  /// Reads a linking code by ID. Returns the patient UID, or null if the
  /// code is missing / expired.
  Future<String?> resolveLinkingCode(String code) async {
    _requireFirebase();
    final doc = await _db.collection('linkingCodes').doc(code).get();
    final data = doc.data();
    if (data == null) return null;
    final expiry = (data['expiryDate'] as Timestamp?)?.toDate();
    if (expiry != null && expiry.isBefore(DateTime.now())) return null;
    return data['patientUID'] as String?;
  }

  /// As a clinician, consume a linking code: add the patient UID to my
  /// `linkedPatients` array and mark the code as used. Schema matches
  /// HearifyPro/Managers/FirebaseClinicianManager.swift + the deployed
  /// Firestore rules, which check `linkedPatients.hasAny([uid])` to
  /// authorize patient-data reads.
  ///
  /// We deliberately do NOT use a batch here — Firestore returns one
  /// `permission-denied` for the whole batch when any single write is
  /// rejected, so a batch hides which document the rules blocked.
  /// Splitting the writes into two awaited calls gives us a clear
  /// error path the UI can show ("can't update linkingCodes/{code} —
  /// check the deployed Firestore rules"), and leaves the clinician's
  /// `linkedPatients` clean if the linkingCodes update fails.
  Future<void> linkPatient({required String code}) async {
    _requireFirebase();
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn) throw StateError('Sign in required');
    final patientUid = await resolveLinkingCode(code);
    if (patientUid == null) throw StateError('Code invalid or expired');

    // Step 1: mark the code consumed so it can't be redeemed again.
    // Rules expect this update to set `clinicianUID == request.auth.uid`.
    try {
      await _db.collection('linkingCodes').doc(code).update({
        'isUsed': true,
        'clinicianUID': auth.uid,
        'usedDate': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw StateError(
          'Firestore denied the linkingCodes/$code update. The deployed '
          'rules need: allow update when request.auth.uid != null and '
          'request.resource.data.clinicianUID == request.auth.uid. '
          'Update via firebase deploy --only firestore:rules.',
        );
      }
      rethrow;
    }

    // Step 2: add the patient to my `linkedPatients` array. `set(...,
    // merge: true)` so first-time clinicians whose doc was created by
    // a slightly older signup path still succeed.
    try {
      await _db.collection('clinicians').doc(auth.uid).set({
        'linkedPatients': FieldValue.arrayUnion([patientUid]),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw StateError(
          'Firestore denied the clinicians/${auth.uid} update. The '
          'rules need: allow write on clinicians/{uid} when '
          'request.auth.uid == uid.',
        );
      }
      rethrow;
    }
  }

  /// Fetches a single patient's full profile, blending the raw Firestore
  /// fields with the derived improvement deltas the detail screen needs.
  Future<PatientProfile?> fetchPatientProfile(String uid) async {
    _requireFirebase();
    final snap = await _db.collection('patients').doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return PatientProfile.fromFirestore(uid, data);
  }

  /// Streams the sessions logged against [patientUid]. Mirrors iOS
  /// `FirebaseClinicianManager.fetchPatientSessions` — no server-side
  /// ordering (avoids an index), capped locally at [limit] most recent.
  Stream<List<PatientSession>> watchPatientSessions(
    String patientUid, {
    int limit = 100,
  }) {
    _requireFirebase();
    return _hardenedStream(() => _db
            .collection('sessions')
            .where('patientUID', isEqualTo: patientUid)
            .snapshots()).map((snap) {
      final out = snap.docs
          .map((d) => PatientSession.fromFirestore(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
      if (out.length > limit) return out.sublist(0, limit);
      return out;
    });
  }

  /// Streams the per-attempt detail for one session. Lazy — only
  /// fetched when the audiologist drills into a specific session in
  /// the UI, so the hot dashboard path never pays for these reads.
  Stream<List<PatientAttempt>> watchSessionAttempts(String sessionId) {
    _requireFirebase();
    return _hardenedStream(() => _db
            .collection('sessions')
            .doc(sessionId)
            .collection('attempts')
            .orderBy('index')
            .snapshots())
        .map((snap) =>
            snap.docs.map((d) => PatientAttempt.fromFirestore(d.data())).toList());
  }

  /// Clinician-side: watches my own `clinicians/{uid}` doc, reads the
  /// `linkedPatients` array, and hydrates each patient profile. Matches
  /// the legacy schema + Firestore rules.
  Stream<List<LinkedPatient>> watchMyPatients() async* {
    _requireFirebase();
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn) return;
    // Confirm Firestore has the propagated auth token BEFORE we open
    // the snapshot listener — a `.get()` against our own clinician
    // doc forces a fresh authenticated round-trip and primes the gRPC
    // channel. After this returns, `.snapshots()` won't get attached
    // to a stale (signed-out) channel.
    try {
      await _db.collection('clinicians').doc(auth.uid).get();
    } catch (_) {/* hardened stream below will retry if this fails */}
    yield* _hardenedStream(
      () => _db.collection('clinicians').doc(auth.uid).snapshots(),
    ).asyncMap((doc) async {
      final data = doc.data() ?? const <String, dynamic>{};
      final uids = ((data['linkedPatients'] as List?) ?? const [])
          .whereType<String>()
          .toList();
      final patients = <LinkedPatient>[];
      for (final uid in uids) {
        try {
          final profile = await _db.collection('patients').doc(uid).get();
          final pdata = profile.data() ?? const <String, dynamic>{};
          patients.add(LinkedPatient(
            uid: uid,
            name: _asString(pdata['patientName']) ?? 'Patient',
            email: _asString(pdata['email']) ?? '',
            totalSessions: _asInt(pdata['totalSessions']) ?? 0,
            streakDays: _asInt(pdata['streakDays']) ?? 0,
            currentWordRecognition:
                _asDouble(pdata['currentWordRecognition']) ?? 0,
            currentSentenceComprehension:
                _asDouble(pdata['currentSentenceComprehension']) ?? 0,
            currentNoisePerformance:
                _asDouble(pdata['currentNoisePerformance']) ?? 0,
            lastActive: _asDate(pdata['lastActiveDate']),
          ));
        } catch (_) {
          // Linked UID whose doc we can't read (rules race / deleted
          // account) — skip it rather than blowing up the whole stream.
        }
      }
      return patients;
    });
  }

  /// Wraps a Firestore snapshot stream so a `permission-denied` on the
  /// FIRST emission (the auth-token race after sign-in: gRPC channel
  /// hadn't propagated the new token by the time we subscribed)
  /// triggers a re-subscribe with backoff instead of bubbling up to
  /// the dashboard `.when(error: ...)` card.
  ///
  /// `_waitForFirestoreAuth` in the auth controller closes most of the
  /// race; this is a belt-and-braces self-heal for the snapshot
  /// listener path which uses a different gRPC stream than `.get()`.
  Stream<T> _hardenedStream<T>(Stream<T> Function() build) async* {
    const maxAttempts = 4;
    const baseDelay = Duration(milliseconds: 400);
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        await for (final value in build()) {
          yield value;
        }
        return;
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied' || attempt == maxAttempts - 1) {
          dev.log(
            'hardened stream giving up: ${e.code} ${e.message}',
            name: 'ClinicianRepository',
          );
          rethrow;
        }
        dev.log(
          'hardened stream attempt ${attempt + 1} denied; '
          'waiting for auth and re-subscribing',
          name: 'ClinicianRepository',
        );
        await Future<void>.delayed(baseDelay * (attempt + 1));
      }
    }
  }

  void _requireFirebase() {
    if (!FirebaseBootstrap.initialized) {
      throw StateError('Firebase not initialized — clinician features '
          'require Firestore. Run flutterfire configure.');
    }
  }
}

class LinkedPatient {
  const LinkedPatient({
    required this.uid,
    required this.name,
    required this.email,
    required this.totalSessions,
    required this.streakDays,
    required this.currentWordRecognition,
    required this.currentSentenceComprehension,
    required this.currentNoisePerformance,
    required this.lastActive,
  });
  final String uid;
  final String name;
  final String email;
  final int totalSessions;
  final int streakDays;
  final double currentWordRecognition;
  final double currentSentenceComprehension;
  final double currentNoisePerformance;
  final DateTime? lastActive;

  int? get daysSinceLastActive => lastActive == null
      ? null
      : DateTime.now().difference(lastActive!).inDays;

  RiskLevel get riskLevel {
    final d = daysSinceLastActive;
    if (d == null) return RiskLevel.moderate;
    if (d <= 2) return RiskLevel.engaged;
    if (d <= 7) return RiskLevel.moderate;
    if (d <= 14) return RiskLevel.atRisk;
    return RiskLevel.critical;
  }

  double get averagePerformance =>
      (currentWordRecognition +
              currentSentenceComprehension +
              currentNoisePerformance) /
          3;
}

/// Mirrors iOS `PatientRecord` in HearifyPro/Models/PatientModels.swift —
/// the rich profile the detail view renders, with baseline/current
/// scores, engagement metrics, and derived improvement deltas.
class PatientProfile {
  const PatientProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.enrollmentDate,
    required this.lastActive,
    required this.totalSessions,
    required this.totalPracticeMinutes,
    required this.averageSessionsPerWeek,
    required this.streakDays,
    required this.baselineWordRecognition,
    required this.baselineSentenceComprehension,
    required this.baselineNoisePerformance,
    required this.currentWordRecognition,
    required this.currentSentenceComprehension,
    required this.currentNoisePerformance,
    required this.hearingType,
  });

  final String uid;
  final String name;
  final String email;
  final DateTime? enrollmentDate;
  final DateTime? lastActive;
  final int totalSessions;
  final double totalPracticeMinutes;
  final double averageSessionsPerWeek;
  final int streakDays;
  final double? baselineWordRecognition;
  final double? baselineSentenceComprehension;
  final double? baselineNoisePerformance;
  final double currentWordRecognition;
  final double currentSentenceComprehension;
  final double currentNoisePerformance;
  final String? hearingType;

  double? get improvementWordRecognition =>
      baselineWordRecognition == null
          ? null
          : currentWordRecognition - baselineWordRecognition!;
  double? get improvementSentenceComprehension =>
      baselineSentenceComprehension == null
          ? null
          : currentSentenceComprehension - baselineSentenceComprehension!;
  double? get improvementNoisePerformance =>
      baselineNoisePerformance == null
          ? null
          : currentNoisePerformance - baselineNoisePerformance!;

  double get averagePerformance =>
      (currentWordRecognition +
              currentSentenceComprehension +
              currentNoisePerformance) /
          3;

  int? get daysSinceLastActive => lastActive == null
      ? null
      : DateTime.now().difference(lastActive!).inDays;

  int? get daysSinceEnrollment => enrollmentDate == null
      ? null
      : DateTime.now().difference(enrollmentDate!).inDays;

  /// iOS RiskLevel — engaged / moderate / atRisk / critical. Drives
  /// the dot color on the roster card.
  RiskLevel get riskLevel {
    final days = daysSinceLastActive;
    if (days == null) return RiskLevel.moderate;
    if (days <= 2) return RiskLevel.engaged;
    if (days <= 7) return RiskLevel.moderate;
    if (days <= 14) return RiskLevel.atRisk;
    return RiskLevel.critical;
  }

  factory PatientProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    return PatientProfile(
      uid: uid,
      name: _asString(data['patientName']) ?? 'Patient',
      email: _asString(data['email']) ?? '',
      enrollmentDate: _asDate(data['enrollmentDate']),
      lastActive: _asDate(data['lastActiveDate']),
      totalSessions: _asInt(data['totalSessions']) ?? 0,
      totalPracticeMinutes: _asDouble(data['totalPracticeTime']) ?? 0,
      averageSessionsPerWeek:
          _asDouble(data['averageSessionsPerWeek']) ?? 0,
      streakDays: _asInt(data['streakDays']) ?? 0,
      baselineWordRecognition: _asDouble(data['baselineWordRecognition']),
      baselineSentenceComprehension:
          _asDouble(data['baselineSentenceComprehension']),
      baselineNoisePerformance: _asDouble(data['baselineNoisePerformance']),
      currentWordRecognition: _asDouble(data['currentWordRecognition']) ?? 0,
      currentSentenceComprehension:
          _asDouble(data['currentSentenceComprehension']) ?? 0,
      currentNoisePerformance:
          _asDouble(data['currentNoisePerformance']) ?? 0,
      hearingType: _asString(data['hearingType']),
    );
  }
}

enum RiskLevel { engaged, moderate, atRisk, critical }

/// One record per stimulus inside a session. Lives at
/// `/sessions/{sessionId}/attempts/{nnn}`. Mirrors `PracticeAttempt`
/// from the patient device side, plus a few server-side conveniences
/// (`index`, `correct` precomputed, `patientUID` denormalized for
/// collection-group queries).
class PatientAttempt {
  const PatientAttempt({
    required this.index,
    required this.target,
    required this.heard,
    required this.score,
    required this.correct,
    required this.timestamp,
    this.exerciseType,
    this.categoryTag,
    this.snrDb,
    this.responseTimeMs,
    this.wrongChoice,
  });

  final int index;
  final String target;
  final String heard;
  final double score; // 0..1
  final bool correct;
  final DateTime timestamp;
  final String? exerciseType;
  final String? categoryTag;
  final double? snrDb;
  final int? responseTimeMs;
  final String? wrongChoice;

  factory PatientAttempt.fromFirestore(Map<String, dynamic> data) {
    return PatientAttempt(
      index: _asInt(data['index']) ?? 0,
      target: _asString(data['target']) ?? '',
      heard: _asString(data['heard']) ?? '',
      score: _asDouble(data['score']) ?? 0,
      correct: data['correct'] == true,
      timestamp: _asDate(data['timestamp']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      exerciseType: _asString(data['exerciseType']),
      categoryTag: _asString(data['categoryTag']),
      snrDb: _asDouble(data['snrDb']),
      responseTimeMs: _asInt(data['responseTimeMs']),
      wrongChoice: _asString(data['wrongChoice']),
    );
  }
}

/// Mirrors iOS `SessionData`. Populated from the `/sessions` collection.
///
/// The five trailing fields ([snr50], [byCategory], [topConfusions],
/// [avgResponseTimeMs], [phonemeBreakdown]) are written by the new
/// per-session aggregator (`session_writer.dart`). They are null on
/// older session documents — the clinical charts handle that by
/// dropping points / skipping rows.
class PatientSession {
  const PatientSession({
    required this.id,
    required this.patientUid,
    required this.sessionDate,
    required this.exerciseType,
    required this.durationSeconds,
    required this.itemsAttempted,
    required this.itemsCorrect,
    required this.accuracy,
    required this.backgroundNoiseLevel,
    this.snr50,
    this.byCategory = const {},
    this.topConfusions = const [],
    this.avgResponseTimeMs,
  });

  final String id;
  final String patientUid;
  final DateTime sessionDate;
  final String exerciseType;
  final double durationSeconds;
  final int itemsAttempted;
  final int itemsCorrect;
  final double accuracy; // 0..1
  final double backgroundNoiseLevel; // 0..1

  /// SNR-50 in dB. Populated only for BKB-SIN / WIN sessions. Lower =
  /// better (less noise tolerated to hit 50% intelligibility).
  final double? snr50;

  /// Per-phoneme-category aggregates: `{tag: (correct, total)}`.
  /// Keys come from `PhoneticCategory` constants.
  final Map<String, ({int correct, int total})> byCategory;

  /// Top 5 confused (target → heard) pairs in this session, sorted by
  /// count descending.
  final List<({String target, String heard, int count})> topConfusions;

  /// Average tap-latency across all items in the session, in ms.
  final int? avgResponseTimeMs;

  factory PatientSession.fromFirestore(String id, Map<String, dynamic> data) {
    return PatientSession(
      id: id,
      patientUid: _asString(data['patientUID']) ?? '',
      sessionDate:
          _asDate(data['sessionDate']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      exerciseType: _asString(data['exerciseType']) ?? 'Unknown',
      durationSeconds: _asDouble(data['duration']) ?? 0,
      itemsAttempted: _asInt(data['itemsAttempted']) ?? 0,
      itemsCorrect: _asInt(data['itemsCorrect']) ?? 0,
      accuracy: _asDouble(data['accuracy']) ?? 0,
      backgroundNoiseLevel: _asDouble(data['backgroundNoiseLevel']) ?? 0,
      snr50: _asDouble(data['snr50']),
      byCategory: _parseByCategory(data['byCategory']),
      topConfusions: _parseTopConfusions(data['topConfusions']),
      avgResponseTimeMs: _asInt(data['avgResponseTimeMs']),
    );
  }
}

/// Decode `{tag: {n: N, correct: K}}` Firestore map into the typed
/// aggregate the dashboard widgets consume.
Map<String, ({int correct, int total})> _parseByCategory(dynamic raw) {
  if (raw is! Map) return const {};
  final out = <String, ({int correct, int total})>{};
  raw.forEach((key, value) {
    if (key is! String || value is! Map) return;
    final n = _asInt(value['n']) ?? 0;
    final correct = _asInt(value['correct']) ?? 0;
    if (n <= 0) return;
    out[key] = (correct: correct, total: n);
  });
  return out;
}

List<({String target, String heard, int count})> _parseTopConfusions(
  dynamic raw,
) {
  if (raw is! List) return const [];
  final out = <({String target, String heard, int count})>[];
  for (final entry in raw) {
    if (entry is! Map) continue;
    final t = _asString(entry['target']);
    final h = _asString(entry['heard']);
    final c = _asInt(entry['count']);
    if (t == null || h == null || c == null) continue;
    out.add((target: t, heard: h, count: c));
  }
  return out;
}

/// Resilient Firestore coercers. Older iOS builds occasionally stored
/// numeric fields as Strings (e.g. `"0.85"`); these helpers accept
/// `num`, numeric `String`, or `null` and never throw a cast.
double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt();
  return null;
}

String? _asString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  if (v is num) {
    // Unix seconds vs milliseconds — 1e12 threshold ~ year 2286 in ms,
    // ~ year 33648 in seconds, so anything that big is already ms.
    final ms = v >= 1e12 ? v.toInt() : (v * 1000).toInt();
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
  return null;
}

final clinicianRepositoryProvider =
    Provider<ClinicianRepository>((ref) => ClinicianRepository(ref));

// All clinician-side data providers are `.autoDispose` so a sign-out
// → sign-in cycle doesn't leave a permission-denied error parked in
// the provider cache. AutoDispose drops the provider when no widget
// is watching it, so when the dashboard remounts post sign-in we get
// a fresh subscription on a fresh (authenticated) gRPC channel.

final patientProfileProvider =
    FutureProvider.autoDispose.family<PatientProfile?, String>(
        (ref, uid) async {
  return ref.read(clinicianRepositoryProvider).fetchPatientProfile(uid);
});

final patientSessionsProvider =
    StreamProvider.autoDispose.family<List<PatientSession>, String>(
        (ref, uid) {
  return ref.read(clinicianRepositoryProvider).watchPatientSessions(uid);
});

/// Per-session attempt drill-down — only watched when the audiologist
/// taps a specific session row, so this is "cold" data that never
/// loads on the main dashboard.
final sessionAttemptsProvider =
    StreamProvider.autoDispose.family<List<PatientAttempt>, String>(
        (ref, sessionId) {
  return ref.read(clinicianRepositoryProvider).watchSessionAttempts(sessionId);
});
