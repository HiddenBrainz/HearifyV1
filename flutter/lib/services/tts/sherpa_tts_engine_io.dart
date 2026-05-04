import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Resolved on-disk paths for the Kokoro v0_19 bundle — exactly what
/// `OfflineTtsKokoroModelConfig` needs.
class _KokoroAssets {
  const _KokoroAssets({
    required this.modelPath,
    required this.voicesPath,
    required this.tokensPath,
    required this.dataDir,
    required this.lexiconPath,
  });

  final String modelPath;
  final String voicesPath;
  final String tokensPath;
  final String dataDir;
  final String lexiconPath;
}

/// Downloads + caches the Sherpa Kokoro INT8 bundle (~88 MB) into the
/// app docs dir. INT8 is plenty for runtime free-text synthesis and
/// avoids a 270 MB FP32 download on first launch.
///
/// Cached layout:
///   `<appDocs>/sherpa_voices/kokoro-int8-en-v0_19/`
///     `model.int8.onnx`
///     `voices.bin`
///     `tokens.txt`
///     `lexicon-us-en.txt`
///     `espeak-ng-data/`
class _SherpaKokoroManager {
  _SherpaKokoroManager._();
  static final _SherpaKokoroManager instance = _SherpaKokoroManager._();

  static const String _bundleId = 'kokoro-int8-en-v0_19';
  static const String _tarballUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/'
      'tts-models/$_bundleId.tar.bz2';

  Future<Directory> _bundleDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/sherpa_voices/$_bundleId');
  }

  _KokoroAssets _assetsFor(Directory dir) => _KokoroAssets(
        modelPath: '${dir.path}/model.int8.onnx',
        voicesPath: '${dir.path}/voices.bin',
        tokensPath: '${dir.path}/tokens.txt',
        dataDir: '${dir.path}/espeak-ng-data',
        lexiconPath: '${dir.path}/lexicon-us-en.txt',
      );

  bool _looksReady(_KokoroAssets a) =>
      File(a.modelPath).existsSync() &&
      File(a.voicesPath).existsSync() &&
      File(a.tokensPath).existsSync() &&
      Directory(a.dataDir).existsSync();

  Future<_KokoroAssets?> ensureReady({
    void Function(double fraction)? onProgress,
  }) async {
    final dir = await _bundleDir();
    final assets = _assetsFor(dir);
    if (_looksReady(assets)) return assets;

    if (kDebugMode) {
      debugPrint('Sherpa: Kokoro bundle missing, downloading…');
    }
    await dir.create(recursive: true);

    try {
      final request = http.Request('GET', Uri.parse(_tarballUrl));
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
        // Strip the leading `<bundleId>/` prefix bundled by Sherpa.
        final segments = entry.name.split('/');
        if (segments.length < 2) continue;
        final relPath = segments.sublist(1).join('/');
        if (relPath.isEmpty) continue;
        final outFile = File('${dir.path}/$relPath');
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(entry.content as List<int>, flush: true);
      }
      if (kDebugMode) debugPrint('Sherpa: Kokoro bundle ready');
      return _looksReady(assets) ? assets : null;
    } catch (e) {
      if (kDebugMode) debugPrint('Sherpa: Kokoro install failed: $e');
      return null;
    }
  }
}

/// Native (non-web) Sherpa-ONNX TTS engine using the Kokoro v0_19 INT8
/// model. Runtime path for Custom Practice free-text input. Synthesizes
/// PCM, writes a temp WAV, and plays it through `audioplayers`.
class SherpaTtsEngine {
  SherpaTtsEngine._();
  static final SherpaTtsEngine instance = SherpaTtsEngine._();

  /// Voice id → speaker id (sid) for the kokoro-en-v0_19 bundle.
  /// Standard kokoro-onnx voices.bin ordering — the four voices the
  /// app exposes plus the rest for safety. If a voice isn't in the
  /// map we fall back to af_bella's sid.
  static const Map<String, int> _sidByVoiceId = {
    'af':          0,
    'af_bella':    1,
    'af_nicole':   2,
    'af_sarah':    3,
    'af_sky':      4,
    'am_adam':     5,
    'am_michael':  6,
    'bf_emma':     7,
    'bf_isabella': 8,
    'bm_george':   9,
    'bm_lewis':   10,
  };
  static const int _defaultSid = 1; // af_bella

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

  /// Idempotent. Returns `false` if the Kokoro bundle can't be installed —
  /// callers should fall back to flutter_tts in that case.
  Future<bool> initialize() async {
    if (_initialized) return true;
    if (_initStarted) return _initCompleter?.future ?? Future.value(false);
    _initStarted = true;
    final completer = Completer<bool>();
    _initCompleter = completer;

    try {
      sherpa.initBindings();
      final assets = await _SherpaKokoroManager.instance.ensureReady();
      if (assets == null) {
        completer.complete(false);
        return false;
      }
      _tts = sherpa.OfflineTts(
        sherpa.OfflineTtsConfig(
          model: sherpa.OfflineTtsModelConfig(
            kokoro: sherpa.OfflineTtsKokoroModelConfig(
              model: assets.modelPath,
              voices: assets.voicesPath,
              tokens: assets.tokensPath,
              dataDir: assets.dataDir,
              lexicon: File(assets.lexiconPath).existsSync()
                  ? assets.lexiconPath
                  : '',
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
      if (kDebugMode) debugPrint('Sherpa Kokoro init failed: $e');
      completer.complete(false);
      return false;
    }
  }

  /// Synthesize [text] with the given Kokoro [voice] (e.g. `'af_bella'`).
  /// Unknown voice ids fall back to af_bella.
  Future<bool> speak(
    String text, {
    double speed = 1.0,
    String voice = 'af_bella',
  }) async {
    if (!_initialized || _tts == null || _player == null) return false;
    if (text.trim().isEmpty) return false;
    await stop();

    final sid = _sidByVoiceId[voice] ?? _defaultSid;

    final sherpa.GeneratedAudio audio;
    try {
      audio = _tts!.generate(text: text, sid: sid, speed: speed);
    } catch (e) {
      if (kDebugMode) debugPrint('Sherpa Kokoro generate failed: $e');
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
      if (kDebugMode) debugPrint('Sherpa Kokoro playback failed: $e');
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
