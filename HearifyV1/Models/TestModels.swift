//
//  TestModels.swift
//  HearifyV1
//
//  Data models for tests, words, and training content
//

import Foundation
import SwiftUI

// MARK: - Word Model
struct Word: Codable {
    var firstWord: String
    var lastWord: String
    var category: String
}

// MARK: - Practice Item
struct PracticeItem: Codable, Identifiable {
    let id: UUID
    let content: String  // The word or sentence
    let type: PracticeItemType
    let category: String
    let choices: [String]?  // For sentences

    init(id: UUID = UUID(), content: String, type: PracticeItemType, category: String, choices: [String]? = nil) {
        self.id = id
        self.content = content
        self.type = type
        self.category = category
        self.choices = choices
    }

    enum PracticeItemType: String, Codable {
        case word
        case sentence
        case matchedPair
    }

    var displayText: String {
        if type == .matchedPair, let choices = choices, choices.count >= 2 {
            return "\(choices[0]) vs \(choices[1])"
        }
        return content
    }
}

// MARK: - Training Category
enum TrainingCategory: String, CaseIterable {
    case matchedPairs = "Matched Pairs"
    case wordRecognition = "Word Recognition"
    case sentenceComprehension = "Sentence Comprehension"
    case sentencesInNoise = "Sentences in Noise"
    case diagnosticTest = "Diagnostic Test"
    case aiAnalysis = "Practice Insights"
    case customPractice = "Custom Practice"

    var icon: String {
        switch self {
        case .matchedPairs: return "list.bullet.rectangle"
        case .wordRecognition: return "textformat.size"
        case .sentenceComprehension: return "quote.bubble"
        case .sentencesInNoise: return "waveform.path.ecg"
        case .diagnosticTest: return "stethoscope"
        case .aiAnalysis: return "brain.head.profile"
        case .customPractice: return "square.and.pencil"
        }
    }

    var description: String {
        switch self {
        case .matchedPairs: return "Compare and identify similar sounding words"
        case .wordRecognition: return "Identify individual words in quiet environments"
        case .sentenceComprehension: return "Understand complete sentences and phrases"
        case .sentencesInNoise: return "Comprehend speech in challenging acoustic environments"
        case .diagnosticTest: return "Comprehensive assessment of listening abilities"
        case .aiAnalysis: return "View practice patterns and ideas to discuss with your audiologist"
        case .customPractice: return "Practice with your own uploaded words and sentences"
        }
    }

    var color: Color {
        switch self {
        case .matchedPairs: return AppTheme.primaryBlue
        case .wordRecognition: return AppTheme.success
        case .sentenceComprehension: return AppTheme.accentOrange
        case .sentencesInNoise: return AppTheme.warning
        case .diagnosticTest: return AppTheme.error
        case .aiAnalysis: return Color.purple
        case .customPractice: return Color.cyan
        }
    }
}

// MARK: - TrainingCategory Codable Extension
extension TrainingCategory: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        if let category = TrainingCategory(rawValue: rawValue) {
            self = category
        } else {
            // Default to wordRecognition if unknown value
            self = .wordRecognition
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}
