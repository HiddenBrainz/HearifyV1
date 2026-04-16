//
//  AVSpeechTestView.swift
//  HearifyV1
//
//  TEST VIEW: Compare AVSpeechSynthesizer vs Pre-recorded Audio
//  This is a standalone test - not integrated into the main app yet
//

import SwiftUI
import AVFoundation

// MARK: - AVSpeech Manager (Test Implementation)
class AVSpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    @Published var currentText = ""
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []

    private let synthesizer = AVSpeechSynthesizer()
    private var completion: ((Bool) -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
        loadAvailableVoices()
    }

    // Load all English voices available on the device
    func loadAvailableVoices() {
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { $0.name < $1.name }

        print("📢 Found \(availableVoices.count) English voices:")
        for (index, voice) in availableVoices.enumerated() {
            print("  \(index + 1). \(voice.name) - \(voice.language) - Quality: \(voice.quality.rawValue)")
        }
    }

    // Speak text with customizable parameters
    func speak(
        text: String,
        voice: AVSpeechSynthesisVoice? = nil,
        rate: Float = 0.5, // 0.0 (slow) to 1.0 (fast)
        pitch: Float = 1.0, // 0.5 to 2.0
        volume: Float = 1.0, // 0.0 to 1.0
        completion: ((Bool) -> Void)? = nil
    ) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        self.completion = completion
        currentText = text

        let utterance = AVSpeechUtterance(string: text)

        // Set voice (default to US English if not specified)
        if let voice = voice {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        // Set speech parameters
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume

        // Optional: Pre/post utterance delays
        utterance.preUtteranceDelay = 0.0
        utterance.postUtteranceDelay = 0.0

        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Audio session error: \(error)")
            completion?(false)
            return
        }

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
            print("🎤 Started speaking: \(utterance.speechString)")
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            print("✅ Finished speaking: \(utterance.speechString)")
            self.completion?(true)
            self.completion = nil
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            print("🛑 Cancelled speaking: \(utterance.speechString)")
            self.completion?(false)
            self.completion = nil
        }
    }
}

