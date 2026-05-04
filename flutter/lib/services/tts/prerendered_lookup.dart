import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:crypto/crypto.dart' as crypto;

/// Display + identity info for a single Kokoro voice the bundled
/// manifest knows about.
@immutable
class KokoroVoiceInfo {
  const KokoroVoiceInfo({
    required this.id,
    required this.displayName,
    required this.gender,
  });

  /// Short voice identifier — also the subdirectory name under
  /// `assets/audio/tts/`. Examples: `af_bella`, `af_sarah`,
  /// `am_adam`, `am_michael`.
  final String id;

  final String displayName;

  /// `'female'` or `'male'`. Used by the Settings picker to pick
  /// an icon.
  final String gender;

  factory KokoroVoiceInfo.fromJson(Map<String, dynamic> json) =>
      KokoroVoiceInfo(
        id: (json['id'] as String?) ?? '',
        displayName: (json['displayName'] as String?) ?? '',
        gender: (json['gender'] as String?) ?? '',
      );
}

/// Runtime accessor for `assets/audio/tts/manifest.json` (schema v2).
///
/// The manifest is produced by `tools/prerender_tts.py` (Kokoro FP16).
/// Every voice has the same set of stimulus hashes; the asset path is
/// reconstructed at lookup time as
/// `assets/audio/tts/$voiceId/$hash.mp3`.
///
/// `AudioService.speak()` calls [PrerenderedLookup.assetPath] on every
/// utterance — if the text has a bundled clip we play it (bit-identical
/// across every platform), otherwise we fall through to the Sherpa
/// Kokoro engine or `flutter_tts`.
///
/// The normalization function here MUST stay byte-equivalent with
/// `normalize()` in `tools/prerender_tts.py`.
class PrerenderedLookup {
  PrerenderedLookup._();
  static final PrerenderedLookup instance = PrerenderedLookup._();

  static const String _manifestAsset = 'assets/audio/tts/manifest.json';

  Set<String>? _keys;
  List<KokoroVoiceInfo> _voices = const [];
  String _defaultVoice = 'af_bella';
  String _voiceId = 'af_bella';
  Future<void>? _loading;

  /// Resolves once the manifest has been loaded (or definitively
  /// failed to load). Callers don't need to wait — `assetPath` returns
  /// null until the load completes, which is the correct behavior
  /// (silent fallthrough to the next TTS engine).
  Future<void> initialize() {
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(_manifestAsset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final voicesJson = (json['voices'] as List?) ?? const [];
      _voices = [
        for (final v in voicesJson)
          KokoroVoiceInfo.fromJson(v as Map<String, dynamic>),
      ];
      _defaultVoice = (json['defaultVoice'] as String?) ?? 'af_bella';
      // Default to whatever the manifest declares unless the caller has
      // already picked a voice (e.g. via setVoice from a saved pref).
      if (!_voices.any((v) => v.id == _voiceId)) {
        _voiceId = _defaultVoice;
      }
      final keys = (json['keys'] as Map<String, dynamic>?) ?? const {};
      _keys = keys.keys.toSet();
      debugPrint(
        '[TTS-Lookup] manifest v${json['version']} loaded: '
        '${_keys!.length} stimuli × ${_voices.length} voices '
        '(default=$_defaultVoice, current=$_voiceId).',
      );
    } catch (e) {
      debugPrint('[TTS-Lookup] manifest unavailable: $e — falling through.');
      _keys = const <String>{};
      _voices = const [];
    }
  }

  /// Returns the asset path for [text] in the active voice if a
  /// pre-rendered MP3 exists, otherwise null. Safe to call before
  /// [initialize] resolves — returns null in that window.
  String? assetPath(String text) {
    final keys = _keys;
    if (keys == null || keys.isEmpty) return null;
    final key = _keyFor(text);
    if (!keys.contains(key)) return null;
    return 'assets/audio/tts/$_voiceId/$key.mp3';
  }

  /// Selects the active voice. Unknown voice ids fall back to the
  /// manifest's declared default. Idempotent.
  void setVoice(String voiceId) {
    if (_voiceId == voiceId) return;
    if (_voices.isNotEmpty && !_voices.any((v) => v.id == voiceId)) {
      debugPrint(
        '[TTS-Lookup] unknown voice "$voiceId", '
        'falling back to "$_defaultVoice"',
      );
      _voiceId = _defaultVoice;
      return;
    }
    _voiceId = voiceId;
    debugPrint('[TTS-Lookup] active voice → $_voiceId');
  }

  bool get isReady => _keys != null;
  int get clipCount => _keys?.length ?? 0;
  String get currentVoice => _voiceId;
  String get defaultVoice => _defaultVoice;
  List<KokoroVoiceInfo> get availableVoices => List.unmodifiable(_voices);

  /// Hash of the normalized text — keep in sync with the Python script.
  static String _keyFor(String text) {
    final normalized = _normalizeForLookup(text);
    final digest = crypto.sha1.convert(utf8.encode(normalized));
    return digest.toString().substring(0, 16);
  }

  /// Lowercase, drop non-letters (except apostrophes), collapse
  /// whitespace. Mirrors `normalize()` in `tools/prerender_tts.py`.
  static String _normalizeForLookup(String text) {
    final lower = text.toLowerCase();
    final stripped = lower.replaceAll(RegExp(r"[^a-z']"), ' ');
    return stripped.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).join(' ');
  }
}
