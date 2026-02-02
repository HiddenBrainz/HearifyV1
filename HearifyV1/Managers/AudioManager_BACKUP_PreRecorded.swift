//
//  AudioManager_BACKUP_PreRecorded.swift
//  HearifyV1
//
//  ⚠️ BACKUP FILE - DO NOT DELETE ⚠️
//  This is the original AudioManager that used pre-recorded MP3 files
//  Created: January 9, 2026
//
//  To restore this system:
//  1. Rename this file back to AudioManager.swift
//  2. Delete the new AudioManager.swift (AVSpeech version)
//  3. Restore VoiceSettings.swift from VoiceSettings_BACKUP.swift
//  4. Clean and rebuild project
//

import Foundation
import AVFoundation
import SwiftUI

// MARK: - Audio Manager (ORIGINAL - Pre-recorded MP3 System)
class AudioManager_BACKUP: ObservableObject {
    @Published private var audioPlayer = GenerateAudio_BACKUP(audio: "")
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

// MARK: - Generate Audio (ORIGINAL - Low-level MP3 player)
public class GenerateAudio_BACKUP {
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
