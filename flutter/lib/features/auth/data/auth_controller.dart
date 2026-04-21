import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../onboarding/data/consent_controller.dart';
import '../../onboarding/data/hearing_profile_controller.dart';

/// Port of HearifyV1/Managers/FirebaseManager.swift (patient) merged
/// with HearifyPro/Managers/FirebaseClinicianManager.swift (clinician).
///
/// Patients live in `patients/{uid}`; clinicians live in
/// `clinicians/{uid}`. Both use Firebase Auth with the same shared
/// email/password identity, differentiated only by which Firestore
/// doc holds their profile.
///
/// On sign-in, the controller probes both collections to determine
/// role, then for patients hydrates the onboarding flags before
/// flipping `isSignedIn` — so the router's redirect sees the right
/// state immediately and the user doesn't see a flash of the
/// legal/consent/welcome screens if they've already completed them on
/// another device.
enum UserRole { patient, clinician }

class AuthState {
  const AuthState({
    required this.isSignedIn,
    this.uid,
    this.displayName,
    this.role,
  });

  final bool isSignedIn;
  final String? uid;
  final String? displayName;
  final UserRole? role;

  static const signedOut = AuthState(isSignedIn: false);

  AuthState copyWith({
    bool? isSignedIn,
    String? uid,
    String? displayName,
    UserRole? role,
  }) =>
      AuthState(
        isSignedIn: isSignedIn ?? this.isSignedIn,
        uid: uid ?? this.uid,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState.signedOut) {
    if (!FirebaseBootstrap.initialized) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u != null && !u.isAnonymous) {
      // Restore from a prior session: hydrate asynchronously so the local
      // SharedPreferences copy is overwritten by the server truth if the
      // user onboarded on another device while we were signed out here.
      _restoreSession(u);
    } else if (u != null && u.isAnonymous) {
      FirebaseAuth.instance.signOut();
    }
  }

  final Ref _ref;

  Future<void> _restoreSession(User u) async {
    final role = await _detectRole(u.uid);
    if (role == UserRole.patient) {
      await _hydrateFromPatientDoc(u.uid);
    }
    state = AuthState(
      isSignedIn: true,
      uid: u.uid,
      displayName: u.displayName,
      role: role,
    );
  }

  /// Probe both collections to find which one owns this UID. Returns
  /// `clinician` first (cheaper common-case for clinicians), then
  /// `patient`. Defaults to patient when the lookup fails so offline
  /// sessions still flow correctly.
  Future<UserRole> _detectRole(String uid) async {
    try {
      final clin =
          await FirebaseFirestore.instance.collection('clinicians').doc(uid).get();
      if (clin.exists) return UserRole.clinician;
    } catch (e) {
      dev.log('clinician role probe failed: $e', name: 'AuthController');
    }
    return UserRole.patient;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.patient,
  }) async {
    _requireFirebase();
    final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await res.user?.updateDisplayName(name);
    final uid = res.user!.uid;
    if (role == UserRole.clinician) {
      // Mirrors HearifyPro/Managers/FirebaseClinicianManager.swift L63-75.
      await FirebaseFirestore.instance
          .collection('clinicians')
          .doc(uid)
          .set({
        'name': name,
        'email': email,
        'role': 'clinician',
        'createdDate': Timestamp.now(),
        'linkedPatients': <String>[],
      });
      // Clinicians don't walk the patient onboarding gauntlet; wipe any
      // stale local flags in case this device was previously a patient.
      await _clearOnboardingLocal();
    } else {
      await FirebaseFirestore.instance.collection('patients').doc(uid).set({
        'patientName': name,
        'email': email,
        'enrollmentDate': Timestamp.now(),
        'totalSessions': 0,
        'currentWordRecognition': 0.0,
        'currentSentenceComprehension': 0.0,
        'currentNoisePerformance': 0.0,
        'lastActiveDate': Timestamp.now(),
        'streakDays': 0,
        'totalPracticeTime': 0.0,
        'averageSessionsPerWeek': 0.0,
        // Onboarding flags — explicit false so a query like
        // `where('hasAcceptedLegalTerms', '==', false)` is well-defined.
        'hasAcceptedLegalTerms': false,
        'hasCompletedConsentFlow': false,
        'consents': <String, bool>{},
        'hearingType': null,
      });
      // Fresh account — ensure local onboarding state is pristine so the
      // user walks the gauntlet exactly once.
      await _clearOnboardingLocal();
    }
    state = AuthState(
      isSignedIn: true,
      uid: uid,
      displayName: name,
      role: role,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
    UserRole expectedRole = UserRole.patient,
  }) async {
    _requireFirebase();
    final res = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = res.user!.uid;
    final actualRole = await _detectRole(uid);
    if (actualRole != expectedRole) {
      // Wrong tab — sign the user back out and surface a clear error.
      await FirebaseAuth.instance.signOut();
      throw StateError(
        expectedRole == UserRole.clinician
            ? 'This account is registered as a patient. Switch to the '
                'Patient tab to sign in.'
            : 'This account is registered as an audiologist. Switch to '
                'the Audiologist tab to sign in.',
      );
    }
    if (actualRole == UserRole.patient) {
      await _hydrateFromPatientDoc(uid);
    }
    state = AuthState(
      isSignedIn: true,
      uid: uid,
      displayName: res.user!.displayName,
      role: actualRole,
    );
  }

  Future<void> signOut() async {
    if (FirebaseBootstrap.initialized) {
      await FirebaseAuth.instance.signOut();
    }
    // Reset local onboarding state so the next sign-in starts from a clean
    // slate instead of inheriting this user's flags.
    await _clearOnboardingLocal();
    state = AuthState.signedOut;
  }

  /// Debug-only: enter a local "guest" session without Firebase. Used for
  /// developing UI on platforms where Firebase config isn't wired yet.
  void debugSignInAsGuest({UserRole role = UserRole.patient}) {
    state = AuthState(
      isSignedIn: true,
      uid: 'debug-guest',
      displayName: role == UserRole.clinician
          ? 'Debug Clinician'
          : 'Debug Guest',
      role: role,
    );
  }

  Future<void> _hydrateFromPatientDoc(String uid) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('patients')
          .doc(uid)
          .get();
      final data = snap.data() ?? const <String, dynamic>{};

      final hasLegal = data['hasAcceptedLegalTerms'] == true;
      final consentFlowDone = data['hasCompletedConsentFlow'] == true;
      final rawConsents = data['consents'];
      final grants = <String, bool>{};
      if (rawConsents is Map) {
        rawConsents.forEach((k, v) {
          if (k is String && v is bool) grants[k] = v;
        });
      }
      final hearingType = data['hearingType'];

      await _ref
          .read(legalAcceptanceProvider.notifier)
          .hydrateFromServer(hasLegal);
      await _ref.read(consentControllerProvider.notifier).hydrateFromServer(
            flowComplete: consentFlowDone,
            grants: grants,
          );
      await _ref.read(hearingProfileProvider.notifier).hydrateFromServer(
            hearingType is String ? hearingType : null,
          );
    } catch (e) {
      // Offline or read failure — fall back to whatever SharedPreferences
      // already loaded. The user may see onboarding if the cache is empty,
      // but writes will sync once the network returns.
      dev.log('patient doc hydration failed: $e', name: 'AuthController');
    }
  }

  Future<void> _clearOnboardingLocal() async {
    await _ref.read(legalAcceptanceProvider.notifier).clearLocal();
    await _ref.read(consentControllerProvider.notifier).clearLocal();
    await _ref.read(hearingProfileProvider.notifier).clearLocal();
  }

  void _requireFirebase() {
    if (!FirebaseBootstrap.initialized) {
      throw StateError(
        'Firebase is not initialized. Add the native config files '
        '(GoogleService-Info.plist / google-services.json) before signing in.',
      );
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
