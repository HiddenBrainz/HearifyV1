//
//  SpeakingPracticeView.swift
//  HearifyV1
//
//  UI for speaking practice exercises with pronunciation feedback
//  Phase 2: Speaking/Pronunciation Module
//

import SwiftUI

// MARK: - Practice Item Model
struct SpeakingPracticeItem {
    let id: UUID
    let text: String
    let type: ExerciseType
    let tip: String

    init(id: UUID = UUID(), text: String, type: ExerciseType, tip: String = "") {
        self.id = id
        self.text = text
        self.type = type
        self.tip = tip
    }
}

// MARK: - Speaking Practice View
struct SpeakingPracticeView: View {
    @StateObject private var speechManager = SpeechRecognitionManagerAdvanced()
    // Use shared instances to avoid creating duplicates (performance issue)
    @ObservedObject private var gamificationManager = GamificationManager.shared
    @ObservedObject private var progressManager = ProgressTrackingManager.shared
    @State private var currentExerciseIndex = 0
    @State private var showResults = false
    @State private var showBadgeCelebration = false
    @State private var showPermissionAlert = false
    @State private var showWaveformComparison = false
    @State private var exerciseStartTime: Date?
    @State private var showCameraMode = false
    @State private var firstWordDetected = false // Track when first word is detected
    @State private var isPlayingAudio = false // Track when audio is playing before recording
    @State private var shuffledExercises: [SpeakingPracticeItem] = [] // Shuffled exercises array
    var onDismiss: () -> Void = {}

    // Sample exercises - Comprehensive pronunciation practice
    private let baseExercises: [SpeakingPracticeItem] = [
        // Basic Words (Easy)
        SpeakingPracticeItem(
            text: "Hello",
            type: .word,
            tip: "Start with a strong 'H' sound, then 'eh-LOW'"
        ),
        SpeakingPracticeItem(
            text: "Thank you",
            type: .word,
            tip: "TH sound: tongue between teeth. 'THANK yoo'"
        ),
        SpeakingPracticeItem(
            text: "Water",
            type: .word,
            tip: "American: WAH-der, British: WAW-ter"
        ),
        SpeakingPracticeItem(
            text: "Coffee",
            type: .word,
            tip: "KAW-fee (short 'o' sound, stress first syllable)"
        ),
        SpeakingPracticeItem(
            text: "Monday",
            type: .word,
            tip: "MUN-day (like 'fun', not 'moon')"
        ),

        // Medium Difficulty Words
        SpeakingPracticeItem(
            text: "Beautiful",
            type: .word,
            tip: "BYOO-ti-ful (3 syllables, stress first)"
        ),
        SpeakingPracticeItem(
            text: "Important",
            type: .word,
            tip: "im-POR-tant (stress middle syllable)"
        ),
        SpeakingPracticeItem(
            text: "Comfortable",
            type: .word,
            tip: "KUMF-ter-bul (3 syllables, not 4)"
        ),
        SpeakingPracticeItem(
            text: "Restaurant",
            type: .word,
            tip: "RES-tuh-ront (stress first syllable)"
        ),
        SpeakingPracticeItem(
            text: "Definitely",
            type: .word,
            tip: "DEF-in-it-lee (4 syllables, not 'definately')"
        ),

        // Challenging Words
        SpeakingPracticeItem(
            text: "Pronunciation",
            type: .word,
            tip: "pruh-nun-see-AY-shun (5 syllables)"
        ),
        SpeakingPracticeItem(
            text: "Communication",
            type: .word,
            tip: "kuh-myoo-ni-KAY-shun (5 syllables)"
        ),
        SpeakingPracticeItem(
            text: "Massachusetts",
            type: .word,
            tip: "mass-uh-CHOO-sits (4 syllables)"
        ),
        SpeakingPracticeItem(
            text: "Phenomenon",
            type: .word,
            tip: "fuh-NOM-uh-non (4 syllables, stress second)"
        ),
        SpeakingPracticeItem(
            text: "Uncomfortable",
            type: .word,
            tip: "un-KUMF-ter-bul (stress second syllable)"
        ),

        // Common Problem Words
        SpeakingPracticeItem(
            text: "Three",
            type: .word,
            tip: "TH-REE (tongue between teeth for TH)"
        ),
        SpeakingPracticeItem(
            text: "Thirty",
            type: .word,
            tip: "THIR-tee (not 'tree' or 'dirty')"
        ),
        SpeakingPracticeItem(
            text: "Library",
            type: .word,
            tip: "LY-brair-ee (3 syllables, not 'lie-berry')"
        ),
        SpeakingPracticeItem(
            text: "February",
            type: .word,
            tip: "FEB-roo-air-ee (4 syllables, don't skip the first 'r')"
        ),
        SpeakingPracticeItem(
            text: "Veterinarian",
            type: .word,
            tip: "vet-er-in-AIR-ee-an (6 syllables)"
        ),

        // Short Sentences (Easy)
        SpeakingPracticeItem(
            text: "Good morning",
            type: .sentence,
            tip: "GOOD MOR-ning (stress both words equally)"
        ),
        SpeakingPracticeItem(
            text: "How are you",
            type: .sentence,
            tip: "Natural flow: 'How-are-you' as one phrase"
        ),
        SpeakingPracticeItem(
            text: "Nice to meet you",
            type: .sentence,
            tip: "NICE to MEET you (stress 'nice' and 'meet')"
        ),
        SpeakingPracticeItem(
            text: "Have a good day",
            type: .sentence,
            tip: "Link words smoothly: 'Have-a good day'"
        ),
        SpeakingPracticeItem(
            text: "See you later",
            type: .sentence,
            tip: "SEE you LAY-ter (casual pronunciation)"
        ),

        // Medium Sentences
        SpeakingPracticeItem(
            text: "The weather is beautiful today",
            type: .sentence,
            tip: "Stress: WEATHER, BEAU-ti-ful, TO-day"
        ),
        SpeakingPracticeItem(
            text: "I would like a cup of coffee",
            type: .sentence,
            tip: "Contract: I'd like a cup-a coffee (natural speech)"
        ),
        SpeakingPracticeItem(
            text: "Can you help me with this",
            type: .sentence,
            tip: "Rising intonation at the end (it's a question)"
        ),
        SpeakingPracticeItem(
            text: "Where is the nearest restaurant",
            type: .sentence,
            tip: "WHERE is the NEAR-est RES-tuh-ront"
        ),
        SpeakingPracticeItem(
            text: "I am going to the library",
            type: .sentence,
            tip: "Contract: I'm going-to (gonna) the library"
        ),
    ]

