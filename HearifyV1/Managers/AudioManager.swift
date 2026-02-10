//
//  AudioManager.swift
//  HearifyV1
//
//  🆕 NEW VERSION - AVSpeechSynthesizer (Text-to-Speech)
//  Replaced pre-recorded MP3 system with AVSpeech
//  Date: January 9, 2026
//
//  ⚠️ BACKUP: Original version saved in AudioManager_BACKUP_PreRecorded.swift
//

import Foundation
import AVFoundation
import SwiftUI

// MARK: - Audio Manager (NEW - AVSpeech System)
@MainActor
class AudioManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    // Speech synthesizer
    private let synthesizer = AVSpeechSynthesizer()

    // Settings
    private var voiceSettings: VoiceSettings?
    private var currentVolume: Float = 1.0
    private var currentSpeed: Float = 1.0
    private var voiceVariationEnabled: Bool = false // DISABLED: No auto-rotation, use selected voice
    private var lastVoiceIndex: Int = 0 // Track last used voice for rotation

    // State
    @Published var isSpeaking = false
    private var completion: (@Sendable (Bool) -> Void)?
    private var audioSessionConfigured = false
    private var lastPlayTime: Date = .distantPast
    private let minimumPlayInterval: TimeInterval = 0.1 // Prevent clicks faster than 100ms (reduced for better UX)

    // Background noise support
    private var backgroundNoisePlayer: AVAudioPlayer?
    @Published var isPlayingBackgroundNoise = false
    private var backgroundNoiseVolume: Float = 0.3 // Default noise volume (30%)
    
    // Notification observers for proper cleanup
    private var appBecameActiveObserver: NSObjectProtocol?
    private var willEnterForegroundObserver: NSObjectProtocol?
    private var audioInterruptionObserver: NSObjectProtocol?
    private var routeChangeObserver: NSObjectProtocol?

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSessionOnce()
        setupAudioInterruptionHandling()
        setupRouteChangeHandling()
        setupAppLifecycleHandling()
        print("✅ AudioManager initialized with AVSpeech")
    }

    // Handle app lifecycle to keep audio session ready
    private func setupAppLifecycleHandling() {
        // When app becomes active, ensure audio session is ready
        appBecameActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            print("📱 App became active - ensuring audio session is active")
            self.ensureAudioSessionActive()
        }

        // When app enters foreground, prepare audio system
        willEnterForegroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            print("📱 App entering foreground - preparing audio")
            self.ensureAudioSessionActive()
        }
    }

    // Configure audio session once at startup
    private func configureAudioSessionOnce() {
        guard !audioSessionConfigured else {
            // Already configured, just ensure it's active
            ensureAudioSessionActive()
            return
        }

        do {
            // Use .playAndRecord to support both speech synthesis AND speech recognition
            // This prevents crashes when switching between playback and recording
            // Added .allowBluetoothA2DP for better Bluetooth headphone support
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true, options: [])
            audioSessionConfigured = true
            print("✅ Audio session configured for playback AND recording (with headphone support)")
        } catch {
            print("❌ Audio session configuration error: \(error)")
        }
    }

    // Ensure audio session is active (can be called multiple times safely)
    private func ensureAudioSessionActive() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Ignore errors - session might already be active
        }
    }

    // Handle audio interruptions (phone calls, etc.)
    private func setupAudioInterruptionHandling() {
        audioInterruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }

            switch type {
            case .began:
                print("🔕 Audio interrupted - stopping speech")
                self.stopAudio()
            case .ended:
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        print("🔔 Audio interruption ended - ready to resume")
                        // Re-activate audio session
                        self.ensureAudioSessionActive()
                    }
                }
            @unknown default:
                break
            }
        }
    }

    // Handle audio route changes (headphones plugged in/out, Bluetooth, etc.)
    private func setupRouteChangeHandling() {
        routeChangeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
            }

            switch reason {
            case .newDeviceAvailable:
                // Headphones or Bluetooth device connected
                print("🎧 New audio device available (headphones/Bluetooth)")
                // Audio session automatically routes to new device - no action needed
                // Speech will continue seamlessly

            case .oldDeviceUnavailable:
                // Headphones or Bluetooth device disconnected
                print("🔌 Audio device disconnected")
                // Audio automatically routes back to speaker
                // Speech will continue seamlessly

            case .categoryChange:
                print("🔄 Audio category changed")
                // Re-ensure our session is active
                self.ensureAudioSessionActive()

            case .override, .wakeFromSleep, .routeConfigurationChange:
                print("🔄 Audio route changed: \(reason.rawValue)")
                // These are normal route changes - no action needed

            @unknown default:
                print("🔄 Unknown audio route change (reason: \(reason.rawValue))")
            }
        }
    }

    func setVoiceSettings(_ settings: VoiceSettings) {
        self.voiceSettings = settings
        print("🎤 Voice settings updated: \(settings.selectedVoice.displayName)")
    }

    // MARK: - Main Play Audio Method (Drop-in replacement)
    func playAudio(_ audioName: String, completion: (@Sendable (Bool) -> Void)? = nil) {
        // Debouncing: Prevent rapid clicks (less than 100ms apart)
        let now = Date()
        let timeSinceLastPlay = now.timeIntervalSince(lastPlayTime)

        if timeSinceLastPlay < minimumPlayInterval {
            print("⚠️ Ignoring rapid click (too soon: \(Int(timeSinceLastPlay * 1000))ms)")
            completion?(false)
            return
        }

        lastPlayTime = now

        // Stop any current speech SAFELY
        if synthesizer.isSpeaking {
            print("🛑 Stopping current speech before starting new one")
            synthesizer.stopSpeaking(at: .immediate)
            // No sleep needed - AVSpeech handles this internally
        }

        self.completion = completion

        // Clean the audio name (remove voice suffix if present)
        let cleanText = cleanAudioName(audioName)

        print("🔊 Playing AVSpeech: '\(cleanText)' (original: '\(audioName)')")

        // Create utterance
        let utterance = AVSpeechUtterance(string: cleanText)

        // Set voice - rotate through all 6 voices for variety
        if voiceVariationEnabled {
            utterance.voice = getRotatedVoice()
        } else if let voiceSettings = voiceSettings {
            utterance.voice = voiceSettings.getAVSpeechVoice()
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        // Apply speed (convert app speed to AVSpeech rate)
        // App speed: 0.5-2.0 → AVSpeech rate: 0.0-1.0
        let rate = convertSpeedToRate(currentSpeed)
        utterance.rate = rate

        // Apply volume
        utterance.volume = currentVolume

        // Apply pitch (neutral for now)
        utterance.pitchMultiplier = 1.0

        // No delays
        utterance.preUtteranceDelay = 0.0
        utterance.postUtteranceDelay = 0.0

        // Validate utterance has content
        guard !cleanText.isEmpty else {
            print("⚠️ Empty text - skipping speech")
            completion?(false)
            return
        }

        // Ensure audio session is configured (only configures once)
        configureAudioSessionOnce()

        // Speak
        isSpeaking = true
        synthesizer.speak(utterance)
        print("✅ Successfully queued speech utterance")
    }

    // MARK: - Voice Variation
    func setVoiceVariation(enabled: Bool) {
        voiceVariationEnabled = enabled
        print("🎭 Voice variation: \(enabled ? "ON" : "OFF")")
    }

    private func getRotatedVoice() -> AVSpeechSynthesisVoice? {
        // Rotate through all 6 voices (3 male + 3 female)
        let allVoiceTypes = VoiceType.allCases
        let selectedVoiceType = allVoiceTypes[lastVoiceIndex % allVoiceTypes.count]
        lastVoiceIndex += 1

        print("🎭 Using rotated voice: \(selectedVoiceType.displayName)")
        return selectedVoiceType.getVoice()
    }

    // MARK: - Helper: Clean Audio Name
    private func cleanAudioName(_ name: String) -> String {
        var cleaned = name

        // Remove voice suffixes (Male1, Male2, Female1, etc.)
        let voiceSuffixes = ["Male1", "Male2", "Male3", "Female1", "Female2", "Female3",
                            "male1", "male2", "male3", "female1", "female2", "female3"]

        for suffix in voiceSuffixes {
            if cleaned.hasSuffix(suffix) {
                cleaned = String(cleaned.dropLast(suffix.count))
                break
            }
        }

        // Special cases
        if cleaned == "buttonpress" {
            return "" // Silent for button press, or could return a click sound
        }

        // Capitalize first letter for natural speech
        if !cleaned.isEmpty {
            cleaned = cleaned.prefix(1).uppercased() + cleaned.dropFirst()
        }

        return cleaned
    }

    // MARK: - Helper: Convert Speed to Rate
    private func convertSpeedToRate(_ speed: Float) -> Float {
        // App uses 0.5-2.0 range
        // AVSpeech uses 0.0-1.0 range where:
        // - 0.0 = very slow
        // - 0.5 = default/normal
        // - 1.0 = very fast

        // Mapping:
        // App 0.5 → AVSpeech 0.25 (slow)
        // App 1.0 → AVSpeech 0.5 (normal)
        // App 2.0 → AVSpeech 0.75 (fast)

        let rate = (speed - 0.5) * 0.25 + 0.25
        return max(AVSpeechUtteranceMinimumSpeechRate, min(AVSpeechUtteranceMaximumSpeechRate, rate))
    }

    // MARK: - Volume Control
    func setVolume(_ volume: Float) {
        currentVolume = max(0.0, min(1.0, volume))
        print("🔊 Volume set to: \(Int(currentVolume * 100))%")
    }

    // MARK: - Speed Control
    func setPlaybackSpeed(_ speed: Float) {
        currentSpeed = max(0.5, min(2.0, speed))
        print("⚡ Speed set to: \(String(format: "%.1fx", currentSpeed))")
    }

    // MARK: - Stop Audio
    func stopAudio() {
        if synthesizer.isSpeaking {
            print("🛑 Manually stopping audio")
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        completion?(false)
        completion = nil
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
            print("🎤 Started speaking: \(utterance.speechString)")
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            print("✅ Finished speaking: \(utterance.speechString)")

            // Call completion only once
            if let completion = self.completion {
                completion(true)
                self.completion = nil
            }
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            print("🛑 Cancelled speaking: \(utterance.speechString)")

            // Call completion only once
            if let completion = self.completion {
                completion(false)
                self.completion = nil
            }
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            print("⏸️ Paused speaking: \(utterance.speechString)")
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            print("▶️ Resumed speaking: \(utterance.speechString)")
        }
    }

    // MARK: - Background Noise Methods

    /// Start playing background noise (looping)
    func startBackgroundNoise(volume: Float? = nil) {
        // Stop any existing background noise
        stopBackgroundNoise()

        // Use provided volume or default
        if let volume = volume {
            backgroundNoiseVolume = max(0.0, min(1.0, volume))
        }

        guard let url = Bundle.main.url(forResource: "BackgroundNoise", withExtension: "mp3") else {
            print("❌ Background noise file not found")
            return
        }

        do {
            // Create and configure player
            backgroundNoisePlayer = try AVAudioPlayer(contentsOf: url)
            backgroundNoisePlayer?.numberOfLoops = -1 // Loop infinitely
            backgroundNoisePlayer?.volume = backgroundNoiseVolume
            backgroundNoisePlayer?.prepareToPlay()

            // Start playing
            let success = backgroundNoisePlayer?.play() ?? false
            if success {
                isPlayingBackgroundNoise = true
                print("🔊 Background noise started at \(Int(backgroundNoiseVolume * 100))% volume")
            } else {
                print("❌ Failed to start background noise")
            }
        } catch {
            print("❌ Error loading background noise: \(error)")
        }
    }

    /// Stop playing background noise
    func stopBackgroundNoise() {
        backgroundNoisePlayer?.stop()
        backgroundNoisePlayer = nil
        isPlayingBackgroundNoise = false
        print("🔇 Background noise stopped")
    }

    /// Adjust background noise volume
    func setBackgroundNoiseVolume(_ volume: Float) {
        backgroundNoiseVolume = max(0.0, min(1.0, volume))
        backgroundNoisePlayer?.volume = backgroundNoiseVolume
        print("🔊 Background noise volume set to: \(Int(backgroundNoiseVolume * 100))%")
    }

    deinit {
        // Remove notification observers
        if let observer = appBecameActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = willEnterForegroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = audioInterruptionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = routeChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        // Directly stop synthesizer without calling @MainActor method
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // Stop background noise
        backgroundNoisePlayer?.stop()
        backgroundNoisePlayer = nil

        print("🧹 AudioManager deinitialized")
    }
}

