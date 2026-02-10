//
//  ChallengeModels.swift
//  HearifyV1
//
//  Daily challenge system models
//
// IMPORTANT: DifficultyLevel, ChartDataPoint, and DailyProgressData 
// are defined in CommonModels.swift - DO NOT redefine them here!

import Foundation

// MARK: - Challenge Type  
enum ChallengeType: String, CaseIterable, Codable {
    case speedChallenge = "Speed Challenge"
    case accuracyChallenge = "Accuracy Challenge"
    case enduranceChallenge = "Endurance Challenge"
    case mixedChallenge = "Mixed Challenge"
    
    var icon: String {
        switch self {
        case .speedChallenge: return "bolt.fill"
        case .accuracyChallenge: return "target"
        case .enduranceChallenge: return "infinity"
        case .mixedChallenge: return "shuffle"
        }
    }
}

// MARK: - Daily Challenge
struct DailyChallenge: Codable, Identifiable {
    let id: String
    let type: ChallengeType
    let title: String
    let description: String
    let targetAccuracy: Double?
    let timeLimit: TimeInterval?
    let wordCount: Int
    let category: String
    let difficulty: DifficultyLevel  // Uses DifficultyLevel from CommonModels.swift
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
// MARK: - Challenge Result
struct ChallengeResult: Codable, Identifiable {
    let id: UUID
    let challengeId: String
    let completionDate: Date
    let accuracy: Double
    let timeSpent: TimeInterval
    let wordsCompleted: Int
    let pointsEarned: Int
    let isSuccessful: Bool
    
    init(id: UUID = UUID(), challengeId: String, completionDate: Date = Date(), accuracy: Double, timeSpent: TimeInterval, wordsCompleted: Int, pointsEarned: Int, isSuccessful: Bool) {
        self.id = id
        self.challengeId = challengeId
        self.completionDate = completionDate
        self.accuracy = accuracy
        self.timeSpent = timeSpent
        self.wordsCompleted = wordsCompleted
        self.pointsEarned = pointsEarned
        self.isSuccessful = isSuccessful
    }
}

// MARK: - Challenge Progress
struct ChallengeProgress: Codable {
    var currentWordIndex: Int
    var correctAnswers: Int
    var incorrectAnswers: Int
    var startTime: Date
    var endTime: Date?
    
    var totalAttempts: Int {
        correctAnswers + incorrectAnswers
    }
    
    var accuracy: Double {
        guard totalAttempts > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalAttempts)
    }
    
    var timeElapsed: TimeInterval {
        if let end = endTime {
            return end.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    init(currentWordIndex: Int = 0, correctAnswers: Int = 0, incorrectAnswers: Int = 0, startTime: Date = Date(), endTime: Date? = nil) {
        self.currentWordIndex = currentWordIndex
        self.correctAnswers = correctAnswers
        self.incorrectAnswers = incorrectAnswers
        self.startTime = startTime
        self.endTime = endTime
    }
}

