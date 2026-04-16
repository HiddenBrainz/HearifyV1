//
//  HearingProfileManager.swift
//  HearifyV1
//
//  Manages user's hearing profile and training type selection
//

import Foundation
import SwiftUI

class HearingProfileManager: ObservableObject {
    @Published var selectedType: TrainingModuleType? {
        didSet {
            if let type = selectedType {
                UserDefaults.standard.set(type.rawValue, forKey: "userHearingType")
            }
        }
    }

    @Published var hasCompletedSelection: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedSelection, forKey: "hasCompletedHearingTypeSelection")
        }
    }

    init() {
        // Load saved selection
        if let savedTypeString = UserDefaults.standard.string(forKey: "userHearingType"),
           let savedType = TrainingModuleType(rawValue: savedTypeString) {
            self.selectedType = savedType
            self.hasCompletedSelection = true
        } else {
            self.selectedType = nil
            self.hasCompletedSelection = UserDefaults.standard.bool(forKey: "hasCompletedHearingTypeSelection")
        }
    }

    func setHearingType(_ type: TrainingModuleType) {
        selectedType = type
        hasCompletedSelection = true
    }

    func resetSelection() {
        selectedType = nil
        hasCompletedSelection = false
        UserDefaults.standard.removeObject(forKey: "userHearingType")
        UserDefaults.standard.removeObject(forKey: "hasCompletedHearingTypeSelection")
    }

    var needsSelection: Bool {
        return selectedType == nil || !hasCompletedSelection
    }
}
