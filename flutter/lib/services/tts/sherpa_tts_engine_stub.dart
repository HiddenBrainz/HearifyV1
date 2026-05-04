/// Web stub for [SherpaTtsEngine]. The Sherpa-ONNX Dart bindings rely
/// on `dart:ffi`, which doesn't compile to JavaScript — so on web we
/// expose a no-op class with the same surface and `AudioService` falls
/// through to `flutter_tts`.
class SherpaTtsEngine {
  SherpaTtsEngine._();
  static final SherpaTtsEngine instance = SherpaTtsEngine._();

  bool get isInitialized => false;
  bool get isSpeaking => false;

  Future<bool> initialize() async => false;
  Future<bool> speak(
    String text, {
    double speed = 1.0,
    String voice = 'af_bella',
  }) async =>
      false;
  Future<void> stop() async {}
  Future<void> dispose() async {}
}
