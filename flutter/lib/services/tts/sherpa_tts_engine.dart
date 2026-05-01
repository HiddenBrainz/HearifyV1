// Public entrypoint for the Sherpa-ONNX Piper engine.
//
// `dart:ffi` (which `sherpa_onnx` depends on) doesn't compile to
// JavaScript, so on web we re-export a no-op stub that always reports
// `isInitialized = false` — `AudioService` then routes to flutter_tts
// for browser builds. Native targets get the real implementation.
export 'sherpa_tts_engine_stub.dart'
    if (dart.library.io) 'sherpa_tts_engine_io.dart';
