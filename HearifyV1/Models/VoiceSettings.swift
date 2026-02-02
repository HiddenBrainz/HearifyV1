//
//  VoiceSettings.swift
//  HearifyV1
//
//  🆕 NEW VERSION - AVSpeech voice mapping
//  Maps app voice types to AVSpeechSynthesisVoice
//  Date: January 9, 2026
//
//  ⚠️ BACKUP: Original version saved in VoiceSettings_BACKUP.swift
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - Voice Type Enum (Simplified - 2 Voices)
// Male and Female voices - Premium/Enhanced quality
enum VoiceType: String, CaseIterable {
    case male = "Male"
    case female = "Female"

    var displayName: String {
        switch self {
        case .male: return "Male Voice"
        case .female: return "Female Voice"
        }
    }

    var description: String {
        switch self {
        case .male: return "Natural male voice"
        case .female: return "Natural female voice"
        }
    }

    var isAvailable: Bool {
        return true
    }

    // Map to AVSpeechSynthesisVoice - Try multiple identifier patterns
    var possibleIdentifiers: [String] {
        switch self {
        case .male:
            return [
                "com.apple.voice.premium.en-US.Fred",   // iOS Premium Male
                "com.apple.voice.enhanced.en-US.Fred",  // macOS/iOS Enhanced Male
                "com.apple.voice.compact.en-US.Fred",   // Compact Fred
                "com.apple.ttsbundle.siri_male_en-US_premium",  // Siri Male
                "com.apple.voice.compact.en-US.Aaron"  // Fallback compact male
            ]
        case .female:
            return [
                "com.apple.voice.premium.en-US.Samantha",   // iOS Premium Female
                "com.apple.voice.enhanced.en-US.Samantha",  // macOS/iOS Enhanced Female
                "com.apple.ttsbundle.siri_female_en-US_premium",  // Siri Female
                "com.apple.voice.compact.en-US.Nicky"  // Fallback compact female
            ]
        }
    }

    // Get the actual AVSpeechSynthesisVoice
    func getVoice() -> AVSpeechSynthesisVoice? {
        // Try each identifier in order
        for identifier in possibleIdentifiers {
            if let voice = AVSpeechSynthesisVoice(identifier: identifier) {
                print("✅ Found voice: \(voice.name) (\(identifier))")
                return voice
            }
        }

        print("⚠️ None of the preferred voices available - using smart fallback")

        // Smart fallback: Get voices and select by name pattern
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        let enUSVoices = allVoices.filter { $0.language == "en-US" }

        print("📊 Found \(enUSVoices.count) US English voices available")
        
        // Debug: Print all available voices
        for voice in enUSVoices.prefix(10) {
            print("   Available: \(voice.name) - \(voice.identifier)")
        }

        // Try to find voice matching our preference
        var matchedVoice: AVSpeechSynthesisVoice?

        switch self {
        case .male:
            // Look for male-sounding voice names (avoid female names)
            matchedVoice = enUSVoices.first(where: {
                let name = $0.name.lowercased()
                let identifier = $0.identifier.lowercased()
                
                // Exclude female names explicitly
                let isFemale = name.contains("samantha") || name.contains("nicky") || 
                              name.contains("allison") || name.contains("female") ||
                              identifier.contains("samantha") || identifier.contains("nicky")
                
                if isFemale { return false }
                
                // Look for male indicators (Fred is preferred, no Albert)
                return name.contains("fred") || name.contains("male") || 
                       name.contains("aaron") || name.contains("reed") || name.contains("alex") ||
                       identifier.contains("fred") || identifier.contains("male") || 
                       identifier.contains("aaron") || identifier.contains("reed") || 
                       identifier.contains("alex")
            })
        case .female:
            // Look for female-sounding voice names (avoid male names)
            matchedVoice = enUSVoices.first(where: {
                let name = $0.name.lowercased()
                let identifier = $0.identifier.lowercased()
                
                // Exclude male names explicitly
                let isMale = name.contains("aaron") || name.contains("reed") || 
                            name.contains("alex") || name.contains("male") ||
                            identifier.contains("aaron") || identifier.contains("reed") ||
                            identifier.contains("alex")
                
                if isMale { return false }
                
                // Look for female indicators
                return name.contains("female") || name.contains("samantha") || 
                       name.contains("nicky") || name.contains("allison") ||
                       identifier.contains("female") || identifier.contains("samantha") || 
                       identifier.contains("nicky")
            })
        }

        if let voice = matchedVoice {
            print("✅ Using name-matched fallback: \(voice.name) (\(voice.identifier))")
            return voice
        }

        // Gender-aware quality fallback
        switch self {
        case .male:
            // Try to find any non-female premium/enhanced voice
            if let premiumVoice = enUSVoices.first(where: { voice in
                let name = voice.name.lowercased()
                let identifier = voice.identifier.lowercased()
                let isFemale = name.contains("samantha") || name.contains("nicky") || 
                              identifier.contains("samantha") || identifier.contains("nicky")
                return voice.quality == .premium && !isFemale
            }) {
                print("⚠️ Using premium male-ish voice: \(premiumVoice.name)")
                return premiumVoice
            }
        case .female:
            // Try to find any non-male premium/enhanced voice
            if let premiumVoice = enUSVoices.first(where: { voice in
                let name = voice.name.lowercased()
                let identifier = voice.identifier.lowercased()
                let isMale = name.contains("aaron") || name.contains("reed") || 
                            identifier.contains("aaron") || identifier.contains("reed")
                return voice.quality == .premium && !isMale
            }) {
                print("⚠️ Using premium female-ish voice: \(premiumVoice.name)")
                return premiumVoice
            }
        }

        // Final fallback: Use system default but warn about gender mismatch
        let fallbackVoice = AVSpeechSynthesisVoice(language: "en-US")
        if let voice = fallbackVoice {
            print("⚠️ Using system default voice (gender may not match): \(voice.name)")
        } else {
            print("⚠️ Using absolute system default voice")
        }
        return fallbackVoice
    }
}

