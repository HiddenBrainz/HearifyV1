import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/patient_profile_writer.dart';

/// Port of HearifyV1/Models/TrainingModels.swift `TrainingModuleType` enum.
enum TrainingModuleType {
  hearingLoss('Hearing Loss', Icons.hearing,
      'Learn about hearing loss, its causes, and management strategies'),
  hearingAids('Hearing Aids', Icons.hearing_disabled,
      'Master hearing aid use, maintenance, and optimization'),
  cochlearImplants('Cochlear Implants', Icons.memory,
      'Understand cochlear implants and auditory rehabilitation');

  const TrainingModuleType(this.displayName, this.icon, this.description);

  final String displayName;
  final IconData icon;
  final String description;

  Color color(Brightness b) => switch (this) {
        TrainingModuleType.hearingLoss => AppTheme.primaryBlue(b),
        TrainingModuleType.hearingAids => AppTheme.accentPurple(b),
        TrainingModuleType.cochlearImplants => AppTheme.success(b),
      };

  static TrainingModuleType? fromRaw(String? raw) {
    if (raw == null) return null;
    for (final t in values) {
      if (t.displayName == raw) return t;
    }
    return null;
  }
}

class HearingProfileState {
  const HearingProfileState({required this.selected, required this.completed});
  final TrainingModuleType? selected;
  final bool completed;

  static const initial = HearingProfileState(selected: null, completed: false);
}

class HearingProfileController extends StateNotifier<HearingProfileState> {
  HearingProfileController(this._ref) : super(HearingProfileState.initial) {
    _load();
  }
  final Ref _ref;

  static const _keyType = 'userHearingType';
  static const _keyDone = 'hasCompletedHearingTypeSelection';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyType);
    final done = prefs.getBool(_keyDone) ?? false;
    final resolved = TrainingModuleType.fromRaw(raw);
    state = HearingProfileState(
        selected: resolved, completed: resolved != null || done);
  }

  Future<void> hydrateFromServer(String? rawType) async {
    final resolved = TrainingModuleType.fromRaw(rawType);
    state = HearingProfileState(
      selected: resolved,
      completed: resolved != null,
    );
    final prefs = await SharedPreferences.getInstance();
    if (resolved != null) {
      await prefs.setString(_keyType, resolved.displayName);
      await prefs.setBool(_keyDone, true);
    } else {
      await prefs.remove(_keyType);
      await prefs.setBool(_keyDone, false);
    }
  }

  Future<void> clearLocal() async {
    state = HearingProfileState.initial;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyType);
    await prefs.remove(_keyDone);
  }

  Future<void> setType(TrainingModuleType t) async {
    state = HearingProfileState(selected: t, completed: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyType, t.displayName);
    await prefs.setBool(_keyDone, true);
    await updatePatientFields(_ref, {
      'hearingType': t.displayName,
      'hearingTypeSelectedAt': Timestamp.now(),
    });
  }
}

final hearingProfileProvider = StateNotifierProvider<HearingProfileController,
    HearingProfileState>((ref) {
  return HearingProfileController(ref);
});
