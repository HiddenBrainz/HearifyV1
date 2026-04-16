import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Port of HearifyV1/Managers/ConsentManager.swift.
/// Stores five consent flags in SharedPreferences plus a flow-complete flag.
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
  ConsentController() : super(ConsentState.initial()) {
    _load();
  }

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

  Future<void> grant(ConsentType t) => _set(t, true);
  Future<void> revoke(ConsentType t) async {
    if (t.required) return;
    await _set(t, false);
  }

  Future<void> _set(ConsentType t, bool granted) async {
    final next = Map<ConsentType, bool>.from(state.grants)..[t] = granted;
    state = state.copyWith(grants: next);
    await _persist();
  }

  Future<void> completeFlow() async {
    state = state.copyWith(flowComplete: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFlow, true);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode({for (final e in state.grants.entries) e.key.raw: e.value});
    await prefs.setString(_keyGrants, encoded);
  }
}

final consentControllerProvider =
    StateNotifierProvider<ConsentController, ConsentState>((ref) {
  return ConsentController();
});

/// Legal agreement (Terms + Privacy) accept flag — kept separate from consent
/// grants because in the Swift app it's stored under a distinct UserDefaults
/// key (`hasAgreedToLegalTerms`) and gates a different onboarding step.
class LegalAcceptanceController extends StateNotifier<bool> {
  LegalAcceptanceController() : super(false) {
    _load();
  }
  static const _key = 'hasAgreedToLegalTerms';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> accept() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

final legalAcceptanceProvider =
    StateNotifierProvider<LegalAcceptanceController, bool>((ref) {
  return LegalAcceptanceController();
});
