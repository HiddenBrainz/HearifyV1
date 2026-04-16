//
//  PhonemeVisual.swift
//  HearifyV1
//
//  Visual representation data for phonemes
//  Phase 3: Computer Vision & Visual Graphics
//

import SwiftUI

// MARK: - Phoneme Visual Data
struct PhonemeVisual: Identifiable, Codable {
    let id: String // IPA symbol
    let symbol: String // IPA symbol (same as id)
    let name: String // Common name
    let examples: [String] // Example words
    let exampleIPA: [String] // IPA transcription of examples

    // Articulation data
    let tongueConfig: TongueConfiguration
    let lipShape: LipShape
    let jawOpening: JawOpening
    let voicing: Voicing
    let airflowType: AirflowType
    let articulationPoint: ArticulationPoint
    let mannerOfArticulation: MannerOfArticulation

    // Learning aids
    let description: String
    let visualHints: [VisualHint]
    let commonMistakes: [String]
    let tips: [String]

    // Comparisons
    let confusedWith: [String] // IPA symbols of commonly confused phonemes
    let difficultyLevel: DifficultyLevel

    // Category
    let category: PhonemeCategory

    var displayName: String {
        return "\(symbol) - \(name)"
    }

    var examplesString: String {
        return examples.joined(separator: ", ")
    }
}

// MARK: - Phoneme Category
enum PhonemeCategory: String, Codable, CaseIterable {
    case consonantStop = "Stops"
    case consonantFricative = "Fricatives"
    case consonantAffricate = "Affricates"
    case consonantNasal = "Nasals"
    case consonantLiquid = "Liquids"
    case consonantGlide = "Glides"
    case vowelClose = "Close Vowels"
    case vowelMid = "Mid Vowels"
    case vowelOpen = "Open Vowels"
    case diphthong = "Diphthongs"

    var icon: String {
        switch self {
        case .consonantStop: return "stop.circle"
        case .consonantFricative: return "wind"
        case .consonantAffricate: return "stop.circle.fill"
        case .consonantNasal: return "nose.fill"
        case .consonantLiquid: return "drop.fill"
        case .consonantGlide: return "arrow.right"
        case .vowelClose: return "circle"
        case .vowelMid: return "circle.lefthalf.filled"
        case .vowelOpen: return "circle.fill"
        case .diphthong: return "arrow.right.circle"
        }
    }

    var color: Color {
        switch self {
        case .consonantStop: return AppTheme.error
        case .consonantFricative: return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .consonantAffricate: return Color(red: 0.9, green: 0.4, blue: 0.5)
        case .consonantNasal: return AppTheme.success
        case .consonantLiquid: return Color(red: 0.4, green: 0.7, blue: 0.9)
        case .consonantGlide: return AppTheme.info
        case .vowelClose: return AppTheme.accentPurple
        case .vowelMid: return AppTheme.primaryBlue
        case .vowelOpen: return AppTheme.warning
        case .diphthong: return Color(red: 0.8, green: 0.5, blue: 0.9)
        }
    }
}

// MARK: - Phoneme Comparison Pair
struct PhonemeComparisonPair: Identifiable {
    let id: String
    let phoneme1: PhonemeVisual
    let phoneme2: PhonemeVisual
    let title: String
    let keyDifferences: [String]
    let practiceExamples: [(String, String)] // Minimal pairs

    var displayTitle: String {
        return "\(phoneme1.symbol) vs \(phoneme2.symbol)"
    }
}

// MARK: - Common Comparison Pairs
extension PhonemeComparisonPair {
    static let commonPairs: [PhonemeComparisonPair] = []
    // Will be populated with actual data from PhonemeDatabase
}

// MARK: - Phoneme Mastery
struct PhonemeMastery: Identifiable, Codable {
    let id: String // Phoneme IPA symbol
    var masteryLevel: Double // 0.0 - 1.0
    var practiceCount: Int
    var lastPracticed: Date?
    var averageScore: Double

    var masteryColor: Color {
        if masteryLevel >= 0.9 { return AppTheme.success }
        else if masteryLevel >= 0.7 { return AppTheme.warning }
        else { return AppTheme.error }
    }

    var masteryText: String {
        if masteryLevel >= 0.9 { return "Mastered" }
        else if masteryLevel >= 0.7 { return "Good" }
        else if masteryLevel >= 0.5 { return "Practicing" }
        else { return "Needs Work" }
    }
}

// MARK: - Phoneme Practice Session
struct PhonemePracticeSession: Identifiable, Codable {
    let id: UUID
    let phonemeSymbol: String
    let date: Date
    let score: Double
    let exercisesCompleted: Int
}
