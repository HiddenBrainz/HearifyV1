# Hearify Phase 2 & 3 Implementation Guide

## Overview
This document outlines the implementation of Phase 2 (Speaking/Pronunciation) and Phase 3 (Facial Expression & Engagement) for the Hearify communication training app.

---

## 🎯 Phase 2: Speaking / Pronunciation Module

### Features Implemented
- ✅ **Speech-to-Text Recognition** - Using Apple's Speech framework
- ✅ **Phoneme-Level Pronunciation Scoring** - Word-by-word accuracy analysis
- ✅ **Intonation and Prosody Feedback** - Audio level variation analysis
- ✅ **Error Highlighting** - Visual feedback for problem words
- ✅ **Gamified Exercises** - Streaks, levels, badges, and XP system

### New Files Created

#### 1. `SpeechRecognitionManager.swift`
**Purpose:** Manages speech recording and pronunciation analysis

**Key Features:**
- Real-time speech recognition using `SFSpeechRecognizer`
- Phoneme-level accuracy scoring using Levenshtein distance algorithm
- Prosody analysis through audio level variation
- Detailed feedback generation
- Support for word and sentence pronunciation

**Main Methods:**
- `startRecording(expectedText:)` - Begin recording and analyzing speech
- `stopRecording()` - End recording and calculate scores
- `calculatePronunciationScore()` - Generate overall pronunciation score (0-1)
- `getPronunciationFeedback()` - Get user-friendly feedback messages

#### 2. `GamificationManager.swift`
**Purpose:** Handles all gamification aspects (levels, streaks, badges, points)

**Key Features:**
- Streak tracking (daily practice)
- Level progression with XP system
- Badge unlocking system (15+ different badges)
- Daily goal tracking
- Weekly statistics and analytics
- Persistent data storage with UserDefaults

**Badge Types:**
- Streak badges (3, 7, 14, 30, 100 days)
- Perfect score badges
- Exercise completion milestones (100 words, 50 sentences, etc.)
- Daily goal achievement

**Point System:**
- Word pronunciation: 10 base points
- Sentence pronunciation: 20 base points
- Conversation practice: 30 base points
- Multipliers based on score quality (1.0x - 1.5x)
- Streak bonus (1.2x for 7+ day streaks)

#### 3. `SpeakingPracticeView.swift`
**Purpose:** Main UI for speaking practice exercises

**Key Components:**
- Exercise card display with pronunciation tips
- Real-time recording controls with visual feedback
- Live transcription preview
- Comprehensive results view with:
  - Overall pronunciation score (circular progress)
  - Word-by-word accuracy breakdown
  - Color-coded feedback (green/yellow/red)
  - Detailed suggestions for improvement
- Progress tracking across multiple exercises
- Badge unlock celebrations

**Exercise Types:**
- Word pronunciation (individual words)
- Sentence pronunciation (full sentences)
- Conversation practice (natural dialogue)

---

## 📹 Phase 3: Facial Expression & Engagement Module

### Features Implemented
- ✅ **Video Recording** - Front/back camera support
- ✅ **Facial Expression Analysis** - Using Vision framework
- ✅ **Engagement Scoring** - Multi-factor engagement metrics
- ✅ **Real-time Feedback** - Live engagement indicators during recording
- ✅ **Detailed Analytics** - Expression timeline, recommendations, and metrics

### New Files Created

#### 4. `VideoRecordingManager.swift`
**Purpose:** Manages camera access and video recording

**Key Features:**
- Camera authorization handling
- AVFoundation-based video capture
- Front/back camera switching
- Recording duration tracking
- Temporary file management for recorded videos

**Main Methods:**
- `setupCaptureSession()` - Initialize camera preview
- `startRecording()` - Begin video recording
- `stopRecording()` - End recording and save file
- `switchCamera()` - Toggle between front/back cameras

#### 5. `FacialAnalysisManager.swift`
**Purpose:** Analyzes facial expressions and engagement from recorded videos

**Key Features:**
- Frame-by-frame facial landmark detection using Vision framework
- Expression classification (Neutral, Happy, Enthusiastic, Engaged, Speaking)
- Multiple engagement metrics:
  - **Smile Detection** - Mouth corner position analysis
  - **Eye Contact** - Pupil centering detection
  - **Eyebrow Movement** - Expressiveness indicator
  - **Lip Movement Clarity** - Mouth opening analysis for clear speech

**Analysis Metrics:**
- Smile percentage (0-100%)
- Eye contact percentage (0-100%)
- Lip movement clarity (0-100%)
- Expression variety score (0-100%)
- Overall engagement score (weighted combination)

