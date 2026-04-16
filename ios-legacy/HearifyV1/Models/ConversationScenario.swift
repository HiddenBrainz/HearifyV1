//
//  ConversationScenario.swift
//  HearifyV1
//
//  Models for conversation practice scenarios
//  Phase 3: Conversation/Context Module
//

import Foundation

// MARK: - Conversation Scenario
struct ConversationScenario: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: DifficultyLevel
    let category: ScenarioCategory
    let turns: [ConversationTurn]
    let context: String
    let culturalNotes: [String]
    let keyPhrases: [String]

    init(id: UUID = UUID(), title: String, description: String, difficulty: DifficultyLevel, category: ScenarioCategory, turns: [ConversationTurn], context: String, culturalNotes: [String] = [], keyPhrases: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.category = category
        self.turns = turns
        self.context = context
        self.culturalNotes = culturalNotes
        self.keyPhrases = keyPhrases
    }
}

// MARK: - Conversation Turn
struct ConversationTurn: Identifiable {
    let id: UUID
    let speaker: Speaker
    let text: String
    let audioHint: String  // Pronunciation guide
    let expectedResponses: [String]  // Multiple valid responses
    let context: String  // What's happening at this point
    let tip: String  // Pronunciation or cultural tip

    init(id: UUID = UUID(), speaker: Speaker, text: String, audioHint: String = "", expectedResponses: [String] = [], context: String = "", tip: String = "") {
        self.id = id
        self.speaker = speaker
        self.text = text
        self.audioHint = audioHint
        self.expectedResponses = expectedResponses
        self.context = context
        self.tip = tip
    }
}

// MARK: - Speaker Enum
enum Speaker {
    case user
    case other
    case narrator
}

// MARK: - Scenario Category
enum ScenarioCategory: String, CaseIterable {
    case restaurant = "Restaurant"
    case shopping = "Shopping"
    case medical = "Medical"
    case business = "Business"
    case social = "Social"
    case travel = "Travel"
    case emergency = "Emergency"
    case phone = "Phone Call"

    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .shopping: return "cart.fill"
        case .medical: return "cross.case.fill"
        case .business: return "briefcase.fill"
        case .social: return "person.3.fill"
        case .travel: return "airplane"
        case .emergency: return "exclamationmark.triangle.fill"
        case .phone: return "phone.fill"
        }
    }
}

// MARK: - Conversation Result
struct ConversationResult {
    let scenarioId: UUID
    let completedTurns: Int
    let totalTurns: Int
    let averageScore: Double
    let turnResults: [TurnResult]
    let completionTime: TimeInterval
    let date: Date
}

// MARK: - Turn Result
struct TurnResult: Identifiable {
    let id: UUID
    let turnIndex: Int
    let userResponse: String
    let expectedResponse: String
    let score: Double
    let pronunciationScore: Double
    let grammarScore: Double
    let contextScore: Double
    let feedback: String

    init(id: UUID = UUID(), turnIndex: Int, userResponse: String, expectedResponse: String, score: Double, pronunciationScore: Double, grammarScore: Double, contextScore: Double, feedback: String) {
        self.id = id
        self.turnIndex = turnIndex
        self.userResponse = userResponse
        self.expectedResponse = expectedResponse
        self.score = score
        self.pronunciationScore = pronunciationScore
        self.grammarScore = grammarScore
        self.contextScore = contextScore
        self.feedback = feedback
    }
}

// MARK: - Sample Scenarios
extension ConversationScenario {
    static let restaurantOrder = ConversationScenario(
        title: "Ordering at a Restaurant",
        description: "Practice ordering food and drinks at a restaurant",
        difficulty: DifficultyLevel.easy,
        category: ScenarioCategory.restaurant,
        turns: [
            ConversationTurn(
                speaker: .other,
                text: "Good evening! Welcome to our restaurant. How many in your party?",
                audioHint: "Good EE-vning! WEL-come to our RES-tuh-ront. How many in your PAR-ty?",
                expectedResponses: ["Table for two please", "Two people", "Party of two"],
                context: "The host greets you at the entrance",
                tip: "Speak clearly when stating numbers"
            ),
            ConversationTurn(
                speaker: .user,
                text: "Table for two, please",
                audioHint: "TAY-bul for TOO, pleez",
                expectedResponses: ["Table for two please", "Two people please", "A table for two"],
                context: "You're requesting a table",
                tip: "Stress 'two' clearly to avoid confusion with 'too'"
            ),
            ConversationTurn(
                speaker: .other,
                text: "Perfect! Right this way. Here are your menus.",
                audioHint: "PUR-fect! Right this way. Here are your MEN-yooz.",
                expectedResponses: ["Thank you", "Thanks"],
                context: "The host leads you to your table",
                tip: "A simple 'thank you' is appropriate"
            ),
            ConversationTurn(
                speaker: .user,
                text: "Thank you",
                audioHint: "Thank you",
                expectedResponses: ["Thank you", "Thanks"],
                context: "Acknowledging the host",
                tip: "Make eye contact and smile"
            ),
            ConversationTurn(
                speaker: .other,
                text: "Are you ready to order, or do you need a few more minutes?",
                audioHint: "Are you REA-dy to OR-der, or do you need a few more MIN-its?",
                expectedResponses: ["I'll have the pasta please", "Can I have the chicken?", "I'd like the salad"],
                context: "The waiter is taking your order",
                tip: "Use 'I'll have' or 'I'd like' to order politely"
            ),
            ConversationTurn(
                speaker: .user,
                text: "I'll have the grilled chicken, please",
                audioHint: "I'll have the GRILD CHIK-in, pleez",
                expectedResponses: ["I'll have the chicken", "The chicken please", "Can I have the chicken"],
                context: "Ordering your main dish",
                tip: "Pronounce 'grilled' with one syllable: GRILD"
            )
        ],
        context: "You're at a nice restaurant for dinner. The staff is friendly and professional.",
        culturalNotes: [
            "In the US, it's common to say 'please' when ordering",
            "Tipping 15-20% is expected in American restaurants",
            "It's polite to make eye contact with servers"
        ],
        keyPhrases: ["Table for two", "I'll have", "Thank you", "The check please"]
    )