// MARK: - Voice Settings Manager (NEW)
class VoiceSettings: ObservableObject {
    @Published var selectedVoice: VoiceType {
        didSet {
            UserDefaults.standard.set(selectedVoice.rawValue, forKey: "selectedVoice")
            print("🎤 Voice changed to: \(selectedVoice.displayName)")
        }
    }

    init() {
        let savedVoice = UserDefaults.standard.string(forKey: "selectedVoice")
        self.selectedVoice = VoiceType(rawValue: savedVoice ?? VoiceType.male.rawValue) ?? .male
        print("🎤 VoiceSettings initialized with: \(selectedVoice.displayName)")
    }

    // NEW: Get AVSpeechSynthesisVoice for current selection
    func getAVSpeechVoice() -> AVSpeechSynthesisVoice? {
        return selectedVoice.getVoice()
    }

    // KEPT FOR COMPATIBILITY: Old MP3 filename method (not used anymore)
    func getAudioFileName(for baseFileName: String) -> String {
        return "\(baseFileName)\(selectedVoice.rawValue)"
    }
}

// MARK: - COMMENTED OUT: Original Voice Settings
/*

 ⚠️ ORIGINAL CODE BELOW - Pre-recorded MP3 voice mapping
 This code is preserved for reference and potential rollback
 To restore: See VoiceSettings_BACKUP.swift

// MARK: - Voice Type Enum (OLD)
enum VoiceType_OLD: String, CaseIterable {
    case male1 = "Male1"
    case male2 = "Male2"
    case male3 = "Male3"
    case female1 = "Female1"
    case female2 = "Female2"
    case female3 = "Female3"
    case maleClear = "Male (Clear)"
    case femaleClear = "Female (Clear)"
    case maleAccented = "Male (Accented)"
    case femaleAccented = "Female (Accented)"
    case child = "Child"
    case elderly = "Elderly"

    var displayName: String {
        switch self {
        case .male1: return "Male Voice 1"
        case .male2: return "Male Voice 2"
        case .male3: return "Male Voice 3"
        case .female1: return "Female Voice 1"
        case .female2: return "Female Voice 2"
        case .female3: return "Female Voice 3"
        case .maleClear: return "Male (Clear)"
        case .femaleClear: return "Female (Clear)"
        case .maleAccented: return "Male (Accented)"
        case .femaleAccented: return "Female (Accented)"
        case .child: return "Child"
        case .elderly: return "Elderly"
        }
    }

    var description: String {
        return self.rawValue
    }

    var isAvailable: Bool {
        // Only Male Voice 1 is available - other voices coming soon
        switch self {
        case .male1:
            return true
        default:
            return false
        }
    }
}

// MARK: - Voice Settings Manager (OLD)
class VoiceSettings_OLD: ObservableObject {
    @Published var selectedVoice: VoiceType_OLD {
        didSet {
            UserDefaults.standard.set(selectedVoice.rawValue, forKey: "selectedVoice")
        }
    }

    init() {
        let savedVoice = UserDefaults.standard.string(forKey: "selectedVoice")
        self.selectedVoice = VoiceType_OLD(rawValue: savedVoice ?? VoiceType_OLD.male1.rawValue) ?? .male1
    }

    func getAudioFileName(for baseFileName: String) -> String {
        return "\(baseFileName)\(selectedVoice.rawValue)"
    }
}

*/