**Scoring Algorithm:**
```
Overall Engagement =
  (Smile × 25%) +
  (Eye Contact × 30%) +
  (Expression Variety × 25%) +
  (Lip Clarity × 20%)
```

**Main Methods:**
- `analyzeRecordedVideo(url:completion:)` - Analyze full video asynchronously
- `analyzeFrame(cgImage:timestamp:)` - Single frame analysis
- `detectSmile()`, `detectEyeContact()`, `detectEyebrowMovement()` - Feature detection
- `generateRecommendations()` - Create actionable feedback

#### 6. `PresentationPracticeView.swift`
**Purpose:** Main UI for presentation and facial expression practice

**Screens:**
1. **Instructions** - Onboarding with tips and feature explanations
2. **Recording** - Live camera preview with real-time engagement overlay
3. **Processing** - Video analysis with progress indicator
4. **Results** - Comprehensive feedback display

**Results Components:**
- Overall engagement grade (A+ to D)
- Circular score visualization
- Detailed metric breakdowns with progress bars
- Expression timeline (scrollable snapshot view)
- Personalized recommendations
- Try again / Done actions

---

## 🎮 Unified Navigation

#### 7. `CommunicationHubView.swift`
**Purpose:** Central hub connecting all three phases of training

**Key Features:**
- User stats dashboard (level, streak, points, badges)
- Phase selection cards with visual indicators
- Progress overview with XP bar
- Recent achievements display
- Unified gamification across all phases

**Navigation Flow:**
- Phase 1 (Hearing) → Existing ContentView exercises
- Phase 2 (Speaking) → SpeakingPracticeView
- Phase 3 (Presentation) → PresentationPracticeView

---

## 🔐 Required Permissions

The `Info.plist` file includes the following privacy descriptions:

### Phase 2 Permissions:
- **NSSpeechRecognitionUsageDescription** - Speech recognition for pronunciation analysis
- **NSMicrophoneUsageDescription** - Microphone access for speech recording

### Phase 3 Permissions:
- **NSCameraUsageDescription** - Camera access for presentation recording
- **NSPhotoLibraryUsageDescription** - Photo library access for saving videos
- **NSPhotoLibraryAddUsageDescription** - Permission to add videos to library

---

## 📱 Integration Steps

### 1. Add Files to Xcode Project
Add all new Swift files to your Xcode project:
- SpeechRecognitionManager.swift
- GamificationManager.swift
- SpeakingPracticeView.swift
- VideoRecordingManager.swift
- FacialAnalysisManager.swift
- PresentationPracticeView.swift
- CommunicationHubView.swift

### 2. Update Info.plist
Merge the provided Info.plist permissions into your existing Info.plist or project settings.

In Xcode:
1. Select your project target
2. Go to "Info" tab
3. Add the privacy descriptions from the Info.plist file

### 3. Update App Entry Point
Modify `HearifyV1App.swift` to use the new CommunicationHubView:

```swift
@main
struct HearifyV1App: App {
    var body: some Scene {
        WindowGroup {
            CommunicationHubView()  // Changed from ContentView()
        }
    }
}
```

Alternatively, add a button in your existing ContentView to navigate to CommunicationHubView.

### 4. Add Required Frameworks
Ensure these frameworks are linked in your project:
- **Speech.framework** - For speech recognition
- **AVFoundation.framework** - For audio/video recording
- **Vision.framework** - For facial analysis

### 5. Test Permissions
When first running the app:
1. Grant microphone permission for Phase 2
2. Grant speech recognition permission for Phase 2
3. Grant camera permission for Phase 3
4. Test on a physical device (camera/mic not available in simulator)

---

## 🎨 UI/UX Design

### Color Scheme (AppTheme)
The implementation uses the existing AppTheme:
- `primaryBlue` - Main accent color
- `accentPurple` - Secondary accent
- `backgroundPrimary` - Main background
- `backgroundSecondary` - Card backgrounds
- `textPrimary` / `textSecondary` - Text colors

### Consistent Components
- **ResponsiveButton** - Reused from existing codebase
- **ModernCard** - Consistent card styling
- **Circular Progress Indicators** - Score visualization
- **Color-coded Feedback** - Green (excellent), Yellow (good), Red (needs work)

---

## 🔄 Data Flow

### Phase 2 (Speaking) Flow:
1. User selects speaking exercise
2. `SpeakingPracticeView` displays exercise with target text
3. User taps record → `SpeechRecognitionManager.startRecording()`
4. Real-time transcription shown during recording
5. User stops → Analysis begins
6. Phoneme accuracy calculated using Levenshtein distance
7. Prosody score from audio level variance
8. Results displayed with visual feedback
9. `GamificationManager` awards points and updates progress
10. Badge unlock if criteria met

