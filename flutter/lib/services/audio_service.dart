import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tts/prerendered_lookup.dart';
import 'tts/sherpa_tts_engine.dart';

/// Cross-platform audio service — port of HearifyV1/Managers/AudioManager.swift.
///
/// **TTS routing** (in priority order):
///   1. **Pre-rendered MP3** — bundled Kokoro FP16 renders of every
///      clinical stimulus (BKB-SIN / WIN / AzBio / Word Recognition /
///      matched-pair / phoneme corpora). Bit-identical across iOS /
///      Android / desktop, zero generation latency.
///   2. **Sherpa-ONNX Kokoro** — same Kokoro model used at build time,
///      but at runtime, for any text not in the manifest (Custom
///      Practice). Downloaded on first launch; skipped on web.
///   3. **flutter_tts** — last resort: web Custom Practice, or while
///      Sherpa is still installing on first native launch.
///
/// Looping background noise still goes through `audioplayers`; the
/// foreground player here is dedicated to pre-rendered MP3 playback so
/// noise + speech don't fight for the same handle.
class AudioService extends ChangeNotifier {
  AudioService() {
    _bootstrap();
  }

  /// Public flag UI can read to decide whether to surface "Voice
  /// installing…" copy. Mirrors `SherpaTtsEngine.isInitialized`.
  bool get isNeuralVoiceReady => _sherpa.isInitialized;

  /// True once the pre-rendered manifest has been parsed (or
  /// definitively failed to load — either way `speak()` is safe).
  bool get isPrerenderedReady => _prerendered.isReady;

  /// Number of bundled stimuli that will hit the pre-rendered path.
  int get prerenderedClipCount => _prerendered.clipCount;

  /// Active Kokoro voice id (e.g. `'af_bella'`). Persisted across runs.
  String get kokoroVoiceId => _prerendered.currentVoice;

  /// Voices the bundled manifest knows about. Empty until manifest
  /// finishes loading at startup.
  List<KokoroVoiceInfo> get kokoroVoices => _prerendered.availableVoices;

  static const _kokoroVoicePrefKey = 'tts.kokoroVoiceId';

  final SherpaTtsEngine _sherpa = SherpaTtsEngine.instance;
  final PrerenderedLookup _prerendered = PrerenderedLookup.instance;

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _noise = AudioPlayer();
  final AudioPlayer _foreground = AudioPlayer();
  StreamSubscription<void>? _foregroundCompleteSub;
  Completer<bool>? _foregroundCompleter;

  bool _initialized = false;
  bool _isSpeaking = false;
  bool _isPlayingBackgroundNoise = false;
  double _currentVolume = 1.0;
  double _currentSpeed = 1.0;
  double _backgroundNoiseVolume = 0.3;
  String? _currentVoiceName;
  String? _currentVoiceLocale;

