import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';

/// Port of HearifyV1/Managers/FirebaseManager.swift — auth slice only.
/// Analytics/gamification/session-sync logic from the Swift version lives in
/// managers that will be ported in later phases; this class deliberately
/// stops at auth + patient profile document creation.
class AuthState {
  const AuthState({required this.isSignedIn, this.uid, this.displayName});

  final bool isSignedIn;
  final String? uid;
  final String? displayName;

  static const signedOut = AuthState(isSignedIn: false);

  AuthState copyWith({bool? isSignedIn, String? uid, String? displayName}) =>
      AuthState(
        isSignedIn: isSignedIn ?? this.isSignedIn,
        uid: uid ?? this.uid,
        displayName: displayName ?? this.displayName,
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState.signedOut) {
    if (!FirebaseBootstrap.initialized) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u != null && !u.isAnonymous) {
      state = AuthState(
        isSignedIn: true,
        uid: u.uid,
        displayName: u.displayName,
      );
    } else if (u != null && u.isAnonymous) {
      FirebaseAuth.instance.signOut();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _requireFirebase();
    final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await res.user?.updateDisplayName(name);
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(res.user!.uid)
        .set({
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
    });
    state = AuthState(isSignedIn: true, uid: res.user!.uid, displayName: name);
  }

  Future<void> signIn({required String email, required String password}) async {
    _requireFirebase();
    final res = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    state = AuthState(
      isSignedIn: true,
      uid: res.user!.uid,
      displayName: res.user!.displayName,
    );
  }

  Future<void> signOut() async {
    if (FirebaseBootstrap.initialized) {
      await FirebaseAuth.instance.signOut();
    }
    state = AuthState.signedOut;
  }

  /// Debug-only: enter a local "guest" session without Firebase. Used for
  /// developing UI on platforms where Firebase config isn't wired yet.
  void debugSignInAsGuest() {
    state = const AuthState(
      isSignedIn: true,
      uid: 'debug-guest',
      displayName: 'Debug Guest',
    );
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
  return AuthController();
});
