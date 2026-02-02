//
//  SpeechRecognitionManager.swift
//  HearifyV1
//
//  Speech recognition and transcription management
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

// MARK: - Speech Recognition Manager
class SpeechRecognitionManager: ObservableObject {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var isAuthorized = false

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()

    // First word detection
    private var hasDetectedFirstWord = false
    var onFirstWordDetected: (() -> Void)? // Callback when first word is detected

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.isAuthorized = (authStatus == .authorized)
            }
        }
    }

    func startRecording() {
        guard isAuthorized else {
            requestAuthorization()
            return
        }

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            return
        }

        // CRITICAL: Stop any existing recording FIRST to clean up resources
        if audioEngine.isRunning {
            print("⚠️ Audio engine already running - stopping it first")
            stopRecording()
            // Give it a moment to fully clean up
            usleep(100000) // 100ms delay
        }

        recognitionTask?.cancel()
        recognitionTask = nil

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
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

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

        isRecording = true
        recognizedText = ""
        hasDetectedFirstWord = false // Reset flag for new recording

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
                }
            }

            if error != nil || result?.isFinal == true {
                if self.audioEngine.isRunning {
                    self.audioEngine.stop()
                }
                // Safe tap removal
                if inputNode.numberOfInputs > 0 {
                    inputNode.removeTap(onBus: 0)
                }
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }

    func stopRecording() {
        print("🛑 Stopping recording - recognized text: '\(recognizedText)'")

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

        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        // Update state
        isRecording = false
        print("✅ Recording fully stopped")
    }
}
