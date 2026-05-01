import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Resolved on-disk paths for a Piper voice — exactly what
/// `OfflineTtsVitsModelConfig` needs.
class _PiperVoiceAssets {
  const _PiperVoiceAssets({
    required this.voiceId,
    required this.modelPath,
    required this.tokensPath,
    required this.dataDir,
  });

  final String voiceId;
  final String modelPath;
  final String tokensPath;
  final String dataDir;
}

/// Downloads + caches Piper voices into the app docs dir.
///
/// Voice tarballs live at the Sherpa-ONNX release bucket as
/// `vits-piper-<voiceId>.tar.bz2`. Cached directory layout:
/// `<appDocs>/sherpa_voices/<voiceId>/{<id>.onnx,tokens.txt,espeak-ng-data/}`.
class _SherpaVoiceManager {
  _SherpaVoiceManager._();
  static final _SherpaVoiceManager instance = _SherpaVoiceManager._();

  static const String defaultVoiceId = 'en_US-amy-low';

  static String _tarballUrl(String voiceId) =>
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/'
      'tts-models/vits-piper-$voiceId.tar.bz2';

  Future<Directory> _voiceDir(String voiceId) async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/sherpa_voices/$voiceId');
  }

  _PiperVoiceAssets _assetsFor(String voiceId, Directory dir) =>
      _PiperVoiceAssets(
        voiceId: voiceId,
        modelPath: '${dir.path}/$voiceId.onnx',
        tokensPath: '${dir.path}/tokens.txt',
        dataDir: '${dir.path}/espeak-ng-data',
      );

  bool _looksReady(_PiperVoiceAssets a) =>
      File(a.modelPath).existsSync() &&
      File(a.tokensPath).existsSync() &&
      Directory(a.dataDir).existsSync();

  Future<_PiperVoiceAssets?> ensureReady({
    String voiceId = defaultVoiceId,
    void Function(double fraction)? onProgress,
  }) async {
    final dir = await _voiceDir(voiceId);
    final assets = _assetsFor(voiceId, dir);
    if (_looksReady(assets)) return assets;

    if (kDebugMode) {
      debugPrint('Sherpa: voice "$voiceId" missing, downloading…');
    }
    await dir.create(recursive: true);

    try {
      final url = _tarballUrl(voiceId);
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('Sherpa: download failed (${response.statusCode})');
        }
        return null;
      }
      final total = response.contentLength ?? 0;
      final bytes = <int>[];
      var received = 0;
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      }

      // .tar.bz2 → bzip2 decompress → tar archive → extract files.
      final tarBytes = BZip2Decoder().decodeBytes(bytes);
      final archive = TarDecoder().decodeBytes(tarBytes);
      for (final entry in archive.files) {
        if (!entry.isFile) continue;
        // Strip the leading `vits-piper-<voiceId>/` prefix bundled by Sherpa.
        final segments = entry.name.split('/');
        if (segments.length < 2) continue;
        final relPath = segments.sublist(1).join('/');
        if (relPath.isEmpty) continue;
        final outFile = File('${dir.path}/$relPath');
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(entry.content as List<int>, flush: true);
      }
      if (kDebugMode) debugPrint('Sherpa: voice "$voiceId" ready');
      return _looksReady(assets) ? assets : null;
    } catch (e) {
      if (kDebugMode) debugPrint('Sherpa: voice install failed: $e');
      return null;
    }
  }
}

/// Native (non-web) Sherpa-ONNX TTS engine. Synthesizes a Piper voice
/// to PCM, writes a temp WAV, and plays it through `audioplayers`.
class SherpaTtsEngine {
  SherpaTtsEngine._();
  static final SherpaTtsEngine instance = SherpaTtsEngine._();

  sherpa.OfflineTts? _tts;
  AudioPlayer? _player;

  bool _initStarted = false;
  bool _initialized = false;
  bool _isSpeaking = false;

  Completer<bool>? _initCompleter;
  Completer<bool>? _speechCompleter;
  StreamSubscription<void>? _playerCompleteSub;

  bool get isInitialized => _initialized;
  bool get isSpeaking => _isSpeaking;

  /// Idempotent. Returns `false` if the voice can't be installed —
  /// callers should fall back to flutter_tts in that case.
  Future<bool> initialize() async {
    if (_initialized) return true;
    if (_initStarted) return _initCompleter?.future ?? Future.value(false);
    _initStarted = true;
    final completer = Completer<bool>();
    _initCompleter = completer;

    try {
      sherpa.initBindings();
      final voice = await _SherpaVoiceManager.instance.ensureReady();
      if (voice == null) {
        completer.complete(false);
        return false;
      }
      _tts = sherpa.OfflineTts(
        sherpa.OfflineTtsConfig(
          model: sherpa.OfflineTtsModelConfig(
            vits: sherpa.OfflineTtsVitsModelConfig(
              model: voice.modelPath,
              tokens: voice.tokensPath,
              dataDir: voice.dataDir,
            ),
            numThreads: 2,
            debug: false,
          ),
        ),
      );
      _player = AudioPlayer();
      _initialized = true;
      completer.complete(true);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Sherpa init failed: $e');
      completer.complete(false);
      return false;
    }
  }

  Future<bool> speak(String text, {double speed = 1.0}) async {
    if (!_initialized || _tts == null || _player == null) return false;
    if (text.trim().isEmpty) return false;
    await stop();

    final sherpa.GeneratedAudio audio;
    try {
      audio = _tts!.generate(text: text, sid: 0, speed: speed);
    } catch (e) {
      if (kDebugMode) debugPrint('Sherpa generate failed: $e');
      return false;
    }
    if (audio.samples.isEmpty || audio.sampleRate <= 0) return false;

    final tmp = await getTemporaryDirectory();
    final outPath =
        '${tmp.path}/sherpa_${DateTime.now().microsecondsSinceEpoch}.wav';
    final ok = sherpa.writeWave(
      filename: outPath,
      samples: audio.samples,
      sampleRate: audio.sampleRate,
    );
    if (!ok) return false;

    final completer = Completer<bool>();
    _speechCompleter = completer;
    _isSpeaking = true;

    await _playerCompleteSub?.cancel();
    _playerCompleteSub = _player!.onPlayerComplete.listen((_) {
      _isSpeaking = false;
      _completeSpeech(true);
      File(outPath).delete().catchError((_) => File(outPath));
    });

    try {
      await _player!.setReleaseMode(ReleaseMode.release);
      await _player!.play(DeviceFileSource(outPath));
    } catch (e) {
      if (kDebugMode) debugPrint('Sherpa playback failed: $e');
      _isSpeaking = false;
      _completeSpeech(false);
    }

    return completer.future;
  }

  Future<void> stop() async {
    if (!_isSpeaking && _speechCompleter == null) return;
    _isSpeaking = false;
    try {
      await _player?.stop();
    } catch (_) {/* ignore */}
    await _playerCompleteSub?.cancel();
    _playerCompleteSub = null;
    _completeSpeech(false);
  }

  void _completeSpeech(bool success) {
    final c = _speechCompleter;
    _speechCompleter = null;
    if (c != null && !c.isCompleted) c.complete(success);
  }

  Future<void> dispose() async {
    await _playerCompleteSub?.cancel();
    _playerCompleteSub = null;
    await _player?.dispose();
    _player = null;
    _tts?.free();
    _tts = null;
    _initialized = false;
  }
}
