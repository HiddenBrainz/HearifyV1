import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Initializes Firebase using the generated options for this platform. Falls
/// back to a graceful no-op when options are missing or init throws (e.g.
/// native iOS step still pending). Callers should treat `false` as
/// "run in degraded mode".
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;
  static bool get initialized => _initialized;

  static Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      dev.log('Firebase initialized', name: 'FirebaseBootstrap');
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        dev.log(
          'Firebase init failed — running without backend. '
          'Reason: $e',
          name: 'FirebaseBootstrap',
          error: e,
          stackTrace: st,
        );
      }
      return false;
    }
  }
}