// MARK: - COMMENTED OUT: Old Pre-recorded MP3 System
/*

 ⚠️ ORIGINAL CODE BELOW - Pre-recorded MP3 playback system
 This code is preserved for reference and potential rollback
 To restore: See AudioManager_BACKUP_PreRecorded.swift

// MARK: - Audio Manager (OLD)
class AudioManager_OLD: ObservableObject {
    @Published private var audioPlayer = GenerateAudio(audio: "")
    private var voiceSettings: VoiceSettings?

    func setVoiceSettings(_ settings: VoiceSettings) {
        self.voiceSettings = settings
    }

    func playAudio(_ audioName: String, completion: ((Bool) -> Void)? = nil) {
        let finalAudioName: String

        // Special handling for button press and other system sounds
        if audioName == "buttonpress" {
            finalAudioName = "buttonpressMale1" // Always use Male1 for system sounds
        } else if let voiceSettings = voiceSettings {
            finalAudioName = voiceSettings.getAudioFileName(for: audioName)
        } else {
            finalAudioName = "\(audioName)Male1" // Default fallback
        }

        audioPlayer.playAudio(audio1: finalAudioName, completion: completion)
    }

    func setVolume(_ volume: Float) {
        audioPlayer.setVolume(volume)
    }

    func setPlaybackSpeed(_ speed: Float) {
        audioPlayer.setPlaybackSpeed(speed)
    }

    func stopAudio() {
        audioPlayer.stopAudio()
    }
}

// MARK: - Generate Audio (OLD - Low-level player)
public class GenerateAudio_OLD {
    var audio: String
    init(audio: String) {
        self.audio = audio
    }
    private var player: AVAudioPlayer?
    private var isPlaying: Bool = false
    private var playbackRate: Float = 1.0

    func playAudio(audio1: String, completion: ((Bool) -> Void)? = nil) {
        guard !audio1.isEmpty else {
            print("Error: Empty audio filename provided")
            completion?(false)
            return
        }

        // Try exact match first
        if let url = Bundle.main.url(forResource: audio1, withExtension: "mp3") {
            playAudioFromUrl(url, completion: completion)
            return
        }

        // Try capitalized version (first letter uppercase)
        let capitalizedAudio = audio1.prefix(1).uppercased() + audio1.dropFirst()
        if let url = Bundle.main.url(forResource: capitalizedAudio, withExtension: "mp3") {
            playAudioFromUrl(url, completion: completion)
            return
        }

        // Try lowercase version
        let lowercaseAudio = audio1.lowercased()
        if let url = Bundle.main.url(forResource: lowercaseAudio, withExtension: "mp3") {
            playAudioFromUrl(url, completion: completion)
            return
        }

        print("Error: Could not find audio file: \(audio1).mp3")
        // Try alternative file extensions
        if let wavUrl = Bundle.main.url(forResource: audio1, withExtension: "wav") {
            playAudioFromUrl(wavUrl, completion: completion)
            return
        }

        completion?(false)
    }

    private func playAudioFromUrl(_ url: URL, completion: ((Bool) -> Void)? = nil) {
        do {
            // Configure audio session for proper playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)

            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)

            guard let player = player else {
                completion?(false)
                return
            }

            // Enable rate control and apply current playback speed
            player.enableRate = true
            player.rate = playbackRate

            player.prepareToPlay()
            isPlaying = player.play()

            if isPlaying {
                print("Successfully playing audio: \(url.lastPathComponent)")
            } else {
                print("Failed to start audio playback: \(url.lastPathComponent)")
            }

            completion?(isPlaying)
        } catch {
            print("Error playing audio file \(url.lastPathComponent): \(error.localizedDescription)")
            completion?(false)
        }
    }

    func stopAudio() {
        player?.stop()
        player = nil
        isPlaying = false

        // Deactivate audio session when done
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func isCurrentlyPlaying() -> Bool {
        return isPlaying && (player?.isPlaying ?? false)
    }

    func getVolume() -> Float {
        return player?.volume ?? 1.0
    }

    func setVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(1.0, volume))
        player?.volume = clampedVolume
    }

    func setPlaybackSpeed(_ speed: Float) {
        let clampedSpeed = max(0.5, min(2.0, speed))
        playbackRate = clampedSpeed

        // Apply speed to current player if it exists
        if let player = player {
            player.enableRate = true
            player.rate = clampedSpeed
        }
    }

    deinit {
        stopAudio()
    }

    func getPlaybackSpeed() -> Float {
        return playbackRate
    }
}

*/