  bool get isSpeaking => _isSpeaking;
  bool get isPlayingBackgroundNoise => _isPlayingBackgroundNoise;
  double get currentVolume => _currentVolume;
  double get currentSpeed => _currentSpeed;
  double get backgroundNoiseVolume => _backgroundNoiseVolume;
  String? get currentVoiceName => _currentVoiceName;
  String? get currentVoiceLocale => _currentVoiceLocale;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setVolume(_currentVolume);
    await _tts.setSpeechRate(_convertSpeedToRate(_currentSpeed));
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
      _completeSpeech(true);
    });
    _tts.setCancelHandler(() {
      _isSpeaking = false;
      notifyListeners();
      _completeSpeech(false);
    });
    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
      _completeSpeech(false);
      // On web, calling `cancel()` immediately before `speak()` fires an
      // `interrupted` / `canceled` SpeechSynthesisErrorEvent — that's our
      // own teardown, not a real failure. Keep the console clean.
      final s = (msg ?? '').toString().toLowerCase();
      if (s.contains('interrupt') || s.contains('cancel')) return;
      if (kDebugMode) debugPrint('TTS error: $msg');
    });
    _initialized = true;
  }

  Completer<bool>? _speechCompleter;

  void _completeSpeech(bool success) {
    final c = _speechCompleter;
    _speechCompleter = null;
    if (c != null && !c.isCompleted) c.complete(success);
  }

  /// Loads the pre-rendered manifest first (cheap, every platform),
  /// applies any saved voice pref, then asynchronously installs the
  /// Sherpa Kokoro voice on native targets. Notifies listeners as each
  /// stage flips ready so any "voice loading…" UI can hide.
  Future<void> _bootstrap() async {
    // Apply any saved voice pref BEFORE the manifest loads so the
    // first speak() call doesn't briefly use the default voice.
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kokoroVoicePrefKey);
      if (saved != null && saved.isNotEmpty) {
        _prerendered.setVoice(saved);
      }
    } catch (e) {
      debugPrint('[TTS] kokoro-voice prefs read failed: $e');
    }
    await _prerendered.initialize();
    notifyListeners();
    if (kIsWeb) return;
    final ok = await _sherpa.initialize();
    if (ok) notifyListeners();
  }

  /// Speaks `text`. Completes with true on normal completion, false
  /// when cancelled or on error.
  ///
  /// Priority: pre-rendered Kokoro MP3 → Sherpa Kokoro → flutter_tts.
  Future<bool> speak(String text) async {
    final clean = _cleanName(text);
    if (clean.isEmpty) {
      debugPrint('[TTS] speak("$text") → empty after clean, skip');
      return false;
    }
    // Wait for the manifest on cold start so the first utterance
    // doesn't fall through to flutter_tts when a clip is bundled.
    if (!_prerendered.isReady) {
      await _prerendered.initialize();
    }
    final prerenderedPath = _prerendered.assetPath(clean);
    if (prerenderedPath != null) {
      debugPrint('[TTS] speak("$clean") → PRERENDERED $prerenderedPath');
      return _speakViaPrerendered(prerenderedPath);
    }
    if (_sherpa.isInitialized) {
      debugPrint(
        '[TTS] speak("$clean") → SHERPA voice=${_prerendered.currentVoice}',
      );
      return _speakViaSherpa(clean);
    }
    debugPrint('[TTS] speak("$clean") → FLUTTER_TTS (last resort)');
    return _speakViaFlutterTts(clean);
  }

  Future<bool> _speakViaPrerendered(String assetPath) async {
    await _stopPrerendered();
    // The path stored as `assets/audio/tts/...` strips its leading
    // `assets/` because audioplayers' AssetSource is rooted at the
    // bundle's assets dir.
    const prefix = 'assets/';
    final source = AssetSource(
      assetPath.startsWith(prefix)
          ? assetPath.substring(prefix.length)
          : assetPath,
    );

    final completer = Completer<bool>();
    _foregroundCompleter = completer;
    _isSpeaking = true;
    notifyListeners();

    await _foregroundCompleteSub?.cancel();
    _foregroundCompleteSub = _foreground.onPlayerComplete.listen((_) {
      _isSpeaking = false;
      notifyListeners();
      _completeForeground(true);
    });

    try {
      await _foreground.setReleaseMode(ReleaseMode.release);
      await _foreground.setVolume(_currentVolume);
      await _foreground.play(source);
    } catch (e) {
      debugPrint('[TTS-Player] FAILED for ${source.path}: $e');
      _isSpeaking = false;
      notifyListeners();
      _completeForeground(false);
      // Fall back to Sherpa or flutter_tts when an asset fails to load
      // (e.g. corrupt MP3, web-asset-not-bundled). Don't silently swallow.
      if (_sherpa.isInitialized) {
        return _speakViaSherpa(_lastSpeakClean ?? '');
      }
      return _speakViaFlutterTts(_lastSpeakClean ?? '');
    }
    return completer.future;
  }

  void _completeForeground(bool ok) {
    final c = _foregroundCompleter;
    _foregroundCompleter = null;
    if (c != null && !c.isCompleted) c.complete(ok);
  }

  Future<void> _stopPrerendered() async {
    await _foregroundCompleteSub?.cancel();
    _foregroundCompleteSub = null;
    try {
      await _foreground.stop();
    } catch (_) {/* ignore */}
    _completeForeground(false);
  }

  String? _lastSpeakClean;

  Future<bool> _speakViaSherpa(String clean) async {
    _lastSpeakClean = clean;
    _isSpeaking = true;
    notifyListeners();
    final ok = await _sherpa.speak(
      clean,
      speed: _currentSpeed,
      voice: _prerendered.currentVoice,
    );
    _isSpeaking = false;
    notifyListeners();
    return ok;
  }

  Future<bool> _speakViaFlutterTts(String clean) async {
    _lastSpeakClean = clean;
    await _ensureInit();
    await _stopFlutterTts();
    if (kIsWeb) {
      // Chrome's SpeechSynthesis queue needs a real timer tick between
      // `cancel()` and the next `speak()`. Without this gap the new
      // utterance fires a stray SpeechSynthesisErrorEvent('interrupted').
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
    final completer = Completer<bool>();
    _speechCompleter = completer;
    try {
      await _tts.speak(clean);
    } catch (e) {
      _completeSpeech(false);
      if (kDebugMode) debugPrint('TTS speak threw: $e');
      return false;
    }
    return completer.future;
  }

  Future<void> stop() async {
    await _stopPrerendered();
    if (_sherpa.isInitialized) {
      await _sherpa.stop();
    }
    await _stopFlutterTts();
    final wasSpeaking = _isSpeaking;
    _isSpeaking = false;
    if (wasSpeaking) notifyListeners();
  }

  Future<void> _stopFlutterTts() async {
    await _ensureInit();
    await _tts.stop();
    _completeSpeech(false);
  }

  Future<void> setVolume(double v) async {
    _currentVolume = v.clamp(0.0, 1.0);
    await _ensureInit();
    await _tts.setVolume(_currentVolume);
    try {
      await _foreground.setVolume(_currentVolume);
    } catch (_) {/* ignore — player may not be active */}
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double s) async {
    _currentSpeed = s.clamp(0.5, 2.0);
    await _ensureInit();
    await _tts.setSpeechRate(_convertSpeedToRate(_currentSpeed));
    notifyListeners();
  }

  /// Switches the active Kokoro voice for pre-rendered playback (and
  /// for runtime Sherpa Kokoro synthesis on Custom Practice). Persists
  /// the choice across launches.
  Future<void> setKokoroVoice(String voiceId) async {
    if (voiceId == _prerendered.currentVoice) return;
    _prerendered.setVoice(voiceId);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kokoroVoicePrefKey,
        _prerendered.currentVoice,
      );
    } catch (e) {
      debugPrint('[TTS] kokoro-voice prefs write failed: $e');
    }
  }

  /// Legacy flutter_tts voice setter — kept for callers that pick from
  /// the OS voice list (web Custom Practice, debug screens). Doesn't
  /// touch the Kokoro selection.
  Future<void> setVoice(String name, String locale) async {
    await _ensureInit();
    try {
      await _tts.setVoice({'name': name, 'locale': locale});
      _currentVoiceName = name;
      _currentVoiceLocale = locale;
      notifyListeners();
    } catch (e) {
      debugPrint('setVoice failed: $e');
    }
  }

  Future<List<Map<String, String>>> availableVoices() async {
    await _ensureInit();
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v.toString())))
        .toList();
  }

  // ── Background noise (BackgroundNoise.mp3 in assets)

  Future<void> startBackgroundNoise({double? volume}) async {
    if (volume != null) _backgroundNoiseVolume = volume.clamp(0.0, 1.0);
    await _noise.stop();
    await _noise.setReleaseMode(ReleaseMode.loop);
    await _noise.setVolume(_backgroundNoiseVolume);
    await _noise.play(AssetSource('audio/BackgroundNoise.mp3'));
    _isPlayingBackgroundNoise = true;
    notifyListeners();
  }

  Future<void> stopBackgroundNoise() async {
    await _noise.stop();
    _isPlayingBackgroundNoise = false;
    notifyListeners();
  }

  Future<void> setBackgroundNoiseVolume(double v) async {
    _backgroundNoiseVolume = v.clamp(0.0, 1.0);
    if (_isPlayingBackgroundNoise) {
      await _noise.setVolume(_backgroundNoiseVolume);
    }
    notifyListeners();
  }

  /// Matches HearifyV1 AudioManager's rate conversion:
  /// app speed 0.5 → rate 0.25; 1.0 → 0.5; 2.0 → 0.75.
  /// `flutter_tts` uses a 0..1 rate scale similar to AVSpeech.
  double _convertSpeedToRate(double speed) {
    final rate = (speed - 0.5) * 0.25 + 0.25;
    return rate.clamp(0.0, 1.0);
  }

  String _cleanName(String name) {
    var cleaned = name;
    const voiceSuffixes = [
      'Male1', 'Male2', 'Male3', 'Female1', 'Female2', 'Female3',
      'male1', 'male2', 'male3', 'female1', 'female2', 'female3',
    ];
    for (final s in voiceSuffixes) {
      if (cleaned.endsWith(s)) {
        cleaned = cleaned.substring(0, cleaned.length - s.length);
        break;
      }
    }
    if (cleaned == 'buttonpress') return '';
    if (cleaned.isEmpty) return '';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  @override
  void dispose() {
    _tts.stop();
    _foregroundCompleteSub?.cancel();
    _foreground.dispose();
    _sherpa.dispose();
    _noise.dispose();
    super.dispose();
  }
}

final audioServiceProvider = ChangeNotifierProvider<AudioService>((ref) {
  final s = AudioService();
  ref.onDispose(s.dispose);
  return s;
});