    // Use shuffled exercises or base if not shuffled yet
    private var exercises: [SpeakingPracticeItem] {
        shuffledExercises.isEmpty ? baseExercises : shuffledExercises
    }

    private var currentExercise: SpeakingPracticeItem {
        exercises[currentExerciseIndex]
    }

    // Helper function to set up first-word detection callback
    private func setupFirstWordDetectionCallback() {
        speechManager.onFirstWordDetected = {
            // Trigger haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Update state
            firstWordDetected = true
            print("🎉 First word detected - haptic feedback triggered!")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    // CRITICAL: Stop recording before dismissing
                    if speechManager.isRecording {
                        speechManager.stopRecording()
                        print("🛑 Stopped recording via back button")
                    }
                    speechManager.stopSpeaking()
                    onDismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Speaking Practice")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text("Level \(gamificationManager.currentLevel)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(gamificationManager.currentStreak)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Main content
            ScrollView {
                VStack(spacing: 16) {
                    // Progress
                    VStack(spacing: 8) {
                        Text("Exercise \(currentExerciseIndex + 1) of \(exercises.count)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)

                        ProgressView(value: Double(currentExerciseIndex + 1), total: Double(exercises.count))
                            .tint(AppTheme.primaryBlue)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4)

                    if showResults, let result = speechManager.pronunciationResult {
                        // RESULTS VIEW
                        resultsViewSimple(result: result)
                    } else {
                        // EXERCISE VIEW
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: currentExercise.type == .word ? "textformat.size" : "quote.bubble.fill")
                                    .foregroundColor(.white)
                                Text(currentExercise.type.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: currentExercise.type == .word ?
                                        [AppTheme.accentOrange, AppTheme.accentOrange.opacity(0.8)] :
                                        [AppTheme.info, AppTheme.info.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)

                            Text(currentExercise.text)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(AppTheme.warning)
                                Text(currentExercise.tip)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding()
                            .background(AppTheme.warning.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4)

                        // Hear Pronunciation Button
                        Button(action: {
                            speechManager.playCorrectPronunciation(text: currentExercise.text)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(.system(size: 20))
                                Text("Hear Correct Pronunciation")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.success, AppTheme.success.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 4)
                        }
                        .padding(.horizontal)

                        // Camera Mode Button (Phase 3)
                        Button(action: {
                            showCameraMode = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                Text("Practice with Camera")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.6, green: 0.4, blue: 0.9), Color(red: 0.5, green: 0.3, blue: 0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 4)
                        }
                        .padding(.horizontal)

                        Text("OR")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)

                        // Microphone button
                        VStack(spacing: 12) {
                            Button(action: {
                                if speechManager.isRecording {
                                    // Trigger haptic feedback when stopping
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()

                                    speechManager.stopRecording()
                                    print("🛑 Recording stopped by user")

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showResults = true
                                    }
                                } else {
                                    if !speechManager.isAuthorized {
                                        showPermissionAlert = true
                                        speechManager.requestAuthorization()
                                    } else {
                                        exerciseStartTime = Date()  // Track start time
                                        firstWordDetected = false  // Reset detection state
                                        setupFirstWordDetectionCallback()  // Set up callback
                                        speechManager.startRecording(expectedText: currentExercise.text)
                                    }
                                }
                            }) {
                                ZStack {
                                    // Outer pulse ring when recording
                                    if speechManager.isRecording {
                                        Circle()
                                            .stroke(AppTheme.error.opacity(0.3), lineWidth: 4)
                                            .frame(width: 140, height: 140)
                                            .scaleEffect(firstWordDetected ? 1.1 : 1.0)
                                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: firstWordDetected)
                                    }

                                    // Main circle
                                    Circle()
                                        .fill(speechManager.isRecording ? AppTheme.error : AppTheme.success)
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.white)
                                        )
                                        .shadow(radius: 8)

                                    // Checkmark overlay when first word detected
                                    if firstWordDetected {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.green)
                                                    .background(Circle().fill(Color.white).frame(width: 20, height: 20))
                                                    .offset(x: -5, y: -5)
                                            }
                                        }
                                        .frame(width: 120, height: 120)
                                    }
                                }
                            }

                            // Dynamic status text based on state
                            if isPlayingAudio {
                                HStack(spacing: 6) {
                                    Image(systemName: "speaker.wave.3.fill")
                                        .foregroundColor(AppTheme.primaryBlue)
                                    Text("🔊 Playing word... Listen carefully!")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.primaryBlue)
                            } else if speechManager.isRecording {
                                if firstWordDetected {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Word detected! Tap stop when done")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.green)
                                } else {
                                    VStack(spacing: 4) {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(AppTheme.error)
                                                .frame(width: 8, height: 8)
                                            Text("Listening... Start speaking!")
                                        }
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppTheme.error)

                                        Text("Tip: You can spell out the word if needed")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                            } else {
                                Text("🎤 Tap to record or wait for auto-start")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(.vertical, 20)

                        // BIG STOP BUTTON - Separate and obvious when recording
                        if speechManager.isRecording {
                            Button(action: {
                                // Trigger haptic feedback when stopping
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()

                                speechManager.stopRecording()
                                print("🛑 Recording stopped by user via STOP button")

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showResults = true
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 28))
                                    Text("STOP & GET FEEDBACK")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    LinearGradient(
                                        colors: [AppTheme.error, AppTheme.error.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: AppTheme.error.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        }

                        // Live transcription while recording
                        if speechManager.isRecording {
                            VStack(spacing: 12) {
                                VStack(spacing: 8) {
                                    HStack {
                                        Circle()
                                            .fill(AppTheme.error)
                                            .frame(width: 8, height: 8)
                                        Text("LISTENING...")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.error)
                                    }

                                    Text(speechManager.recognizedText.isEmpty ? "Speak now..." : speechManager.recognizedText)
                                        .font(.system(size: 16))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .frame(minHeight: 50)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 4)

                                // Replay word button while recording
                                Button(action: {
                                    speechManager.playCorrectPronunciation(text: currentExercise.text)
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 16))
                                        Text("Replay Word")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(AppTheme.primaryBlue)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.primaryBlue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
        .onAppear {
            // Shuffle exercises on first appearance for variety
            if shuffledExercises.isEmpty {
                shuffledExercises = baseExercises.shuffled()
                print("🔀 Exercises shuffled - total: \(shuffledExercises.count)")
            }
            
            speechManager.requestAuthorization()
            // Set session start time for progress tracking
            if exerciseStartTime == nil {
                exerciseStartTime = Date()
                print("📝 Phase 1 session started at \(Date())")
            }

            // Set up first word detection callback
            setupFirstWordDetectionCallback()

            // AUTO-PLAY AUDIO FIRST, THEN AUTO-START RECORDING
            // This ensures the user hears the word before recording starts
            if speechManager.isAuthorized && !speechManager.isRecording {
                firstWordDetected = false // Reset for new exercise

                // Step 1: Play the correct pronunciation
                isPlayingAudio = true
                speechManager.playCorrectPronunciation(text: currentExercise.text)
                print("🔊 Auto-playing pronunciation: \(currentExercise.text)")

                // Step 2: Start recording after audio finishes (typical duration: 1-3 seconds)
                // We wait 2.5 seconds to ensure audio has finished playing
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    isPlayingAudio = false
                    if !self.showResults { // Only start recording if we're not already in results
                        speechManager.startRecording(expectedText: currentExercise.text)
                        print("🎤 Auto-started recording after audio playback for: \(currentExercise.text)")
                    }
                }
            }
        }
        .onDisappear {
            // CRITICAL: Clean up audio engine and speech when user exits
            print("👋 SpeakingPracticeView disappeared - cleaning up audio resources")
            
            // Stop recording and clean up audio engine
            if speechManager.isRecording {
                speechManager.stopRecording()
            }
            
            // Stop any ongoing speech synthesis
            speechManager.stopSpeaking()
            
            // Complete reset to ensure audio engine is fully stopped
            speechManager.resetForNewSession()
            
            print("✅ Audio resources cleaned up successfully")
        }
        .alert("Microphone Permission Required", isPresented: $showPermissionAlert) {
            Button("OK") {
                showPermissionAlert = false
            }
        } message: {
            Text("Please grant microphone and speech recognition permissions in Settings to use this feature. Tap the microphone button again after granting permissions.")
        }
        .fullScreenCover(isPresented: $showWaveformComparison) {
            if let result = speechManager.pronunciationResult {
                WaveformComparisonView(
                    userAudioLevels: result.audioLevels,
                    expectedText: result.expectedText,
                    recognizedText: result.recognizedText,
                    onDismiss: {
                        showWaveformComparison = false
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showCameraMode) {
            CameraPracticeView(
                exerciseText: currentExercise.text,
                phoneme: extractPhoneme(from: currentExercise.text),
                onDismiss: {
                    showCameraMode = false
                }
            )
        }
    }

    // Extract primary phoneme from exercise text (simplified)
    private func extractPhoneme(from text: String) -> String {
        // Map common words to their primary phoneme for camera feedback
        let phonemeMap: [String: String] = [
            "sheep": "iː",
            "ship": "ɪ",
            "food": "uː",
            "book": "ʊ",
            "bed": "ɛ",
            "cup": "ʌ",
            "cat": "æ",
            "father": "ɑː",
            "think": "θ",
            "fish": "f",
            "we": "w",
        ]

        let lowercased = text.lowercased()
        for (word, phoneme) in phonemeMap {
            if lowercased.contains(word) {
                return phoneme
            }
        }

        // Default to schwa for unknown
        return "ə"
    }

    // MARK: - Header View
    private func headerView(layout: ResponsiveLayoutHelper) -> some View {
        HStack {
            Button(action: { onDismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Speaking Practice")
                    .font(.system(size: layout.titleFontSize * 0.6, weight: .bold))
                    .foregroundColor(.white)

                Text("Level \(gamificationManager.currentLevel)")
                    .font(.system(size: layout.bodyFontSize * 0.8))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // Stats
            VStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(gamificationManager.currentStreak)")
                    .font(.system(size: layout.bodyFontSize * 0.8, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(AppTheme.primaryGradient)
    }

    // MARK: - Progress View
    private func progressView(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard {
            VStack(spacing: layout.spacingS) {
                Text("Exercise \(currentExerciseIndex + 1) of \(exercises.count)")
                    .font(.system(size: layout.bodyFontSize, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.backgroundSecondary)
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(AppTheme.primaryGradient)
                        .frame(maxWidth: .infinity)
                        .frame(height: 6)
                        .scaleEffect(x: CGFloat(currentExerciseIndex + 1) / CGFloat(exercises.count), y: 1, anchor: .leading)
                        .cornerRadius(3)
                }
                .frame(height: 6)
            }
        }
    }

    // MARK: - Exercise View
    private func exerciseView(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard {
            VStack(spacing: layout.spacingL) {
                // Exercise type badge
                HStack {
                    Image(systemName: currentExercise.type == .word ? "textformat.size" : "quote.bubble.fill")
                        .foregroundColor(.white)
                    Text(currentExercise.type.rawValue)
                        .font(.system(size: layout.bodyFontSize * 0.9, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, layout.padding)
                .padding(.vertical, layout.spacingS)
                .background(AppTheme.accentGradient)
                .cornerRadius(AppTheme.radiusSmall)

                // Text to speak
                Text(currentExercise.text)
                    .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, layout.spacingL)

                // Pronunciation tip
                if !currentExercise.tip.isEmpty {
                    HStack(spacing: layout.spacingS) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(AppTheme.warning)
                        Text(currentExercise.tip)
                            .font(.system(size: layout.bodyFontSize * 0.9))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(AppTheme.warning.opacity(0.1))
                    .cornerRadius(AppTheme.radiusSmall)
                }
            }
        }
    }

    // MARK: - Recording Controls
    private func recordingControls(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: layout.spacing) {
            // Microphone button
            Button(action: {
                if speechManager.isRecording {
                    speechManager.stopRecording()
                    // Wait for results
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showResults = true
                    }
                } else {
                    // Check authorization first
                    if !speechManager.isAuthorized {
                        showPermissionAlert = true
                        speechManager.requestAuthorization()
                    } else {
                        speechManager.startRecording(expectedText: currentExercise.text)
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(speechManager.isRecording ? AppTheme.error : AppTheme.success)
                        .frame(width: layout.imageSize * 0.8, height: layout.imageSize * 0.8)
                        .shadow(color: AppTheme.buttonShadow, radius: 8, x: 0, y: 4)

                    if speechManager.isRecording {
                        Circle()
                            .stroke(AppTheme.error.opacity(0.3), lineWidth: 4)
                            .frame(width: layout.imageSize, height: layout.imageSize)
                            .scaleEffect(speechManager.isRecording ? 1.2 : 1.0)
                            .opacity(speechManager.isRecording ? 0 : 1)
                            .animation(.easeOut(duration: 1).repeatForever(autoreverses: false), value: speechManager.isRecording)
                    }

                    Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: layout.titleFontSize * 1.5))
                        .foregroundColor(.white)
                }
            }

            Text(speechManager.isRecording ? "🎤 Listening... (tap to stop)" : "🎤 Auto-detecting audio...")
                .font(.system(size: layout.bodyFontSize, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(layout.padding)
    }

    // MARK: - Live Transcription View
    private func liveTranscriptionView(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard {
            VStack(spacing: layout.spacingS) {
                HStack {
                    Circle()
                        .fill(AppTheme.error)
                        .frame(width: 8, height: 8)
                    Text("RECORDING")
                        .font(.system(size: layout.bodyFontSize * 0.8, weight: .bold))
                        .foregroundColor(AppTheme.error)
                }

                Text(speechManager.recognizedText.isEmpty ? "Listening..." : speechManager.recognizedText)
                    .font(.system(size: layout.bodyFontSize))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 60)
            }
            .padding(layout.padding)
        }
    }

    // MARK: - Results View
    private func resultsView(result: PronunciationResult, layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: layout.spacing) {
            // Overall score
            ModernCard {
                VStack(spacing: layout.spacing) {
                    Text("Your Score")
                        .font(.system(size: layout.titleFontSize * 0.8, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)

                    ZStack {
                        Circle()
                            .stroke(AppTheme.backgroundSecondary, lineWidth: 15)
                            .frame(width: layout.imageSize * 1.2, height: layout.imageSize * 1.2)

                        Circle()
                            .trim(from: 0, to: CGFloat(result.overallScore))
                            .stroke(scoreColor(result.overallScore), lineWidth: 15)
                            .frame(width: layout.imageSize * 1.2, height: layout.imageSize * 1.2)
                            .rotationEffect(.degrees(-90))

                        VStack {
                            Text("\(Int(result.overallScore * 100))%")
                                .font(.system(size: layout.titleFontSize * 1.5, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Image(systemName: scoreIcon(result.overallScore))
                                .font(.system(size: layout.titleFontSize))
                                .foregroundColor(scoreColor(result.overallScore))
                        }
                    }

                    Text(result.feedback)
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(layout.padding)
            }

            // Word-by-word accuracy
            if !result.phonemeAccuracy.isEmpty {
                ModernCard {
                    VStack(alignment: .leading, spacing: layout.spacingS) {
                        Text("Word Accuracy")
                            .font(.system(size: layout.titleFontSize * 0.7, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        ForEach(result.phonemeAccuracy) { phoneme in
                            HStack {
                                Text(phoneme.word)
                                    .font(.system(size: layout.bodyFontSize, weight: .medium))
                                    .foregroundColor(AppTheme.textPrimary)

                                Spacer()

                                Text("\(Int(phoneme.accuracy * 100))%")
                                    .font(.system(size: layout.bodyFontSize, weight: .bold))
                                    .foregroundColor(scoreColor(phoneme.accuracy))

                                Image(systemName: scoreIcon(phoneme.accuracy))
                                    .foregroundColor(scoreColor(phoneme.accuracy))
                            }
                            .padding(.vertical, layout.spacingXS)
                        }
                    }
                    .padding(layout.padding)
                }
            }

            // Detailed feedback
            if !result.detailedFeedback.isEmpty {
                ModernCard {
                    VStack(alignment: .leading, spacing: layout.spacingS) {
                        Text("Suggestions")
                            .font(.system(size: layout.titleFontSize * 0.7, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        ForEach(result.detailedFeedback, id: \.self) { feedback in
                            HStack(alignment: .top, spacing: layout.spacingS) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(AppTheme.info)
                                Text(feedback)
                                    .font(.system(size: layout.bodyFontSize * 0.9))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    .padding(layout.padding)
                }
            }

            // Action buttons
            HStack(spacing: layout.spacing) {
                ResponsiveButton(
                    text: "Try Again",
                    action: {
                        showResults = false
                        speechManager.pronunciationResult = nil
                    },
                    layout: layout,
                    style: .secondary,
                    icon: "arrow.counterclockwise"
                )

                ResponsiveButton(
                    text: currentExerciseIndex < exercises.count - 1 ? "Next" : "Submit",
                    action: {
                        // Record score
                        if let result = speechManager.pronunciationResult {
                            gamificationManager.addPoints(for: result.overallScore, exerciseType: currentExercise.type)

                            // Check for new badges
                            if !gamificationManager.newlyUnlockedBadges.isEmpty {
                                showBadgeCelebration = true
                            }
                        }

                        if currentExerciseIndex < exercises.count - 1 {
                            // Move to next exercise
                            currentExerciseIndex += 1
                            showResults = false
                            speechManager.pronunciationResult = nil
                        } else {
                            // Finished all exercises - record session and dismiss
                            print("✅ Phase 1 session completed - recording progress...")

                            // Record the full session to progress manager
                            if let startTime = exerciseStartTime {
                                let duration = Date().timeIntervalSince(startTime)
                                ProgressManager.shared.recordSession(
                                    phase: 1,
                                    exerciseType: "Speaking Practice",
                                    phoneme: "mixed",
                                    score: speechManager.pronunciationResult?.overallScore ?? 0,
                                    duration: duration
                                )
                            }

                            // Clean up state before dismissing
                            showResults = false
                            speechManager.pronunciationResult = nil

                            // Small delay to ensure state is clean
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onDismiss()
                            }
                        }
                    },
                    layout: layout,
                    style: .success,
                    icon: currentExerciseIndex < exercises.count - 1 ? "arrow.right" : "checkmark"
                )
            }
        }
    }

    // MARK: - Badge Celebration View
    private func badgeCelebrationView(layout: ResponsiveLayoutHelper) -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    showBadgeCelebration = false
                }

            ModernCard {
                VStack(spacing: layout.spacing) {
                    Text("🎉 New Badge!")
                        .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    ForEach(gamificationManager.newlyUnlockedBadges) { badge in
                        VStack(spacing: layout.spacingS) {
                            Image(systemName: badge.icon)
                                .font(.system(size: layout.titleFontSize * 2))
                                .foregroundColor(AppTheme.warning)

                            Text(badge.name)
                                .font(.system(size: layout.titleFontSize, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text(badge.description)
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    ResponsiveButton(
                        text: "Awesome!",
                        action: { showBadgeCelebration = false },
                        layout: layout,
                        style: .success
                    )
                }
                .padding(layout.padding * 2)
            }
            .padding(layout.padding * 2)
        }
    }

    // MARK: - Results View
    private func resultsViewSimple(result: PronunciationResult) -> some View {
        VStack(spacing: 16) {
            // Overall Score Card
            VStack(spacing: 12) {
                Text("Your Score")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)

                ZStack {
                    Circle()
                        .stroke(AppTheme.backgroundSecondary, lineWidth: 12)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: result.overallScore)
                        .stroke(scoreColor(result.overallScore), lineWidth: 12)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    VStack {
                        Text("\(Int(result.overallScore * 100))%")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }

                Text(result.feedback)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4)

            // Word Comparison - What was expected vs what was recognized
            if result.recognizedText != "(No speech detected)" {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "text.quote")
                            .foregroundColor(AppTheme.primaryBlue)
                        Text("Speech Comparison")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    // Expected word
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expected:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)

                        Text(currentExercise.text)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary) // Fixed: Use textPrimary for better contrast
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.success.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Recognized word
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You said:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)

                        Text(result.recognizedText)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary) // Fixed: Use textPrimary for better contrast
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background((result.recognizedText.lowercased() == currentExercise.text.lowercased() ? AppTheme.success : AppTheme.warning).opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Match indicator
                    if result.recognizedText.lowercased() == currentExercise.text.lowercased() {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.success)
                            Text("Perfect match!")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.success)
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppTheme.warning)
                            Text("Not quite - try again")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.warning)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4)
            }

            // No Speech Detected Message
            if result.recognizedText == "(No speech detected)" {
                VStack(spacing: 12) {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.error)

                    Text("No Speech Detected")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Make sure you:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text("Speak clearly and loudly into the microphone")
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text("Check microphone permissions in Settings")
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text("Wait for the microphone icon to turn red")
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text("Use a real iOS device (Simulator has limited audio)")
                        }
                    }
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4)
            }

            // Phonetic Comparison (if available and speech was detected)
            if let phoneticGuide = result.phoneticGuide, result.recognizedText != "(No speech detected)" {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(AppTheme.accentPurple)
                        Text("Phonetic Analysis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    // Expected pronunciation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("How to pronounce:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)

                        HStack(spacing: 8) {
                            Text(phoneticGuide.word.uppercased())
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("→")
                                .foregroundColor(AppTheme.textSecondary)

                            Text(phoneticGuide.ipa)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.success.opacity(0.1))
                                .cornerRadius(6)
                        }

                        // Syllable breakdown
                        HStack(spacing: 4) {
                            ForEach(phoneticGuide.breakdown, id: \.syllable) { part in
                                VStack(spacing: 2) {
                                    Text(part.syllable)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text(part.phonetic)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(4)
                            }
                        }
                    }

                    // What you actually said (phonetically)
                    if let detectedPhonetics = result.detectedPhonetics {
                        Divider()

                        VStack(alignment: .leading, spacing: 6) {
                            Text("What you said (phonetically):")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)

                            HStack(spacing: 8) {
                                Text(result.recognizedText.uppercased())
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)

                                Text("→")
                                    .foregroundColor(AppTheme.textSecondary)

                                Text(detectedPhonetics)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(phoneticGuide.ipa == detectedPhonetics ? AppTheme.success : AppTheme.error)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background((phoneticGuide.ipa == detectedPhonetics ? AppTheme.success : AppTheme.error).opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }

                        // Phonetic difference explanation
                        if phoneticGuide.ipa != detectedPhonetics {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppTheme.warning)
                                    .font(.system(size: 14))

                                Text("The sounds don't match! Focus on matching the correct phonetic pronunciation above.")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(8)
                            .background(AppTheme.warning.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }

                    // Audio playback buttons
                    HStack(spacing: 12) {
                        // Play correct pronunciation
                        Button(action: {
                            speechManager.playCorrectPronunciation(text: result.expectedText)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(AppTheme.success)
                                Text("Hear Correct")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(AppTheme.success)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.success.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppTheme.success, lineWidth: 2)
                            )
                        }

                        // Play user's recording
                        if result.recordedAudio != nil {
                            Button(action: {
                                speechManager.playUserRecording()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(AppTheme.info)
                                    Text("Hear Yours")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(AppTheme.info)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.info.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(AppTheme.info, lineWidth: 2)
                                )
                            }
                        }
                    }

                    // Speed Controls
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(AppTheme.accentOrange)
                                .font(.system(size: 12))
                            Text("Playback Speed")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        HStack(spacing: 8) {
                            SpeedButton(speed: "0.25x", label: "Very Slow") {
                                speechManager.playAtSpeed25(text: result.expectedText)
                            }
                            SpeedButton(speed: "0.5x", label: "Slow") {
                                speechManager.playAtSpeed50(text: result.expectedText)
                            }
                            SpeedButton(speed: "0.75x", label: "Medium") {
                                speechManager.playAtSpeed75(text: result.expectedText)
                            }
                            SpeedButton(speed: "1x", label: "Normal") {
                                speechManager.playAtSpeed100(text: result.expectedText)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4)
            }

            // Character-by-Character Comparison (only show if speech detected)
            if result.recognizedText != "(No speech detected)" {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.magnifyingglass")
                            .foregroundColor(AppTheme.info)
                        Text("Pronunciation Analysis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expected:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)

                        Text(result.expectedText)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Divider()

                        Text("You said:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)

                        // Character-by-character comparison with highlighting
                        characterComparisonView(expected: result.expectedText, recognized: result.recognizedText)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4)
            }

            // Raw Sounds Picked Up (Actual Transcription) - only show if speech detected
            if !result.rawSegments.isEmpty && result.recognizedText != "(No speech detected)" {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(AppTheme.accentOrange)
                        Text("Raw Sounds Detected")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Text("This shows exactly what sounds the microphone picked up:")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)

                    ForEach(result.rawSegments) { segment in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                // The sound that was detected
                                Text("[\(segment.substring)]")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(confidenceColor(segment.confidence))
                                    )

                                Spacer()

                                // Confidence score
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(Int(segment.confidence * 100))%")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(scoreColor(Double(segment.confidence)))
                                    Text("confidence")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }

                            // Show alternative interpretations if any
                            if !segment.alternatives.isEmpty {
                                HStack(spacing: 4) {
                                    Text("Also heard:")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.textSecondary)
                                    ForEach(segment.alternatives.prefix(3), id: \.self) { alt in
                                        Text("[\(alt)]")
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(AppTheme.textSecondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(AppTheme.backgroundSecondary)
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(AppTheme.backgroundSecondary.opacity(0.5))
                        .cornerRadius(8)
                    }

                    // Show all alternative full transcriptions
                    if result.allAlternatives.count > 1 {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Other interpretations:")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)

                            ForEach(Array(result.allAlternatives.prefix(5).enumerated()), id: \.offset) { index, alternative in
                                HStack(spacing: 6) {
                                    Text("\(index + 1).")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text(alternative)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(index == 0 ? AppTheme.textPrimary : AppTheme.textSecondary)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4)
            }

            // Waveform Comparison Button - only show if speech detected
            if result.recognizedText != "(No speech detected)" && !result.audioLevels.isEmpty {
                Button(action: {
                    showWaveformComparison = true
                }) {
                    HStack {
                        Image(systemName: "waveform.path.ecg.rectangle")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.accentPurple)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("View Waveform Comparison")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("See visual sound patterns of your pronunciation")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [AppTheme.accentPurple.opacity(0.1), AppTheme.accentPurple.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.accentPurple.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4)
                }
            }

            // Word-by-Word Breakdown
            if !result.phonemeAccuracy.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .foregroundColor(AppTheme.info)
                        Text("Word-by-Word Analysis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    ForEach(result.phonemeAccuracy) { phoneme in
                        HStack {
                            Text(phoneme.word.capitalized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(minWidth: 100, alignment: .leading)

                            Spacer()

                            HStack(spacing: 4) {
                                Text("\(Int(phoneme.accuracy * 100))%")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(scoreColor(phoneme.accuracy))

                                Image(systemName: scoreIcon(phoneme.accuracy))
                                    .foregroundColor(scoreColor(phoneme.accuracy))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4)
            }

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    // CRITICAL: Completely reset the speech manager first
                    speechManager.resetForNewSession()

                    showResults = false
                    firstWordDetected = false // Reset detection state

                    // Auto-restart: Play audio first, then start recording
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if speechManager.isAuthorized && !speechManager.isRecording {
                            // Play pronunciation first
                            isPlayingAudio = true
                            speechManager.playCorrectPronunciation(text: currentExercise.text)
                            print("🔊 Playing pronunciation after Try Again")

                            // Then start recording after audio finishes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                isPlayingAudio = false
                                if !self.showResults {
                                    exerciseStartTime = Date()
                                    setupFirstWordDetectionCallback()  // Set up callback
                                    speechManager.startRecording(expectedText: currentExercise.text)
                                    print("🎤 Auto-restarted recording after Try Again")
                                }
                            }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Try Again")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.backgroundSecondary)
                    .cornerRadius(12)
                }

                Button(action: {
                    // Save practice session to history
                    if result.recognizedText != "(No speech detected)" {
                        let duration = exerciseStartTime != nil ? Date().timeIntervalSince(exerciseStartTime!) : 0
                        let phonemeAccuracy = Dictionary(uniqueKeysWithValues:
                            result.phonemeAccuracy.map { ($0.word, $0.accuracy) }
                        )

                        let session = PracticeSession(
                            date: Date(),
                            exerciseText: currentExercise.text,
                            exerciseType: currentExercise.type,
                            recognizedText: result.recognizedText,
                            score: result.overallScore,
                            duration: duration,
                            phonemeAccuracy: phonemeAccuracy
                        )
                        progressManager.addSession(session)
                    }

                    // Record score for gamification
                    gamificationManager.addPoints(for: result.overallScore, exerciseType: currentExercise.type)

                    if !gamificationManager.newlyUnlockedBadges.isEmpty {
                        showBadgeCelebration = true
                    }

                    if currentExerciseIndex < exercises.count - 1 {
                        currentExerciseIndex += 1

                        // CRITICAL: Completely reset the speech manager for new exercise
                        speechManager.resetForNewSession()

                        showResults = false
                        exerciseStartTime = nil
                        firstWordDetected = false // Reset detection state for next exercise

                        // Auto-start: Play audio first, then start recording for next exercise
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if speechManager.isAuthorized && !speechManager.isRecording {
                                // Play pronunciation first
                                isPlayingAudio = true
                                speechManager.playCorrectPronunciation(text: currentExercise.text)
                                print("🔊 Playing pronunciation for next exercise: \(currentExercise.text)")

                                // Then start recording after audio finishes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    isPlayingAudio = false
                                    if !self.showResults {
                                        exerciseStartTime = Date()
                                        setupFirstWordDetectionCallback()  // Set up callback
                                        speechManager.startRecording(expectedText: currentExercise.text)
                                        print("🎤 Auto-started recording for next exercise: \(currentExercise.text)")
                                    }
                                }
                            }
                        }
                    } else {
                        onDismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: currentExerciseIndex < exercises.count - 1 ? "arrow.right" : "checkmark")
                        Text(currentExerciseIndex < exercises.count - 1 ? "Next" : "Finish")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [AppTheme.success, AppTheme.success.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
        }
    }

    // Character-by-character comparison with color coding
    @ViewBuilder
    private func characterComparisonView(expected: String, recognized: String) -> some View {
        let expectedChars = Array(expected.lowercased())
        let recognizedChars = Array(recognized.lowercased())

        VStack(alignment: .leading, spacing: 8) {
            // Flexible wrapping layout for long words
            if #available(iOS 16.0, *) {
                FlowLayout(spacing: 4) {
                    ForEach(0..<max(expectedChars.count, recognizedChars.count), id: \.self) { index in
                        characterBox(expectedChars: expectedChars, recognizedChars: recognizedChars, index: index)
                    }
                }
            } else {
                // Fallback for iOS 15 and below - simple vertical layout
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<max(expectedChars.count, recognizedChars.count), id: \.self) { index in
                        characterBox(expectedChars: expectedChars, recognizedChars: recognizedChars, index: index)
                    }
                }
            }

            // Legend
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.success)
                        .frame(width: 16, height: 16)
                    Text("Correct")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }

                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.warning)
                        .frame(width: 16, height: 16)
                    Text("Close")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }

                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.error)
                        .frame(width: 16, height: 16)
                    Text("Wrong")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.top, 4)
        }
    }

    // Helper to create character box
    @ViewBuilder
    private func characterBox(expectedChars: [Character], recognizedChars: [Character], index: Int) -> some View {
        let expectedChar = index < expectedChars.count ? expectedChars[index] : " "
        let recognizedChar = index < recognizedChars.count ? recognizedChars[index] : " "

        VStack(spacing: 2) {
            // What you said
            Text(String(recognizedChar))
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .frame(minWidth: 28, minHeight: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(characterMatchColor(expected: expectedChar, recognized: recognizedChar))
                )
                .foregroundColor(.white)

            // Expected character (small, below)
            Text(String(expectedChar))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(AppTheme.textSecondary)
        }
    }

    // Flow layout for wrapping characters (iOS 16+)
    @available(iOS 16.0, *)
    struct FlowLayout: Layout {
        var spacing: CGFloat = 8

        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
            return result.size
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
            for (index, subview) in subviews.enumerated() {
                subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
            }
        }

        struct FlowResult {
            var size: CGSize = .zero
            var positions: [CGPoint] = []

            init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
                var x: CGFloat = 0
                var y: CGFloat = 0
                var lineHeight: CGFloat = 0

                for subview in subviews {
                    let size = subview.sizeThatFits(.unspecified)

                    if x + size.width > maxWidth && x > 0 {
                        x = 0
                        y += lineHeight + spacing
                        lineHeight = 0
                    }

                    positions.append(CGPoint(x: x, y: y))
                    lineHeight = max(lineHeight, size.height)
                    x += size.width + spacing
                }

                self.size = CGSize(width: maxWidth, height: y + lineHeight)
            }
        }
    }

    // Fallback simple wrapping view for iOS 15 and below
    struct SimpleFlowLayout: View {
        let spacing: CGFloat
        let content: [AnyView]

        init(spacing: CGFloat = 8, @ViewBuilder content: () -> [AnyView]) {
            self.spacing = spacing
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: spacing) {
                // Simple vertical stacking as fallback
                ForEach(0..<content.count, id: \.self) { index in
                    content[index]
                }
            }
        }
    }

    // Color coding for character matches
    private func characterMatchColor(expected: Character, recognized: Character) -> Color {
        if expected == recognized {
            return AppTheme.success // Green - perfect match
        } else if expected.isLetter && recognized.isLetter {
            // Check if similar (both vowels or both consonants)
            let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
            if vowels.contains(expected) && vowels.contains(recognized) {
                return AppTheme.warning // Yellow - similar sound
            } else if !vowels.contains(expected) && !vowels.contains(recognized) {
                return AppTheme.warning // Yellow - both consonants
            }
            return AppTheme.error // Red - different type
        } else if expected == " " {
            return AppTheme.error.opacity(0.5) // Light red - extra character
        } else if recognized == " " {
            return AppTheme.error.opacity(0.3) // Lighter red - missing character
        } else {
            return AppTheme.error // Red - mismatch
        }
    }

    // MARK: - Helper Functions
    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.9 { return AppTheme.success }
        else if score >= 0.7 { return AppTheme.warning }
        else { return AppTheme.error }
    }

    private func scoreIcon(_ score: Double) -> String {
        if score >= 0.9 { return "star.fill" }
        else if score >= 0.7 { return "checkmark.circle.fill" }
        else { return "exclamationmark.triangle.fill" }
    }

    // Color based on confidence score
    private func confidenceColor(_ confidence: Float) -> Color {
        if confidence >= 0.8 {
            return AppTheme.success.opacity(0.2) // High confidence - green tint
        } else if confidence >= 0.5 {
            return AppTheme.warning.opacity(0.2) // Medium confidence - yellow tint
        } else {
            return AppTheme.error.opacity(0.2) // Low confidence - red tint
        }
    }
}

// MARK: - Speed Button Component
struct SpeedButton: View {
    let speed: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(speed)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.accentOrange)
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(AppTheme.accentOrange.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.accentOrange.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