// MARK: - Voice Quality Helper
extension AVSpeechSynthesisVoice {
    var qualityDescription: String {
        switch quality {
        case .default: return "Default"
        case .enhanced: return "Enhanced"
        case .premium: return "Premium"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Test View
struct AVSpeechTestView: View {
    @StateObject private var speechManager = AVSpeechManager()
    @StateObject private var audioManager = AudioManager()

    // Test words (matching your audio files)
    let testWords = ["Tree", "Bush", "Cat", "Dog", "House", "Moon", "Sun", "Book"]

    // Test sentences
    let testSentences = [
        "The quick brown fox jumps over the lazy dog",
        "She sells seashells by the seashore",
        "How much wood would a woodchuck chuck"
    ]

    // Speech parameters
    @State private var selectedVoiceIndex = 0
    @State private var speechRate: Float = 0.5
    @State private var speechPitch: Float = 1.0
    @State private var speechVolume: Float = 1.0
    @State private var customText = "Hello, this is a test"

    @State private var lastSpokenText = ""
    @State private var comparisonResult = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Voice Selection
                    voiceSelectionSection

                    // Speech Controls
                    speechControlsSection

                    // Quick Test Words
                    testWordsSection

                    // Test Sentences
                    testSentencesSection

                    // Custom Text Input
                    customTextSection

                    // Comparison Test
                    comparisonSection

                    // Status Display
                    statusSection
                }
                .padding()
            }
            .navigationTitle("AVSpeech Test Lab")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("AVSpeechSynthesizer Test")
                .font(.title2.bold())

            Text("Test text-to-speech before replacing audio files")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Voice Selection
    private var voiceSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Voice Selection")
                .font(.headline)

            Text("\(speechManager.availableVoices.count) voices available")
                .font(.caption)
                .foregroundColor(.secondary)

            if !speechManager.availableVoices.isEmpty {
                Picker("Voice", selection: $selectedVoiceIndex) {
                    ForEach(0..<speechManager.availableVoices.count, id: \.self) { index in
                        let voice = speechManager.availableVoices[index]
                        Text("\(voice.name) (\(voice.qualityDescription))")
                            .tag(index)
                    }
                }
                .pickerStyle(.menu)

                // Selected voice info
                let selectedVoice = speechManager.availableVoices[selectedVoiceIndex]
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedVoice.name)
                            .font(.subheadline.bold())
                        Text("\(selectedVoice.language) • \(selectedVoice.qualityDescription)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    // MARK: - Speech Controls
    private var speechControlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Speech Controls")
                .font(.headline)

            // Rate
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Speed")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.2fx", speechRate * 2))
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.blue)
                }
                Slider(value: $speechRate, in: 0.0...1.0)
                HStack {
                    Text("Slow (0.0x)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Fast (2.0x)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Pitch
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Pitch")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.2fx", speechPitch))
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.blue)
                }
                Slider(value: $speechPitch, in: 0.5...2.0)
                HStack {
                    Text("Low (0.5x)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("High (2.0x)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Volume
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Volume")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.0f%%", speechVolume * 100))
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.blue)
                }
                Slider(value: $speechVolume, in: 0.0...1.0)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    // MARK: - Test Words
    private var testWordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Test Words")
                .font(.headline)

            Text("Tap to hear AVSpeech version")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(testWords, id: \.self) { word in
                    Button(action: {
                        speakWord(word)
                    }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 12))
                            Text(word)
                                .font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(speechManager.isSpeaking && lastSpokenText == word ? Color.green.opacity(0.2) : Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    // MARK: - Test Sentences
    private var testSentencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test Sentences")
                .font(.headline)

            ForEach(testSentences, id: \.self) { sentence in
                Button(action: {
                    speakText(sentence)
                }) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .foregroundColor(.purple)
                        Text(sentence)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(speechManager.isSpeaking && lastSpokenText == sentence ? .green : .purple)
                    }
                    .padding()
                    .background(speechManager.isSpeaking && lastSpokenText == sentence ? Color.green.opacity(0.1) : Color.purple.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    // MARK: - Custom Text
    private var customTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Text")
                .font(.headline)

            TextField("Enter any text to speak", text: $customText)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 4)

            Button(action: {
                speakText(customText)
            }) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Speak Custom Text")
                        .font(.subheadline.bold())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    // MARK: - Comparison Section
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compare: AVSpeech vs Pre-recorded")
                .font(.headline)

            Text("Test words that exist in your audio files")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button(action: {
                    speakWord("Tree")
                    comparisonResult = "Playing AVSpeech: Tree"
                }) {
                    VStack {
                        Image(systemName: "waveform")
                        Text("AVSpeech")
                            .font(.caption.bold())
                        Text("Tree")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }

                Button(action: {
                    audioManager.playAudio("Tree")
                    comparisonResult = "Playing Pre-recorded: Tree"
                }) {
                    VStack {
                        Image(systemName: "music.note")
                        Text("Pre-recorded")
                            .font(.caption.bold())
                        Text("Tree")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }

            if !comparisonResult.isEmpty {
                Text(comparisonResult)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    // MARK: - Status
    private var statusSection: some View {
        VStack(spacing: 12) {
            if speechManager.isSpeaking {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Speaking: \(speechManager.currentText)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    speechManager.stop()
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Ready to test")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Helper Functions

    private func speakWord(_ word: String) {
        lastSpokenText = word
        let voice = speechManager.availableVoices[selectedVoiceIndex]
        speechManager.speak(
            text: word,
            voice: voice,
            rate: speechRate,
            pitch: speechPitch,
            volume: speechVolume
        )
    }

    private func speakText(_ text: String) {
        lastSpokenText = text
        let voice = speechManager.availableVoices[selectedVoiceIndex]
        speechManager.speak(
            text: text,
            voice: voice,
            rate: speechRate,
            pitch: speechPitch,
            volume: speechVolume
        )
    }
}

// MARK: - Preview
struct AVSpeechTestView_Previews: PreviewProvider {
    static var previews: some View {
        AVSpeechTestView()
    }
}
