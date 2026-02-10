//
//  TrainingModels.swift
//  HearifyV1
//
//  Models for educational training modules
//

import Foundation
import SwiftUI

// MARK: - Training Module Type
enum TrainingModuleType: String, CaseIterable, Codable {
    case hearingLoss = "Hearing Loss"
    case hearingAids = "Hearing Aids"
    case cochlearImplants = "Cochlear Implants"

    var icon: String {
        switch self {
        case .hearingLoss: return "ear"
        case .hearingAids: return "ear.badge.waveform"
        case .cochlearImplants: return "cpu"
        }
    }

    var color: Color {
        switch self {
        case .hearingLoss: return AppTheme.primaryBlue
        case .hearingAids: return AppTheme.accentPurple
        case .cochlearImplants: return AppTheme.success
        }
    }

    var description: String {
        switch self {
        case .hearingLoss:
            return "Learn about hearing loss, its causes, and management strategies"
        case .hearingAids:
            return "Master hearing aid use, maintenance, and optimization"
        case .cochlearImplants:
            return "Understand cochlear implants and auditory rehabilitation"
        }
    }
}

// MARK: - Training Exercise Type
enum TrainingExerciseType: String, CaseIterable, Codable {
    case multipleChoice = "Multiple Choice"
    case fillInTheBlank = "Fill in the Blank"
    case openSet = "Open Set"

    var icon: String {
        switch self {
        case .multipleChoice: return "checklist"
        case .fillInTheBlank: return "underline"
        case .openSet: return "text.bubble"
        }
    }

    var description: String {
        switch self {
        case .multipleChoice:
            return "Select the correct answer from multiple options"
        case .fillInTheBlank:
            return "Complete the sentence by filling in missing words"
        case .openSet:
            return "Listen and type what you hear without hints"
        }
    }
}

// MARK: - Cochlear Implant Training Levels
enum CochlearImplantLevel: Int, CaseIterable, Codable {
    case wordLevel1 = 1          // Word Recognition - Closed Set (Multiple Choice)
    case wordLevel2 = 2          // Word Recognition - Open Set
    case sentenceLevel1 = 3      // Sentence Recognition - Multiple Choice
    case sentenceLevel2 = 4      // Sentence Recognition - Fill in the Blank
    case sentenceLevel3 = 5      // Sentence Recognition - Open Set

    var displayName: String {
        switch self {
        case .wordLevel1: return "Words - Level 1"
        case .wordLevel2: return "Words - Level 2"
        case .sentenceLevel1: return "Sentences - Level 1"
        case .sentenceLevel2: return "Sentences - Level 2"
        case .sentenceLevel3: return "Sentences - Level 3"
        }
    }

    var shortName: String {
        switch self {
        case .wordLevel1: return "W1"
        case .wordLevel2: return "W2"
        case .sentenceLevel1: return "S1"
        case .sentenceLevel2: return "S2"
        case .sentenceLevel3: return "S3"
        }
    }

    var description: String {
        switch self {
        case .wordLevel1:
            return "Closed set - Multiple choice word recognition"
        case .wordLevel2:
            return "Open set - Type the word you hear"
        case .sentenceLevel1:
            return "Multiple choice - Select the correct sentence"
        case .sentenceLevel2:
            return "Fill in the blank - Complete missing words"
        case .sentenceLevel3:
            return "Open set - Type the full sentence"
        }
    }

    var exerciseType: TrainingExerciseType {
        switch self {
        case .wordLevel1, .sentenceLevel1:
            return .multipleChoice
        case .sentenceLevel2:
            return .fillInTheBlank
        case .wordLevel2, .sentenceLevel3:
            return .openSet
        }
    }

    var contentCategory: CochlearContentCategory {
        switch self {
        case .wordLevel1, .wordLevel2:
            return .words
        case .sentenceLevel1, .sentenceLevel2, .sentenceLevel3:
            return .sentences
        }
    }

    var icon: String {
        switch self {
        case .wordLevel1: return "1.circle.fill"
        case .wordLevel2: return "2.circle.fill"
        case .sentenceLevel1: return "1.circle.fill"
        case .sentenceLevel2: return "2.circle.fill"
        case .sentenceLevel3: return "3.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .wordLevel1, .wordLevel2:
            return AppTheme.success
        case .sentenceLevel1, .sentenceLevel2, .sentenceLevel3:
            return AppTheme.accentPurple
        }
    }
}

// MARK: - Cochlear Content Category
enum CochlearContentCategory: String, Codable {
    case words = "Words"
    case sentences = "Sentences"
}

// MARK: - Training Sentence
struct TrainingSentence: Codable, Identifiable {
    let id: UUID
    let content: String
    let choices: [String]  // For multiple choice (includes correct answer)
    let blankWords: [String]  // Words to blank out for fill-in-the-blank
    let difficulty: DifficultyLevel
    let moduleType: TrainingModuleType
    let category: String  // Subcategory within the module

    init(
        id: UUID = UUID(),
        content: String,
        choices: [String],
        blankWords: [String],
        difficulty: DifficultyLevel,
        moduleType: TrainingModuleType,
        category: String
    ) {
        self.id = id
        self.content = content
        self.choices = choices
        self.blankWords = blankWords
        self.difficulty = difficulty
        self.moduleType = moduleType
        self.category = category
    }

    // Generate a sentence with blanks
    func sentenceWithBlanks() -> String {
        var result = content
        for word in blankWords {
            // Replace the word with underscores of the same length
            let blank = String(repeating: "_", count: word.count)
            result = result.replacingOccurrences(of: word, with: blank, options: .caseInsensitive)
        }
        return result
    }