    static let doctorAppointment = ConversationScenario(
        title: "Doctor's Appointment",
        description: "Describe symptoms and understand medical advice",
        difficulty: DifficultyLevel.medium,
        category: ScenarioCategory.medical,
        turns: [
            ConversationTurn(
                speaker: .other,
                text: "Good morning. What brings you in today?",
                audioHint: "Good MOR-ning. What brings you in tuh-DAY?",
                expectedResponses: ["I have a headache", "I'm not feeling well", "I have a sore throat"],
                context: "Doctor asking about your symptoms",
                tip: "Be clear and specific about your symptoms"
            ),
            ConversationTurn(
                speaker: .user,
                text: "I've been having headaches for three days",
                audioHint: "I've been HAV-ing HED-ayks for three days",
                expectedResponses: ["I have headaches", "My head hurts", "I've been having headaches"],
                context: "Describing your symptom",
                tip: "Stress important words: HEADACHES, THREE DAYS"
            ),
            ConversationTurn(
                speaker: .other,
                text: "I see. How would you describe the pain? Is it sharp or dull?",
                audioHint: "I see. How would you des-CRIBE the pain? Is it sharp or dull?",
                expectedResponses: ["It's a dull pain", "Sharp pain", "Throbbing pain"],
                context: "Doctor asking for details",
                tip: "Learn pain descriptors: sharp, dull, throbbing, constant"
            ),
            ConversationTurn(
                speaker: .user,
                text: "It's a dull, throbbing pain",
                audioHint: "It's a dull, THROB-ing pain",
                expectedResponses: ["Dull throbbing pain", "A dull ache", "Throbbing pain"],
                context: "Describing pain quality",
                tip: "'Throbbing' = THROB-ing (2 syllables)"
            )
        ],
        context: "You're at a doctor's office for a checkup. The doctor is professional and caring.",
        culturalNotes: [
            "Be honest and detailed about symptoms",
            "Bring a list of current medications",
            "It's okay to ask questions if you don't understand"
        ],
        keyPhrases: ["I've been having", "For three days", "It hurts when", "What should I do"]
    )

    static let jobInterview = ConversationScenario(
        title: "Job Interview",
        description: "Practice professional conversation and self-introduction",
        difficulty: DifficultyLevel.hard,
        category: ScenarioCategory.business,
        turns: [
            ConversationTurn(
                speaker: .other,
                text: "Good afternoon. Thank you for coming in today. Please, have a seat.",
                audioHint: "Good af-ter-NOON. Thank you for COM-ing in tuh-DAY. Please, have a seat.",
                expectedResponses: ["Thank you", "Thank you for having me", "Thanks for the opportunity"],
                context: "Interviewer greeting you",
                tip: "Professional, confident tone is important"
            ),
            ConversationTurn(
                speaker: .user,
                text: "Thank you for the opportunity to interview",
                audioHint: "Thank you for the op-or-TU-ni-ty to IN-ter-view",
                expectedResponses: ["Thank you for having me", "Thanks for the opportunity", "I appreciate the opportunity"],
                context: "Responding professionally",
                tip: "Opportunity = op-or-TU-ni-ty (5 syllables)"
            ),
            ConversationTurn(
                speaker: .other,
                text: "Let's start with you telling me a bit about yourself and your experience.",
                audioHint: "Let's start with you TELL-ing me a bit about your-SELF and your ex-PEER-ee-ence.",
                expectedResponses: ["I have five years of experience", "I'm a software engineer", "I've been working in"],
                context: "Interviewer asking about your background",
                tip: "Keep response concise, highlight key achievements"
            ),
            ConversationTurn(
                speaker: .user,
                text: "I have five years of experience in software development",
                audioHint: "I have five years of ex-PEER-ee-ence in SOFT-wear de-VEL-op-ment",
                expectedResponses: ["I have experience in", "I've been working in", "My background is in"],
                context: "Introducing your experience",
                tip: "Speak confidently, emphasize key skills"
            )
        ],
        context: "You're in a formal job interview for a professional position. The interviewer is evaluating your communication skills.",
        culturalNotes: [
            "Maintain eye contact to show confidence",
            "Use professional language, avoid slang",
            "It's okay to pause and think before answering",
            "Prepare examples of your achievements"
        ],
        keyPhrases: ["I have experience in", "My strength is", "I'm passionate about", "In my previous role"]
    )

    // Array of all scenarios
    static let allScenarios: [ConversationScenario] = [
        restaurantOrder,
        doctorAppointment,
        jobInterview,
        // More scenarios will be added
    ]
}