### Phase 3 (Presentation) Flow:
1. User enters presentation practice
2. Instructions screen with tips
3. Camera preview loads via `VideoRecordingManager`
4. Real-time engagement overlay during recording
5. Video saved to temporary location
6. `FacialAnalysisManager` processes video frame-by-frame
7. Facial landmarks extracted using Vision
8. Metrics calculated (smile, eye contact, lip clarity, expressions)
9. Results screen with detailed breakdown and recommendations
10. Option to save video or retry

---

## 🧪 Testing Recommendations

### Phase 2 Testing:
1. Test with various words (easy → difficult)
2. Test with clear vs. unclear pronunciation
3. Verify phoneme-level accuracy highlighting
4. Test streak persistence across app restarts
5. Verify badge unlocking at milestones
6. Test with background noise

### Phase 3 Testing:
1. Test in different lighting conditions
2. Verify facial detection with/without glasses
3. Test expression classification accuracy
4. Verify camera switching works
5. Test with different face angles
6. Ensure video analysis doesn't freeze UI (async processing)

---

## 🚀 Future Enhancements

### Phase 2 Potential Additions:
- [ ] Custom word/sentence lists
- [ ] IPA (International Phonetic Alphabet) display
- [ ] Comparison playback (user vs. reference audio)
- [ ] Accent-specific feedback
- [ ] Multi-language support
- [ ] Social features (share progress, compete with friends)

### Phase 3 Potential Additions:
- [ ] Gesture analysis (hand movements)
- [ ] Posture detection
- [ ] Emotion intensity scoring
- [ ] Presentation timer and pacing analysis
- [ ] Slide integration for full presentation practice
- [ ] Eye tracking for audience engagement simulation

### Unified Enhancements:
- [ ] Cloud sync for cross-device progress
- [ ] AI-powered personalized learning paths
- [ ] Video tutorials for each exercise
- [ ] Leaderboards and competitions
- [ ] Export progress reports (PDF/CSV)

---

## 📚 API Reference

### SpeechRecognitionManager

```swift
class SpeechRecognitionManager: ObservableObject {
    @Published var isRecording: Bool
    @Published var recognizedText: String
    @Published var pronunciationScore: Double
    @Published var phonemeAccuracy: [PhonemeScore]

    func startRecording(expectedText: String)
    func stopRecording()
    func getPronunciationFeedback() -> String
    func getDetailedFeedback() -> [String]
}
```

### FacialAnalysisManager

```swift
class FacialAnalysisManager: ObservableObject {
    @Published var isAnalyzing: Bool
    @Published var analysisProgress: Double
    @Published var facialAnalysisResults: FacialAnalysisResult?

    func analyzeRecordedVideo(url: URL, completion: @escaping (FacialAnalysisResult?) -> Void)
}

struct FacialAnalysisResult {
    let smilePercentage: Double
    let eyeContactPercentage: Double
    let lipMovementClarity: Double
    let expressionVarietyScore: Double
    let overallEngagementScore: Double
    let recommendations: [String]
}
```

### GamificationManager

```swift
class GamificationManager: ObservableObject {
    @Published var currentStreak: Int
    @Published var currentLevel: Int
    @Published var totalPoints: Int
    @Published var unlockedBadges: [Badge]

    func addPoints(for score: Double, exerciseType: ExerciseType)
    func getProgressToNextLevel() -> Double
    func getWeeklyAverage() -> Double
}
```

---

## 💡 Architecture Notes

### MVVM Pattern
- **Models:** PracticeItem, Badge, ExpressionSnapshot, FacialAnalysisResult
- **ViewModels:** SpeechRecognitionManager, FacialAnalysisManager, GamificationManager
- **Views:** SpeakingPracticeView, PresentationPracticeView, CommunicationHubView

### Async/Await
Video analysis uses Swift concurrency for non-blocking UI:
```swift
Task {
    let results = try await processVideoFrames(asset: asset, duration: duration)
    // Update UI on main thread
}
```

### Persistence
- UserDefaults for gamification data (lightweight, fast)
- Temporary files for video recordings (cleaned up automatically)
- Option to expand to CoreData for more complex data

---

## 📞 Support & Questions

For implementation questions or issues:
1. Check this documentation first
2. Review inline code comments in each file
3. Test on physical device (not simulator) for camera/mic features
4. Ensure all permissions are granted in Settings

---

**Last Updated:** October 2025
**Version:** 1.0
**Compatible with:** iOS 15.0+
