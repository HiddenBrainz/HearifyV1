# HearifyV1: Swift → Flutter Migration Log

## Status: Parity reached (Apr 16 2026)

The Flutter port at `flutter/` now covers the full feature set of the Swift app except for the Vision/Camera module (deliberately deferred).

## Repository Layout

```
HearifyV1/                              (repo root)
├── flutter/                            ← production Flutter app
│   ├── lib/                            ← Dart sources (runs on iOS + Android + web)
│   ├── ios/                            ← Flutter's iOS shell (bundle: com.hearify.hearify)
│   ├── android/                        ← Flutter's Android shell (pkg: com.hearify.hearify)
│   ├── assets/
│   │   ├── csv/                        ← 25 training CSVs
│   │   └── audio/                      ← 514 mp3 recordings
│   └── pubspec.yaml
├── ios-legacy/                         ← the original SwiftUI app, archived
│   ├── HearifyV1/                      ← Swift sources
│   ├── HearifyV1.xcodeproj/
│   ├── HearifyV1Tests/
│   ├── HearifyV1UITests/
│   ├── Podfile
│   └── GoogleService-Info.plist        (bundle: VeerChopra.HearifyV1)
├── *.md                                ← original project docs (kept for reference)
└── MIGRATION_LOG.md                    (this file)
```

## Phase Status

| Phase | Scope | Status |
|---|---|---|
| 0 | Foundation — theme, routing, Riverpod, Firebase, CSV loader | ✅ |
| 1 | Education screens (Module 1, About, Terms, Privacy) | ✅ |
| 2 | Auth + onboarding (login, legal, consent, hearing type) | ✅ |
| 3 | Shared UI primitives (waveform, success animation, modern card) | ✅ |
| 4 | Advanced listening + AV speech test (TTS, background noise) | ✅ |
| 4.5 | Classic exercises (Matched Pairs, Word Recognition, etc.) | ✅ |
| 5 | Speaking practice (STT, phoneme DB, targeted, history) | ✅ |
| 6 | Progress + analytics + gamification (streak, XP, achievements) | ✅ |
| 7 | Conversations (3 sample scenarios, turn-by-turn practice) | ✅ |
| 8 | Clinician features on Firestore (linking code, dashboard) | ✅ |
| 9 | Cutover — Swift moved to `ios-legacy/` | ✅ |
| — | Vision / Camera (CameraManager, FaceDetection, mouth comparison) | 🚫 Skipped |

## Known Caveats

- **iOS Flutter builds** still require Xcode full install + `brew install cocoapods` + re-running `flutterfire configure --platforms=ios` to register the iOS app in Firebase. See the "iOS configuration is still pending" note from Phase 0.
- **Android Flutter builds** require `brew install --cask android-commandlinetools` and `flutter doctor --android-licenses`.
- **STT phoneme data** — `speech_to_text` doesn't expose phoneme-level confidence on Android the way `SFSpeechRecognizer` does on iOS. The port falls back to word-level Levenshtein similarity; phoneme-specific feedback is deferred.
- **Tongue-position canvas** in the phoneme visualization is deferred — the Dart screen shows the catalog + TTS preview but not the animated diagram. Low priority since the Vision module is deferred anyway.
- **Session history storage** currently lives in SharedPreferences only. Firestore sync of sessions (matching the Swift `FirebaseManager.syncSession`) is wired but gated on the (ported) gamification state converging with the Firestore patient doc.

## Next Steps (when the team is ready)

1. Switch Flutter's production bundle ID + package name from `com.hearify.hearify` → `com.hearify.v1` (matching Swift's `VeerChopra.HearifyV1` trademark).
2. Archive the Swift app on App Store Connect.
3. Submit the Flutter build for both iOS and Android stores.
4. Decommission any CloudKit-specific backend resources now that clinician linking is Firestore-only.

## How to Run

```
cd flutter
flutter pub get
flutter run -d chrome           # web
flutter run -d <device-id>      # iOS simulator / Android emulator once SDKs are configured
flutter build apk               # Android release
flutter build ios --no-codesign # iOS release (needs Xcode)
```
