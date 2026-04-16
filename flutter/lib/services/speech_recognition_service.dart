import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Recognition result exposed to the UI.
///
/// `phonemes` is nullable: iOS's SFSpeechRecognizer returns phoneme-level
/// confidence but Android's platform STT does NOT. Callers should degrade
/// gracefully to word-level scoring when phonemes are absent.
class RecognitionResult {
  const RecognitionResult({
    required this.words,
    required this.confidence,
    required this.isFinal,
    this.phonemes,
  });

  final String words;
  final double confidence;
  final bool isFinal;
  final List<PhonemeHit>? phonemes;
}

class PhonemeHit {
  const PhonemeHit({required this.symbol, required this.confidence});
  final String symbol;
  final double confidence;
}

/// Port of HearifyV1/Managers/SpeechRecognitionManager.swift.
/// Wraps the `speech_to_text` plugin with a first-word-detection callback
/// that the Swift manager exposes. Works on iOS + Android + web (web uses
/// the browser's WebSpeech API).
class SpeechRecognitionService extends ChangeNotifier {
  SpeechRecognitionService();

  final SpeechToText _stt = SpeechToText();

  bool _authorized = false;
  bool _isRecording = false;
  bool _available = false;
  String _recognizedText = '';
  double _audioLevel = 0.0;
  String? _lastError;

  void Function(String firstWord)? onFirstWordDetected;

  bool get isAuthorized => _authorized;
  bool get isRecording => _isRecording;
  bool get available => _available;
  String get recognizedText => _recognizedText;
  double get audioLevel => _audioLevel;
  String? get lastError => _lastError;

  Future<bool> requestAuthorization() async {
    try {
      _available = await _stt.initialize(
        onStatus: (status) {
          if (status == SpeechToText.notListeningStatus ||
              status == SpeechToText.doneStatus) {
            _isRecording = false;
            notifyListeners();
          }
        },
        onError: (e) {
          _lastError = e.errorMsg;
          _isRecording = false;
          notifyListeners();
        },
        debugLogging: false,
      );
      _authorized = _available;
      notifyListeners();
      return _available;
    } catch (e) {
      _lastError = e.toString();
      _available = false;
      _authorized = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> startRecording({String? expectedText}) async {
    if (!_authorized) {
      final ok = await requestAuthorization();
      if (!ok) return;
    }
    _recognizedText = '';
    _lastError = null;
    _isRecording = true;
    notifyListeners();

    bool firstWordEmitted = false;

    await _stt.listen(
      onResult: (r) {
        _recognizedText = r.recognizedWords;
        if (!firstWordEmitted && r.recognizedWords.trim().isNotEmpty) {
          final first = r.recognizedWords.trim().split(RegExp(r'\s+')).first;
          onFirstWordDetected?.call(first);
          firstWordEmitted = true;
        }
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
      onSoundLevelChange: (level) {
        _audioLevel = (level / 10).clamp(0.0, 1.0);
        notifyListeners();
      },
      localeId: 'en-US',
    );
  }

  Future<RecognitionResult?> stopRecording() async {
    if (!_isRecording) return null;
    await _stt.stop();
    _isRecording = false;
    final confidence = _confidenceOf(_stt.lastRecognizedWords);
    notifyListeners();
    return RecognitionResult(
      words: _recognizedText,
      confidence: confidence,
      isFinal: true,
    );
  }

  Future<void> cancel() async {
    if (!_isRecording) return;
    await _stt.cancel();
    _isRecording = false;
    notifyListeners();
  }

  double _confidenceOf(String lastWords) {
    // speech_to_text doesn't expose a guaranteed confidence on all platforms;
    // fall back to 0 when unknown so the UI treats it as "unknown".
    final results = _stt.lastRecognizedWords;
    if (results.isEmpty) return 0;
    return 0.0;
  }

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
  }
}

final sttServiceProvider =
    ChangeNotifierProvider<SpeechRecognitionService>((ref) {
  final s = SpeechRecognitionService();
  ref.onDispose(s.dispose);
  return s;
});

/// Simple similarity score (0..1) between what the user said and the
/// expected target. Used in word/sentence-level scoring where no phoneme
/// data is available.
///
/// Based on normalized Levenshtein distance to mirror the Swift
/// `SpeechRecognitionManagerAdvanced` scoring approach.
double pronunciationSimilarity(String expected, String actual) {
  final a = expected.toLowerCase().trim();
  final b = actual.toLowerCase().trim();
  if (a.isEmpty && b.isEmpty) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  final dist = _levenshtein(a, b);
  final maxLen = a.length > b.length ? a.length : b.length;
  return 1 - dist / maxLen;
}

int _levenshtein(String a, String b) {
  final m = a.length, n = b.length;
  final dp = List<int>.filled(n + 1, 0);
  for (var j = 0; j <= n; j++) {
    dp[j] = j;
  }
  for (var i = 1; i <= m; i++) {
    var prev = dp[0];
    dp[0] = i;
    for (var j = 1; j <= n; j++) {
      final tmp = dp[j];
      if (a[i - 1] == b[j - 1]) {
        dp[j] = prev;
      } else {
        dp[j] = 1 +
            [prev, dp[j - 1], dp[j]].reduce((v, e) => v < e ? v : e);
      }
      prev = tmp;
    }
  }
  return dp[n];
}
