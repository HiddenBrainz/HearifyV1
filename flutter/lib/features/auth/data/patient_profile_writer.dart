import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import 'auth_controller.dart';

/// Shared helper used by onboarding controllers to push small field updates
/// to `patients/{uid}` without each controller having to know the Firestore
/// collection path or guard against offline / debug-guest edge cases.
///
/// Silently no-ops when:
/// - Firebase isn't initialized (e.g. `--debug-guest` on platforms without
///   Firebase config)
/// - No user is signed in (or the signed-in user is the debug guest)
///
/// This keeps the onboarding flow usable on web dev builds and falls back
/// gracefully if Firestore is unreachable — the `SharedPreferences` writes in
/// the controllers still keep the device-local state correct.
Future<void> updatePatientFields(Ref ref, Map<String, Object?> fields) async {
  if (!FirebaseBootstrap.initialized) return;
  final uid = ref.read(authControllerProvider).uid;
  if (uid == null || uid == 'debug-guest') return;
  try {
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(uid)
        .set(fields, SetOptions(merge: true));
  } catch (e) {
    // Offline writes are queued by the Firestore SDK; only transient errors
    // (e.g. permission denied) reach here. Log and move on — the
    // SharedPreferences cache has already been updated by the caller.
    dev.log('patient fields write failed: $e', name: 'PatientProfileWriter');
  }
}
