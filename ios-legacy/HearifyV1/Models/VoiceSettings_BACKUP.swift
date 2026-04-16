//
//  VoiceSettings_BACKUP.swift
//  HearifyV1
//
//  ⚠️ BACKUP FILE - DO NOT DELETE ⚠️
//  This is the original VoiceSettings that mapped to pre-recorded MP3 files
//  Created: January 9, 2026
//

import Foundation
import SwiftUI

// MARK: - Voice Type Enum (ORIGINAL)
enum VoiceType_BACKUP: String, CaseIterable {
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

// MARK: - Voice Settings Manager (ORIGINAL)
class VoiceSettings_BACKUP: ObservableObject {
    @Published var selectedVoice: VoiceType_BACKUP {
        didSet {
            UserDefaults.standard.set(selectedVoice.rawValue, forKey: "selectedVoice")
        }
    }

    init() {
        let savedVoice = UserDefaults.standard.string(forKey: "selectedVoice")
        self.selectedVoice = VoiceType_BACKUP(rawValue: savedVoice ?? VoiceType_BACKUP.male1.rawValue) ?? .male1
    }

    func getAudioFileName(for baseFileName: String) -> String {
        return "\(baseFileName)\(selectedVoice.rawValue)"
    }
}
