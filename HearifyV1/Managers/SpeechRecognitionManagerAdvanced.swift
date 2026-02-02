//
//  SpeechRecognitionManagerAdvanced.swift
//  HearifyV1
//
//  Advanced speech recognition with pronunciation scoring
//  Phase 2: Speaking/Pronunciation Module
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

// MARK: - Phonetic Notation
struct PhoneticGuide {
    let word: String
    let ipa: String  // International Phonetic Alphabet
    let breakdown: [(syllable: String, phonetic: String)]
}

// MARK: - Audio Recording
struct RecordedAudio {
    let url: URL
    let duration: TimeInterval
}

// MARK: - Phoneme Score Model
struct PhonemeScore: Identifiable {
    let id = UUID()
    let word: String
    let accuracy: Double
    let feedback: String
}

// MARK: - Transcription Segment (raw sounds picked up)
struct TranscriptionSegment: Identifiable {
    let id = UUID()
    let substring: String
    let confidence: Float
    let timestamp: TimeInterval
    let alternatives: [String]  // What else it thought it heard
}

// MARK: - Pronunciation Result
struct PronunciationResult {
    let recognizedText: String
    let expectedText: String
    let overallScore: Double
    let phonemeAccuracy: [PhonemeScore]
    let prosodyScore: Double
    let audioLevelVariation: Double
    let feedback: String
    let detailedFeedback: [String]
    let rawSegments: [TranscriptionSegment]  // Raw sounds/phonemes picked up
    let allAlternatives: [String]  // All interpretations the recognizer considered
    let recordedAudio: RecordedAudio?  // User's recorded pronunciation
    let phoneticGuide: PhoneticGuide?  // IPA and phonetic breakdown
    let detectedPhonetics: String?  // What phonetics were actually detected
    let audioLevels: [Float]  // Captured audio levels for waveform visualization
}

// MARK: - Advanced Speech Recognition Manager
class SpeechRecognitionManagerAdvanced: ObservableObject {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var isAuthorized = false
    @Published var pronunciationResult: PronunciationResult?
    @Published var audioLevel: Float = 0.0

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var expectedText: String = ""
    private var recordingStartTime: Date?
    private var audioLevels: [Float] = []
    private var rawTranscriptionSegments: [TranscriptionSegment] = []
    private var allTranscriptionAlternatives: [String] = []
    private var hasDetectedFirstWord = false

    // Callbacks
    var onFirstWordDetected: (() -> Void)? // Callback when first word is detected

    // Audio recording for playback
    private var audioRecorder: AVAudioRecorder?
    private var recordedAudioURL: URL?

    // Text-to-speech for correct pronunciation
    private let speechSynthesizer = AVSpeechSynthesizer()

    // MARK: - Complete Session Reset
    /// Call this at the start of each new exercise to ensure clean state
    func resetForNewSession() {
        print("🔄 Resetting speech recognition manager for new session...")

        // Stop any ongoing recording completely
        if isRecording {
            stopRecording()
        }

        // Stop any text-to-speech
        stopSpeaking()

        // Clear all state variables
        recognizedText = ""
        pronunciationResult = nil
        audioLevel = 0.0
        expectedText = ""
        recordingStartTime = nil
        audioLevels = []
        rawTranscriptionSegments = []
        allTranscriptionAlternatives = []
        hasDetectedFirstWord = false

        // Clean up old audio recordings
        if let oldURL = recordedAudioURL {
            try? FileManager.default.removeItem(at: oldURL)
        }
        recordedAudioURL = nil
        audioRecorder = nil

        // Ensure audio engine is completely stopped
        if audioEngine.isRunning {
            audioEngine.stop()
        }

        // Remove any existing taps
        let inputNode = audioEngine.inputNode
        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
        }

