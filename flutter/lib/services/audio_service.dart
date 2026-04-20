import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cross-platform audio service — port of HearifyV1/Managers/AudioManager.swift.
///
/// - TTS via `flutter_tts` (Apple AVSpeechSynthesizer on iOS, Android TTS
///   engine on Android, WebSpeech API on web).
/// - Looping background noise via `audioplayers`.
/// - The Swift manager's AVAudioSession routing / interruption handling is
///   delegated to the plugin layer; explicit session config isn't required
///   here because `flutter_tts` and `audioplayers` both configure their
///   own sessions on iOS.
class AudioService extends ChangeNotifier {
  AudioService();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _noise = AudioPlayer();

  bool _initialized = false;
  bool _isSpeaking = false;
  bool _isPlayingBackgroundNoise = false;
  double _currentVolume = 1.0;
  double _currentSpeed = 1.0;
  double _backgroundNoiseVolume = 0.3;

  bool get isSpeaking => _isSpeaking;
  bool get isPlayingBackgroundNoise => _isPlayingBackgroundNoise;
  double get currentVolume => _currentVolume;
  double get currentSpeed => _currentSpeed;
  double get backgroundNoiseVolume => _backgroundNoiseVolume;

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

  /// Speaks `text`. Completes with true on normal completion, false when
  /// cancelled or on error. Automatically strips voice suffixes (e.g.
  /// "batMale1" → "bat") preserved from the old pre-recorded asset names.
  Future<bool> speak(String text) async {
    await _ensureInit();
    await stop();
    if (kIsWeb) {
      // Chrome's SpeechSynthesis queue needs a real timer tick between
      // `cancel()` (fired from `stop()` above) and the next `speak()`.
      // Without this gap the new utterance fires a stray
      // `SpeechSynthesisErrorEvent('interrupted')`. A microtask yield
      // (`Duration.zero`) is not enough — use a short real delay.
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
    final clean = _cleanName(text);
    if (clean.isEmpty) return false;
    final completer = Completer<bool>();
    _speechCompleter = completer;
    try {
      await _tts.speak(clean);
    } catch (e) {
      // flutter_tts_web rethrows the underlying SpeechSynthesisErrorEvent
      // from its internal speak-completer. The error handler above has
      // already flipped state and completed `_speechCompleter`; we just
      // need to swallow the throw so it doesn't bubble as unhandled.
      _completeSpeech(false);
      if (kDebugMode) debugPrint('TTS speak threw: $e');
      return false;
    }
    return completer.future;
  }

  Future<void> stop() async {
    await _ensureInit();
    // Always ask the engine to stop — `_isSpeaking` only flips true after
    // the start handler fires, so gating on it would skip cancelling an
    // utterance that's still queued.
    await _tts.stop();
    final wasSpeaking = _isSpeaking;
    _isSpeaking = false;
    _completeSpeech(false);
    if (wasSpeaking) notifyListeners();
  }

  Future<void> setVolume(double v) async {
    _currentVolume = v.clamp(0.0, 1.0);
    await _ensureInit();
    await _tts.setVolume(_currentVolume);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double s) async {
    _currentSpeed = s.clamp(0.5, 2.0);
    await _ensureInit();
    await _tts.setSpeechRate(_convertSpeedToRate(_currentSpeed));
    notifyListeners();
  }

  Future<void> setVoice(String name, String locale) async {
    await _ensureInit();
    try {
      await _tts.setVoice({'name': name, 'locale': locale});
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
    if (_isPlayingBackgroundNoise) await _noise.setVolume(_backgroundNoiseVolume);
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
    _noise.dispose();
    super.dispose();
  }
}

final audioServiceProvider = ChangeNotifierProvider<AudioService>((ref) {
  final s = AudioService();
  ref.onDispose(s.dispose);
  return s;
});