    // Get the correct answer (first choice)
    var correctAnswer: String {
        return content
    }
}

// MARK: - Training Module
struct TrainingModule: Identifiable, Codable {
    let id: UUID
    let type: TrainingModuleType
    let title: String
    let description: String
    let lessons: [TrainingLesson]

    init(
        id: UUID = UUID(),
        type: TrainingModuleType,
        title: String,
        description: String,
        lessons: [TrainingLesson]
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.lessons = lessons
    }
}

// MARK: - Training Lesson
struct TrainingLesson: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let sentences: [TrainingSentence]
    let requiredAccuracy: Double  // e.g., 0.8 for 80%

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        sentences: [TrainingSentence],
        requiredAccuracy: Double = 0.8
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.sentences = sentences
        self.requiredAccuracy = requiredAccuracy
    }

    // Get sentences filtered by difficulty
    func sentences(forDifficulty difficulty: DifficultyLevel) -> [TrainingSentence] {
        return sentences.filter { $0.difficulty == difficulty }
    }
}

// MARK: - Training Exercise Session
struct TrainingExerciseSession: Codable, Identifiable {
    let id: UUID
    let moduleType: TrainingModuleType
    let lessonId: UUID
    let exerciseType: TrainingExerciseType
    let difficulty: DifficultyLevel
    let startTime: Date
    var endTime: Date?
    var responses: [ExerciseResponse]

    init(
        id: UUID = UUID(),
        moduleType: TrainingModuleType,
        lessonId: UUID,
        exerciseType: TrainingExerciseType,
        difficulty: DifficultyLevel,
        startTime: Date = Date(),
        endTime: Date? = nil,
        responses: [ExerciseResponse] = []
    ) {
        self.id = id
        self.moduleType = moduleType
        self.lessonId = lessonId
        self.exerciseType = exerciseType
        self.difficulty = difficulty
        self.startTime = startTime
        self.endTime = endTime
        self.responses = responses
    }

    var accuracy: Double {
        guard !responses.isEmpty else { return 0.0 }
        let correct = responses.filter { $0.isCorrect }.count
        return Double(correct) / Double(responses.count)
    }

    var isComplete: Bool {
        return endTime != nil
    }
}

// MARK: - Exercise Response
struct ExerciseResponse: Codable, Identifiable {
    let id: UUID
    let sentenceId: UUID
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let timestamp: Date

    init(
        id: UUID = UUID(),
        sentenceId: UUID,
        userAnswer: String,
        correctAnswer: String,
        isCorrect: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.sentenceId = sentenceId
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.isCorrect = isCorrect
        self.timestamp = timestamp
    }
}

// MARK: - Training Progress
struct TrainingProgress: Codable {
    var moduleType: TrainingModuleType
    var completedLessons: Set<UUID>
    var sessionHistory: [TrainingExerciseSession]
    var currentDifficulty: DifficultyLevel
    var lastAccessDate: Date

    init(
        moduleType: TrainingModuleType,
        completedLessons: Set<UUID> = [],
        sessionHistory: [TrainingExerciseSession] = [],
        currentDifficulty: DifficultyLevel = .easy,
        lastAccessDate: Date = Date()
    ) {
        self.moduleType = moduleType
        self.completedLessons = completedLessons
        self.sessionHistory = sessionHistory
        self.currentDifficulty = currentDifficulty
        self.lastAccessDate = lastAccessDate
    }

    var overallAccuracy: Double {
        let completedSessions = sessionHistory.filter { $0.isComplete }
        guard !completedSessions.isEmpty else { return 0.0 }
        let totalAccuracy = completedSessions.reduce(0.0) { $0 + $1.accuracy }
        return totalAccuracy / Double(completedSessions.count)
    }

    mutating func updateDifficulty(basedOnAccuracy accuracy: Double) {
        // Increase difficulty if accuracy is high
        if accuracy >= 0.9 && currentDifficulty != .hard {
            if currentDifficulty == .easy {
                currentDifficulty = .medium
            } else if currentDifficulty == .medium {
                currentDifficulty = .hard
            }
        }
        // Decrease difficulty if accuracy is low
        else if accuracy < 0.6 && currentDifficulty != .easy {
            if currentDifficulty == .hard {
                currentDifficulty = .medium
            } else if currentDifficulty == .medium {
                currentDifficulty = .easy
            }
        }
    }
}

// MARK: - Sample Data
extension TrainingModule {
    static let hearingLossSample = TrainingModule(
        type: .hearingLoss,
        title: "Understanding Hearing Loss",
        description: "Learn about types of hearing loss and their impact",
        lessons: [
            TrainingLesson(
                title: "Types of Hearing Loss",
                description: "Understand conductive, sensorineural, and mixed hearing loss",
                sentences: []
            )
        ]
    )

    static let hearingAidsSample = TrainingModule(
        type: .hearingAids,
        title: "Hearing Aid Basics",
        description: "Master the fundamentals of hearing aid use",
        lessons: [
            TrainingLesson(
                title: "Getting Started",
                description: "Learn to insert, adjust, and maintain your hearing aids",
                sentences: []
            )
        ]
    )

    static let cochlearImplantsSample = TrainingModule(
        type: .cochlearImplants,
        title: "Cochlear Implant Training",
        description: "Develop listening skills with your cochlear implant",
        lessons: [
            TrainingLesson(
                title: "Sound Awareness",
                description: "Begin recognizing environmental sounds",
                sentences: []
            )
        ]
    )
}
