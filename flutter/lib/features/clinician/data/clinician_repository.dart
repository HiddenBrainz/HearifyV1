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
  Future<void> linkPatient({required String code}) async {
    _requireFirebase();
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn) throw StateError('Sign in required');
    final patientUid = await resolveLinkingCode(code);
    if (patientUid == null) throw StateError('Code invalid or expired');
    final batch = _db.batch();
    // Rule (legacy): update allowed only if the resulting doc has
    // `isUsed == true` AND `clinicianUID == request.auth.uid`.
    batch.update(_db.collection('linkingCodes').doc(code), {
      'isUsed': true,
      'clinicianUID': auth.uid,
      'usedDate': Timestamp.now(),
    });
    batch.update(_db.collection('clinicians').doc(auth.uid), {
      'linkedPatients': FieldValue.arrayUnion([patientUid]),
    });
    await batch.commit();
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
    return _db
        .collection('sessions')
        .where('patientUID', isEqualTo: patientUid)
        .snapshots()
        .map((snap) {
      final out = snap.docs
          .map((d) => PatientSession.fromFirestore(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
      if (out.length > limit) return out.sublist(0, limit);
      return out;
    });
  }

  /// Clinician-side: watches my own `clinicians/{uid}` doc, reads the
  /// `linkedPatients` array, and hydrates each patient profile. Matches
  /// the legacy schema + Firestore rules.
  Stream<List<LinkedPatient>> watchMyPatients() {
    _requireFirebase();
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn) return const Stream.empty();
    return _db
        .collection('clinicians')
        .doc(auth.uid)
        .snapshots()
        .asyncMap((doc) async {
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

/// Mirrors iOS `SessionData`. Populated from the `/sessions` collection.
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
    );
  }
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

final patientProfileProvider =
    FutureProvider.family<PatientProfile?, String>((ref, uid) async {
  return ref.read(clinicianRepositoryProvider).fetchPatientProfile(uid);
});

final patientSessionsProvider =
    StreamProvider.family<List<PatientSession>, String>((ref, uid) {
  return ref.read(clinicianRepositoryProvider).watchPatientSessions(uid);
});