        // Cancel any recognition tasks
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        print("✅ Speech recognition manager reset complete")
    }

    // Phonetic dictionary
    private let phoneticDictionary: [String: PhoneticGuide] = [
        // Basic words
        "hello": PhoneticGuide(word: "hello", ipa: "/həˈloʊ/", breakdown: [("he", "hə"), ("llo", "ˈloʊ")]),
        "hallow": PhoneticGuide(word: "hallow", ipa: "/ˈhæloʊ/", breakdown: [("hal", "ˈhæl"), ("low", "oʊ")]),
        "thank you": PhoneticGuide(word: "thank you", ipa: "/θæŋk juː/", breakdown: [("thank", "θæŋk"), ("you", "juː")]),
        "water": PhoneticGuide(word: "water", ipa: "/ˈwɔːtər/", breakdown: [("wa", "ˈwɔː"), ("ter", "tər")]),
        "coffee": PhoneticGuide(word: "coffee", ipa: "/ˈkɔːfi/", breakdown: [("co", "ˈkɔː"), ("ffee", "fi")]),
        "monday": PhoneticGuide(word: "monday", ipa: "/ˈmʌndeɪ/", breakdown: [("mon", "ˈmʌn"), ("day", "deɪ")]),

        // Medium words
        "beautiful": PhoneticGuide(word: "beautiful", ipa: "/ˈbjuːtɪfəl/", breakdown: [("beau", "ˈbjuː"), ("ti", "tɪ"), ("ful", "fəl")]),
        "important": PhoneticGuide(word: "important", ipa: "/ɪmˈpɔːrtənt/", breakdown: [("im", "ɪm"), ("por", "ˈpɔːr"), ("tant", "tənt")]),
        "comfortable": PhoneticGuide(word: "comfortable", ipa: "/ˈkʌmftəbəl/", breakdown: [("com", "ˈkʌm"), ("for", "ft"), ("ta", "tə"), ("ble", "bəl")]),
        "restaurant": PhoneticGuide(word: "restaurant", ipa: "/ˈrɛstərɑnt/", breakdown: [("res", "ˈrɛs"), ("tau", "tər"), ("rant", "ɑnt")]),
        "definitely": PhoneticGuide(word: "definitely", ipa: "/ˈdɛfɪnɪtli/", breakdown: [("def", "ˈdɛf"), ("i", "ɪ"), ("nite", "nɪt"), ("ly", "li")]),

        // Challenging words
        "pronunciation": PhoneticGuide(word: "pronunciation", ipa: "/prəˌnʌnsiˈeɪʃən/", breakdown: [("pro", "prə"), ("nun", "ˌnʌn"), ("ci", "si"), ("a", "ˈeɪ"), ("tion", "ʃən")]),
        "communication": PhoneticGuide(word: "communication", ipa: "/kəˌmjunɪˈkeɪʃən/", breakdown: [("com", "kə"), ("mu", "ˌmju"), ("ni", "nɪ"), ("ca", "ˈkeɪ"), ("tion", "ʃən")]),
        "massachusetts": PhoneticGuide(word: "massachusetts", ipa: "/ˌmæsəˈtʃusɪts/", breakdown: [("mas", "ˌmæs"), ("sa", "ə"), ("chu", "ˈtʃu"), ("setts", "sɪts")]),
        "phenomenon": PhoneticGuide(word: "phenomenon", ipa: "/fəˈnɑmɪnɑn/", breakdown: [("phe", "fə"), ("nom", "ˈnɑm"), ("e", "ɪ"), ("non", "nɑn")]),
        "uncomfortable": PhoneticGuide(word: "uncomfortable", ipa: "/ʌnˈkʌmftəbəl/", breakdown: [("un", "ʌn"), ("com", "ˈkʌm"), ("for", "ft"), ("ta", "tə"), ("ble", "bəl")]),

        // Problem words
        "three": PhoneticGuide(word: "three", ipa: "/θriː/", breakdown: [("thr", "θr"), ("ee", "iː")]),
        "tree": PhoneticGuide(word: "tree", ipa: "/triː/", breakdown: [("tr", "tr"), ("ee", "iː")]),
        "thirty": PhoneticGuide(word: "thirty", ipa: "/ˈθɜːrti/", breakdown: [("thir", "ˈθɜːr"), ("ty", "ti")]),
        "dirty": PhoneticGuide(word: "dirty", ipa: "/ˈdɜːrti/", breakdown: [("dir", "ˈdɜːr"), ("ty", "ti")]),
        "library": PhoneticGuide(word: "library", ipa: "/ˈlaɪbreri/", breakdown: [("li", "ˈlaɪ"), ("bra", "bre"), ("ry", "ri")]),
        "february": PhoneticGuide(word: "february", ipa: "/ˈfɛbrueri/", breakdown: [("feb", "ˈfɛb"), ("ru", "ru"), ("a", "e"), ("ry", "ri")]),
        "veterinarian": PhoneticGuide(word: "veterinarian", ipa: "/ˌvɛtərɪˈnɛriən/", breakdown: [("vet", "ˌvɛt"), ("er", "ər"), ("i", "ɪ"), ("nar", "ˈnɛr"), ("i", "i"), ("an", "ən")]),
    ]

    // MARK: - Authorization
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.isAuthorized = (authStatus == .authorized)
            }
        }
    }

    // MARK: - Start Recording with Expected Text
    func startRecording(expectedText: String) {
        print("🎤 Starting new recording session for: '\(expectedText)'")

        // CRITICAL: First, completely reset everything from any previous session
        // This ensures audio engine is stopped, taps removed, and all state cleared
        if isRecording || audioEngine.isRunning {
            print("⚠️ Previous session still active - forcing complete reset")
            resetForNewSession()
            // Give it a moment to fully clean up
            usleep(200000) // 200ms delay to ensure cleanup
        } else {
            // Even if not recording, clear the state
            recognizedText = ""
            pronunciationResult = nil
            audioLevel = 0.0
        }

        // Now set up for new recording
        self.expectedText = expectedText
        self.recordingStartTime = Date()
        self.audioLevels = []
        self.rawTranscriptionSegments = []
        self.allTranscriptionAlternatives = []
        self.hasDetectedFirstWord = false

        guard isAuthorized else {
            print("❌ Not authorized for speech recognition")
            requestAuthorization()
            return
        }

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("❌ Speech recognizer not available")
            return
        }

        // Don't reconfigure audio session - AudioManager already configured it with .playAndRecord
        // This prevents crashes from rapid audio session category switching
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Just ensure it's active, don't change category
            if !audioSession.isOtherAudioPlaying {
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            }
        } catch {
            print("⚠️ Audio session activation warning: \(error)")
            // Continue anyway - session might already be active from AudioManager
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // CRITICAL: Remove any existing tap before installing new one
        // This prevents the "nullptr == Tap()" crash
        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
            print("✅ Removed existing tap before installing new one")
        }

        // Now install the tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self = self else { return }
            recognitionRequest.append(buffer)

            // Analyze audio level for prosody
            let level = self.calculateAudioLevel(from: buffer)
            DispatchQueue.main.async {
                self.audioLevel = level
                self.audioLevels.append(level)
            }
        }

        // Set up audio recorder to save user's pronunciation
        setupAudioRecorder()

        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("✅ Audio engine started successfully")
        } catch {
            print("❌ Audio engine start error: \(error)")
            // Clean up on failure
            inputNode.removeTap(onBus: 0)
            return
        }

        // Start the audio recorder
        audioRecorder?.record()

        isRecording = true
        recognizedText = ""

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                DispatchQueue.main.async {
                    // Convert numbers to words in transcription
                    let rawText = result.bestTranscription.formattedString
                    self.recognizedText = NumberToWordConverter.convertNumbersToWords(in: rawText)

                    // First word detection: Trigger callback when we detect the first word
                    if !self.recognizedText.isEmpty && !self.hasDetectedFirstWord {
                        self.hasDetectedFirstWord = true
                        print("✅ First word detected: '\(self.recognizedText)'")
                        self.onFirstWordDetected?()
                    }

                    // Capture raw transcription segments (actual sounds picked up)
                    self.rawTranscriptionSegments = result.bestTranscription.segments.map { segment in
                        TranscriptionSegment(
                            substring: segment.substring,
                            confidence: segment.confidence,
                            timestamp: segment.timestamp,
                            alternatives: segment.alternativeSubstrings
                        )
                    }

                    // Capture all alternative interpretations the recognizer considered
                    self.allTranscriptionAlternatives = result.transcriptions.map { $0.formattedString }
                }
            }

            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }
    }

    // MARK: - Stop Recording and Analyze
    func stopRecording() {
        print("🛑 Stopping recording...")

        // Stop the audio engine FIRST
        if audioEngine.isRunning {
            audioEngine.stop()
            print("✅ Audio engine stopped")
        }

        // Remove tap safely (even if engine wasn't running)
        let inputNode = audioEngine.inputNode
        if inputNode.numberOfInputs > 0 {
            inputNode.removeTap(onBus: 0)
            print("✅ Tap removed")
        }

        // End audio for recognition
        recognitionRequest?.endAudio()

        // Stop audio recorder
        audioRecorder?.stop()

        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        // Update state
        isRecording = false
        print("✅ Recording fully stopped")

        // Analyze pronunciation
        analyzePronunciation()
    }

    // MARK: - Setup Audio Recorder
    private func setupAudioRecorder() {
        // Create unique filename
        let timestamp = Date().timeIntervalSince1970
        let filename = "recording_\(timestamp).m4a"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordedAudioURL = documentsPath.appendingPathComponent(filename)

        guard let url = recordedAudioURL else { return }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch {
            print("Failed to setup audio recorder: \(error)")
        }
    }

    // MARK: - Play User's Recording
    func playUserRecording() {
        guard let url = recordedAudioURL else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("Failed to play recording: \(error)")
        }
    }

    // MARK: - Play Correct Pronunciation (Text-to-Speech)
    func playCorrectPronunciation(text: String, speed: Float = 0.4) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = speed  // Adjustable speed
        utterance.pitchMultiplier = 1.0
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Stop Text-to-Speech
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Convenience Methods for Different Speeds
    func playAtSpeed25(text: String) {
        playCorrectPronunciation(text: text, speed: 0.2)
    }

    func playAtSpeed50(text: String) {
        playCorrectPronunciation(text: text, speed: 0.4)
    }

    func playAtSpeed75(text: String) {
        playCorrectPronunciation(text: text, speed: 0.5)
    }

    func playAtSpeed100(text: String) {
        playCorrectPronunciation(text: text, speed: AVSpeechUtteranceDefaultSpeechRate)
    }

    // MARK: - Calculate Audio Level
    private func calculateAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let frames = buffer.frameLength

        var sum: Float = 0
        for i in 0..<Int(frames) {
            sum += abs(channelData[i])
        }

        return sum / Float(frames)
    }

    // MARK: - Pronunciation Analysis
    private func analyzePronunciation() {
        // Ensure we have valid text to analyze
        guard !expectedText.isEmpty else {
            print("Error: Expected text is empty")
            return
        }

        // Check if speech was detected
        let speechDetected = !recognizedText.isEmpty && recognizedText.trimmingCharacters(in: .whitespaces) != ""

        // Only calculate scores if speech was detected
        let overallScore: Double
        let phonemeAccuracy: [PhonemeScore]
        let prosodyScore: Double
        let detectedPhonetics: String?

        if speechDetected {
            overallScore = calculatePronunciationScore()
            phonemeAccuracy = analyzePhonemeAccuracy()
            prosodyScore = calculateProsodyScore()
            detectedPhonetics = generateDetectedPhonetics(from: recognizedText)
        } else {
            overallScore = 0.0
            phonemeAccuracy = []
            prosodyScore = 0.0
            detectedPhonetics = nil
        }

        let feedback = generateFeedback(score: overallScore)
        let detailedFeedback = generateDetailedFeedback(phonemeAccuracy: phonemeAccuracy, prosodyScore: prosodyScore)

        // Get phonetic guide for this word/phrase
        let phoneticGuide = phoneticDictionary[expectedText.lowercased()]

        // Create recorded audio object if we have a recording
        var recordedAudio: RecordedAudio? = nil
        if let url = recordedAudioURL,
           let recorder = audioRecorder {
            let duration = recorder.currentTime
            recordedAudio = RecordedAudio(url: url, duration: duration)
        }

        let result = PronunciationResult(
            recognizedText: speechDetected ? recognizedText : "(No speech detected)",
            expectedText: expectedText,
            overallScore: overallScore,
            phonemeAccuracy: phonemeAccuracy,
            prosodyScore: prosodyScore,
            audioLevelVariation: calculateAudioLevelVariation(),
            feedback: feedback,
            detailedFeedback: detailedFeedback,
            rawSegments: speechDetected ? rawTranscriptionSegments : [],
            allAlternatives: speechDetected ? allTranscriptionAlternatives : [],
            recordedAudio: recordedAudio,
            phoneticGuide: phoneticGuide,
            detectedPhonetics: detectedPhonetics,
            audioLevels: speechDetected ? audioLevels : []
        )

        DispatchQueue.main.async {
            self.pronunciationResult = result
        }
    }

    // MARK: - Calculate Pronunciation Score (0-1)
    private func calculatePronunciationScore() -> Double {
        let recognizedLower = recognizedText.lowercased()
        let expectedLower = expectedText.lowercased()

        // Check if the expected text is contained anywhere in the recognized text
        // This gives full credit as long as the target word/phrase is present
        if recognizedLower.contains(expectedLower) {
            return 1.0  // Perfect score - word is contained in the response
        }

        // Also check word-by-word for single word exercises
        let expectedWords = expectedLower.split(separator: " ")
        let recognizedWords = recognizedLower.split(separator: " ")

        // For single-word exercises, check if the word appears anywhere in recognized text
        if expectedWords.count == 1 {
            let targetWord = String(expectedWords[0])
            if recognizedWords.contains(where: { String($0) == targetWord }) {
                return 1.0  // Perfect score - word found
            }
        }

        // Otherwise, use traditional similarity scoring
        let similarity = stringSimilarity(recognizedLower, expectedLower)
        return similarity
    }

    // MARK: - Analyze Phoneme-Level Accuracy
    private func analyzePhonemeAccuracy() -> [PhonemeScore] {
        guard !expectedText.isEmpty else { return [] }

        let expectedWords = expectedText.split(separator: " ").map { String($0).lowercased() }
        let recognizedWords = recognizedText.split(separator: " ").map { String($0).lowercased() }

        var phonemeScores: [PhonemeScore] = []

        for (index, expectedWord) in expectedWords.enumerated() {
            guard !expectedWord.isEmpty else { continue }

            let recognizedWord = index < recognizedWords.count ? recognizedWords[index] : ""
            let accuracy = stringSimilarity(recognizedWord, expectedWord)

            let feedback: String
            if accuracy >= 0.9 {
                feedback = "Excellent pronunciation"
            } else if accuracy >= 0.7 {
                feedback = "Good, minor improvement needed"
            } else if accuracy >= 0.5 {
                feedback = "Needs practice"
            } else {
                feedback = "Try again, focus on clarity"
            }

            phonemeScores.append(PhonemeScore(
                word: expectedWord,
                accuracy: accuracy,
                feedback: feedback
            ))
        }

        return phonemeScores
    }

    // MARK: - Calculate Prosody Score
    private func calculateProsodyScore() -> Double {
        guard !audioLevels.isEmpty else { return 0.5 }

        let variation = calculateAudioLevelVariation()

        // Good prosody has moderate variation (not too flat, not too erratic)
        if variation > 0.15 && variation < 0.4 {
            return 0.9 // Excellent prosody
        } else if variation > 0.1 && variation < 0.5 {
            return 0.7 // Good prosody
        } else {
            return 0.5 // Needs improvement
        }
    }

    // MARK: - Calculate Audio Level Variation
    private func calculateAudioLevelVariation() -> Double {
        guard audioLevels.count > 1 else { return 0 }

        let mean = audioLevels.reduce(0, +) / Float(audioLevels.count)
        let variance = audioLevels.map { pow($0 - mean, 2) }.reduce(0, +) / Float(audioLevels.count)
        let standardDeviation = sqrt(variance)

        return Double(standardDeviation)
    }

    // MARK: - String Similarity (Levenshtein Distance)
    private func stringSimilarity(_ str1: String, _ str2: String) -> Double {
        let distance = levenshteinDistance(str1, str2)
        let maxLength = max(str1.count, str2.count)
        guard maxLength > 0 else { return 1.0 }

        return 1.0 - (Double(distance) / Double(maxLength))
    }

    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let m = str1.count
        let n = str2.count

        // Handle empty strings
        guard m > 0 else { return n }
        guard n > 0 else { return m }

        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m {
            matrix[i][0] = i
        }
        for j in 0...n {
            matrix[0][j] = j
        }

        let str1Array = Array(str1)
        let str2Array = Array(str2)

        for i in 1...m {
            for j in 1...n {
                let cost = str1Array[i - 1] == str2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }

        return matrix[m][n]
    }

    // MARK: - Generate Feedback
    private func generateFeedback(score: Double) -> String {
        if score == 0.0 {
            return "No speech detected. Please speak clearly into the microphone and try again."
        } else if score >= 0.9 {
            return "Excellent pronunciation! Very clear and accurate."
        } else if score >= 0.8 {
            return "Great job! Your pronunciation is very good."
        } else if score >= 0.7 {
            return "Good effort! A few minor improvements needed."
        } else if score >= 0.6 {
            return "Not bad! Keep practicing for better clarity."
        } else if score >= 0.5 {
            return "Needs improvement. Focus on pronouncing each word clearly."
        } else {
            return "Try again! Speak slowly and clearly."
        }
    }

    // MARK: - Generate Detailed Feedback
    private func generateDetailedFeedback(phonemeAccuracy: [PhonemeScore], prosodyScore: Double) -> [String] {
        var feedback: [String] = []

        // Word-specific feedback
        let problematicWords = phonemeAccuracy.filter { $0.accuracy < 0.7 }
        if !problematicWords.isEmpty {
            let words = problematicWords.map { $0.word }.joined(separator: ", ")
            feedback.append("Focus on these words: \(words)")
        }

        // Prosody feedback
        if prosodyScore < 0.6 {
            feedback.append("Try to vary your intonation more naturally")
        } else if prosodyScore >= 0.85 {
            feedback.append("Excellent intonation and rhythm!")
        }

        // Overall encouragement
        let avgAccuracy = phonemeAccuracy.map { $0.accuracy }.reduce(0, +) / Double(max(phonemeAccuracy.count, 1))
        if avgAccuracy >= 0.8 {
            feedback.append("You're doing great! Keep it up!")
        } else {
            feedback.append("Practice makes perfect! Try again.")
        }

        return feedback
    }

    // MARK: - Generate Detected Phonetics
    private func generateDetectedPhonetics(from recognizedText: String) -> String? {
        // Try to find phonetic representation of what was actually recognized
        let words = recognizedText.lowercased().split(separator: " ")
        var phoneticParts: [String] = []

        for word in words {
            if let guide = phoneticDictionary[String(word)] {
                phoneticParts.append(guide.ipa)
            } else {
                // Fallback: show the word in brackets if no phonetic found
                phoneticParts.append("/\(word)/")
            }
        }

        return phoneticParts.isEmpty ? nil : phoneticParts.joined(separator: " ")
    }
}
