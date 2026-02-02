//
//  AdvancedListeningExercise.swift
//  HearifyV1
//
//  Advanced listening exercises and models
//  Phase 1 Enhancements: Advanced Listening Module
//

import Foundation

// MARK: - Advanced Exercise Types
enum AdvancedExerciseType: String, CaseIterable {
    case soundDiscrimination = "Sound Discrimination"
    case sentenceComprehension = "Sentence Comprehension"
    case contextualListening = "Contextual Listening"
    case multipleChoice = "Multiple Choice"
    case fillInTheBlank = "Fill in the Blank"
    case sequencing = "Sequence Ordering"
    case dictation = "Dictation"

    var icon: String {
        switch self {
        case .soundDiscrimination: return "waveform.path.ecg"
        case .sentenceComprehension: return "text.bubble.fill"
        case .contextualListening: return "book.fill"
        case .multipleChoice: return "list.bullet.circle.fill"
        case .fillInTheBlank: return "text.insert"
        case .sequencing: return "list.number"
        case .dictation: return "pencil.line"
        }
    }

    var description: String {
        switch self {
        case .soundDiscrimination:
            return "Distinguish between similar sounds"
        case .sentenceComprehension:
            return "Understand complete sentences"
        case .contextualListening:
            return "Comprehend speech in context"
        case .multipleChoice:
            return "Select the correct answer from options"
        case .fillInTheBlank:
            return "Identify missing words in sentences"
        case .sequencing:
            return "Put sentences in the correct order"
        case .dictation:
            return "Write what you hear accurately"
        }
    }
}

// MARK: - Advanced Listening Exercise
struct AdvancedListeningExercise: Identifiable {
    let id: UUID
    let type: AdvancedExerciseType
    let difficulty: DifficultyLevel
    let title: String
    let instructions: String
    let audioContent: AudioContent
    let questions: [ListeningQuestion]
    let backgroundNoiseLevel: BackgroundNoiseLevel
    let adaptiveDifficulty: Bool

    init(id: UUID = UUID(), type: AdvancedExerciseType, difficulty: DifficultyLevel, title: String, instructions: String, audioContent: AudioContent, questions: [ListeningQuestion], backgroundNoiseLevel: BackgroundNoiseLevel = .none, adaptiveDifficulty: Bool = false) {
        self.id = id
        self.type = type
        self.difficulty = difficulty
        self.title = title
        self.instructions = instructions
        self.audioContent = audioContent
        self.questions = questions
        self.backgroundNoiseLevel = backgroundNoiseLevel
        self.adaptiveDifficulty = adaptiveDifficulty
    }
}

// MARK: - Audio Content
struct AudioContent {
    let text: String
    let audioFile: String
    let duration: TimeInterval
    let voice: VoiceType
    let speed: AudioSpeed

    enum AudioSpeed: String {
        case verySlow = "0.5x"
        case slow = "0.75x"
        case normal = "1.0x"
        case fast = "1.25x"
        case veryFast = "1.5x"

        var multiplier: Float {
            switch self {
            case .verySlow: return 0.5
            case .slow: return 0.75
            case .normal: return 1.0
            case .fast: return 1.25
            case .veryFast: return 1.5
            }
        }
    }
}

// MARK: - Background Noise Level
enum BackgroundNoiseLevel: String, CaseIterable {
    case none = "Silent"
    case quiet = "Quiet (Library)"
    case moderate = "Moderate (Office)"
    case noisy = "Noisy (Restaurant)"
    case veryNoisy = "Very Noisy (Street)"

    var icon: String {
        switch self {
        case .none: return "speaker.slash.fill"
        case .quiet: return "speaker.wave.1.fill"
        case .moderate: return "speaker.wave.2.fill"
        case .noisy: return "speaker.wave.3.fill"
        case .veryNoisy: return "speaker.3.fill"
        }
    }

    var snrDB: Double {
        switch self {
        case .none: return 100
        case .quiet: return 20
        case .moderate: return 10
        case .noisy: return 5
        case .veryNoisy: return 0
        }
    }
}

// MARK: - Listening Question
struct ListeningQuestion: Identifiable {
    let id: UUID
    let questionType: QuestionType
    let prompt: String
    let correctAnswer: String
    let options: [String]  // For multiple choice
    let hint: String

    init(id: UUID = UUID(), questionType: QuestionType, prompt: String, correctAnswer: String, options: [String] = [], hint: String = "") {
        self.id = id
        self.questionType = questionType
        self.prompt = prompt
        self.correctAnswer = correctAnswer
        self.options = options
        self.hint = hint
    }

    enum QuestionType {
        case multipleChoice
        case trueFalse
        case fillInBlank
        case shortAnswer
        case sequencing
    }
}

// MARK: - Exercise Result
struct AdvancedExerciseResult {
    let exerciseId: UUID
    let score: Double
    let completionTime: TimeInterval
    let answers: [QuestionAnswer]
    let backgroundNoiseLevel: BackgroundNoiseLevel
    let difficulty: DifficultyLevel
    let date: Date
}

struct QuestionAnswer {
    let questionId: UUID
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
}

// MARK: - Sample Exercises
extension AdvancedListeningExercise {
    static let soundDiscriminationBD = AdvancedListeningExercise(
        type: .soundDiscrimination,
        difficulty: .easy,
        title: "B vs D Sounds",
        instructions: "Listen carefully and select which word you hear",
        audioContent: AudioContent(
            text: "bat",
            audioFile: "bat",
            duration: 1.0,
            voice: VoiceType.male,
            speed: AudioContent.AudioSpeed.normal
        ),
        questions: [
            ListeningQuestion(
                questionType: .multipleChoice,
                prompt: "Which word did you hear?",
                correctAnswer: "bat",
                options: ["bat", "dat", "pat", "mat"],
                hint: "Listen for the initial sound"
            )
        ]
    )

