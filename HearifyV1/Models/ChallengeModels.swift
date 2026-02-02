//
//  ChallengeModels.swift
//  HearifyV1
//
//  Daily challenge system models
//

import Foundation

// MARK: - Challenge Type
enum ChallengeType: String, CaseIterable, Codable {
    case speedChallenge = "Speed Challenge"
    case accuracyChallenge = "Accuracy Challenge"
    case enduranceChallenge = "Endurance Challenge"
    case mixedChallenge = "Mixed Challenge"
}

// MARK: - Daily Challenge
struct DailyChallenge: Codable {
    let id: String
    let type: ChallengeType
    let title: String
    let description: String
    let targetAccuracy: Double?
    let timeLimit: TimeInterval?
    let wordCount: Int
    let category: String
    let difficulty: DifficultyLevel
    let bonusPoints: Int
    let date: Date

    static func generateDailyChallenge() -> DailyChallenge {
        let today = Date()
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: today) ?? 1

        // Use day of year as seed for consistent daily challenges
        let challengeIndex = dayOfYear % ChallengeType.allCases.count
        let type = ChallengeType.allCases[challengeIndex]

        switch type {
        case .speedChallenge:
            return DailyChallenge(
                id: "speed_\(dayOfYear)",
                type: .speedChallenge,
                title: "Lightning Round",
                description: "Complete 15 words in under 3 minutes with 80% accuracy",
                targetAccuracy: 80.0,
                timeLimit: 180.0, // 3 minutes
                wordCount: 15,
                category: "cm", // Consonants Manner
                difficulty: .medium,
                bonusPoints: 50,
                date: today
            )
        case .accuracyChallenge:
            return DailyChallenge(
                id: "accuracy_\(dayOfYear)",
                type: .accuracyChallenge,
                title: "Perfect Precision",
                description: "Achieve 95% accuracy on 20 challenging words",
                targetAccuracy: 95.0,
                timeLimit: nil,
                wordCount: 20,
                category: "cv", // Consonants Voicing
                difficulty: .hard,
                bonusPoints: 75,
                date: today
            )
        case .enduranceChallenge:
            return DailyChallenge(
                id: "endurance_\(dayOfYear)",
                type: .enduranceChallenge,
                title: "Marathon Master",
                description: "Complete 30 words with steady performance",
                targetAccuracy: 75.0,
                timeLimit: nil,
                wordCount: 30,
                category: "nv", // Narrow Vowels
                difficulty: .medium,
                bonusPoints: 60,
                date: today
            )
        case .mixedChallenge:
            return DailyChallenge(
                id: "mixed_\(dayOfYear)",
                type: .mixedChallenge,
                title: "Variety Pack",
                description: "Master mixed categories with 85% accuracy",
                targetAccuracy: 85.0,
                timeLimit: 300.0, // 5 minutes
                wordCount: 25,
                category: "wv", // Wide Vowels
                difficulty: .medium,
                bonusPoints: 65,
                date: today
            )
        }
    }
}
