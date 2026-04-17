import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/data/patient_profile_writer.dart';

/// Port of HearifyV1/Managers/ConsentManager.swift.
/// Stores five consent flags in SharedPreferences (device cache) AND
/// `patients/{uid}` in Firestore (source of truth across devices).
enum ConsentType {
  clinicalResearch('clinical_research', 'Clinical Research',
      'Allow de-identified data for research. Personal info never shared.',
      required: false),
  anonymizedAnalytics('anonymized_analytics', 'Anonymized Analytics',
      'Share anonymized usage data to help improve the app experience.',
      required: false),
  progressSharing('progress_sharing', 'Progress Data Sharing',
      'Allow progress/performance data to be shared with healthcare providers.',
      required: false),
  performanceData('performance_data', 'Performance Metrics',
      'Collect detailed performance metrics for personalized recommendations.',
      required: true),
  usageStatistics('usage_statistics', 'Usage Statistics',
      'Collect basic usage stats (time spent, features used).',
      required: true);

  const ConsentType(this.raw, this.title, this.description,
      {required this.required});

  final String raw;
  final String title;
  final String description;
  final bool required;

  static ConsentType? fromRaw(String raw) {
    for (final t in values) {
      if (t.raw == raw) return t;
    }
    return null;
  }
}

class ConsentState {
  const ConsentState({required this.grants, required this.flowComplete});

  final Map<ConsentType, bool> grants;
  final bool flowComplete;

  bool isGranted(ConsentType t) => grants[t] ?? false;

  ConsentState copyWith({Map<ConsentType, bool>? grants, bool? flowComplete}) =>
      ConsentState(
        grants: grants ?? this.grants,
        flowComplete: flowComplete ?? this.flowComplete,
      );

  static ConsentState initial() => ConsentState(
        grants: {for (final t in ConsentType.values) t: t.required},
        flowComplete: false,
      );
}

class ConsentController extends StateNotifier<ConsentState> {
  ConsentController(this._ref) : super(ConsentState.initial()) {
    _load();
  }
  final Ref _ref;

  static const _keyGrants = 'userConsents';
  static const _keyFlow = 'hasCompletedConsentFlow';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final flow = prefs.getBool(_keyFlow) ?? false;
    final raw = prefs.getString(_keyGrants);
    Map<ConsentType, bool> grants = {
      for (final t in ConsentType.values) t: t.required
    };
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final t in ConsentType.values) {
          final v = decoded[t.raw];
          if (v is bool) grants[t] = v;
        }
      } catch (_) {/* fall back to defaults */}
    }
    state = ConsentState(grants: grants, flowComplete: flow);
  }

  /// Applies server-side flags on sign-in. Overwrites both the notifier
  /// state AND the SharedPreferences cache so the device reflects the
  /// authoritative account state.
  Future<void> hydrateFromServer({
    required bool flowComplete,
    required Map<String, bool> grants,
  }) async {
    final mapped = <ConsentType, bool>{
      for (final t in ConsentType.values) t: t.required,
    };
    for (final entry in grants.entries) {
      final t = ConsentType.fromRaw(entry.key);
      if (t != null) mapped[t] = entry.value;
    }
    state = ConsentState(grants: mapped, flowComplete: flowComplete);
    await _persistLocal();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFlow, flowComplete);
  }

  /// Used on sign-out to prevent leaking the previous user's flags into the
  /// next session on the same device.
  Future<void> clearLocal() async {
    state = ConsentState.initial();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGrants);
    await prefs.remove(_keyFlow);
  }

  Future<void> grant(ConsentType t) => _set(t, true);
  Future<void> revoke(ConsentType t) async {
    if (t.required) return;
    await _set(t, false);
  }

  Future<void> _set(ConsentType t, bool granted) async {
    final next = Map<ConsentType, bool>.from(state.grants)..[t] = granted;
    state = state.copyWith(grants: next);
    await _persistLocal();
    await updatePatientFields(_ref, {
      'consents': _grantsAsRawMap(next),
    });
  }

  Future<void> completeFlow() async {
    state = state.copyWith(flowComplete: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFlow, true);
    await _persistLocal();
    await updatePatientFields(_ref, {
      'consents': _grantsAsRawMap(state.grants),
      'hasCompletedConsentFlow': true,
      'consentFlowCompletedAt': Timestamp.now(),
    });
  }

  Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGrants, jsonEncode(_grantsAsRawMap(state.grants)));
  }

  Map<String, bool> _grantsAsRawMap(Map<ConsentType, bool> g) =>
      {for (final e in g.entries) e.key.raw: e.value};
}

final consentControllerProvider =
    StateNotifierProvider<ConsentController, ConsentState>((ref) {
  return ConsentController(ref);
});

/// Legal agreement (Terms + Privacy) accept flag. Synced to Firestore so
/// accepting on one device lets the same account skip the screen on any
/// other device.
class LegalAcceptanceController extends StateNotifier<bool> {
  LegalAcceptanceController(this._ref) : super(false) {
    _load();
  }
  final Ref _ref;

  static const _key = 'hasAgreedToLegalTerms';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> hydrateFromServer(bool accepted) async {
    state = accepted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, accepted);
  }

  Future<void> clearLocal() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> accept() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    await updatePatientFields(_ref, {
      'hasAcceptedLegalTerms': true,
      'legalAcceptedAt': Timestamp.now(),
    });
  }
}

final legalAcceptanceProvider =
    StateNotifierProvider<LegalAcceptanceController, bool>((ref) {
  return LegalAcceptanceController(ref);
});