    static let sentenceComprehension1 = AdvancedListeningExercise(
        type: .sentenceComprehension,
        difficulty: .medium,
        title: "Understanding Requests",
        instructions: "Listen to the sentence and answer the question",
        audioContent: AudioContent(
            text: "Could you please pass me the salt?",
            audioFile: "sentence_request",
            duration: 2.5,
            voice: VoiceType.female,
            speed: AudioContent.AudioSpeed.normal
        ),
        questions: [
            ListeningQuestion(
                questionType: .multipleChoice,
                prompt: "What is the speaker asking for?",
                correctAnswer: "Salt",
                options: ["Salt", "Sugar", "Pepper", "Water"],
                hint: "Focus on the key noun"
            ),
            ListeningQuestion(
                questionType: .trueFalse,
                prompt: "Is the speaker being polite?",
                correctAnswer: "True",
                options: ["True", "False"],
                hint: "Listen for polite phrases"
            )
        ],
        backgroundNoiseLevel: .quiet
    )

    static let contextualListening1 = AdvancedListeningExercise(
        type: .contextualListening,
        difficulty: .hard,
        title: "Airport Announcement",
        instructions: "Listen to the announcement and answer questions about it",
        audioContent: AudioContent(
            text: "Attention passengers. Flight 205 to Boston has been delayed by 30 minutes. The new departure time is 3:45 PM. We apologize for any inconvenience.",
            audioFile: "airport_announcement",
            duration: 8.0,
            voice: VoiceType.female,
            speed: AudioContent.AudioSpeed.normal
        ),
        questions: [
            ListeningQuestion(
                questionType: .multipleChoice,
                prompt: "What is the flight number?",
                correctAnswer: "205",
                options: ["205", "215", "305", "105"],
                hint: "Listen for numbers"
            ),
            ListeningQuestion(
                questionType: .multipleChoice,
                prompt: "How long is the delay?",
                correctAnswer: "30 minutes",
                options: ["15 minutes", "30 minutes", "45 minutes", "1 hour"],
                hint: "Focus on time references"
            ),
            ListeningQuestion(
                questionType: .multipleChoice,
                prompt: "What is the new departure time?",
                correctAnswer: "3:45 PM",
                options: ["3:15 PM", "3:30 PM", "3:45 PM", "4:15 PM"],
                hint: "Listen for the specific time mentioned"
            )
        ],
        backgroundNoiseLevel: .moderate
    )

    static let fillInBlank1 = AdvancedListeningExercise(
        type: .fillInTheBlank,
        difficulty: .medium,
        title: "Complete the Sentence",
        instructions: "Listen and fill in the missing word",
        audioContent: AudioContent(
            text: "The cat is sleeping on the couch",
            audioFile: "sentence_cat",
            duration: 2.0,
            voice: VoiceType.male,
            speed: AudioContent.AudioSpeed.slow
        ),
        questions: [
            ListeningQuestion(
                questionType: .fillInBlank,
                prompt: "The cat is _____ on the couch",
                correctAnswer: "sleeping",
                hint: "What action is the cat doing?"
            )
        ]
    )

    static let dictation1 = AdvancedListeningExercise(
        type: .dictation,
        difficulty: .hard,
        title: "Medical Instructions",
        instructions: "Write exactly what you hear",
        audioContent: AudioContent(
            text: "Take two tablets twice a day with food",
            audioFile: "medical_instruction",
            duration: 3.0,
            voice: VoiceType.female,
            speed: AudioContent.AudioSpeed.normal
        ),
        questions: [
            ListeningQuestion(
                questionType: .shortAnswer,
                prompt: "Write the complete sentence:",
                correctAnswer: "take two tablets twice a day with food",
                hint: "Listen for numbers and timing"
            )
        ],
        backgroundNoiseLevel: .quiet
    )

    static let allExercises: [AdvancedListeningExercise] = [
        soundDiscriminationBD,
        sentenceComprehension1,
        contextualListening1,
        fillInBlank1,
        dictation1
    ]
}

// MARK: - Adaptive Difficulty Manager
class AdaptiveDifficultyManager: ObservableObject {
    @Published var currentDifficulty: DifficultyLevel = .easy
    @Published var performanceHistory: [Double] = []

    private let windowSize = 5  // Last 5 exercises

    func updateDifficulty(score: Double) {
        performanceHistory.append(score)
        if performanceHistory.count > windowSize {
            performanceHistory.removeFirst()
        }

        let average = performanceHistory.reduce(0, +) / Double(performanceHistory.count)

        // Adjust difficulty based on performance
        if average >= 0.9 && currentDifficulty != .hard {
            // Excellent performance, increase difficulty
            currentDifficulty = currentDifficulty == .easy ? .medium : .hard
        } else if average < 0.6 && currentDifficulty != .easy {
            // Struggling, decrease difficulty
            currentDifficulty = currentDifficulty == .hard ? .medium : .easy
        }
    }

    func recommendedNoiseLevel() -> BackgroundNoiseLevel {
        let average = performanceHistory.isEmpty ? 0.8 : performanceHistory.reduce(0, +) / Double(performanceHistory.count)

        if average >= 0.9 {
            return .moderate
        } else if average >= 0.8 {
            return .quiet
        } else {
            return .none
        }
    }
}
