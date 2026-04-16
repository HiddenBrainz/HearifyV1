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

  /// As a clinician, consume a linking code: add the patient to my roster
  /// and mark the code as used.
  Future<void> linkPatient({required String code}) async {
    _requireFirebase();
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn) throw StateError('Sign in required');
    final patientUid = await resolveLinkingCode(code);
    if (patientUid == null) throw StateError('Code invalid or expired');
    final batch = _db.batch();
    batch.update(_db.collection('linkingCodes').doc(code), {
      'isUsed': true,
      'consumedBy': auth.uid,
      'consumedAt': Timestamp.now(),
    });
    batch.set(
      _db
          .collection('clinicians')
          .doc(auth.uid)
          .collection('patients')
          .doc(patientUid),
      {
        'patientUID': patientUid,
        'linkedAt': Timestamp.now(),
        'code': code,
      },
    );
    await batch.commit();
  }

  /// Clinician-side: subscribes to the patients I've linked to.
  Stream<List<LinkedPatient>> watchMyPatients() {
    _requireFirebase();
    final auth = _ref.read(authControllerProvider);
    if (!auth.isSignedIn) return const Stream.empty();
    return _db
        .collection('clinicians')
        .doc(auth.uid)
        .collection('patients')
        .snapshots()
        .asyncMap((snap) async {
      final patients = <LinkedPatient>[];
      for (final d in snap.docs) {
        final uid = d.data()['patientUID'] as String;
        final profile = await _db.collection('patients').doc(uid).get();
        final pdata = profile.data() ?? const {};
        patients.add(LinkedPatient(
          uid: uid,
          name: pdata['patientName'] as String? ?? 'Patient',
          email: pdata['email'] as String? ?? '',
          totalSessions: (pdata['totalSessions'] as num?)?.toInt() ?? 0,
          streakDays: (pdata['streakDays'] as num?)?.toInt() ?? 0,
          currentWordRecognition:
              (pdata['currentWordRecognition'] as num?)?.toDouble() ?? 0,
          currentSentenceComprehension:
              (pdata['currentSentenceComprehension'] as num?)?.toDouble() ?? 0,
          currentNoisePerformance:
              (pdata['currentNoisePerformance'] as num?)?.toDouble() ?? 0,
          lastActive: (pdata['lastActiveDate'] as Timestamp?)?.toDate(),
        ));
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
}

final clinicianRepositoryProvider =
    Provider<ClinicianRepository>((ref) => ClinicianRepository(ref));
