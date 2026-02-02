//
//  ContentView_Clean.swift
//  ListeningDemoOne
//
//  Created by Claude Code - Clean responsive version
//

import SwiftUI
import AVFoundation
import Foundation
import Speech
import UIKit

// MARK: - Design System
// EXTRACTED TO: Theme/AppTheme.swift
/*
struct AppTheme {
    // Primary Colors
    static let primaryBlue = Color(red: 0.1, green: 0.4, blue: 0.8)
    static let primaryCyan = Color(red: 0.2, green: 0.7, blue: 0.9)
    static let accentOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let accentPurple = Color(red: 0.6, green: 0.3, blue: 0.9)

    // Semantic Colors
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.0)
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3)
    static let info = Color(red: 0.3, green: 0.6, blue: 1.0)

    // Background Colors
    static let backgroundPrimary = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let backgroundSecondary = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let cardBackground = Color.white
    static let overlayBackground = Color.black.opacity(0.1)

    // Text Colors
    static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.2)
    static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.6)
    static let textTertiary = Color(red: 0.7, green: 0.7, blue: 0.75)

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, primaryCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accentOrange, Color(red: 1.0, green: 0.4, blue: 0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [success, Color(red: 0.4, green: 0.9, blue: 0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [cardBackground, backgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )

    // Shadows
    static let cardShadow = Color.black.opacity(0.08)
    static let buttonShadow = Color.black.opacity(0.12)
    static let deepShadow = Color.black.opacity(0.15)

    // Corner Radius
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXLarge: CGFloat = 24

    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
}
*/

// MARK: - Button Styles
// ScaleButtonStyle temporarily removed for compatibility

// Custom Upload Type
enum CustomUploadType {
    case words
    case sentences
    case matchedPairs
}

// User Response Tracking
struct UserResponse {
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let wasCorrect: Bool
    let timestamp: Date

    init(question: String, userAnswer: String, correctAnswer: String, wasCorrect: Bool) {
        self.question = question
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.wasCorrect = wasCorrect
        self.timestamp = Date()
    }
}

// EXTRACTED TO: Models/Screen.swift
/*
enum Screen {
    case screen1, screen2, screen3, screen5, screen8, homescreen, beginscreen, creditsscreen, settingscreen, onboardingscreen, statsscreen, dailychallengescreen
    // New category screens
    case wordRecognitionScreen, sentenceComprehensionScreen, sentencesInNoiseScreen, diagnosticTestScreen, matchedPairsScreen, aiAnalysisScreen, practiceListSessionScreen
    // Phase selection screens
    case phaseSelectionScreen, speakingPracticeScreen
}
*/

// EXTRACTED TO: Models/VoiceSettings.swift
/*
// Voice Type Enum
enum VoiceType: String, CaseIterable {
    case male1 = "Male1"
    case male2 = "Male2"
    case male3 = "Male3"
    case female1 = "Female1"
    case female2 = "Female2"
    case female3 = "Female3"

    var displayName: String {
        switch self {
        case .male1: return "Male Voice 1"
        case .male2: return "Male Voice 2"
        case .male3: return "Male Voice 3"
        case .female1: return "Female Voice 1"
        case .female2: return "Female Voice 2"
        case .female3: return "Female Voice 3"
        }
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

// Voice Settings Manager
class VoiceSettings: ObservableObject {
    @Published var selectedVoice: VoiceType {
        didSet {
            UserDefaults.standard.set(selectedVoice.rawValue, forKey: "selectedVoice")
        }
    }

    init() {
        let savedVoice = UserDefaults.standard.string(forKey: "selectedVoice")
        self.selectedVoice = VoiceType(rawValue: savedVoice ?? VoiceType.male1.rawValue) ?? .male1
    }

    func getAudioFileName(for baseFileName: String) -> String {
        return "\(baseFileName)\(selectedVoice.rawValue)"
    }
}
*/

// EXTRACTED TO: Models/CommonModels.swift and Models/ChallengeModels.swift
/*
// Analytics Chart Data
struct ChartDataPoint {
    let label: String
    let value: Double
    let color: Color
}

struct DailyProgressData {
    let date: Date
    let accuracy: Double
    let attempts: Int
}

// Daily Challenge System
enum ChallengeType: String, CaseIterable, Codable {
    case speedChallenge = "Speed Challenge"
    case accuracyChallenge = "Accuracy Challenge"
    case enduranceChallenge = "Endurance Challenge"
    case mixedChallenge = "Mixed Challenge"
}

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
*/

// EXTRACTED TO: Models/CommonModels.swift
/*
// Responsive Layout Helper
struct ResponsiveLayoutHelper {
    let geometry: GeometryProxy

    var deviceType: DeviceType {
        if geometry.size.width >= 768 {
            return .iPad
        } else if geometry.size.width < 375 || geometry.size.height < 667 {
            return .iPhoneSmall
        } else if geometry.size.width >= 414 {
            return .iPhoneLarge
        } else {
            return .iPhoneRegular
        }
    }
    
    var isLandscape: Bool {
        geometry.size.width > geometry.size.height
    }
    
    var buttonWidth: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? geometry.size.width * 0.5 : geometry.size.width * 0.7
        case .iPhoneLarge:
            return geometry.size.width * 0.85
        case .iPhoneRegular:
            return geometry.size.width * 0.8
        case .iPhoneSmall:
            return geometry.size.width * 0.9
        }
    }
    
    var buttonHeight: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 80 : 100
        case .iPhoneLarge:
            return 75
        case .iPhoneRegular:
            return 65
        case .iPhoneSmall:
            return 50
        }
    }
    
    var titleFontSize: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 32 : 40
        case .iPhoneLarge:
            return 28
        case .iPhoneRegular:
            return 24
        case .iPhoneSmall:
            return 20
        }
    }
    
    var bodyFontSize: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 20 : 24
        case .iPhoneLarge:
            return 18
        case .iPhoneRegular:
            return 16
        case .iPhoneSmall:
            return 14
        }
    }
    
    var largeFontSize: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 80 : 100
        case .iPhoneLarge:
            return 70
        case .iPhoneRegular:
            return 60
        case .iPhoneSmall:
            return 50
        }
    }
    
    var imageSize: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 200 : 250
        case .iPhoneLarge:
            return 180
        case .iPhoneRegular:
            return 150
        case .iPhoneSmall:
            return 120
        }
    }
    
    var spacing: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 20 : 25
        case .iPhoneLarge:
            return 15
        case .iPhoneRegular:
            return 12
        case .iPhoneSmall:
            return 8
        }
    }
    
    var padding: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 20 : 24
        case .iPhoneLarge:
            return 16
        case .iPhoneRegular:
            return 12
        case .iPhoneSmall:
            return 8
        }
    }
    
    var maxButtonTextWidth: CGFloat {
        // Leave padding for button styling
        return buttonWidth - (padding * 4)
    }
}

enum DeviceType {
    case iPad
    case iPhoneLarge    // iPhone 14 Pro Max, etc.
    case iPhoneRegular  // iPhone 14, 13, etc.
    case iPhoneSmall    // iPhone SE, etc.
}

enum BackgroundNoiseType: String, CaseIterable, Codable {
    case none = "None"
    case cafe = "Café"
    case traffic = "Traffic"
    case crowd = "Crowd"
    case office = "Office"
    case nature = "Nature"
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
}
*/

// MARK: - Enhanced UI Components
// EXTRACTED TO: Views/Components/ModernCard.swift, ResponsiveButton.swift, ModernHeader.swift
/*
// Modern Card Component
struct ModernCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let backgroundColor: Color
    
    init(
        padding: CGFloat = AppTheme.spacingM,
        cornerRadius: CGFloat = AppTheme.radiusMedium,
        shadowRadius: CGFloat = 8,
        backgroundColor: Color = AppTheme.cardBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: AppTheme.cardShadow, radius: shadowRadius, x: 0, y: 4)
    }
}

// Enhanced Button Styles
enum ButtonStyle {
    case primary, secondary, accent, success, warning, danger, ghost
    
    var backgroundColor: Color {
        switch self {
        case .primary: return AppTheme.primaryBlue
        case .secondary: return AppTheme.backgroundSecondary
        case .accent: return AppTheme.accentOrange
        case .success: return AppTheme.success
        case .warning: return AppTheme.warning
        case .danger: return AppTheme.error
        case .ghost: return Color.clear
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .accent, .success, .warning, .danger: return .white
        case .secondary, .ghost: return AppTheme.textPrimary
        }
    }
    
    var gradient: LinearGradient? {
        switch self {
        case .primary: return AppTheme.primaryGradient
        case .accent: return AppTheme.accentGradient
        case .success: return AppTheme.successGradient
        default: return nil
        }
    }
}

// Modern Header Component
struct ModernHeader: View {
    let text: String
    let layout: ResponsiveLayoutHelper

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with gradient
                AppTheme.primaryGradient
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Content
                VStack(spacing: 4) {
                    Text(text)
                        .font(.system(size: layout.titleFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)

                    // Subtle accent line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, .white.opacity(0.4), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .frame(maxWidth: layout.buttonWidth * 0.5)
                }
                .padding(.top, geometry.safeAreaInsets.top + 50)
                .padding(.bottom, 12)
                .padding(.horizontal, 12)
            }
            .frame(maxWidth: .infinity)
            .shadow(color: AppTheme.deepShadow, radius: 8, x: 0, y: 4)
        }
        .frame(height: layout.deviceType == .iPad ? 135 : 115)
    }
}

// Enhanced Responsive Button
struct ResponsiveButton: View {
    let text: String
    let action: () -> Void
    let layout: ResponsiveLayoutHelper
    let style: ButtonStyle
    let icon: String?
    let width: CGFloat?
    let height: CGFloat?
    let isLoading: Bool
    
    // Legacy support for existing code
    let backgroundColor: Color?
    let foregroundColor: Color?
    
    @State private var isPressed = false
    
    init(
        text: String,
        action: @escaping () -> Void,
        layout: ResponsiveLayoutHelper,
        style: ButtonStyle = .primary,
        icon: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        isLoading: Bool = false,
        // Legacy parameters for backward compatibility
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil
    ) {
        self.text = text
        self.action = action
        self.layout = layout
        self.style = style
        self.icon = icon
        self.width = width
        self.height = height
        self.isLoading = isLoading
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    private var resolvedStyle: ButtonStyle {
        // Use legacy colors if provided for backward compatibility
        if backgroundColor != nil || foregroundColor != nil {
            return .secondary
        }
        return style
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacingS) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(foregroundColor ?? resolvedStyle.foregroundColor)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                }
                
                Text(text)
                    .font(.system(size: layout.titleFontSize, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
            }
            .foregroundColor(foregroundColor ?? resolvedStyle.foregroundColor)
            .padding(.vertical, AppTheme.spacingM)
            .padding(.horizontal, AppTheme.spacingL)
            .frame(
                width: width ?? layout.buttonWidth,
                height: height ?? layout.buttonHeight
            )
            .background(
                Group {
                    if let legacyColor = backgroundColor {
                        legacyColor
                    } else if let gradient = resolvedStyle.gradient {
                        gradient
                    } else {
                        resolvedStyle.backgroundColor
                    }
                }
            )
            .cornerRadius(AppTheme.radiusMedium)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .shadow(
                color: AppTheme.buttonShadow,
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .disabled(isLoading)
    }
}
*/

// EXTRACTED TO: Models/TestModels.swift
/*
struct Word: Codable {
    var firstWord: String
    var lastWord: String
    var category: String
}

// Unified Practice Item structure for both words and sentences
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
    }

    var displayText: String {
        return content
    }
}
*/

// MARK: - Demo Content Structures

struct DemoWord: Codable {
    let word: String
    var choices: [String]
    let category: TrainingCategory
    let correctAnswer: String

    // Randomize the choices so the correct answer isn't always first
    func randomizedChoices() -> [String] {
        return choices.shuffled()
    }

    // Explicit Codable implementation
    enum CodingKeys: String, CodingKey {
        case word
        case choices
        case category
        case correctAnswer
    }

    init(word: String, choices: [String], category: TrainingCategory, correctAnswer: String) {
        self.word = word
        self.choices = choices
        self.category = category
        self.correctAnswer = correctAnswer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decode(String.self, forKey: .word)
        choices = try container.decode([String].self, forKey: .choices)
        category = try container.decode(TrainingCategory.self, forKey: .category)
        correctAnswer = try container.decode(String.self, forKey: .correctAnswer)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(word, forKey: .word)
        try container.encode(choices, forKey: .choices)
        try container.encode(category, forKey: .category)
        try container.encode(correctAnswer, forKey: .correctAnswer)
    }

    static let demoWords: [DemoWord] = [
        // Word Recognition demos
        DemoWord(word: "Cat", choices: ["Cat", "Bat", "Hat", "Mat"], category: .wordRecognition, correctAnswer: "Cat"),
        DemoWord(word: "House", choices: ["House", "Mouse", "Spouse", "Louse"], category: .wordRecognition, correctAnswer: "House"),
        DemoWord(word: "Tree", choices: ["Tree", "Free", "Three", "Knee"], category: .wordRecognition, correctAnswer: "Tree"),
        DemoWord(word: "Phone", choices: ["Phone", "Bone", "Cone", "Stone"], category: .wordRecognition, correctAnswer: "Phone"),
        DemoWord(word: "Book", choices: ["Book", "Cook", "Look", "Took"], category: .wordRecognition, correctAnswer: "Book"),
    ]

    // Load words from CSV
    static func loadFromCSV(fileName: String, count: Int, excludeWords: Set<String> = []) -> [DemoWord] {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
            print("Could not find CSV file: \(fileName).csv")
            return demoWords.filter { $0.category == .wordRecognition }
        }

        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            let lines = contents.components(separatedBy: .newlines)
            var words: [DemoWord] = []

            // Skip header line and process data
            for line in lines.dropFirst() {
                let values = line.components(separatedBy: ",")
                if values.count >= 6 && !values[0].isEmpty {
                    let word = values[0].trimmingCharacters(in: .whitespaces)

                    // Skip if word was already used
                    if excludeWords.contains(word.lowercased()) {
                        continue
                    }

                    let choice1 = values[1].trimmingCharacters(in: .whitespaces)
                    let choice2 = values[2].trimmingCharacters(in: .whitespaces)
                    let choice3 = values[3].trimmingCharacters(in: .whitespaces)
                    let choice4 = values[4].trimmingCharacters(in: .whitespaces)
                    let choices = [choice1, choice2, choice3, choice4].shuffled()

                    words.append(DemoWord(
                        word: word,
                        choices: choices,
                        category: .wordRecognition,
                        correctAnswer: word  // The word itself is the correct answer
                    ))
                }
            }

            // Shuffle and return requested count
            return Array(words.shuffled().prefix(count))
        } catch {
            print("Error loading CSV: \(error)")
            return demoWords.filter { $0.category == .wordRecognition }
        }
    }
}

struct DemoSentence: Codable {
    let sentence: String
    var choices: [String]
    let category: TrainingCategory

    // correctAnswer is always the sentence itself
    var correctAnswer: String {
        return sentence
    }

    // Custom Codable implementation to handle computed property
    enum CodingKeys: String, CodingKey {
        case sentence
        case choices
        case category
    }

    init(sentence: String, choices: [String], category: TrainingCategory) {
        self.sentence = sentence
        self.choices = choices
        self.category = category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sentence = try container.decode(String.self, forKey: .sentence)
        choices = try container.decode([String].self, forKey: .choices)
        category = try container.decode(TrainingCategory.self, forKey: .category)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sentence, forKey: .sentence)
        try container.encode(choices, forKey: .choices)
        try container.encode(category, forKey: .category)
    }

    static let demoSentences: [DemoSentence] = [
        // Sentence Comprehension demos
        DemoSentence(
            sentence: "The dog is running in the park",
            choices: ["The dog is running in the park", "The cat is walking in the yard", "The bird is flying in the sky", "The fish is swimming in the pond"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "Please turn off the lights before leaving",
            choices: ["Please turn off the lights before leaving", "Please turn on the radio before sleeping", "Please close the door after entering", "Please open the window when arriving"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The weather forecast predicts rain tomorrow",
            choices: ["The weather forecast predicts rain tomorrow", "The news report announces snow yesterday", "The radio station plays music tonight", "The television shows movies today"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "She bought fresh vegetables at the market",
            choices: ["She bought fresh vegetables at the market", "He sold ripe fruits at the store", "They picked wild berries in the forest", "We grew organic herbs in the garden"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The children are playing outside after school",
            choices: ["The children are playing outside after school", "The students are studying inside during class", "The teachers are working upstairs before lunch", "The parents are waiting downstairs after dinner"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "I need to finish my homework by tonight",
            choices: ["I need to finish my homework by tonight", "You want to complete your project by tomorrow", "They have to submit their report by Friday", "We must prepare our presentation by Monday"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The library closes at eight in the evening",
            choices: ["The library closes at eight in the evening", "The museum opens at nine in the morning", "The restaurant serves until ten at night", "The pharmacy operates from seven in the day"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "My brother works as an engineer in the city",
            choices: ["My brother works as an engineer in the city", "Your sister teaches as a professor at the college", "His cousin performs as a musician on the stage", "Her uncle manages as a director in the office"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "We are planning a vacation to the beach",
            choices: ["We are planning a vacation to the beach", "They are organizing a trip to the mountains", "You are arranging a journey to the countryside", "I am scheduling a visit to the islands"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The new movie premieres this Friday night",
            choices: ["The new movie premieres this Friday night", "The latest show debuts next Saturday evening", "The recent play opens last Sunday afternoon", "The fresh episode airs every Monday morning"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "Coffee helps me stay awake during meetings",
            choices: ["Coffee helps me stay awake during meetings", "Tea allows you to remain alert throughout classes", "Water keeps them stay focused within sessions", "Juice enables us to feel refreshed between breaks"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The train arrives at the station every hour",
            choices: ["The train arrives at the station every hour", "The bus departs from the terminal each morning", "The plane lands at the airport twice daily", "The taxi waits at the corner all afternoon"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "She enjoys reading mystery novels before bed",
            choices: ["She enjoys reading mystery novels before bed", "He prefers watching action movies after dinner", "They love listening to music podcasts during exercise", "We like playing video games on weekends"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The doctor recommended drinking more water daily",
            choices: ["The doctor recommended drinking more water daily", "The dentist suggested brushing teeth twice weekly", "The nurse advised taking medication every morning", "The therapist proposed doing exercises each evening"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "Students must submit their assignments by Monday",
            choices: ["Students must submit their assignments by Monday", "Teachers should grade the exams before Tuesday", "Parents need to attend the meeting on Wednesday", "Workers have to complete the tasks until Thursday"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The restaurant serves delicious Italian food",
            choices: ["The restaurant serves delicious Italian food", "The cafe offers tasty French cuisine", "The bakery makes fresh German bread", "The diner cooks authentic Mexican dishes"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "He drives to work every morning at seven",
            choices: ["He drives to work every morning at seven", "She walks to school each afternoon at three", "They cycle to the gym every evening at six", "We commute to town each weekend at nine"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The concert tickets sold out within minutes",
            choices: ["The concert tickets sold out within minutes", "The movie seats filled up during hours", "The event passes ran out before days", "The show reservations closed after weeks"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "My phone battery drains quickly these days",
            choices: ["My phone battery drains quickly these days", "Your laptop charger works slowly those times", "His tablet screen cracks easily some moments", "Their computer memory fills rapidly recent weeks"],
            category: .sentenceComprehension
        ),
        DemoSentence(
            sentence: "The package will arrive by next Thursday",
            choices: ["The package will arrive by next Thursday", "The letter should come before last Friday", "The parcel must reach after this Monday", "The delivery might appear during that Tuesday"],
            category: .sentenceComprehension
        ),

        // Sentences in Noise demos
        DemoSentence(
            sentence: "Can you help me find my keys",
            choices: ["Can you help me find my keys", "Can you help me find my phone", "Can you help me find my wallet", "Can you help me find my glasses"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The meeting starts at three o'clock",
            choices: ["The meeting starts at three o'clock", "The movie begins at two thirty", "The concert ends at four fifteen", "The show opens at five forty"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "I left my umbrella at the office",
            choices: ["I left my umbrella at the office", "You forgot your briefcase in the car", "She dropped her backpack on the bus", "He placed his jacket near the door"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "Would you like some coffee or tea",
            choices: ["Would you like some coffee or tea", "Should I bring you water or juice", "Can they offer us milk or soda", "Will he serve them wine or beer"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The store closes in fifteen minutes",
            choices: ["The store closes in fifteen minutes", "The bank opens within twenty seconds", "The mall shuts during thirty hours", "The shop runs after forty days"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "Please speak louder I cannot hear you",
            choices: ["Please speak louder I cannot hear you", "Kindly talk softer they will not listen", "Simply say faster we could not understand", "Gently whisper quieter he might not notice"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The appointment has been rescheduled to Friday",
            choices: ["The appointment has been rescheduled to Friday", "The reservation was cancelled until Monday", "The booking got confirmed for Tuesday", "The session is postponed since Wednesday"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "Turn left at the next traffic light",
            choices: ["Turn left at the next traffic light", "Go right near the last stop sign", "Drive straight past the first intersection", "Move backward through the second crossing"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The temperature will drop below freezing tonight",
            choices: ["The temperature will drop below freezing tonight", "The humidity might rise above boiling tomorrow", "The pressure could fall under normal yesterday", "The weather should increase over average today"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "I ordered pizza with extra cheese",
            choices: ["I ordered pizza with extra cheese", "You requested pasta without any sauce", "They bought burgers including more pickles", "We selected salad containing less dressing"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The flight departs from gate twelve",
            choices: ["The flight departs from gate twelve", "The journey arrives at terminal seven", "The voyage leaves through section three", "The trip boards via entrance nine"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "Please remember to lock the door",
            choices: ["Please remember to lock the door", "Kindly forget to open the window", "Simply recall to close the gate", "Gently ignore to secure the entrance"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The computer needs to be restarted",
            choices: ["The computer needs to be restarted", "The printer wants to get replaced", "The scanner requires being updated", "The keyboard demands getting cleaned"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "She graduated from college last spring",
            choices: ["She graduated from college last spring", "He enrolled in university next fall", "They transferred to school this winter", "We dropped from academy that summer"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The recipe calls for two cups of flour",
            choices: ["The recipe calls for two cups of flour", "The instructions need three spoons of sugar", "The directions want four bowls of water", "The guidelines require five pints of milk"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "My alarm clock rings every morning at six",
            choices: ["My alarm clock rings every morning at six", "Your timer beeps each evening at eight", "His reminder chimes every afternoon at two", "Their notification sounds each midnight at twelve"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The game was postponed due to rain",
            choices: ["The game was postponed due to rain", "The match got cancelled because of snow", "The competition is delayed owing to wind", "The tournament was rescheduled from fog"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "Could you pass me the salt please",
            choices: ["Could you pass me the salt please", "Would they hand us the pepper thanks", "Should I give you the sugar okay", "Might we share them the butter yes"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "The bridge connects the two islands",
            choices: ["The bridge connects the two islands", "The tunnel links the three cities", "The highway joins the four towns", "The railway separates the five villages"],
            category: .sentencesInNoise
        ),
        DemoSentence(
            sentence: "We need to buy groceries this afternoon",
            choices: ["We need to buy groceries this afternoon", "They want to sell furniture that morning", "You have to return clothes next evening", "I must exchange gifts last night"],
            category: .sentencesInNoise
        ),
    ]

    static func loadFromCSV(fileName: String, count: Int, category: TrainingCategory, excludeSentences: Set<String> = []) -> [DemoSentence] {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
            print("Could not find CSV file: \(fileName).csv")
            return demoSentences.filter { $0.category == category }
        }

        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            let lines = contents.components(separatedBy: .newlines)
            var sentences: [DemoSentence] = []

            // Skip header line and process data
            for line in lines.dropFirst() {
                let values = line.components(separatedBy: ",")
                if values.count >= 6 && !values[0].isEmpty {
                    let sentence = values[0].trimmingCharacters(in: .whitespaces)

                    // Skip if sentence was already used
                    if excludeSentences.contains(sentence.lowercased()) {
                        continue
                    }

                    let choice1 = values[1].trimmingCharacters(in: .whitespaces)
                    let choice2 = values[2].trimmingCharacters(in: .whitespaces)
                    let choice3 = values[3].trimmingCharacters(in: .whitespaces)
                    let choice4 = values[4].trimmingCharacters(in: .whitespaces)
                    let choices = [choice1, choice2, choice3, choice4].shuffled()

                    sentences.append(DemoSentence(
                        sentence: sentence,
                        choices: choices,
                        category: category
                    ))
                }
            }

            // Shuffle and return requested count
            return Array(sentences.shuffled().prefix(count))
        } catch {
            print("Error loading CSV: \(error)")
            return demoSentences.filter { $0.category == category }
        }
    }
}

struct DiagnosticItem {
    let content: String
    let type: DiagnosticType
    let difficulty: DiagnosticDifficulty
    let choices: [String]

    enum DiagnosticType {
        case word, sentence, sentenceInNoise
    }

    enum DiagnosticDifficulty: Int, CaseIterable {
        case easy = 1, medium = 2, hard = 3

        var label: String {
            switch self {
            case .easy: return "Easy"
            case .medium: return "Medium"
            case .hard: return "Hard"
            
            }
        }
    }

    static let diagnosticItems: [DiagnosticItem] = [
        // Easy level
        DiagnosticItem(content: "sun", type: .word, difficulty: .easy, choices: ["sun", "run", "fun", "gun"]),
        DiagnosticItem(content: "The cat sits", type: .sentence, difficulty: .easy, choices: ["The cat sits", "The dog runs", "The bird flies", "The fish swims"]),

        // Medium level
        DiagnosticItem(content: "elephant", type: .word, difficulty: .medium, choices: ["elephant", "telephone", "envelope", "escalator"]),
        DiagnosticItem(content: "Where did you put the book", type: .sentence, difficulty: .medium, choices: ["Where did you put the book", "When did you read the news", "How did you find the key", "Why did you call the friend"]),

        // Hard level
        DiagnosticItem(content: "refrigerator", type: .word, difficulty: .hard, choices: ["refrigerator", "administrator", "accelerator", "facilitator"]),
        DiagnosticItem(content: "The conference call has been rescheduled", type: .sentenceInNoise, difficulty: .hard, choices: ["The conference call has been rescheduled", "The important meeting was postponed", "The business trip got cancelled", "The dinner reservation was confirmed"]),

        // Expert level
        DiagnosticItem(content: "extraordinary", type: .word, difficulty: .hard, choices: ["extraordinary", "inflammatory", "contemporary", "revolutionary"]),
        DiagnosticItem(content: "Despite the challenging circumstances, the team accomplished their objectives", type: .sentenceInNoise, difficulty: .hard, choices: ["Despite the challenging circumstances, the team accomplished their objectives", "Although the difficult conditions, the group achieved their targets", "Because of the tough situations, the crew completed their missions", "Through the hard problems, the staff finished their assignments"]),
    ]
}

// MARK: - Test Results and Scoring

struct TestResult: Codable {
    let question: String
    let correctAnswer: String
    let userAnswer: String
    let isCorrect: Bool
    let responseTime: TimeInterval
    let timestamp: Date
    let category: String

    var formattedResponseTime: String {
        return String(format: "%.1fs", responseTime)
    }
}

struct WordHistoryEntry: Codable, Identifiable {
    let id: UUID
    let firstWord: String
    let lastWord: String
    let userSaid: String  // What the user actually said
    let category: String
    let wasCorrect: Bool
    let timestamp: Date

    init(id: UUID = UUID(), firstWord: String, lastWord: String, userSaid: String = "", category: String, wasCorrect: Bool, timestamp: Date = Date()) {
        self.id = id
        self.firstWord = firstWord
        self.lastWord = lastWord
        self.userSaid = userSaid
        self.category = category
        self.wasCorrect = wasCorrect
        self.timestamp = timestamp
    }
}

struct CategoryStats: Codable {
    var categoryName: String
    var totalAttempts: Int
    var correctAttempts: Int
    var missedWords: [WordHistoryEntry]
    var correctWords: [WordHistoryEntry] = []  // NEW: Track correct words too
    var lastPracticed: Date?

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctAttempts) / Double(totalAttempts)
    }

    var accuracyPercentage: String {
        return String(format: "%.1f%%", accuracy * 100)
    }
}

struct ListeningHistory: Codable {
    var allWordHistory: [WordHistoryEntry]
    var categoryBreakdown: [String: CategoryStats]
    var totalSessionsCompleted: Int
    var totalWordsAttempted: Int
    var overallAccuracy: Double

    init() {
        self.allWordHistory = []
        self.categoryBreakdown = [:]
        self.totalSessionsCompleted = 0
        self.totalWordsAttempted = 0
        self.overallAccuracy = 0.0
    }
}

struct TestSummary {
    let category: TrainingCategory
    let score: Int
    let totalQuestions: Int
    let accuracy: Double
    let testDuration: TimeInterval
    let voiceUsed: VoiceType
    let results: [TestResult]
    let timestamp: Date

    var accuracyPercentage: String {
        return String(format: "%.1f%%", accuracy * 100)
    }

    var averageResponseTime: String {
        let average = results.map { $0.responseTime }.reduce(0, +) / Double(results.count)
        return String(format: "%.1fs", average)
    }

    var testDurationFormatted: String {
        let minutes = Int(testDuration) / 60
        let seconds = Int(testDuration) % 60
        return String(format: "%dm %02ds", minutes, seconds)
    }

    func generateExportText() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        var exportText = """
        📊 HEARIFY - AUDITORY TRAINING TEST RESULTS
        ============================================

        Test Type: \(category.rawValue)
        Date: \(formatter.string(from: timestamp))
        Voice Used: \(voiceUsed.displayName)

        📈 SUMMARY
        ----------
        Score: \(score)/\(totalQuestions) (\(accuracyPercentage))
        Test Duration: \(testDurationFormatted)
        Average Response Time: \(averageResponseTime)

        📝 DETAILED RESULTS
        -------------------
        """

        for (index, result) in results.enumerated() {
            let status = result.isCorrect ? "✓ CORRECT" : "✗ INCORRECT"
            exportText += "\n\n\(index + 1). Question: \(result.question)"
            exportText += "\n   Your Answer: \(result.userAnswer)"
            exportText += "\n   Correct Answer: \(result.correctAnswer)"
            exportText += "\n   Status: \(status)"
            exportText += "\n   Response Time: \(result.formattedResponseTime)"
        }

        exportText += "\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exportText += "\n📱 Generated by Hearify Auditory Training App"
        exportText += "\n   Improving listening skills through practice"
        return exportText
    }
}

// MARK: - AI Analysis Structures

enum FrequencyRange: String, Codable {
    case lowFrequency = "Low Frequency (250-500 Hz)"
    case midFrequency = "Mid Frequency (500-2000 Hz)"
    case highFrequency = "High Frequency (2000-8000 Hz)"
    case veryHighFrequency = "Very High Frequency (8000+ Hz)"
}

enum PhoneticCategory: String, Codable {
    case vowels = "Vowels"
    case consonants = "Consonants"
    case fricatives = "Fricatives (s, sh, f, th)"
    case plosives = "Plosives (p, t, k, b, d, g)"
    case nasals = "Nasals (m, n, ng)"
    case liquids = "Liquids (l, r)"
}

// MARK: - Phonetic Difference Tracking
enum PhoneticDifferenceType: String, Codable {
    case initialConsonant = "Initial Consonant"
    case vowel = "Vowel"
    case finalConsonant = "Final Consonant"
    case consonantCluster = "Consonant Cluster"
    case voicing = "Voicing (voiced vs voiceless)"
    case liquids = "Liquid Sounds (r/l)"
    case fricatives = "Fricative Sounds (s/sh/f/th)"
    case nasals = "Nasal Sounds (m/n/ng)"
}

struct PhoneticDifference: Codable, Identifiable {
    var id: String { "\(word1)-\(word2)" }
    let word1: String
    let word2: String
    let differenceType: PhoneticDifferenceType
    let differingPhoneme1: String  // e.g., "c" in "cat"
    let differingPhoneme2: String  // e.g., "h" in "hat"
    let position: String           // e.g., "initial", "medial", "final"

    var description: String {
        return "\(word1) vs \(word2): \(differingPhoneme1) vs \(differingPhoneme2) (\(position))"
    }
}

struct PhoneticError: Codable {
    let difference: PhoneticDifference
    let missCount: Int
    let lastMissed: Date
}

struct AudiologistRecommendation: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let priority: RecommendationPriority
    let category: RecommendationType
    let specificWords: [String]
    let frequencies: [FrequencyRange]
    let phoneticTargets: [PhoneticCategory]

    init(title: String, description: String, priority: RecommendationPriority, category: RecommendationType, specificWords: [String] = [], frequencies: [FrequencyRange] = [], phoneticTargets: [PhoneticCategory] = []) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.priority = priority
        self.category = category
        self.specificWords = specificWords
        self.frequencies = frequencies
        self.phoneticTargets = phoneticTargets
    }

    enum RecommendationPriority: String, Codable {
        case high = "High Priority"
        case medium = "Medium Priority"
        case low = "Low Priority"

        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
    }

    enum RecommendationType: String, Codable {
        case medicalReferral = "Medical Referral"
        case focusedTraining = "Focused Training"
        case hearingAidProgramming = "Hearing Aid Programming"
        case environmentalStrategies = "environmental Strategies"
    }
}

struct ProblematicWord: Codable {
    let word: String
    let errorCount: Int
    let contexts: [String]  // Example contexts where this word was missed
    let userSaidExamples: [String]  // What the user actually said (for sentences)
    let itemType: String  // "word", "sentence", or "matchedPair"

    // Legacy support
    var missCount: Int { errorCount }
    
    init(word: String, errorCount: Int, contexts: [String] = [], userSaidExamples: [String] = [], itemType: String = "word") {
        self.word = word
        self.errorCount = errorCount
        self.contexts = contexts
        self.userSaidExamples = userSaidExamples
        self.itemType = itemType
    }
}

struct AIAnalysisReport: Codable {
    let generatedDate: Date
    let totalMissedWords: Int
    let totalMissedSentences: Int
    let overallAccuracy: Double
    let recommendations: [AudiologistRecommendation]
    let frequencyAnalysis: [FrequencyRange: Double]
    let phoneticAnalysis: [PhoneticCategory: Double]
    let topProblematicWords: [ProblematicWord]
    let phoneticErrors: [PhoneticError]
    let aiInsights: AIInsights?  // NEW: ChatGPT-generated insights
    let rawFeatures: ExtractedFeatures?  // NEW: Raw feature data for transparency

    var summary: String {
        return """
        Analysis of \(totalMissedWords + totalMissedSentences) errors identified \(recommendations.count) recommendations.
        Overall accuracy: \(String(format: "%.1f%%", overallAccuracy * 100))
        """
    }

    // AI summary for audiologist
    var aiSummary: String {
        return aiInsights?.summary ?? "No AI insights available"
    }
}

// EXTRACTED TO: Utils/Extensions.swift
/*
extension UserDefaults {
    func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String) {
        do {
            let encoded = try JSONEncoder().encode(data)
            set(encoded, forKey: defaultName)
        } catch {
            print("Error encoding object for key \(defaultName): \(error.localizedDescription)")
        }
    }

    func codableObject<T : Codable>(dataType: T.Type, key: String) -> T? {
        guard let userDefaultData = data(forKey: key) else {
            print("No data found for key: \(key)")
            return nil
        }

        do {
            return try JSONDecoder().decode(T.self, from: userDefaultData)
        } catch {
            print("Error decoding object for key \(key): \(error.localizedDescription)")
            removeObject(forKey: key)
            return nil
        }
    }
}
*/

// EXTRACTED TO: Utils/CSVLoader.swift
/*
var WordList = [Word]()
struct JSONWORDLIST: Codable {
    var jsonlist = [Word]()
}

func convertCSVIntoArray(CSV: String) {
    guard let filepath = Bundle.main.path(forResource: CSV, ofType: "csv") else {
        print("Error: Cannot find CSV file: \(CSV).csv")
        return
    }

    var data = ""
    do {
        data = try String(contentsOfFile: filepath)
    } catch {
        print("Error reading CSV file \(CSV): \(error.localizedDescription)")
        return
    }

    let rows = data.components(separatedBy: "\n")
    var validRowCount = 0

    for (index, row) in rows.enumerated() {
        let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedRow.isEmpty else {
            continue
        }

        let columns = trimmedRow.components(separatedBy: ",")

        guard columns.count == 3 else {
            print("Warning: Invalid row format at line \(index + 1) in \(CSV).csv - expected 3 columns, got \(columns.count)")
            continue
        }

        let fw = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let lw = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let cy = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)

        guard !fw.isEmpty && !lw.isEmpty && !cy.isEmpty else {
            print("Warning: Empty values in row \(index + 1) of \(CSV).csv")
            continue
        }

        let word = Word(firstWord: fw, lastWord: lw, category: cy)
        WordList.append(word)
        validRowCount += 1
    }

    print("Loaded \(validRowCount) valid words from \(CSV).csv")
}
*/

// EXTRACTED TO: Views/Components/ResponsiveHeadings.swift
/*
struct ResponsiveHeadings: View {
    var text: String
    var geometry: GeometryProxy?

    var body: some View {
        let layout = geometry.map { ResponsiveLayoutHelper(geometry: $0) }

        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content
            VStack(spacing: 2) {
                Text(text)
                    .font(.system(size: layout?.titleFontSize ?? 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                // Subtle underline accent
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.4), .clear, .cyan.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .frame(maxWidth: min(150, (layout?.buttonWidth ?? 300) * 0.5))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, layout?.padding ?? 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 65)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}
*/

// Background Noise Audio Player with Proper SNR Mixing
public class BackgroundNoisePlayer {
    private var audioEngine: AVAudioEngine?
    private var noisePlayerNode: AVAudioPlayerNode?
    private var noisePCMBuffer: AVAudioPCMBuffer?
    private var isBackgroundPlaying: Bool = false

    // Speech-to-Noise Ratio (SNR) configuration
    // speechVolume should be constant, we adjust noise relative to it
    private let speechReferenceVolume: Float = 0.85  // Speech at 85% volume

    func startBackgroundNoise(type: BackgroundNoiseType, volume: Float) {
        guard type != .none else {
            stopBackgroundNoise()
            return
        }

        // Convert volume (0-1) to SNR (dB)
        // volume 0.85+ = 0 dB SNR (hardest)
        // volume 0.7 = 2 dB SNR (clinical standard)
        // volume 0.5 = 5 dB SNR (moderate)
        let targetSNR = volumeToSNR(Double(volume))

        // Calculate noise volume based on desired SNR
        let noiseVolume = calculateNoiseVolume(forSNR: targetSNR)

        // SAFETY: If already playing, just update volume instead of restarting
        if isBackgroundPlaying && noisePlayerNode?.isPlaying == true {
            print("🔊 Noise already playing - updating volume only")
            updateBackgroundVolume(volume)
            return
        }

        print("🔊 Starting noise generator:")
        print("   Target SNR: \(targetSNR) dB")
        print("   Speech volume: \(speechReferenceVolume)")
        print("   Calculated noise volume: \(noiseVolume)")

        // Generate and play multi-talker babble noise
        generateAndPlayBabbleNoise(volume: noiseVolume)
    }

    func stopBackgroundNoise() {
        noisePlayerNode?.stop()
        audioEngine?.stop()
        audioEngine = nil
        noisePlayerNode = nil
        noisePCMBuffer = nil
        isBackgroundPlaying = false
        print("Stopped background noise generator")
    }

    func updateBackgroundVolume(_ volume: Float) {
        let targetSNR = volumeToSNR(Double(volume))
        let noiseVolume = calculateNoiseVolume(forSNR: targetSNR)
        noisePlayerNode?.volume = noiseVolume
        print("🔊 Updated noise volume to \(noiseVolume) for \(targetSNR) dB SNR")
    }

    func isPlaying() -> Bool {
        return isBackgroundPlaying && (noisePlayerNode?.isPlaying ?? false)
    }

    private func volumeToSNR(_ volume: Double) -> Double {
        // Map volume slider (0-1) to SNR (dB)
        if volume >= 0.85 {
            return 0    // 0 dB SNR - Very challenging
        } else if volume >= 0.7 {
            return 2    // +2 dB SNR - Challenging (clinical standard)
        } else if volume >= 0.55 {
            return 5    // +5 dB SNR - Moderate
        } else if volume >= 0.4 {
            return 10   // +10 dB SNR - Easier
        } else {
            return 15   // +15 dB SNR - Easy
        }
    }

    private func calculateNoiseVolume(forSNR snr: Double) -> Float {
        // SNR formula: SNR (dB) = 20 * log10(Signal / Noise)
        // Rearranged: Noise = Signal / 10^(SNR/20)

        let snrLinear = pow(10.0, snr / 20.0)
        let noiseVolume = Float(Double(speechReferenceVolume) / snrLinear)

        // Clamp between 0.1 and 1.0 for safety
        return min(max(noiseVolume, 0.1), 1.0)
    }

    private func generateAndPlayBabbleNoise(volume: Float) {
        do {
            // Stop any existing playback SAFELY
            if isBackgroundPlaying {
                stopBackgroundNoise()
                // Give the audio system time to fully stop (prevent "did not see IO cycle" crash)
                Thread.sleep(forTimeInterval: 0.05) // 50ms delay
            }

            // Create audio engine
            audioEngine = AVAudioEngine()
            guard let engine = audioEngine else { return }

            // Create player node
            noisePlayerNode = AVAudioPlayerNode()
            guard let playerNode = noisePlayerNode else { return }

            // Attach player node to engine
            engine.attach(playerNode)

            // Get the format from the engine's main mixer
            let format = engine.mainMixerNode.outputFormat(forBus: 0)

            // Generate babble noise buffer (multi-talker speech-like noise)
            let bufferSize = AVAudioFrameCount(format.sampleRate * 5.0) // 5 seconds of noise
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize) else {
                print("Failed to create audio buffer")
                return
            }

            buffer.frameLength = bufferSize

            // Generate multi-talker babble noise (more realistic than white noise)
            if let channelData = buffer.floatChannelData {
                let channelCount = Int(format.channelCount)

                for channel in 0..<channelCount {
                    let samples = channelData[channel]

                    // Create babble noise by mixing multiple frequency bands
                    // This simulates multiple people talking (more realistic)
                    for frame in 0..<Int(bufferSize) {
                        // Mix multiple sine waves at speech-relevant frequencies (100-8000 Hz)
                        var sample: Float = 0.0

                        // Low frequency content (100-500 Hz) - vowel sounds
                        sample += sin(Float(frame) * 0.01 + Float.random(in: 0...2 * .pi)) * 0.3
                        sample += sin(Float(frame) * 0.02 + Float.random(in: 0...2 * .pi)) * 0.25

                        // Mid frequency content (500-2000 Hz) - formants
                        sample += sin(Float(frame) * 0.05 + Float.random(in: 0...2 * .pi)) * 0.2
                        sample += sin(Float(frame) * 0.08 + Float.random(in: 0...2 * .pi)) * 0.15

                        // High frequency content (2000-8000 Hz) - consonants
                        sample += sin(Float(frame) * 0.15 + Float.random(in: 0...2 * .pi)) * 0.1

                        // Add random amplitude modulation (speech-like envelope)
                        let envelope = Float.random(in: 0.5...1.0)
                        sample *= envelope

                        // Normalize and scale
                        samples[frame] = sample * 0.15  // Keep amplitude reasonable
                    }
                }
            }

            noisePCMBuffer = buffer

            // Connect player node to mixer
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)

            // Set volume
            playerNode.volume = volume

            // Start engine FIRST
            try engine.start()

            // IMPORTANT: Give engine time to start and process at least one IO cycle
            // This prevents the "player did not see an IO cycle" crash
            Thread.sleep(forTimeInterval: 0.05) // 50ms delay

            // Schedule buffer to loop
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)

            // SAFETY: Wrap play() in do-catch to prevent crash
            do {
                // Play the node
                playerNode.play()
                isBackgroundPlaying = true
                print("✅ Successfully started babble noise generator at volume \(volume)")
            } catch let playError as NSError {
                print("❌ Error starting player node: \(playError.localizedDescription)")
                // Cleanup on failure
                stopBackgroundNoise()
                isBackgroundPlaying = false
            }

        } catch {
            print("❌ Error generating background noise: \(error.localizedDescription)")
            isBackgroundPlaying = false
        }
    }

    private func getBackgroundNoiseFileName(for type: BackgroundNoiseType) -> String {
        switch type {
        case .none:
            return ""
        case .cafe, .traffic, .crowd, .office, .nature:
            return "BackgroundNoise"
        }
    }
}

// EXTRACTED TO: Managers/AudioManager.swift
/*
class AudioManager: ObservableObject {
    @Published private var audioPlayer = GenerateAudio(audio: "")
    private var voiceSettings: VoiceSettings?
    
    func setVoiceSettings(_ settings: VoiceSettings) {
        self.voiceSettings = settings
    }
    
    func playAudio(_ audioName: String, completion: ((Bool) -> Void)? = nil) {
        let finalAudioName: String
        
        // Special handling for button press and other system sounds
        if audioName == "buttonpress" {
            finalAudioName = "buttonpressMale1" // Always use Male1 for system sounds
        } else if let voiceSettings = voiceSettings {
            finalAudioName = voiceSettings.getAudioFileName(for: audioName)
        } else {
            finalAudioName = "\(audioName)Male1" // Default fallback
        }
        
        audioPlayer.playAudio(audio1: finalAudioName, completion: completion)
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer.setVolume(volume)
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        audioPlayer.setPlaybackSpeed(speed)
    }
    
    func stopAudio() {
        audioPlayer.stopAudio()
    }
}

public class GenerateAudio {
    var audio: String
    init(audio: String) {
        self.audio = audio
    }
    private var player: AVAudioPlayer?
    private var isPlaying: Bool = false
    private var playbackRate: Float = 1.0
    
    func playAudio(audio1: String, completion: ((Bool) -> Void)? = nil) {
        guard !audio1.isEmpty else {
            print("Error: Empty audio filename provided")
            completion?(false)
            return
        }

        // Try exact match first
        if let url = Bundle.main.url(forResource: audio1, withExtension: "mp3") {
            playAudioFromUrl(url, completion: completion)
            return
        }

        // Try capitalized version (first letter uppercase)
        let capitalizedAudio = audio1.prefix(1).uppercased() + audio1.dropFirst()
        if let url = Bundle.main.url(forResource: capitalizedAudio, withExtension: "mp3") {
            playAudioFromUrl(url, completion: completion)
            return
        }

        // Try lowercase version
        let lowercaseAudio = audio1.lowercased()
        if let url = Bundle.main.url(forResource: lowercaseAudio, withExtension: "mp3") {
            playAudioFromUrl(url, completion: completion)
            return
        }

        print("Error: Could not find audio file: \(audio1).mp3")
        // Try alternative file extensions
        if let wavUrl = Bundle.main.url(forResource: audio1, withExtension: "wav") {
            playAudioFromUrl(wavUrl, completion: completion)
            return
        }

        completion?(false)
    }
    
    private func playAudioFromUrl(_ url: URL, completion: ((Bool) -> Void)? = nil) {
        do {
            // Configure audio session for proper playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            
            guard let player = player else {
                completion?(false)
                return
            }
            
            // Enable rate control and apply current playback speed
            player.enableRate = true
            player.rate = playbackRate
            
            player.prepareToPlay()
            isPlaying = player.play()
            
            if isPlaying {
                print("Successfully playing audio: \(url.lastPathComponent)")
            } else {
                print("Failed to start audio playback: \(url.lastPathComponent)")
            }
            
            completion?(isPlaying)
        } catch {
            print("Error playing audio file \(url.lastPathComponent): \(error.localizedDescription)")
            completion?(false)
        }
    }
    
    func stopAudio() {
        player?.stop()
        player = nil
        isPlaying = false
        
        // Deactivate audio session when done
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func isCurrentlyPlaying() -> Bool {
        return isPlaying && (player?.isPlaying ?? false)
    }
    
    func getVolume() -> Float {
        return player?.volume ?? 1.0
    }
    
    func setVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(1.0, volume))
        player?.volume = clampedVolume
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        let clampedSpeed = max(0.5, min(2.0, speed))
        playbackRate = clampedSpeed
        
        // Apply speed to current player if it exists
        if let player = player {
            player.enableRate = true
            player.rate = clampedSpeed
        }
    }
    
    deinit {
        stopAudio()
    }
    
    func getPlaybackSpeed() -> Float {
        return playbackRate
    }
}
*/

struct FavoriteButton: View {
    @Binding var isSet: Bool
    var audio2: String
    var audioManager: AudioManager
    
    var body: some View {
        GeometryReader { geometry in
            let layout = ResponsiveLayoutHelper(geometry: geometry)
            
            Button {
                isSet.toggle()
                if isSet {
                    audioManager.playAudio(audio2)
                }
            } label: {
                Image("soundicon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layout.imageSize, height: layout.imageSize)
            }
        }
    }
}

public class texttoput: ObservableObject {
    @Published var text: String
    init(text: String) {
        self.text = text
    }
}

let key = "foo_key"
let key2 = "onoff"
var oneortwo = 1
public var i = 0
public var j = 0
public var alerttext2 = ""
public var bool2 = false
public var nextdisable = true
public var wrongnextdisable = true
public var finaldisable = true

public var Text1 = texttoput(text: "Hi")
public var Text2 = texttoput(text: "Bye")
public var audioname = texttoput(text: "gold")
public var sectiontitle = texttoput(text: "Suprasegmental Cues")
public var section1 = texttoput(text: "1 Syllable")
public var section2 = texttoput(text: "2 Syllable")
public var section3 = texttoput(text: "3 Syllable")
public var section4 = texttoput(text: "1 Syllable")
public var section5 = texttoput(text: "2 Syllables")
public var backgroundNoise = BackgroundNoisePlayer()

public func cleanup() {
    backgroundNoise.stopBackgroundNoise()
}

public var maxCount = 0
public var topCategory = " "
public var mainCategory = "syllables"
public var currentWordLocation = 0
public var isWrongWord = false
var alerttext = texttoput(text: "")
var tempWordList = [Word]()
var WrongWordList = [Word]()
var wrongI = 0
var PracticeList = [PracticeItem]()

// MARK: - Speech Recognition Manager
// EXTRACTED TO: Managers/SpeechRecognitionManager.swift
/*
class SpeechRecognitionManager: ObservableObject {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var isAuthorized = false

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.isAuthorized = (authStatus == .authorized)
            }
        }
    }

    func startRecording() {
        guard isAuthorized else {
            requestAuthorization()
            return
        }

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            return
        }

        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine error: \(error)")
            return
        }

        isRecording = true
        recognizedText = ""

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }

            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }

        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
    }
}
*/

struct ContentView: View {
    @State var screen = Screen.beginscreen
    @State private var showingAlert = false
    @State private var showingAlert2 = false
    @State private var showingWordAddedAlert = false
    @State private var showingPracticeItemAddedAlert = false
    @State private var addedPracticeItemText = ""
    @State private var buttonconfirm: Bool = true
    @State private var jsonlistobject = JSONWORDLIST(jsonlist: [])
    @State private var addedWordPair = ""
    @StateObject private var audioManager = AudioManager()
    @StateObject private var voiceSettings = VoiceSettings()
    // Use shared instances to avoid creating duplicates (performance issue)
    @ObservedObject private var progressTrackingManager = ProgressTrackingManager.shared
    @ObservedObject private var analyticsManager = AnalyticsManager.shared
    @EnvironmentObject private var firebase: FirebaseManager
    @State private var showSignOutAlert = false
    
    // Module Program state
    @State private var selectedModuleProgram: ModuleProgram? = nil
    
    // Word pair selection state
    @State private var showWordPairSelector: Bool = false
    @State private var availableWordPairs: [Word] = []
    @State private var selectedWordPairs: Set<String> = []  // Store IDs as "firstWord-lastWord"
    @State private var wordPairCategory: String = ""
    @State private var selectedSinglePair: Word? = nil  // For single pair practice
    @State private var pairPracticeCount: Int = 10  // How many times to practice the pair
    @State private var multiPairPracticeCount: Int = 10  // How many times to practice each pair in multi-select
    
    // User responses tracking
    @State private var userResponses: [UserResponse] = []
    
    // Phase 2: Speaking Practice state
    @StateObject private var speechManager = SpeechRecognitionManager()
    // OLD Speaking Practice state variables (no longer used with new SpeakingPracticeView)
    /*
     @State private var targetSpeechText = "Hello, how are you today?"
     @State private var speechScore: Double = 0.0
     @State private var showSpeechResults = false
     */
    
    // Speech recognition for sentence testing
    @State private var isSentenceSpeechMode: Bool = true // New: sentences use speech by default
    @State private var spokenText: String = ""
    @State private var wordMatchScore: Double = 0.0
    @State private var matchedWords: Int = 0
    @State private var totalWords: Int = 0
    
    // New Training Category state
    @State private var currentTrainingCategory: TrainingCategory = .matchedPairs
    @State private var currentDemoWords: [DemoWord] = []
    @State private var currentDemoSentences: [DemoSentence] = []
    @State private var usedWords: Set<String> = []
    @State private var usedSentences: Set<String> = []
    @State private var currentDiagnosticItems: [DiagnosticItem] = []
    @State private var currentQuestionIndex: Int = 0
    @State private var userAnswer: String = ""
    @State private var showingAnswer: Bool = false
    @State private var showingFeedback: Bool = false
    @State private var isAnswerCorrect: Bool = false
    @State private var firstWordDetected: Bool = false // Track when first word is detected
    @State private var waitingForRecordingStart: Bool = false // Track if we're waiting for recording to start after audio
    @State private var recordingTimeoutTask: DispatchWorkItem? = nil // Track timeout task to cancel if needed
    @State private var currentPracticeItems: [PracticeItem] = []
    @State private var practiceItemChoices: [[String]] = []
    @State private var playedMatchedPairWord: String? = nil // Track which word was played for matched pairs
    @State private var practiceListSubScreen: PracticeListSubScreen = .question // Track which sub-screen to show
    @State private var practiceListOneOrTwo: Int = 1 // Track which word was played (1 or 2) for matched pairs
    @State private var selectedWordCount: Int = 0
    @State private var showWordCountPicker: Bool = true
    @State private var selectedChoices: [[String]] = []
    @State private var selectedSentenceCount: Int = 0
    @State private var showSentenceCountPicker: Bool = true
    @State private var diagnosticWordCount: Int = 0
    @State private var diagnosticSentenceCount: Int = 0
    @State private var diagnosticNoiseSentenceCount: Int = 0
    @State private var showDiagnosticSelection: Bool = true
    
    // Unlimited Practice Mode
    @State private var isUnlimitedMode: Bool = false
    @State private var unlimitedSessionCorrect: Int = 0
    @State private var unlimitedSessionTotal: Int = 0
    @State private var unlimitedSessionStartTime: Date? = nil
    @State private var showStatsPanel: Bool = true
    @State private var showFatigueWarning: Bool = false
    @State private var currentStreak: Int = 0
    @State private var adaptiveNoiseLevel: Double = 0.3 // For adaptive noise difficulty
    @State private var usedSentencesInSession: Set<String> = [] // Track used sentences to avoid repetition
    @State private var usedWordsInSession: Set<String> = [] // Track used words to avoid repetition
    
    // Scoring and Results
    @State private var testResults: [TestResult] = []
    @State private var currentScore: Int = 0
    @State private var totalQuestions: Int = 0
    @State private var testStartTime: Date = Date()
    @State private var testCompletionTime: Date?
    @State private var showingExportSheet: Bool = false
    @State private var questionStartTime: Date = Date()
    @State private var currentTestSummary: TestSummary?
    @State private var statsShareItems: [Any] = []
    @State private var showingClearDataAlert: Bool = false
    
    // AI Analysis state
    @State private var currentAIReport: AIAnalysisReport?
    @State private var isGeneratingAnalysis: Bool = false
    @State private var showingAIAnalysis: Bool = false
    
    // Custom Practice mode flag
    @State private var isCustomPracticeMode: Bool = false
    
    // Practice List state
    @State private var practiceRepetitions: Int = 3
    @State private var showingAddWordSheet: Bool = false
    @State private var showCustomUploadSheet: Bool = false
    @State private var showClinicianDashboard: Bool = false
    @State private var showCloudKitDebug: Bool = false
    @State private var showAboutScreen: Bool = false
    @State private var hasAgreedToLegalTerms: Bool = UserDefaults.standard.bool(forKey: "hasAgreedToLegalTerms")
    @State private var customWordsText: String = ""
    @State private var editingPracticeItem: PracticeItem? = nil // Item being edited
    @State private var wordListSearchText: String = "" // Search filter
    @State private var newItemWord: String = "" // For add/edit sheet
    @State private var newItemSentence: String = "" // For add/edit sheet
    @State private var newItemType: PracticeItem.PracticeItemType = .word // For add/edit sheet
    @State private var newItemCategory: String = "Custom" // For add/edit sheet
    @State private var selectedPracticeItems: Set<UUID> = [] // Selected items for bulk actions
    @State private var isSelectionMode: Bool = false // Toggle selection mode
    @State private var selectedCustomWordIndices: Set<Int> = [] // Selected custom word indices
    @State private var selectedCustomSentenceIndices: Set<Int> = [] // Selected custom sentence indices
    @State private var selectedCustomMatchedPairIndices: Set<Int> = [] // Selected custom matched pair indices
    @State private var isCustomWordsSelectionMode: Bool = false // Toggle for custom words
    @State private var isCustomSentencesSelectionMode: Bool = false // Toggle for custom sentences
    @State private var isCustomMatchedPairsSelectionMode: Bool = false // Toggle for custom matched pairs
    @State private var customItemsRefreshTrigger: UUID = UUID() // Force view refresh after deletion
    @State private var uploadType: CustomUploadType = .words
    @State private var newWordFirst: String = ""
    @State private var newWordLast: String = ""
    @State private var newWordCategory: String = "Custom"
    
    // Settings state
    @State private var playbackSpeed: Double = 1.0
    @State private var volumeLevel: Float = 1.0
    @State private var backgroundNoiseEnabled: Bool = false
    @State private var backgroundNoiseType: BackgroundNoiseType = .cafe
    @State private var backgroundNoiseVolume: Float = 0.7  // Clinical standard: ~0-5 dB SNR
    @State private var difficultyLevel: DifficultyLevel = .medium
    @State private var showProgressAfterEachWord: Bool = true
    
    // Onboarding state
    @State private var isFirstLaunch: Bool = true
    @State private var onboardingStep: Int = 0
    
    // Progress tracking state
    @State private var totalAttempts: Int = 0
    @State private var correctAttempts: Int = 0
    @State private var sessionAttempts: Int = 0
    @State private var sessionCorrect: Int = 0
    @State private var dailyStreak: Int = 0
    @State private var lastPlayDate: Date = Date()
    @State private var categoryStats: [String: [String: Int]] = [:]
    
    // Daily challenge state
    @State private var currentChallenge: DailyChallenge?
    @State private var challengeCompleted: Bool = false
    @State private var challengeAttempts: Int = 0
    @State private var challengeCorrect: Int = 0
    @State private var lastChallengeDate: Date = Date()
    @State private var challengeStreak: Int = 0
    
    // Analytics state
    @State private var weeklyProgressData: [DailyProgressData] = []
    @State private var categoryPerformanceData: [ChartDataPoint] = []
    @State private var listeningHistory: ListeningHistory = ListeningHistory()
    @State private var selectedHistoryCategory: String? = nil
    
    public func randomize() -> Bool {
        tempWordList.removeAll()
        
        print("🔍 Randomize called - Looking for category: '\(mainCategory)'")
        print("📚 Total words in WordList: \(WordList.count)")
        
        for x in WordList {
            if (x.category == mainCategory) {
                tempWordList.append(x)
            }
        }
        
        guard !tempWordList.isEmpty else {
            print("❌ Error: No words found for category '\(mainCategory)'")
            if WordList.count > 0 {
                print("   Available categories in WordList:")
                let uniqueCategories = Set(WordList.map { $0.category })
                for category in uniqueCategories {
                    let count = WordList.filter { $0.category == category }.count
                    print("   - '\(category)' (\(count) words)")
                }
            } else {
                print("   WordList is completely empty - CSV may not have loaded")
            }
            return false
        }
        
        print("✅ Found \(tempWordList.count) words for category '\(mainCategory)'")
        
        i = Int.random(in: 0..<tempWordList.count)
        wrongI = i
        currentWordLocation = i
        Text1.text = tempWordList[i].firstWord
        Text2.text = tempWordList[i].lastWord
        j = Int.random(in: 1..<3)
        oneortwo = j
        if (j==1) {
            audioname.text = tempWordList[i].firstWord
        } else {
            audioname.text = tempWordList[i].lastWord
        }
        maxCount = tempWordList.count
        
        print("   After randomize - audioname: \(audioname.text)")
        return true
    }
    
    public func nextWord() {
        if (topCategory != "WrongWordList") {
            guard currentWordLocation >= 0 && currentWordLocation < tempWordList.count else {
                print("Error: Invalid currentWordLocation \(currentWordLocation) for list size \(tempWordList.count)")
                return
            }
            tempWordList.remove(at: currentWordLocation)
        }
        
        if (tempWordList.count == 0) {
            screen = .homescreen
            alerttext.text = "Finished all words in category"
            showingAlert = true
            return
        }
        
        guard !tempWordList.isEmpty else {
            print("Error: tempWordList is empty in nextWord()")
            return
        }
        
        i = Int.random(in: 0..<tempWordList.count)
        wrongI = i
        currentWordLocation = i
        Text1.text = tempWordList[i].firstWord
        Text2.text = tempWordList[i].lastWord
        j = Int.random(in: 1..<3)
        oneortwo = j
        if (j==1) {
            audioname.text = tempWordList[i].firstWord
        } else {
            audioname.text = tempWordList[i].lastWord
        }
    }
    
    // MARK: - Computed Properties
    
    // Filtered practice list for search functionality
    var filteredPracticeList: [PracticeItem] {
        if wordListSearchText.isEmpty {
            return PracticeList
        }
        
        return PracticeList.filter { item in
            // Search in content (word/sentence)
            let contentMatch = item.content.localizedCaseInsensitiveContains(wordListSearchText)
            
            // Search in category
            let categoryMatch = item.category.localizedCaseInsensitiveContains(wordListSearchText)
            
            // Search in choices (for matched pairs)
            let choicesMatch = item.choices?.contains { choice in
                choice.localizedCaseInsensitiveContains(wordListSearchText)
            } ?? false
            
            return contentMatch || categoryMatch || choicesMatch
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let layout = ResponsiveLayoutHelper(geometry: geometry)
            
            // Show legal agreement first if not agreed
            if !hasAgreedToLegalTerms {
                LegalAgreementView(hasAgreedToTerms: $hasAgreedToLegalTerms)
            } else {
                mainAppContent(layout: layout)
            }
        }
        .onDisappear {
            audioManager.stopAudio()
            cleanup()
        }
        .sheet(isPresented: $showCustomUploadSheet) {
            CustomUploadSheetView(
                uploadType: $uploadType,
                customWordsText: $customWordsText,
                onSubmit: {
                    processCustomUpload()
                    showCustomUploadSheet = false
                }
            )
        }
        .sheet(isPresented: $showClinicianDashboard) {
            ClinicianDashboardView()
        }
        .sheet(isPresented: $showCloudKitDebug) {
            CloudKitDebugView()
        }
        .sheet(isPresented: $showAboutScreen) {
            AboutScreenView()
        }
        .sheet(item: $selectedModuleProgram) { program in
            NavigationView {
                ModuleProgramView(
                    program: program,
                    onDismiss: {
                        selectedModuleProgram = nil
                    },
                    onStartTraining: {
                        // Navigate to the appropriate module screen
                        switch program.moduleNumber {
                        case 1:
                            // Module 1: Hearing Training - go to main practice screen
                            screen = .homescreen
                        case 2:
                            // Module 2: Speaking & Pronunciation
                            screen = .speakingPracticeScreen
                        case 3:
                            // Module 3: Camera Vision Analysis (disabled for now)
                            screen = .cameraVisionScreen
                        default:
                            screen = .homescreen
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showWordPairSelector) {
            WordPairSelectorView(
                availableWordPairs: $availableWordPairs,
                selectedWordPairs: $selectedWordPairs,
                practiceCount: $multiPairPracticeCount,
                category: wordPairCategory,
                onStart: {
                    startPracticeWithSelectedPairs(count: multiPairPracticeCount)
                },
                onSelectSinglePair: { pair in
                    print("🔘 Practice button clicked for pair: \(pair.firstWord) vs \(pair.lastWord)")
                    showWordPairSelector = false
                    selectedSinglePair = pair
                    print("   selectedSinglePair set to: \(pair.firstWord) vs \(pair.lastWord)")
                }
            )
        }
        .sheet(isPresented: Binding<Bool>(
            get: { selectedSinglePair != nil },
            set: { if !$0 { selectedSinglePair = nil } }
        )) {
            if let pair = selectedSinglePair {
                PairPracticeConfigView(
                    pair: pair,
                    practiceCount: $pairPracticeCount,
                    onStart: {
                        startSinglePairPractice(pair: pair, count: pairPracticeCount)
                        selectedSinglePair = nil
                    },
                    onCancel: {
                        selectedSinglePair = nil
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    func mainAppContent(layout: ResponsiveLayoutHelper) -> some View {
        ZStack {
            // Enhanced Background with Gradient - fills entire screen
            AppTheme.backgroundPrimary
                .overlay(
                    LinearGradient(
                        colors: [
                            AppTheme.primaryBlue.opacity(0.05),
                            AppTheme.primaryCyan.opacity(0.03),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Enhanced Header (hidden for screens with custom headers)
                if screen != .cameraVisionScreen &&
                    screen != .beginscreen &&
                    screen != .mainSelectionScreen &&
                    screen != .phaseSelectionScreen &&
                    screen != .tutorialScreen &&
                    screen != .homescreen &&
                    screen != .screen1 &&
                    screen != .screen2 &&
                    screen != .screen3 &&
                    screen != .screen5 &&
                    screen != .screen8 &&
                    screen != .settingscreen &&
                    screen != .statsscreen &&
                    screen != .wordRecognitionScreen &&
                    screen != .sentenceComprehensionScreen &&
                    screen != .sentencesInNoiseScreen &&
                    screen != .diagnosticTestScreen &&
                    screen != .practiceListSessionScreen &&
                    screen != .aiAnalysisScreen &&
                    screen != .customPracticeScreen {
                    ModernHeader(text: getScreenTitle(), layout: layout)
                }
                
                // Main Content - special handling for begin screen
                if screen == .beginscreen {
                    VStack(spacing: 0) {
                        Spacer()
                        Spacer()
                        
                        Image("App_Begin_Icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: min(280, layout.buttonWidth * 0.9), maxHeight: 280)
                            .padding(.horizontal, layout.padding)
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        Button("Begin!") {
                            screen = .mainSelectionScreen // Go to selection screen
                            setupUserSettings()
                        }
                        .font(.system(size: layout.largeFontSize * 0.8, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: layout.buttonWidth, height: layout.buttonHeight * 1.5)
                        .background(Color.cyan)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, layout.padding)
                        .padding(.bottom, layout.geometry.safeAreaInsets.bottom + 30)
                    }
                } else if screen == .cameraVisionScreen {
                    // Full-screen camera view (no scrollview, no padding)
                    getScreenContent(layout: layout)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all, edges: .all)
                } else {
                    ScrollViewReader { scrollProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            Group {
                                if layout.deviceType == .iPad && layout.isLandscape {
                                    // iPad landscape layout with better spacing
                                    HStack(spacing: layout.spacing * 2) {
                                        Spacer()
                                        VStack(spacing: layout.spacing) {
                                            getScreenContent(layout: layout)
                                        }
                                        .frame(maxWidth: layout.geometry.size.width * 0.8)
                                        Spacer()
                                    }
                                } else {
                                    // Standard layout for iPhone and iPad portrait
                                    VStack(spacing: layout.spacing) {
                                        getScreenContent(layout: layout)
                                    }
                                }
                            }
                            .padding(.horizontal, layout.padding)
                            .padding(.top, layout.spacing * 2)
                            .padding(.bottom, layout.geometry.safeAreaInsets.bottom + layout.spacing * 2)
                            .id("scrollTop")
                        }
                        .onChange(of: screen) { newScreen in
                            withAnimation {
                                scrollProxy.scrollTo("scrollTop", anchor: .top)
                            }
                            
                            // IMPORTANT: Stop any ongoing recording when changing screens
                            if speechManager.isRecording {
                                speechManager.stopRecording()
                                print("🛑 Stopped recording due to screen change to: \(newScreen)")
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            setupInitialData()
        }
        .onChange(of: backgroundNoiseEnabled) { _ in
            updateBackgroundNoiseSettings()
        }
        .onChange(of: backgroundNoiseType) { _ in
            updateBackgroundNoiseSettings()
        }
        .onChange(of: backgroundNoiseVolume) { _ in
            if backgroundNoiseEnabled && backgroundNoise.isPlaying() {
                backgroundNoise.updateBackgroundVolume(backgroundNoiseVolume)
            }
        }
        .onChange(of: playbackSpeed) { _ in
            audioManager.setPlaybackSpeed(Float(playbackSpeed))
        }
        .onChange(of: volumeLevel) { _ in
            audioManager.setVolume(volumeLevel)
        }
        .onChange(of: voiceSettings.selectedVoice) { _ in
            audioManager.setVoiceSettings(voiceSettings)
        }
        .onAppear {
            audioManager.setVoiceSettings(voiceSettings)
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                do {
                    try firebase.signOut()
                    // Navigate back to begin screen
                    screen = .beginscreen
                    print("✅ Signed out and navigated to begin screen")
                } catch {
                    print("❌ Error signing out: \(error)")
                }
            }
        } message: {
            Text("Are you sure you want to sign out? Your data will be saved and you can sign in again anytime.")
        }
    }
    
    func getScreenTitle() -> String {
        switch screen {
        case .beginscreen: return "Welcome to Hearify"
        case .homescreen: return "Choose Your Mode"
        case .screen1: return "Practice"
        case .screen2: return sectiontitle.text
        case .screen5: return sectiontitle.text
        case .screen3: return "Auditory Hierarchy"
        case .screen8: return "My Practice List (\(PracticeList.count) items)"
        case .settingscreen: return "Settings"
        case .onboardingscreen: return "Welcome!"
        case .statsscreen: return "Progress & Statistics"
        case .dailychallengescreen: return "Daily Challenge"
            // New Training Category Screens
        case .wordRecognitionScreen: return "Word Recognition"
        case .sentenceComprehensionScreen: return "Sentence Comprehension"
        case .aiAnalysisScreen: return "Practice Insights"
        case .sentencesInNoiseScreen: return "Sentences in Noise"
        case .diagnosticTestScreen: return "Diagnostic Test"
        case .matchedPairsScreen: return "Matched Pairs"
        case .customPracticeScreen: return "Custom Practice"
        case .practiceListSessionScreen: return "Practice List Session"
        case .mainSelectionScreen: return "Choose Your Training"
        case .tutorialScreen: return "Program Structure"
        case .phaseSelectionScreen: return "Choose Your Training Phase"
        case .speakingPracticeScreen: return "Speaking Practice"
        case .cameraVisionScreen: return "" // No title for full-screen camera
        case .avSpeechTestScreen: return "AVSpeech Test Lab"
        default: return "Auditory Training"
        }
    }
    
    @ViewBuilder
    func getScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        switch screen {
        case .homescreen:
            VStack(spacing: 0) {
                // Header with back button
                HStack {
                    Button(action: {
                        screen = .mainSelectionScreen
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Auditory Training")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Practice Menu")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Stats indicator
                    VStack(spacing: 2) {
                        Image(systemName: "ear.fill")
                            .foregroundColor(.white)
                        Text("\(totalAttempts)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(AppTheme.primaryGradient)
                
                // Content
                ScrollView {
                    homeScreenContent(layout: layout)
                }
                .background(AppTheme.backgroundPrimary)
            }
            .onAppear {
                stopBackgroundNoise()
            }
        case .screen1:
            practiceScreenContent(layout: layout)
                .onAppear {
                    startBackgroundNoiseIfEnabled()
                }
        case .screen2:
            successScreenContent(layout: layout)
        case .screen5:
            incorrectScreenContent(layout: layout)
        case .screen3:
            auditoryHierarchyScreenContent(layout: layout)
        case .screen8:
            wordListManagementScreenContent(layout: layout)
        case .settingscreen:
            settingsScreenContent(layout: layout)
        case .onboardingscreen:
            onboardingScreenContent(layout: layout)
        case .statsscreen:
            statsScreenContent(layout: layout)
                .onAppear {
                    updateAnalyticsData()
                }
            // TODO: Re-enable Daily Challenge later
            // case .dailychallengescreen:
            //     dailyChallengeScreenContent(layout: layout)
            // New Training Category Screens
        case .wordRecognitionScreen:
            wordRecognitionScreenContent(layout: layout)
                .onAppear {
                    // RESET STATE to prevent glitches from previous exercises
                    resetSpeechState()
                    
                    // Request authorization first
                    speechManager.requestAuthorization()
                    
                    // Don't auto-play or auto-record - user must manually play
                }
                .onDisappear {
                    // Ensure background noise is OFF for Word Recognition
                    backgroundNoiseEnabled = false
                    stopBackgroundNoise()
                }
        case .sentenceComprehensionScreen:
            sentenceComprehensionScreenContent(layout: layout)
                .onAppear {
                    // RESET STATE to prevent glitches from previous exercises
                    resetSpeechState()
                    
                    // Request speech recognition authorization early
                    speechManager.requestAuthorization()
                    
                    // Don't auto-play or auto-record - user must manually play
                }
                .onDisappear {
                    // Ensure background noise is OFF for Sentence Comprehension
                    backgroundNoiseEnabled = false
                    stopBackgroundNoise()
                }
        case .sentencesInNoiseScreen:
            sentencesInNoiseScreenContent(layout: layout)
                .onAppear {
                    // RESET STATE to prevent glitches from previous exercises
                    resetSpeechState()
                    
                    // Request speech recognition authorization early
                    speechManager.requestAuthorization()
                    
                    // FORCE background noise ON for Sentences in Noise exercises
                    // Use clinical standard volume (0.7 = ~0-2 dB SNR)
                    backgroundNoiseEnabled = true
                    if backgroundNoiseVolume < 0.6 {
                        // If noise is too quiet, bump it up to clinical standard
                        backgroundNoiseVolume = 0.7  // Clinical standard: ~0-2 dB SNR
                    }
                    print("🔊 Sentences in Noise: Background noise enabled at \(Int(backgroundNoiseVolume * 100))% (≈\(Int(getSNRFromVolume())) dB SNR)")
                    
                    // Don't auto-play or auto-record - user must manually play
                }
                .onDisappear {
                    // STOP background noise when leaving Sentences in Noise screen
                    backgroundNoiseEnabled = false
                    stopBackgroundNoise()
                    print("🔇 Left Sentences in Noise: Background noise disabled and stopped")
                }
        case .diagnosticTestScreen:
            diagnosticTestScreenContent(layout: layout)
                .onAppear {
                    // RESET STATE to prevent glitches from previous exercises
                    resetSpeechState()
                    
                    // Request speech recognition authorization early
                    speechManager.requestAuthorization()
                    print("🎤 [DIAGNOSTIC] Requested speech authorization on screen appear")
                    
                    // Don't auto-play or auto-record - user must manually play
                }
                .onDisappear {
                    // STOP background noise when leaving Diagnostic Test screen
                    backgroundNoiseEnabled = false
                    stopBackgroundNoise()
                    print("🔇 Left Diagnostic Test: Background noise disabled and stopped")
                }
        case .aiAnalysisScreen:
            aiAnalysisScreenContent(layout: layout)
        case .matchedPairsScreen:
            // Redirect to existing auditory hierarchy
            auditoryHierarchyScreenContent(layout: layout)
        case .practiceListSessionScreen:
            practiceListSessionScreenContent(layout: layout)
                .onAppear {
                    // RESET STATE to prevent glitches from previous exercises
                    resetSpeechState()
                    
                    // Request speech recognition authorization early
                    speechManager.requestAuthorization()
                    print("🎤 Practice List Session: Speech state reset and authorization requested")
                }
        case .customPracticeScreen:
            customPracticeScreenContent(layout: layout)
                .onAppear {
                    // RESET STATE to prevent glitches from previous exercises
                    resetSpeechState()
                    
                    // Request speech recognition authorization early
                    speechManager.requestAuthorization()
                    print("🎤 Custom Practice: Speech state reset and authorization requested")
                }
        case .mainSelectionScreen:
            mainSelectionScreenContent(layout: layout)
        case .tutorialScreen:
            tutorialScreenContent(layout: layout)
        case .phaseSelectionScreen:
            phaseSelectionScreenContent(layout: layout)
        case .speakingPracticeScreen:
            SpeakingPracticeHubView(onDismiss: {
                screen = .phaseSelectionScreen
            })
        case .cameraVisionScreen:
            CameraVisionHubView(onDismiss: {
                screen = .phaseSelectionScreen
            })
        case .avSpeechTestScreen:
            AVSpeechTestView()
        default:
            defaultScreenContent(layout: layout)
        }
    }
    
    // MARK: - Phase Selection Screen
    @ViewBuilder
    func phaseSelectionScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: {
                    screen = .beginscreen
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.primaryBlue)
                }
                .padding()
                Spacer()
            }
            .background(AppTheme.backgroundSecondary)
            
            ScrollView {
                VStack(spacing: layout.spacing * 1.5) {
                    Text("Choose Your Training Phase")
                        .font(.system(size: layout.titleFontSize, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.top, layout.spacing)
                    
                    // Module 1: Hearing
                    VStack(spacing: layout.spacing * 0.5) {
                        Button(action: {
                            screen = .homescreen
                        }) {
                            VStack(alignment: .leading, spacing: layout.spacing * 0.5) {
                                HStack {
                                    Image(systemName: "ear.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("MODULE 1")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Text("Module 1: Hearing Training")
                                    .font(.system(size: layout.titleFontSize * 0.8, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Practice word recognition, sentence comprehension, and listening in noise")
                                    .font(.system(size: layout.bodyFontSize))
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(layout.spacing)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: AppTheme.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: {
                            selectedModuleProgram = ModuleProgram.module1
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 14))
                                Text("View Program Structure")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(AppTheme.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    
                    // Module 2: Speaking & Pronunciation (DISABLED - Coming Soon)
                    VStack(spacing: layout.spacing * 0.5) {
                        ZStack(alignment: .topTrailing) {
                            VStack(alignment: .leading, spacing: layout.spacing * 0.5) {
                                HStack {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.5))
                                    Spacer()
                                    Text("MODULE 2")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                Text("Module 2: Speaking & Pronunciation")
                                    .font(.system(size: layout.titleFontSize * 0.8, weight: .bold))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Practice pronunciation with real-time speech-to-text feedback")
                                    .font(.system(size: layout.bodyFontSize))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(layout.spacing)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            // "Coming Soon" Badge
                            Text("COMING SOON")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.accentOrange)
                                .cornerRadius(8)
                                .offset(x: -12, y: 12)
                        }
                        // Disabled "View Program" button
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                            Text("In Development")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .opacity(0.7)
                    
                    // Module 3: Camera Vision (DISABLED - Coming Soon)
                    VStack(spacing: layout.spacing * 0.5) {
                        ZStack(alignment: .topTrailing) {
                            VStack(alignment: .leading, spacing: layout.spacing * 0.5) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.5))
                                    Spacer()
                                    Text("MODULE 3")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                Text("Module 3: Camera Vision Analysis")
                                    .font(.system(size: layout.titleFontSize * 0.8, weight: .bold))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Use camera to analyze your mouth position and get real-time visual feedback")
                                    .font(.system(size: layout.bodyFontSize))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(layout.spacing)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            
                            // "Coming Soon" Badge
                            Text("COMING SOON")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.accentOrange)
                                .cornerRadius(8)
                                .offset(x: -12, y: 12)
                        }
                        
                        // Disabled "View Program" button
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                            Text("In Development")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .opacity(0.7)
                }
                .padding(.horizontal, layout.spacing)
            }
        }
    }
    
    // MARK: - OLD Speaking Practice Screen (REPLACED WITH Views/SpeakingPracticeView.swift)
    /*
     @ViewBuilder
     func speakingPracticeScreenContent(layout: ResponsiveLayoutHelper) -> some View {
     VStack(spacing: 0) {
     // Back button
     HStack {
     Button(action: {
     screen = .phaseSelectionScreen
     resetSpeechPractice()
     }) {
     HStack(spacing: 4) {
     Image(systemName: "chevron.left")
     .font(.system(size: 16, weight: .semibold))
     Text("Back")
     .font(.system(size: 16, weight: .semibold))
     }
     .foregroundColor(AppTheme.primaryBlue)
     }
     .padding()
     Spacer()
     }
     .background(AppTheme.backgroundSecondary)
     
     ScrollView {
     VStack(spacing: layout.spacing * 1.5) {
     // Target text
     VStack(spacing: layout.spacing * 0.5) {
     Text("Say this:")
     .font(.system(size: layout.bodyFontSize))
     .foregroundColor(AppTheme.textSecondary)
     Text(targetSpeechText)
     .font(.system(size: layout.titleFontSize, weight: .bold))
     .foregroundColor(AppTheme.textPrimary)
     .multilineTextAlignment(.center)
     .padding()
     .frame(maxWidth: .infinity)
     .background(AppTheme.backgroundSecondary)
     .cornerRadius(12)
     }
     .padding(.horizontal, layout.spacing)
     .padding(.top, layout.spacing)
     
     // Recording button
     VStack(spacing: layout.spacing * 0.5) {
     Button(action: {
     toggleSpeechRecording()
     }) {
     ZStack {
     Circle()
     .fill(
     LinearGradient(
     colors: speechManager.isRecording ? [.red, .orange] : [AppTheme.primaryBlue, AppTheme.accentPurple],
     startPoint: .topLeading,
     endPoint: .bottomTrailing
     )
     )
     .frame(width: 100, height: 100)
     .shadow(color: speechManager.isRecording ? .red.opacity(0.4) : AppTheme.primaryBlue.opacity(0.4), radius: 10)
     Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
     .font(.system(size: 40))
     .foregroundColor(.white)
     }
     }
     .scaleEffect(speechManager.isRecording ? 1.1 : 1.0)
     .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: speechManager.isRecording)
     Text(speechManager.isRecording ? "Recording... Tap to stop" : "Tap to record")
     .font(.system(size: layout.bodyFontSize, weight: .medium))
     .foregroundColor(AppTheme.textSecondary)
     }
     .padding(.vertical, layout.spacing * 2)
     
     // Recognized text preview
     if !speechManager.recognizedText.isEmpty {
     VStack(spacing: layout.spacing * 0.5) {
     Text("You said:")
     .font(.system(size: layout.bodyFontSize))
     .foregroundColor(AppTheme.textSecondary)
     Text(speechManager.recognizedText)
     .font(.system(size: layout.bodyFontSize * 1.1, weight: .medium))
     .foregroundColor(AppTheme.textPrimary)
     .multilineTextAlignment(.center)
     .padding()
     .frame(maxWidth: .infinity)
     .background(AppTheme.backgroundSecondary)
     .cornerRadius(12)
     }
     .padding(.horizontal, layout.spacing)
     }
     
     // Results section
     if showSpeechResults {
     VStack(spacing: layout.spacing) {
     // Score circle
     ZStack {
     Circle()
     .stroke(AppTheme.backgroundSecondary, lineWidth: 12)
     .frame(width: 120, height: 120)
     Circle()
     .trim(from: 0, to: speechScore)
     .stroke(
     LinearGradient(
     colors: [AppTheme.primaryBlue, AppTheme.accentPurple],
     startPoint: .topLeading,
     endPoint: .bottomTrailing
     ),
     style: StrokeStyle(lineWidth: 12, lineCap: .round)
     )
     .frame(width: 120, height: 120)
     .rotationEffect(.degrees(-90))
     VStack(spacing: 4) {
     Text("\(Int(speechScore * 100))")
     .font(.system(size: 36, weight: .bold))
     .foregroundColor(AppTheme.textPrimary)
     Text("/ 100")
     .font(.system(size: 16))
     .foregroundColor(AppTheme.textSecondary)
     }
     }
     .padding(.top, layout.spacing)
     
     // Feedback message
     Text(getSpeechFeedback())
     .font(.system(size: layout.bodyFontSize * 1.1, weight: .semibold))
     .foregroundColor(AppTheme.textPrimary)
     .multilineTextAlignment(.center)
     .padding(.horizontal, layout.spacing * 2)
     
     // Try again button
     Button(action: {
     resetSpeechPractice()
     }) {
     HStack {
     Image(systemName: "arrow.counterclockwise")
     Text("Try Again")
     }
     .font(.system(size: layout.bodyFontSize, weight: .semibold))
     .foregroundColor(.white)
     .frame(maxWidth: .infinity)
     .padding()
     .background(
     LinearGradient(
     colors: [AppTheme.primaryBlue, AppTheme.accentPurple],
     startPoint: .leading,
     endPoint: .trailing
     )
     )
     .cornerRadius(12)
     }
     .padding(.horizontal, layout.spacing)
     }
     .padding()
     .background(AppTheme.backgroundSecondary)
     .cornerRadius(16)
     .padding(.horizontal, layout.spacing)
     }
     
     // Info card
     if !showSpeechResults {
     VStack(alignment: .leading, spacing: layout.spacing * 0.5) {
     HStack {
     Image(systemName: "lightbulb.fill")
     .foregroundColor(.yellow)
     Text("Tip")
     .font(.system(size: layout.bodyFontSize, weight: .semibold))
     .foregroundColor(AppTheme.textPrimary)
     }
     Text("Speak clearly and at a normal pace. The app will analyze your pronunciation and provide feedback.")
     .font(.system(size: layout.bodyFontSize - 2))
     .foregroundColor(AppTheme.textSecondary)
     }
     .padding()
     .background(AppTheme.backgroundSecondary.opacity(0.5))
     .cornerRadius(12)
     .padding(.horizontal, layout.spacing)
     }
     Spacer()
     }
     }
     }
     .onAppear {
     speechManager.requestAuthorization()
     }
     }
     */
    
    // MARK: - Main Selection Screen (Auditory Training / Tutorial)
    @ViewBuilder
    func mainSelectionScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and profile
                HStack {
                    Button(action: {
                        screen = .beginscreen
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.primaryBlue)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Profile button
                    Menu {
                        if let user = firebase.currentUser {
                            Text(user.email ?? "Patient Account")
                                .foregroundColor(.secondary)
                        }
                        
                        Button(role: .destructive, action: {
                            showSignOutAlert = true
                        }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.primaryBlue)
                    }
                    .padding()
                }
                .frame(height: 60)
                .background(AppTheme.backgroundPrimary)
                
                // Main content - Two stylish button cards
                VStack(spacing: AppTheme.spacingL) {
                    // TOP HALF: Auditory Training Block
                    Button(action: {
                        screen = .homescreen
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }) {
                        ZStack {
                            AppTheme.primaryGradient
                            
                            VStack(spacing: AppTheme.spacingL) {
                                Spacer()
                                
                                Image(systemName: "ear.fill")
                                    .font(.system(size: 80, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                
                                VStack(spacing: AppTheme.spacingS) {
                                    Text("Auditory Training")
                                        .font(.system(size: layout.titleFontSize * 1.4, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Practice listening and comprehension")
                                        .font(.system(size: layout.bodyFontSize * 1.1))
                                        .foregroundColor(.white.opacity(0.95))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                        .padding(.horizontal, AppTheme.spacingL)
                                }
                                
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(AppTheme.radiusLarge)
                        .shadow(color: AppTheme.primaryBlue.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // BOTTOM HALF: Tutorial Block
                    Button(action: {
                        screen = .tutorialScreen
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }) {
                        ZStack {
                            AppTheme.accentGradient
                            
                            VStack(spacing: AppTheme.spacingL) {
                                Spacer()
                                
                                Image(systemName: "book.fill")
                                    .font(.system(size: 80, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                
                                VStack(spacing: AppTheme.spacingS) {
                                    Text("Program Structure")
                                        .font(.system(size: layout.titleFontSize * 1.4, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Learn how to use the program")
                                        .font(.system(size: layout.bodyFontSize * 1.1))
                                        .foregroundColor(.white.opacity(0.95))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                        .padding(.horizontal, AppTheme.spacingL)
                                }
                                
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(AppTheme.radiusLarge)
                        .shadow(color: AppTheme.accentOrange.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(AppTheme.spacingL)
            }
        }
    }
    
    // MARK: - Tutorial Screen
    @ViewBuilder
    func tutorialScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: {
                    screen = .mainSelectionScreen
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.primaryBlue)
                }
                .padding()
                Spacer()
            }
            .background(AppTheme.backgroundSecondary)
            
            // Tutorial content
            ScrollView {
                VStack(spacing: layout.spacing * 1.5) {
                    // Header
                    VStack(spacing: AppTheme.spacingS) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(AppTheme.primaryBlue)
                        
                        Text("Program Structure & Tutorial")
                            .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("A structured approach to improve your listening and comprehension skills")
                            .font(.system(size: layout.bodyFontSize))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, layout.spacing)
                    
                    // Program structure content
                    ModernCard(padding: AppTheme.spacingL) {
                        programStructureContent(layout: layout)
                    }
                }
                .padding(.horizontal, layout.padding)
                .padding(.bottom, layout.spacing * 2)
            }
        }
    }
    
    // MARK: - Home Screen Helper Views
    @ViewBuilder
    func quickStatView(_ title: String, value: String, color: Color, layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: AppTheme.spacingXS) {
            Text(value)
                .font(.system(size: layout.titleFontSize, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: layout.bodyFontSize - 4, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, AppTheme.spacingS)
        .padding(.horizontal, AppTheme.spacingM)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                .fill(color.opacity(0.1))
        )
    }
    
    @ViewBuilder
    func toolButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingS) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                    )
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppTheme.spacingM)
            .frame(maxWidth: .infinity)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.radiusMedium)
            .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    func homeScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        LazyVStack(spacing: AppTheme.spacingL) {
            homeWelcomeSection(layout: layout)
            homeTrainingSection(layout: layout)
            // TODO: Re-enable Daily Challenge later
            // if currentChallenge != nil {
            //     homeDailyChallengeSection(layout: layout)
            // }
            homeToolsSection(layout: layout)
            // Tutorial removed - now accessible from main selection screen
        }
    }
    
    @ViewBuilder
    func homeWelcomeSection(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(spacing: AppTheme.spacingM) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(AppTheme.primaryBlue)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Auditory Training")
                            .font(.system(size: layout.titleFontSize, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Enhance your listening skills")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                }
                
                // Stats removed from Auditory Training main page as requested
                // Users can view stats in the dedicated Stats page instead
            }
        }
    }
    
    @ViewBuilder
    func homeTrainingSection(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(spacing: AppTheme.spacingM) {
                HStack {
                    Text("Training Categories")
                        .font(.system(size: layout.titleFontSize, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                }
                
                // Training Category Grid (2 columns)
                // Show all categories EXCEPT aiAnalysis in 2-column grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacingS), count: 2), spacing: AppTheme.spacingS) {
                    ForEach(TrainingCategory.allCases.filter { $0 != .aiAnalysis }, id: \.self) { category in
                        trainingCategoryCard(category: category, layout: layout)
                    }
                }
                
                // AI Analysis (Practice Insights) - Full width at bottom
                trainingCategoryCard(category: .aiAnalysis, layout: layout)
                
                Divider()
                    .background(AppTheme.textTertiary.opacity(0.3))
                    .padding(.vertical, AppTheme.spacingXS)
                
                // Custom Options
                VStack(spacing: AppTheme.spacingS) {
                    ResponsiveButton(
                        text: "My Practice List (\(PracticeList.count) items)",
                        action: {
                            screen = .screen8
                            if buttonconfirm {
                                audioManager.playAudio("buttonpress")
                            }
                        },
                        layout: layout,
                        style: .accent,
                        icon: "bookmark.fill"
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    func trainingCategoryCard(category: TrainingCategory, layout: ResponsiveLayoutHelper) -> some View {
        Button(action: {
            print("🟢 BUTTON CLICKED: \(category.rawValue)")
            if buttonconfirm {
                audioManager.playAudio("buttonpress")
            }
            print("🟡 About to call handleTrainingCategorySelection")
            handleTrainingCategorySelection(category)
            print("🟢 handleTrainingCategorySelection completed")
        }) {
            VStack(spacing: AppTheme.spacingXS) {
                Image(systemName: category.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(category.color)
                    .frame(height: 40)
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(category.description)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(AppTheme.spacingM)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(AppTheme.backgroundSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.color.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // TODO: Re-implement Daily Challenge later
    /*
     @ViewBuilder
     func homeDailyChallengeSection(layout: ResponsiveLayoutHelper) -> some View {
     if let challenge = currentChallenge {
     ModernCard(
     backgroundColor: getChallengeColor(challenge.type).opacity(0.1)
     ) {
     VStack(spacing: AppTheme.spacingM) {
     HStack {
     Image(systemName: getChallengeIcon(challenge.type))
     .font(.system(size: 24, weight: .medium))
     .foregroundColor(getChallengeColor(challenge.type))
     
     VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
     Text("Daily Challenge")
     .font(.system(size: layout.titleFontSize, weight: .semibold))
     .foregroundColor(AppTheme.textPrimary)
     
     Text(challenge.title)
     .font(.system(size: layout.bodyFontSize - 2))
     .foregroundColor(getChallengeColor(challenge.type))
     }
     
     Spacer()
     
     if challengeCompleted {
     Image(systemName: "checkmark.circle.fill")
     .font(.system(size: 24))
     .foregroundColor(AppTheme.success)
     }
     }
     
     ResponsiveButton(
     text: challengeCompleted ? "Completed!" : (challengeAttempts > 0 ? "Continue" : "Start Challenge"),
     action: {
     loadDailyChallenge()
     screen = .dailychallengescreen
     if buttonconfirm {
     audioManager.playAudio("buttonpress")
     }
     },
     layout: layout,
     style: challengeCompleted ? .success : .accent,
     icon: challengeCompleted ? "checkmark" : "play.fill"
     )
     }
     }
     }
     }
     */
    
    @ViewBuilder
    func homeToolsSection(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(spacing: AppTheme.spacingM) {
                HStack {
                    Text("Tools & Settings")
                        .font(.system(size: layout.titleFontSize, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppTheme.spacingM) {
                    
                    toolButton("Statistics", icon: "chart.line.uptrend.xyaxis", color: AppTheme.accentPurple) {
                        screen = .statsscreen
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }
                    
                    toolButton("Clinical Dashboard", icon: "stethoscope", color: AppTheme.success) {
                        showClinicianDashboard = true
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }
                    
                    toolButton("Settings", icon: "gearshape.fill", color: AppTheme.textSecondary) {
                        screen = .settingscreen
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }
                    
                    toolButton("Tutorial", icon: "graduationcap.fill", color: AppTheme.info) {
                        screen = .onboardingscreen
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }
                    
                    // TODO: Re-enable Daily Challenge later
                    /*
                     toolButton("Challenges", icon: "trophy.fill", color: AppTheme.warning) {
                     loadDailyChallenge()
                     screen = .dailychallengescreen
                     if buttonconfirm {
                     audioManager.playAudio("buttonpress")
                     }
                     }
                     */
                }
            }
        }
    }
    
    // NEW: Program Structure/Tutorial Section
    @ViewBuilder
    func homeProgramStructureSection(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(spacing: AppTheme.spacingM) {
                // Header
                HStack {
                    Image(systemName: "book.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppTheme.primaryBlue)
                    
                    Text("Program Structure & Tutorial")
                        .font(.system(size: layout.titleFontSize, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                }
                
                Divider()
                    .background(AppTheme.textTertiary.opacity(0.3))
                
                // Program overview
                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                    Text("How to Use Hearify")
                        .font(.system(size: layout.bodyFontSize + 2, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("A structured approach to improve your listening and comprehension skills.")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Detailed program structure - inline instead of modal
                programStructureContent(layout: layout)
            }
        }
    }
    
    @ViewBuilder
    func programStructureContent(layout: ResponsiveLayoutHelper) -> some View {
        let program = ModuleProgram.module1 // Use Module 1 (Hearing Training)
        
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            // Objectives
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(AppTheme.primaryBlue)
                    Text("Program Objectives")
                        .font(.system(size: layout.bodyFontSize + 1, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                ForEach(program.objectives, id: \.self) { objective in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(AppTheme.primaryBlue)
                        Text(objective)
                            .font(.system(size: layout.bodyFontSize - 1))
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            Divider()
                .background(AppTheme.textTertiary.opacity(0.3))
            
            // Training Phases
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                HStack {
                    Image(systemName: "list.number")
                        .foregroundColor(AppTheme.primaryBlue)
                    Text("Training Phases")
                        .font(.system(size: layout.bodyFontSize + 1, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                ForEach(program.structure) { phase in
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        // Phase header
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppTheme.primaryBlue)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("\(phase.phaseNumber)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            Text(phase.title)
                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Phase description
                        Text(phase.description)
                            .font(.system(size: layout.bodyFontSize - 1))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.leading, 32)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Exercises
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(phase.exercises, id: \.self) { exercise in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("→")
                                        .foregroundColor(AppTheme.accentOrange)
                                        .font(.system(size: 12))
                                    Text(exercise)
                                        .font(.system(size: layout.bodyFontSize - 2))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.leading, 32)
                        
                        // Duration & success criteria
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text(phase.duration)
                                    .font(.system(size: layout.bodyFontSize - 3))
                            }
                            .foregroundColor(AppTheme.textTertiary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 10))
                                Text(phase.successCriteria)
                                    .font(.system(size: layout.bodyFontSize - 3))
                            }
                            .foregroundColor(AppTheme.success)
                        }
                        .padding(.leading, 32)
                    }
                    .padding(.vertical, AppTheme.spacingS)
                    .padding(.horizontal, AppTheme.spacingS)
                    .background(AppTheme.backgroundSecondary.opacity(0.5))
                    .cornerRadius(8)
                }
            }
            
            Divider()
                .background(AppTheme.textTertiary.opacity(0.3))
            
            // Tips
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(AppTheme.accentOrange)
                    Text("Training Tips")
                        .font(.system(size: layout.bodyFontSize + 1, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                ForEach(program.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Text("💡")
                            .font(.system(size: 14))
                        Text(tip)
                            .font(.system(size: layout.bodyFontSize - 1))
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // Estimated duration
            HStack {
                Image(systemName: "hourglass")
                    .foregroundColor(AppTheme.primaryCyan)
                Text("Estimated Duration:")
                    .font(.system(size: layout.bodyFontSize - 1, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(program.estimatedDuration)
                    .font(.system(size: layout.bodyFontSize - 1))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, AppTheme.spacingS)
        }
    }
    
    @ViewBuilder
    func practiceScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .screen3
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Practice")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            // Content
            VStack(spacing: layout.spacing) {
                practiceHeaderSection(layout: layout)
                practiceAudioSection(layout: layout)
                practiceQuestionSection(layout: layout)
                practiceNavigationSection(layout: layout)
            }
            .padding(.top, layout.spacing)
        }
        .onAppear {
            // Removed auto-play - user must click play button
            print("🔊 Practice screen loaded. Click play button to hear audio.")
        }
    }
    
    @ViewBuilder
    func practiceHeaderSection(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: layout.spacing) {
            Text("Click Icon Below To Play")
                .font(.system(size: layout.bodyFontSize))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            practiceStatusIndicators(layout: layout)
        }
    }
    
    @ViewBuilder
    func practiceStatusIndicators(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 8) {
            // Background noise indicator
            if backgroundNoiseEnabled && backgroundNoise.isPlaying() {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: layout.bodyFontSize - 2))
                    
                    Text("Background: \(backgroundNoiseType.rawValue)")
                        .font(.system(size: layout.bodyFontSize - 2))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
            
            // Playback speed indicator
            if playbackSpeed != 1.0 {
                HStack(spacing: 8) {
                    Image(systemName: playbackSpeed > 1.0 ? "forward.fill" : "backward.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: layout.bodyFontSize - 2))
                    
                    Text("Speed: " + String(format: "%.1fx", playbackSpeed))
                        .font(.system(size: layout.bodyFontSize - 2))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
        }
    }
    
    @ViewBuilder
    func practiceAudioSection(layout: ResponsiveLayoutHelper) -> some View {
        FavoriteButton(isSet: .constant(true), audio2: audioname.text, audioManager: audioManager)
            .frame(width: layout.imageSize, height: layout.imageSize)
    }
    
    @ViewBuilder
    func practiceQuestionSection(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: layout.spacing) {
            Text("What did you hear?")
                .font(.system(size: layout.titleFontSize, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cyan)
                .cornerRadius(8)
            
            HStack(spacing: layout.spacing) {
                practiceChoiceButton(Text1.text, isFirst: true, layout: layout)
                practiceChoiceButton(Text2.text, isFirst: false, layout: layout)
            }
        }
    }
    
    @ViewBuilder
    func practiceNavigationSection(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: layout.spacing / 2) {
            // Add to Practice List button
            ResponsiveButton(
                text: "Add to Practice List",
                action: {
                    addCurrentMatchedPairToPracticeList()
                },
                layout: layout,
                style: .secondary,
                icon: "plus.circle.fill"
            )
            
            Button("Go Back") {
                navigateBack()
            }
            .font(.system(size: layout.titleFontSize * 0.9))
            .foregroundColor(.black)
            .frame(width: layout.buttonWidth * 0.7, height: layout.buttonHeight * 0.9)
            .background(Color.gray.opacity(0.7))
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    func modernPracticeChoiceButton(_ text: String, isFirst: Bool, layout: ResponsiveLayoutHelper) -> some View {
        Button(action: {
            handlePracticeChoice(isFirst: isFirst)
        }) {
            Text(text)
                .font(.system(size: layout.titleFontSize, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .frame(height: layout.buttonHeight * 1.2)
                .background(AppTheme.primaryGradient)
                .cornerRadius(AppTheme.radiusLarge)
                .shadow(color: AppTheme.buttonShadow, radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    func practiceChoiceButton(_ text: String, isFirst: Bool, layout: ResponsiveLayoutHelper) -> some View {
        Button(action: {
            handlePracticeChoice(isFirst: isFirst)
        }) {
            Text(text)
                .font(.system(size: layout.titleFontSize, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .frame(
                    width: (layout.buttonWidth - layout.spacing) / 2,
                    height: layout.buttonHeight + 10
                )
                .background(Color.cyan)
                .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    func successScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .screen1
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(sectiontitle.text)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            VStack(spacing: layout.spacing * 0.8) {
                Image("App_Check")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layout.imageSize * 0.7, height: layout.imageSize * 0.7)
                
                // Progress display (if enabled)
                if showProgressAfterEachWord {
                    progressDisplayView(layout: layout)
                }
                
                Button("Next") {
                    nextdisable = true
                    screen = .screen1
                    nextWord()
                    // Removed auto-play - user must click play button
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.cyan)
                .cornerRadius(8)
                .disabled(nextdisable)
                
                Button("Try Again") {
                    screen = .screen1
                    // Removed auto-play - user must click play button
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.orange)
                .cornerRadius(8)
                
                Button("Add to Practice List") {
                    addCurrentMatchedPairToPracticeList()
                }
                .font(.system(size: layout.titleFontSize * 0.85))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.green)
                .cornerRadius(8)
                
                Button("Home") {
                    nextdisable = true
                    finaldisable = false
                    screen = .homescreen
                    tempWordList.removeAll()
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                    WordList.removeAll()
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.cyan)
                .cornerRadius(8)
                .disabled(nextdisable)
            }
            .padding(.top, layout.spacing)
        }
        .alert("Added to Practice List!", isPresented: $showingPracticeItemAddedAlert) {
            Button("Continue") { }
            Button("Go to My Practice List") {
                screen = .screen8
            }
        } message: {
            Text(addedPracticeItemText)
        }
    }
    
    @ViewBuilder
    func incorrectScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .screen1
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(sectiontitle.text)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            VStack(spacing: layout.spacing * 0.8) {
                Image("App_X")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layout.imageSize * 0.7, height: layout.imageSize * 0.7)
                
                Button("Next") {
                    screen = .screen1
                    nextWord()
                    // Removed auto-play - user must click play button
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.cyan)
                .cornerRadius(8)
                
                Button("Try Again") {
                    screen = .screen1
                    // Removed auto-play - user must click play button
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.orange)
                .cornerRadius(8)
                
                Button("Add to Practice List") {
                    addCurrentMatchedPairToPracticeList()
                }
                .font(.system(size: layout.titleFontSize * 0.85))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.red)
                .cornerRadius(8)
            }
            .padding(.top, layout.spacing)
        }
        .alert("Added to Practice List!", isPresented: $showingPracticeItemAddedAlert) {
            Button("Continue") { }
            Button("Go to My Practice List") {
                screen = .screen8
            }
        } message: {
            Text(addedPracticeItemText)
        }
    }
    
    @ViewBuilder
    func auditoryHierarchyScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .homescreen
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Auditory Hierarchy")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: layout.spacing) {
                    // Beginner Section
                    Text("Beginner")
                        .font(.system(size: layout.titleFontSize, weight: .semibold))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, layout.spacing)
                        .padding(.bottom, layout.spacing * 0.5)
                    
                    VStack(spacing: layout.spacing) {
                        HStack(spacing: layout.spacing * 0.5) {
                            ResponsiveButton(
                                text: "Different by Syllables",
                                action: {
                                    WordList.removeAll()
                                    convertCSVIntoArray(CSV: "SyllablesData")
                                    finaldisable = true
                                    topCategory = "Syllables"
                                    mainCategory = "syllables"
                                    sectiontitle.text = "Syllables"
                                    
                                    // Check if randomize() succeeded before navigating
                                    if randomize() {
                                        screen = .screen1
                                        if buttonconfirm {
                                            audioManager.playAudio("buttonpress")
                                        }
                                        // Removed auto-play - user must click play button
                                    } else {
                                        alerttext.text = "No words found for \(getCategoryDisplayName("Syllables")). Please check data files."
                                        showingAlert = true
                                    }
                                },
                                layout: layout
                            )
                            
                            Button(action: {
                                loadWordPairsForSelection(csvFile: "SyllablesData", category: "Syllables")
                            }) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: layout.buttonHeight, height: layout.buttonHeight)
                                    .background(AppTheme.accentOrange)
                                    .cornerRadius(8)
                            }
                        }
                        
                        HStack(spacing: layout.spacing * 0.5) {
                            ResponsiveButton(
                                text: "Different Phonetics",
                                action: {
                                    WordList.removeAll()
                                    convertCSVIntoArray(CSV: "PDData")
                                    finaldisable = true
                                    topCategory = "PD"
                                    // Randomly select from phonetic subcategories
                                    let phoneticCategories = ["PD1", "PD2"]
                                    mainCategory = phoneticCategories.randomElement() ?? "PD1"
                                    sectiontitle.text = "Phonetics"
                                    
                                    // Check if randomize() succeeded before navigating
                                    if randomize() {
                                        screen = .screen1
                                        if buttonconfirm {
                                            audioManager.playAudio("buttonpress")
                                        }
                                        // Removed auto-play - user must click play button
                                    } else {
                                        alerttext.text = "No words found for \(getCategoryDisplayName("Phonetics")). Please check data files."
                                        showingAlert = true
                                    }
                                },
                                layout: layout
                            )
                            
                            Button(action: {
                                loadWordPairsForSelection(csvFile: "PDData", category: "Phonetics")
                            }) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: layout.buttonHeight, height: layout.buttonHeight)
                                    .background(AppTheme.accentOrange)
                                    .cornerRadius(8)
                            }
                        }
                        
                        HStack(spacing: layout.spacing * 0.5) {
                            ResponsiveButton(
                                text: "Different Vowels",
                                action: {
                                    WordList.removeAll()
                                    convertCSVIntoArray(CSV: "Vowels")
                                    finaldisable = true
                                    topCategory = "Vowels"
                                    // Randomly select from vowel subcategories
                                    let vowelCategories = ["wv", "nv"]
                                    mainCategory = vowelCategories.randomElement() ?? "wv"
                                    sectiontitle.text = "Vowels"
                                    
                                    // Check if randomize() succeeded before navigating
                                    if randomize() {
                                        screen = .screen1
                                        if buttonconfirm {
                                            audioManager.playAudio("buttonpress")
                                        }
                                        // Removed auto-play - user must click play button
                                    } else {
                                        alerttext.text = "No words found for \(getCategoryDisplayName("Vowels")). Please check data files."
                                        showingAlert = true
                                    }
                                },
                                layout: layout
                            )
                            
                            Button(action: {
                                loadWordPairsForSelection(csvFile: "Vowels", category: "Vowels")
                            }) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: layout.buttonHeight, height: layout.buttonHeight)
                                    .background(AppTheme.accentOrange)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Intermediate/Advanced Section
                    Text("Intermediate/Advanced")
                        .font(.system(size: layout.titleFontSize, weight: .semibold))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, layout.spacing * 1.5)
                        .padding(.bottom, layout.spacing * 0.5)
                    
                    VStack(spacing: layout.spacing) {
                        HStack(spacing: layout.spacing * 0.5) {
                            ResponsiveButton(
                                text: "Different Initial Consonants",
                                action: {
                                    WordList.removeAll()
                                    finaldisable = true
                                    topCategory = "C"
                                    mainCategory = "consonants"
                                    convertCSVIntoArray(CSV: "Consonants")
                                    sectiontitle.text = "Initial Consonants"
                                    
                                    // Check if randomize() succeeded before navigating
                                    if randomize() {
                                        screen = .screen1
                                        if buttonconfirm {
                                            audioManager.playAudio("buttonpress")
                                        }
                                        // Removed auto-play - user must click play button
                                    } else {
                                        alerttext.text = "No words found for \(getCategoryDisplayName("Consonants")). Please check data files."
                                        showingAlert = true
                                    }
                                },
                                layout: layout
                            )
                            
                            Button(action: {
                                loadWordPairsForSelection(csvFile: "Consonants", category: "Initial Consonants")
                            }) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: layout.buttonHeight, height: layout.buttonHeight)
                                    .background(AppTheme.accentOrange)
                                    .cornerRadius(8)
                            }
                        }
                        
                        HStack(spacing: layout.spacing * 0.5) {
                            ResponsiveButton(
                                text: "Final Consonants",
                                action: {
                                    WordList.removeAll()
                                    convertCSVIntoArray(CSV: "FinalConsonants")
                                    finaldisable = true
                                    topCategory = "FC"
                                    mainCategory = "fc"
                                    sectiontitle.text = "Final Consonants"
                                    
                                    // Check if randomize() succeeded before navigating
                                    if randomize() {
                                        screen = .screen1
                                        if buttonconfirm {
                                            audioManager.playAudio("buttonpress")
                                        }
                                        // Removed auto-play - user must click play button
                                    } else {
                                        alerttext.text = "No words found for \(getCategoryDisplayName("Final Consonants")). Please check data files."
                                        showingAlert = true
                                    }
                                },
                                layout: layout
                            )
                            
                            Button(action: {
                                loadWordPairsForSelection(csvFile: "FinalConsonants", category: "Final Consonants")
                            }) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: layout.buttonHeight, height: layout.buttonHeight)
                                    .background(AppTheme.accentOrange)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, layout.spacing)
            }
            .background(AppTheme.backgroundPrimary)
        }
    }
    
    @ViewBuilder
    func defaultScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: layout.spacing) {
            Text("Screen not yet implemented with responsive design")
                .font(.system(size: layout.bodyFontSize))
            
            Button("Back to Home") {
                screen = .homescreen
            }
            .font(.system(size: layout.titleFontSize))
            .foregroundColor(.black)
            .frame(width: layout.buttonWidth, height: layout.buttonHeight)
            .background(Color.cyan)
            .cornerRadius(8)
        }
    }
    
    
    
    
    @ViewBuilder
    func wordListManagementScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        ZStack {
            VStack(spacing: 0) {
                // Header Banner
                HStack {
                    Button(action: {
                        screen = .homescreen
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("My Practice List")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty space for symmetry
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding()
                .background(AppTheme.primaryGradient)
                
                // Content Section
                ScrollView {
                    VStack(spacing: AppTheme.spacingL) {
                        // Header Card
                        ModernCard(padding: AppTheme.spacingL) {
                            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                HStack {
                                    Image(systemName: "list.bullet.clipboard")
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(AppTheme.primaryBlue)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Word & Sentence Lists")
                                            .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        if isSelectionMode && !selectedPracticeItems.isEmpty {
                                            Text("\(selectedPracticeItems.count) selected")
                                                .font(.system(size: layout.bodyFontSize - 2))
                                                .foregroundColor(AppTheme.accentOrange)
                                        } else {
                                            Text("\(filteredPracticeList.count) item\(filteredPracticeList.count == 1 ? "" : "s")")
                                                .font(.system(size: layout.bodyFontSize - 2))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Select button
                                    if !PracticeList.isEmpty {
                                        Button(action: {
                                            isSelectionMode.toggle()
                                            if !isSelectionMode {
                                                selectedPracticeItems.removeAll()
                                            }
                                        }) {
                                            Text(isSelectionMode ? "Cancel" : "Select")
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(AppTheme.primaryBlue)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(AppTheme.primaryBlue.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                // Search bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    TextField("Search words or sentences...", text: $wordListSearchText)
                                        .font(.system(size: layout.bodyFontSize))
                                        .textFieldStyle(PlainTextFieldStyle())
                                    
                                    if !wordListSearchText.isEmpty {
                                        Button(action: { wordListSearchText = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                }
                                .padding(AppTheme.spacingS)
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingM)
                        .padding(.top, AppTheme.spacingM)
                        
                        ScrollView {
                            VStack(spacing: layout.spacing) {
                                if filteredPracticeList.isEmpty {
                                    // Empty state
                                    VStack(spacing: layout.spacing) {
                                        Image(systemName: wordListSearchText.isEmpty ? "tray" : "magnifyingglass")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.top, AppTheme.spacingXL)
                                        
                                        Text(wordListSearchText.isEmpty ? "No items yet!" : "No matches found")
                                            .font(.system(size: layout.titleFontSize, weight: .bold))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                        
                                        Text(wordListSearchText.isEmpty ? "Items added during practice or from Custom Practice will appear here" : "Try a different search term")
                                            .font(.system(size: layout.bodyFontSize))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, layout.padding)
                                    }
                                    .padding(.top, AppTheme.spacingXL)
                                } else {
                                    // Repetition Settings
                                    ModernCard(padding: AppTheme.spacingM) {
                                        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                            Text("Practice Settings")
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            HStack {
                                                Text("Repetitions per item:")
                                                    .font(.system(size: layout.bodyFontSize))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                
                                                Spacer()
                                                
                                                HStack(spacing: AppTheme.spacingS) {
                                                    ForEach([1, 2, 3, 5, 10], id: \.self) { count in
                                                        Button(action: {
                                                            practiceRepetitions = count
                                                        }) {
                                                            Text("\(count)")
                                                                .font(.system(size: 14, weight: .semibold))
                                                                .foregroundColor(practiceRepetitions == count ? .white : AppTheme.textPrimary)
                                                                .frame(width: 40, height: 40)
                                                                .background(practiceRepetitions == count ? AppTheme.accentOrange : AppTheme.backgroundSecondary)
                                                                .cornerRadius(8)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            Text("Items will be randomized and each item repeated \(practiceRepetitions) time\(practiceRepetitions == 1 ? "" : "s")")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                    
                                    // Practice button - only show if items exist
                                    if !PracticeList.isEmpty {
                                        ResponsiveButton(
                                            text: "🎯 Start Practice (\(PracticeList.count) items)",
                                            action: {
                                                startUnifiedPracticeSession()
                                            },
                                            layout: layout,
                                            style: .success,
                                            icon: "play.fill"
                                        )
                                    }
                                    
                                    // Practice list
                                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                        HStack {
                                            Text("Your Practice List")
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            Spacer()
                                            
                                            if !wordListSearchText.isEmpty {
                                                Text("\(filteredPracticeList.count) of \(PracticeList.count)")
                                                    .font(.system(size: layout.bodyFontSize - 2))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                        }
                                        
                                        LazyVStack(spacing: layout.spacing / 2) {
                                            ForEach(filteredPracticeList) { item in
                                                Button(action: {
                                                    if isSelectionMode {
                                                        // Toggle selection
                                                        if selectedPracticeItems.contains(item.id) {
                                                            selectedPracticeItems.remove(item.id)
                                                        } else {
                                                            selectedPracticeItems.insert(item.id)
                                                        }
                                                    }
                                                }) {
                                                    HStack(spacing: AppTheme.spacingS) {
                                                        // Checkbox (only in selection mode)
                                                        if isSelectionMode {
                                                            Image(systemName: selectedPracticeItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                                                .font(.system(size: 24))
                                                                .foregroundColor(selectedPracticeItems.contains(item.id) ? AppTheme.success : AppTheme.textSecondary)
                                                        }
                                                        
                                                        // Content
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            HStack(spacing: 6) {
                                                                Image(systemName: {
                                                                    switch item.type {
                                                                    case .word: return "textformat.size"
                                                                    case .sentence: return "quote.bubble"
                                                                    case .matchedPair: return "square.grid.2x2"
                                                                    }
                                                                }())
                                                                .foregroundColor(AppTheme.primaryBlue)
                                                                .font(.system(size: 14))
                                                                
                                                                Text(item.displayText)
                                                                    .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                                    .foregroundColor(AppTheme.textPrimary)
                                                                    .lineLimit(2)
                                                            }
                                                            
                                                            Text("Category: \(getCategoryDisplayName(item.category))")
                                                                .font(.system(size: layout.bodyFontSize - 2))
                                                                .foregroundColor(AppTheme.textSecondary)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        // Action buttons (only show when NOT in selection mode)
                                                        if !isSelectionMode {
                                                            // Delete button only
                                                            Button(action: {
                                                                if let index = PracticeList.firstIndex(where: { $0.id == item.id }) {
                                                                    removePracticeItem(at: index)
                                                                }
                                                            }) {
                                                                Image(systemName: "trash")
                                                                    .font(.system(size: 14, weight: .medium))
                                                                    .foregroundColor(.white)
                                                                    .padding(8)
                                                                    .background(Color.red)
                                                                    .cornerRadius(6)
                                                            }
                                                        }
                                                    }
                                                    .padding(AppTheme.spacingM)
                                                    .background(
                                                        isSelectionMode && selectedPracticeItems.contains(item.id)
                                                        ? AppTheme.primaryBlue.opacity(0.1)
                                                        : AppTheme.backgroundSecondary
                                                    )
                                                    .cornerRadius(10)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(
                                                                isSelectionMode && selectedPracticeItems.contains(item.id)
                                                                ? AppTheme.primaryBlue
                                                                : Color.clear,
                                                                lineWidth: 2
                                                            )
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        
                                        // Bulk actions (shown when items are selected)
                                        if isSelectionMode && !selectedPracticeItems.isEmpty {
                                            VStack(spacing: AppTheme.spacingM) {
                                                // Practice Selected button
                                                ResponsiveButton(
                                                    text: "🎯 Practice Selected (\(selectedPracticeItems.count) items)",
                                                    action: {
                                                        startSelectedItemsPractice()
                                                    },
                                                    layout: layout,
                                                    style: .success,
                                                    icon: "play.fill"
                                                )
                                                
                                                // Delete Selected button
                                                Button(action: {
                                                    deleteSelectedItems()
                                                }) {
                                                    HStack {
                                                        Image(systemName: "trash.fill")
                                                        Text("Delete Selected")
                                                    }
                                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(Color.red)
                                                    .cornerRadius(8)
                                                }
                                            }
                                            .padding(.top, AppTheme.spacingM)
                                        }
                                    }
                                    
                                    // Action buttons
                                    HStack(spacing: layout.spacing) {
                                        Button(action: {
                                            showingAlert2 = true
                                        }) {
                                            HStack {
                                                Image(systemName: "trash.fill")
                                                Text("Clear All")
                                            }
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.red)
                                            .cornerRadius(8)
                                        }
                                        .alert("Clear All Items?", isPresented: $showingAlert2) {
                                            Button("Cancel", role: .cancel) { }
                                            Button("Clear All", role: .destructive) {
                                                clearAllWordsFromCustomList()
                                            }
                                        } message: {
                                            Text("This will remove all \(PracticeList.count) items from your practice list.")
                                        }
                                        
                                        Button(action: {
                                            exportWordList()
                                        }) {
                                            HStack {
                                                Image(systemName: "square.and.arrow.up")
                                                Text("Export")
                                            }
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(AppTheme.primaryBlue)
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                // Navigation buttons
                                VStack(spacing: AppTheme.spacingM) {
                                    ResponsiveButton(
                                        text: "Back to Home",
                                        action: {
                                            screen = .homescreen
                                            if buttonconfirm {
                                                audioManager.playAudio("buttonpress")
                                            }
                                        },
                                        layout: layout,
                                        style: .secondary,
                                        icon: "arrow.left"
                                    )
                                }
                            }
                            .padding(.horizontal, AppTheme.spacingM)
                            .padding(.bottom, AppTheme.spacingL)
                        }
                        // Closes ScrollView
                    }
                    // Closes VStack(spacing: 0)
                }
            }
            // Closes ZStack
        }
    }

    @ViewBuilder
    func addWordSheetContent(layout: ResponsiveLayoutHelper) -> some View {
        NavigationView {
                ScrollView {
                    VStack(spacing: AppTheme.spacingL) {
                        // Type Selector (only show in add mode, not edit mode)
                        if editingPracticeItem == nil {
                            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                Text("Item Type")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(.horizontal)
                                
                                Picker("Type", selection: $newItemType) {
                                    Text("Word").tag(PracticeItem.PracticeItemType.word)
                                    Text("Sentence").tag(PracticeItem.PracticeItemType.sentence)
                                    Text("Matched Pair").tag(PracticeItem.PracticeItemType.matchedPair)
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                            }
                        }
                        
                        // Content fields based on type
                        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                            if newItemType == .matchedPair {
                                Text("Matched Pair Words")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: AppTheme.spacingS) {
                                    TextField("First word", text: $newItemWord)
                                        .autocapitalization(.none)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                    
                                    TextField("Second word", text: $newItemSentence)
                                        .autocapitalization(.none)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal)
                                }
                            } else if newItemType == .word {
                                Text("Word")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(.horizontal)
                                
                                TextField("Enter word", text: $newItemWord)
                                    .autocapitalization(.none)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                            } else {
                                Text("Sentence")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(.horizontal)
                                
                                TextField("Enter sentence", text: $newItemSentence)
                                    .autocapitalization(.sentences)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Category field
                        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                            Text("Category")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal)
                            
                            TextField("Category (e.g., Custom, Vowels, etc.)", text: $newItemCategory)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                        }
                        
                        // Save button
                        Button(action: {
                            // Dismiss keyboard first
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                            // Small delay to let keyboard dismiss
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if editingPracticeItem != nil {
                                    updatePracticeItem()
                                } else {
                                    addNewPracticeItem()
                                }
                                showingAddWordSheet = false
                            }
                        }) {
                            Text(editingPracticeItem != nil ? "Save Changes" : "Add to Practice List")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isItemValid() ? AppTheme.primaryBlue : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(!isItemValid())
                        .padding(.horizontal)
                        .padding(.bottom, AppTheme.spacingXL)
                    }
                    .padding(.top, AppTheme.spacingL)
                }
                .background(AppTheme.backgroundPrimary.ignoresSafeArea())
                .navigationTitle(editingPracticeItem != nil ? "Edit Item" : "Add Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            // Dismiss keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            showingAddWordSheet = false
                            resetItemFields()
                        }
                    }
                    
                    // Add keyboard dismiss button
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                .onAppear {
                    // Populate fields if editing
                    if let item = editingPracticeItem {
                        newItemType = item.type
                        newItemCategory = item.category
                        
                        if item.type == .matchedPair, let choices = item.choices, choices.count >= 2 {
                            newItemWord = choices[0]
                            newItemSentence = choices[1]
                        } else if item.type == .word {
                            newItemWord = item.content
                            newItemSentence = ""
                        } else {
                            newItemWord = ""
                            newItemSentence = item.content
                        }
                    }
                }
            }
        }
    }

    func addWordToPracticeList() {
            let newWord = Word(
                firstWord: newWordFirst.trimmingCharacters(in: .whitespaces),
                lastWord: newWordLast.trimmingCharacters(in: .whitespaces),
                category: newWordCategory.trimmingCharacters(in: .whitespaces)
            )
            
            WrongWordList.append(newWord)
            saveWrongWordList()
            resetAddWordFields()
        }
        
        func resetAddWordFields() {
            newWordFirst = ""
            newWordLast = ""
            newWordCategory = "Custom"
        }
        
        // MARK: - New Practice Item Management Functions
        
        // Validate form fields based on item type
        func isItemValid() -> Bool {
            let categoryValid = !newItemCategory.trimmingCharacters(in: .whitespaces).isEmpty
            
            switch newItemType {
            case .matchedPair:
                return !newItemWord.trimmingCharacters(in: .whitespaces).isEmpty &&
                !newItemSentence.trimmingCharacters(in: .whitespaces).isEmpty &&
                categoryValid
            case .word:
                return !newItemWord.trimmingCharacters(in: .whitespaces).isEmpty && categoryValid
            case .sentence:
                return !newItemSentence.trimmingCharacters(in: .whitespaces).isEmpty && categoryValid
            }
        }
        
        // Add new item to practice list
        func addNewPracticeItem() {
            let category = newItemCategory.trimmingCharacters(in: .whitespaces)
            
            let newItem: PracticeItem
            
            switch newItemType {
            case .matchedPair:
                let word1 = newItemWord.trimmingCharacters(in: .whitespaces)
                let word2 = newItemSentence.trimmingCharacters(in: .whitespaces)
                newItem = PracticeItem(
                    content: "\(word1) vs \(word2)",
                    type: .matchedPair,
                    category: category,
                    choices: [word1, word2]
                )
            case .word:
                let word = newItemWord.trimmingCharacters(in: .whitespaces)
                newItem = PracticeItem(
                    content: word,
                    type: .word,
                    category: category
                )
            case .sentence:
                let sentence = newItemSentence.trimmingCharacters(in: .whitespaces)
                newItem = PracticeItem(
                    content: sentence,
                    type: .sentence,
                    category: category
                )
            }
            
            PracticeList.append(newItem)
            savePracticeList()
            resetItemFields()
            
            // Show success feedback
            addedPracticeItemText = newItem.displayText
            showingPracticeItemAddedAlert = true
        }
        
        // Update existing item
        func updatePracticeItem() {
            guard let editingItem = editingPracticeItem,
                  let index = PracticeList.firstIndex(where: { $0.id == editingItem.id }) else {
                return
            }
            
            let category = newItemCategory.trimmingCharacters(in: .whitespaces)
            let updatedItem: PracticeItem
            
            switch newItemType {
            case .matchedPair:
                let word1 = newItemWord.trimmingCharacters(in: .whitespaces)
                let word2 = newItemSentence.trimmingCharacters(in: .whitespaces)
                updatedItem = PracticeItem(
                    id: editingItem.id,
                    content: "\(word1) vs \(word2)",
                    type: .matchedPair,
                    category: category,
                    choices: [word1, word2]
                )
            case .word:
                let word = newItemWord.trimmingCharacters(in: .whitespaces)
                updatedItem = PracticeItem(
                    id: editingItem.id,
                    content: word,
                    type: .word,
                    category: category
                )
            case .sentence:
                let sentence = newItemSentence.trimmingCharacters(in: .whitespaces)
                updatedItem = PracticeItem(
                    id: editingItem.id,
                    content: sentence,
                    type: .sentence,
                    category: category
                )
            }
            
            PracticeList[index] = updatedItem
            savePracticeList()
            resetItemFields()
        }
        
        // Reset form fields
        func resetItemFields() {
            newItemWord = ""
            newItemSentence = ""
            newItemType = PracticeItem.PracticeItemType.word
            newItemCategory = "Custom"
            editingPracticeItem = nil
        }
        
        // MARK: - Bulk Actions for Selection Mode
        
        // Practice only selected items
        func startSelectedItemsPractice() {
            // Filter PracticeList to only selected items
            let selectedItems = PracticeList.filter { selectedPracticeItems.contains($0.id) }
            
            guard !selectedItems.isEmpty else {
                print("⚠️ No items selected for practice")
                return
            }
            
            // Create randomized practice session with selected items
            var randomizedItems: [PracticeItem] = []
            let shuffledItems = selectedItems.shuffled()
            
            // Repeat each item according to practiceRepetitions
            for item in shuffledItems {
                for _ in 0..<practiceRepetitions {
                    randomizedItems.append(item)
                }
            }
            
            // Shuffle again so repeated items are mixed
            currentPracticeItems = randomizedItems.shuffled()
            currentQuestionIndex = 0
            
            // Exit selection mode
            isSelectionMode = false
            selectedPracticeItems.removeAll()
            
            // Start practice
            isCustomPracticeMode = true
            screen = .practiceListSessionScreen
            
            print("🎯 Starting practice with \(currentPracticeItems.count) items (\(selectedItems.count) unique)")
        }
        
        // Delete selected items
        func deleteSelectedItems() {
            // Remove all selected items from PracticeList
            PracticeList.removeAll { selectedPracticeItems.contains($0.id) }
            
            // Save updated list
            savePracticeList()
            
            // Clear selection
            selectedPracticeItems.removeAll()
            isSelectionMode = false
            
            print("🗑️ Deleted \(selectedPracticeItems.count) items")
        }
        
        func startPracticeListSession() {
            // Randomize the word list
            var randomizedList: [Word] = []
            let shuffledWords = WrongWordList.shuffled()
            
            // Repeat each word according to practiceRepetitions
            for word in shuffledWords {
                for _ in 0..<practiceRepetitions {
                    randomizedList.append(word)
                }
            }
            
            // Shuffle again so repeated words are mixed
            tempWordList = randomizedList.shuffled()
            topCategory = "WrongWordList"
            nextWord()
            screen = .screen1
            // Removed auto-play - user must click play button
        }
        
        // MARK: - Practice List Functions
        
        func savePracticeList() {
            if let encoded = try? JSONEncoder().encode(PracticeList) {
                UserDefaults.standard.set(encoded, forKey: "PracticeList")
            }
        }
        
        func loadPracticeList() {
            // Clear any existing saved practice list to start fresh
            UserDefaults.standard.removeObject(forKey: "PracticeList")
            PracticeList = []
        }
        
        func addWordToPracticeList(word: String, category: String) {
            let alreadyExists = PracticeList.contains { item in
                item.type == .word && item.content.lowercased() == word.lowercased()
            }
            
            if !alreadyExists {
                let newItem = PracticeItem(
                    content: word,
                    type: .word,
                    category: category
                )
                PracticeList.append(newItem)
                savePracticeList()
                
                addedPracticeItemText = "'\(word)' added to practice list!"
                showingPracticeItemAddedAlert = true
            }
        }
        
        func addSentenceToPracticeList(sentence: String, category: String, choices: [String]) {
            let alreadyExists = PracticeList.contains { item in
                item.type == .sentence && item.content.lowercased() == sentence.lowercased()
            }
            
            if !alreadyExists {
                let newItem = PracticeItem(
                    content: sentence,
                    type: .sentence,
                    category: category,
                    choices: choices
                )
                PracticeList.append(newItem)
                savePracticeList()
                
                addedPracticeItemText = "Sentence added to practice list!\n\nYou now have \(PracticeList.count) item(s) to practice."
                showingPracticeItemAddedAlert = true
            } else {
                addedPracticeItemText = "This sentence is already in your practice list."
                showingPracticeItemAddedAlert = true
            }
        }
        
        func addMatchedPairToPracticeList(firstWord: String, lastWord: String, category: String) {
            let alreadyExists = PracticeList.contains { item in
                if item.type == .matchedPair, let choices = item.choices, choices.count >= 2 {
                    return (choices[0].lowercased() == firstWord.lowercased() && choices[1].lowercased() == lastWord.lowercased()) ||
                    (choices[0].lowercased() == lastWord.lowercased() && choices[1].lowercased() == firstWord.lowercased())
                }
                return false
            }
            
            if !alreadyExists {
                let newItem = PracticeItem(
                    content: "\(firstWord) vs \(lastWord)",  // Display text
                    type: .matchedPair,
                    category: category,
                    choices: [firstWord, lastWord]  // Store both words in choices array
                )
                PracticeList.append(newItem)
                savePracticeList()
                
                addedPracticeItemText = "Matched pair added to practice list!\n\(firstWord) vs \(lastWord)\n\nYou now have \(PracticeList.count) item(s) to practice."
                showingPracticeItemAddedAlert = true
            } else {
                addedPracticeItemText = "This matched pair is already in your practice list."
                showingPracticeItemAddedAlert = true
            }
        }
        
        func addCurrentMatchedPairToPracticeList() {
            guard i < WordList.count else { return }
            
            let currentWord = WordList[i]
            addMatchedPairToPracticeList(firstWord: currentWord.firstWord, lastWord: currentWord.lastWord, category: topCategory)
            
            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        func startUnifiedPracticeSession() {
            currentQuestionIndex = 0
            playedMatchedPairWord = nil // Reset matched pair tracking
            practiceListSubScreen = .question // Reset to question screen
            practiceListOneOrTwo = 1
            currentScore = 0 // Reset score
            totalQuestions = 0 // Reset total questions
            
            // Create repeated list based on practiceRepetitions setting
            var repeatedItems: [PracticeItem] = []
            for _ in 0..<practiceRepetitions {
                repeatedItems.append(contentsOf: PracticeList)
            }
            
            // Shuffle the repeated items
            currentPracticeItems = repeatedItems.shuffled()
            
            // Prepare choices for each item
            practiceItemChoices = currentPracticeItems.map { item in
                if item.type == .sentence, let choices = item.choices {
                    return choices.shuffled()
                } else {
                    return []
                }
            }
            
            screen = .practiceListSessionScreen
            
            // Set up first matched pair word without auto-playing
            if !currentPracticeItems.isEmpty {
                let firstItem = currentPracticeItems[0]
                if firstItem.type == .matchedPair, let choices = firstItem.choices, choices.count >= 2 {
                    // Pre-select random word for matched pairs (but don't play it)
                    let wordToPlay = Bool.random() ? choices[0] : choices[1]
                    playedMatchedPairWord = wordToPlay
                    practiceListOneOrTwo = (wordToPlay == choices[0]) ? 1 : 2
                    // User will manually tap the speaker button to play
                }
                // For words and sentences, user will tap "Play Word" or "Play Sentence" button
            }
        }
        
        func removePracticeItem(at index: Int) {
            PracticeList.remove(at: index)
            savePracticeList()
        }
        
        @ViewBuilder
        func practiceListSessionScreenContent(layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: 0) {
                // Header Banner
                HStack {
                    Button(action: {
                        screen = .screen8
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Practice Session")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty space for symmetry
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding()
                .background(AppTheme.primaryGradient)
                
                if currentPracticeItems.isEmpty {
                    // Empty state
                    LazyVStack(spacing: AppTheme.spacingL) {
                        ModernCard(padding: AppTheme.spacingL) {
                            VStack(spacing: AppTheme.spacingM) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 48, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Text("No items to practice")
                                    .font(.system(size: layout.titleFontSize, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text("Add words or sentences to your practice list to get started.")
                                    .font(.system(size: layout.bodyFontSize))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        navigationButtons(layout: layout)
                    }
                } else if currentQuestionIndex < currentPracticeItems.count {
                    let item = currentPracticeItems[currentQuestionIndex]
                    
                    // Practice screen - switch based on sub-screen state
                    if item.type == .matchedPair {
                        // MATCHED PAIRS - same flow as normal practice
                        if practiceListSubScreen == .question {
                            // Question screen (like screen1)
                            practiceListMatchedPairQuestionScreen(item: item, layout: layout)
                        } else if practiceListSubScreen == .success {
                            // Success screen (like screen2)
                            practiceListSuccessScreen(layout: layout)
                        } else if practiceListSubScreen == .incorrect {
                            // Incorrect screen (like screen5)
                            practiceListIncorrectScreen(layout: layout)
                        }
                    } else if item.type == .sentence {
                        // SENTENCES - same flow as sentence comprehension practice (speech recognition)
                        if practiceListSubScreen == .question {
                            practiceListSentenceQuestionScreen(item: item, choices: [], layout: layout)
                        } else if practiceListSubScreen == .success {
                            practiceListWordSentenceFeedbackScreen(item: item, isCorrect: true, layout: layout)
                        } else if practiceListSubScreen == .incorrect {
                            practiceListWordSentenceFeedbackScreen(item: item, isCorrect: false, layout: layout)
                        }
                    } else {
                        // WORDS - same flow as word recognition practice (speech recognition)
                        if practiceListSubScreen == .question {
                            practiceListWordQuestionScreen(item: item, layout: layout)
                        } else if practiceListSubScreen == .success {
                            practiceListWordSentenceFeedbackScreen(item: item, isCorrect: true, layout: layout)
                        } else if practiceListSubScreen == .incorrect {
                            practiceListWordSentenceFeedbackScreen(item: item, isCorrect: false, layout: layout)
                        }
                    }
                }
            }
        }
        
        // MARK: - Practice List Sub-Screens
        
        @ViewBuilder
        func practiceListMatchedPairQuestionScreen(item: PracticeItem, layout: ResponsiveLayoutHelper) -> some View {
            if let choices = item.choices, choices.count >= 2 {
                VStack(spacing: layout.spacing) {
                    FavoriteButton(isSet: .constant(true), audio2: playedMatchedPairWord ?? choices[0], audioManager: audioManager)
                        .frame(width: layout.imageSize, height: layout.imageSize)
                    
                    Text("What did you hear?")
                        .font(.system(size: layout.titleFontSize, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(8)
                    
                    HStack(spacing: layout.spacing) {
                        practiceListChoiceButton(choices[0], isFirst: true, layout: layout)
                        practiceListChoiceButton(choices[1], isFirst: false, layout: layout)
                    }
                    
                    progressView(current: currentQuestionIndex + 1, total: currentPracticeItems.count, layout: layout)
                    
                    Button("Go Back to Home") {
                        screen = .homescreen
                        practiceListSubScreen = .question
                        showingFeedback = false
                        resetSpeechState()
                    }
                    .font(.system(size: layout.titleFontSize * 0.9))
                    .foregroundColor(.black)
                    .frame(width: layout.buttonWidth * 0.7, height: layout.buttonHeight * 0.9)
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(8)
                }
                .onAppear {
                    // Auto-play the matched pair word
                    if let wordToPlay = playedMatchedPairWord {
                        audioManager.playAudio(wordToPlay)
                        print("🔊 Auto-playing matched pair word: \(wordToPlay)")
                    }
                }
            }
        }
        
        @ViewBuilder
        func practiceListWordQuestionScreen(item: PracticeItem, layout: ResponsiveLayoutHelper) -> some View {
            LazyVStack(spacing: AppTheme.spacingL) {
                ModernCard(padding: AppTheme.spacingL) {
                    VStack(spacing: AppTheme.spacingM) {
                        HStack {
                            Image(systemName: "textformat.size")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(AppTheme.accentOrange)
                            Text("Practice List - Word Recognition")
                                .font(.system(size: layout.titleFontSize, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        
                        Text("Listen to the word and speak it back. We'll check if it matches!")
                            .font(.system(size: layout.bodyFontSize))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.leading)
                        
                        VStack(spacing: AppTheme.spacingM) {
                            ResponsiveButton(
                                text: "🔊 Play Word",
                                action: {
                                    // Check if currently recording - if so, temporarily stop it
                                    let wasRecording = speechManager.isRecording
                                    if wasRecording {
                                        print("🔄 Temporarily stopping recording to play word")
                                        speechManager.stopRecording()
                                    }
                                    
                                    // Play audio with completion handler
                                    audioManager.playAudio(item.content) { success in
                                        // After audio finishes, restart recording if it was previously active
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            guard !speechManager.isRecording else {
                                                print("⚠️ Recording already started - skipping duplicate start")
                                                return
                                            }
                                            
                                            speechManager.requestAuthorization()
                                            
                                            // Reset first word detection if starting fresh
                                            if !wasRecording {
                                                firstWordDetected = false
                                            }
                                            
                                            speechManager.onFirstWordDetected = {
                                                let generator = UINotificationFeedbackGenerator()
                                                generator.notificationOccurred(.success)
                                                firstWordDetected = true
                                            }
                                            
                                            speechManager.startRecording()
                                            
                                            if wasRecording {
                                                print("✅ Recording resumed after playing word")
                                            } else {
                                                print("✅ Recording started after playing word")
                                            }
                                        }
                                    }
                                },
                                layout: layout,
                                style: .primary,
                                icon: "play.fill"
                            )
                            
                            // Speech Recognition UI
                            if !showingFeedback {
                                VStack(spacing: AppTheme.spacingM) {
                                    // Status text
                                    if audioManager.isSpeaking {
                                        HStack(spacing: 6) {
                                            Image(systemName: "speaker.wave.3.fill")
                                                .foregroundColor(AppTheme.primaryBlue)
                                            Text("🔊 Playing word... Listen carefully!")
                                        }
                                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryBlue)
                                    } else if speechManager.isRecording {
                                        if firstWordDetected {
                                            HStack(spacing: 6) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                Text("Word detected! Tap STOP when done")
                                            }
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(.green)
                                        } else {
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(AppTheme.error)
                                                    .frame(width: 8, height: 8)
                                                Text("Listening... Start speaking!")
                                            }
                                            .font(.system(size: layout.bodyFontSize, weight: .medium))
                                            .foregroundColor(AppTheme.error)
                                        }
                                    } else {
                                        Text("Tap 'Play Word' to begin")
                                            .font(.system(size: layout.bodyFontSize, weight: .medium))
                                            .foregroundColor(AppTheme.textPrimary)
                                    }
                                    
                                    // Microphone visualization
                                    VStack(spacing: AppTheme.spacingS) {
                                        Image(systemName: speechManager.isRecording ? "waveform" : "mic.slash.circle")
                                            .font(.system(size: 64))
                                            .foregroundColor(speechManager.isRecording ? (firstWordDetected ? .green : .blue) : AppTheme.textSecondary)
                                            .scaleEffect(speechManager.isRecording ? 1.2 : 1.0)
                                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechManager.isRecording)
                                        
                                        Text(firstWordDetected ? "✅ Ready to stop!" : (speechManager.isRecording ? "🎤 Auto-detecting your speech..." : "Ready to listen"))
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(firstWordDetected ? .green : (speechManager.isRecording ? .blue : AppTheme.textSecondary))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.spacingL)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(speechManager.isRecording ? (firstWordDetected ? Color.green.opacity(0.1) : Color.blue.opacity(0.1)) : Color.gray.opacity(0.05))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(speechManager.isRecording ? (firstWordDetected ? Color.green : Color.blue) : Color.gray.opacity(0.3), lineWidth: 2)
                                    )
                                    
                                    // Show recognized text
                                    if speechManager.isRecording && !speechManager.recognizedText.isEmpty {
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            HStack {
                                                Text("YOU SAID:")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.horizontal, AppTheme.spacingM)
                                            .padding(.vertical, AppTheme.spacingS)
                                            .background(AppTheme.success)
                                            
                                            Text(speechManager.recognizedText)
                                                .font(.system(size: layout.bodyFontSize + 4, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .padding(AppTheme.spacingL)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .background(AppTheme.backgroundPrimary)
                                        }
                                        .background(AppTheme.backgroundPrimary)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppTheme.success, lineWidth: 3)
                                        )
                                        .shadow(color: AppTheme.success.opacity(0.3), radius: 8, x: 0, y: 4)
                                    }
                                    
                                    // STOP BUTTON
                                    if speechManager.isRecording {
                                        Button(action: {
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            
                                            spokenText = speechManager.recognizedText
                                            speechManager.stopRecording()
                                            
                                            // Process answer for practice list word
                                            processPracticeListWordAnswer(correctWord: item.content)
                                        }) {
                                            HStack {
                                                Image(systemName: "stop.circle.fill")
                                                    .font(.system(size: 32))
                                                Text("STOP")
                                                    .font(.system(size: 24, weight: .bold))
                                            }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 20)
                                            .background(AppTheme.error)
                                            .cornerRadius(16)
                                            .shadow(color: AppTheme.error.opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                    }
                                }
                            }
                            
                            progressView(current: currentQuestionIndex + 1, total: currentPracticeItems.count, layout: layout)
                        }
                    }
                }
                
                Button("Go Back to Home") {
                    screen = .homescreen
                    practiceListSubScreen = .question
                    resetSpeechState()
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.7, height: layout.buttonHeight * 0.9)
                .background(Color.gray.opacity(0.7))
                .cornerRadius(8)
            }
        }
        
        @ViewBuilder
        func practiceListSentenceQuestionScreen(item: PracticeItem, choices: [String], layout: ResponsiveLayoutHelper) -> some View {
            // Speech recognition version (choices parameter ignored)
            LazyVStack(spacing: AppTheme.spacingL) {
                ModernCard(padding: AppTheme.spacingL) {
                    VStack(spacing: AppTheme.spacingM) {
                        HStack {
                            Image(systemName: "quote.bubble")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(AppTheme.accentOrange)
                            Text("Practice List - Sentence")
                                .font(.system(size: layout.titleFontSize, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        
                        Text("Listen to the sentence and speak it back. We'll match your words!")
                            .font(.system(size: layout.bodyFontSize))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.leading)
                        
                        VStack(spacing: AppTheme.spacingM) {
                            ResponsiveButton(
                                text: "🔊 Play Sentence",
                                action: {
                                    // Check if currently recording - if so, temporarily stop it
                                    let wasRecording = speechManager.isRecording
                                    if wasRecording {
                                        print("🔄 Temporarily stopping recording to play sentence")
                                        speechManager.stopRecording()
                                    }
                                    
                                    // Play audio with completion handler
                                    audioManager.playAudio(item.content) { success in
                                        // After audio finishes, restart recording if it was previously active
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            guard !speechManager.isRecording else {
                                                print("⚠️ Recording already started - skipping duplicate start")
                                                return
                                            }
                                            
                                            speechManager.requestAuthorization()
                                            
                                            // Reset first word detection if starting fresh
                                            if !wasRecording {
                                                firstWordDetected = false
                                            }
                                            
                                            speechManager.onFirstWordDetected = {
                                                let generator = UINotificationFeedbackGenerator()
                                                generator.notificationOccurred(.success)
                                                firstWordDetected = true
                                            }
                                            
                                            speechManager.startRecording()
                                            
                                            if wasRecording {
                                                print("✅ Recording resumed after playing sentence")
                                            } else {
                                                print("✅ Recording started after playing sentence")
                                            }
                                        }
                                    }
                                },
                                layout: layout,
                                style: .primary,
                                icon: "play.fill"
                            )
                            
                            // Speech Recognition UI (same as word recognition)
                            if !showingFeedback {
                                VStack(spacing: AppTheme.spacingM) {
                                    // Status
                                    if audioManager.isSpeaking {
                                        HStack(spacing: 6) {
                                            Image(systemName: "speaker.wave.3.fill")
                                                .foregroundColor(AppTheme.primaryBlue)
                                            Text("🔊 Playing sentence... Listen carefully!")
                                        }
                                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryBlue)
                                    } else if speechManager.isRecording {
                                        if firstWordDetected {
                                            HStack(spacing: 6) {
                                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                                Text("Speech detected! Tap STOP when done")
                                            }
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(.green)
                                        } else {
                                            HStack(spacing: 6) {
                                                Circle().fill(AppTheme.error).frame(width: 8, height: 8)
                                                Text("Listening... Start speaking!")
                                            }
                                            .font(.system(size: layout.bodyFontSize, weight: .medium))
                                            .foregroundColor(AppTheme.error)
                                        }
                                    } else {
                                        Text("Tap 'Play Sentence' to begin")
                                            .font(.system(size: layout.bodyFontSize, weight: .medium))
                                            .foregroundColor(AppTheme.textPrimary)
                                    }
                                    
                                    // Microphone
                                    VStack(spacing: AppTheme.spacingS) {
                                        Image(systemName: speechManager.isRecording ? "waveform" : "mic.slash.circle")
                                            .font(.system(size: 64))
                                            .foregroundColor(speechManager.isRecording ? (firstWordDetected ? .green : .blue) : AppTheme.textSecondary)
                                            .scaleEffect(speechManager.isRecording ? 1.2 : 1.0)
                                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechManager.isRecording)
                                        Text(firstWordDetected ? "✅ Ready to stop!" : (speechManager.isRecording ? "🎤 Auto-detecting..." : "Ready to listen"))
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(firstWordDetected ? .green : (speechManager.isRecording ? .blue : AppTheme.textSecondary))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.spacingL)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(speechManager.isRecording ? (firstWordDetected ? Color.green.opacity(0.1) : Color.blue.opacity(0.1)) : Color.gray.opacity(0.05)))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(speechManager.isRecording ? (firstWordDetected ? Color.green : Color.blue) : Color.gray.opacity(0.3), lineWidth: 2))
                                    
                                    // Recognized text
                                    if speechManager.isRecording && !speechManager.recognizedText.isEmpty {
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            HStack {
                                                Text("YOU SAID:").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                                            }
                                            .padding(.horizontal, AppTheme.spacingM).padding(.vertical, AppTheme.spacingS).background(AppTheme.success)
                                            Text(speechManager.recognizedText).font(.system(size: layout.bodyFontSize + 4, weight: .bold)).foregroundColor(AppTheme.textPrimary).padding(AppTheme.spacingL).frame(maxWidth: .infinity, alignment: .center).background(AppTheme.backgroundPrimary)
                                        }
                                        .background(AppTheme.backgroundPrimary).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.success, lineWidth: 3)).shadow(color: AppTheme.success.opacity(0.3), radius: 8, x: 0, y: 4)
                                    }
                                    
                                    // STOP button
                                    if speechManager.isRecording {
                                        Button(action: {
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            spokenText = speechManager.recognizedText
                                            speechManager.stopRecording()
                                            processPracticeListSentenceAnswer(correctSentence: item.content)
                                        }) {
                                            HStack {
                                                Image(systemName: "stop.circle.fill").font(.system(size: 32))
                                                Text("STOP").font(.system(size: 24, weight: .bold))
                                            }
                                            .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 20).background(AppTheme.error).cornerRadius(16).shadow(color: AppTheme.error.opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                    }
                                }
                            }
                            
                            progressView(current: currentQuestionIndex + 1, total: currentPracticeItems.count, layout: layout)
                        }
                    }
                }
                
                Button("Go Back to Home") {
                    screen = .homescreen
                    practiceListSubScreen = .question
                    showingFeedback = false
                    resetSpeechState()
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.7, height: layout.buttonHeight * 0.9)
                .background(Color.gray.opacity(0.7))
                .cornerRadius(8)
            }
        }
        
        @ViewBuilder
        func practiceListSuccessScreen(layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: layout.spacing * 0.8) {
                Image("App_Check")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layout.imageSize * 0.7, height: layout.imageSize * 0.7)
                
                Button("Next") {
                    moveToNextPracticeItem()
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.cyan)
                .cornerRadius(8)
                
                Button("Try Again") {
                    // Reset all state variables
                    practiceListSubScreen = .question
                    showingFeedback = false
                    spokenText = ""
                    speechManager.recognizedText = ""
                    speechManager.stopRecording()
                    firstWordDetected = false
                    waitingForRecordingStart = false  // Reset waiting flag to allow replay
                    
                    // Don't auto-play - user will manually tap the play button
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.orange)
                .cornerRadius(8)
                
                Button("Home") {
                    screen = .homescreen
                    practiceListSubScreen = .question
                    showingFeedback = false
                    resetSpeechState()
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.cyan)
                .cornerRadius(8)
            }
        }
        
        @ViewBuilder
        func practiceListIncorrectScreen(layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: layout.spacing * 0.8) {
                Image("App_X")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layout.imageSize * 0.7, height: layout.imageSize * 0.7)
                
                Button("Next") {
                    moveToNextPracticeItem()
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.cyan)
                .cornerRadius(8)
                
                Button("Try Again") {
                    // Reset all state variables
                    practiceListSubScreen = .question
                    showingFeedback = false
                    spokenText = ""
                    speechManager.recognizedText = ""
                    speechManager.stopRecording()
                    firstWordDetected = false
                    waitingForRecordingStart = false  // Reset waiting flag to allow replay
                    
                    // Don't auto-play - user will manually tap the play button
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.orange)
                .cornerRadius(8)
                
                Button("Home") {
                    screen = .homescreen
                    practiceListSubScreen = .question
                    showingFeedback = false
                    resetSpeechState()
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.85, height: layout.buttonHeight * 0.9)
                .background(Color.cyan)
                .cornerRadius(8)
            }
        }
        
        func practiceListChoiceButton(_ text: String, isFirst: Bool, layout: ResponsiveLayoutHelper) -> some View {
            Button(action: {
                handlePracticeListChoice(isFirst: isFirst)
            }) {
                Text(text)
                    .font(.system(size: layout.titleFontSize, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .frame(
                        width: (layout.buttonWidth - layout.spacing) / 2,
                        height: layout.buttonHeight + 10
                    )
                    .background(Color.cyan)
                    .cornerRadius(8)
            }
        }
        
        func practiceListSentenceChoiceButton(choice: String, correctAnswer: String, layout: ResponsiveLayoutHelper) -> some View {
            Button(action: {
                let isCorrect = choice == correctAnswer
                if isCorrect {
                    currentScore += 1
                    practiceListSubScreen = .success
                } else {
                    practiceListSubScreen = .incorrect
                }
                totalQuestions += 1
            }) {
                Text(choice)
                    .font(.system(size: layout.bodyFontSize, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.primaryBlue)
                    .cornerRadius(AppTheme.radiusMedium)
            }
        }
        
        func handlePracticeListChoice(isFirst: Bool) {
            let isCorrect = (isFirst && practiceListOneOrTwo == 1) || (!isFirst && practiceListOneOrTwo == 2)
            
            // Get current item for tracking
            if currentQuestionIndex < currentPracticeItems.count {
                let currentItem = currentPracticeItems[currentQuestionIndex]
                if let choices = currentItem.choices, choices.count >= 2 {
                    // Track history for matched pairs
                    let firstWord = choices[0]
                    let lastWord = choices[1]
                    let playedWord = playedMatchedPairWord ?? firstWord
                    let selectedWord = isFirst ? firstWord : lastWord
                    
                    let entry = WordHistoryEntry(
                        firstWord: firstWord,
                        lastWord: lastWord,
                        userSaid: selectedWord,
                        category: currentItem.category,
                        wasCorrect: isCorrect
                    )
                    
                    // Track to listening history
                    listeningHistory.allWordHistory.append(entry)
                    listeningHistory.totalWordsAttempted += 1
                    
                    // Update category breakdown
                    let displayCategory = getCategoryDisplayName(currentItem.category)
                    if listeningHistory.categoryBreakdown[displayCategory] == nil {
                        listeningHistory.categoryBreakdown[displayCategory] = CategoryStats(
                            categoryName: displayCategory,
                            totalAttempts: 0,
                            correctAttempts: 0,
                            missedWords: [],
                            lastPracticed: Date()
                        )
                    }
                    
                    listeningHistory.categoryBreakdown[displayCategory]!.totalAttempts += 1
                    listeningHistory.categoryBreakdown[displayCategory]!.lastPracticed = Date()
                    
                    if isCorrect {
                        listeningHistory.categoryBreakdown[displayCategory]!.correctAttempts += 1
                        listeningHistory.categoryBreakdown[displayCategory]!.correctWords.append(entry)
                    } else {
                        listeningHistory.categoryBreakdown[displayCategory]!.missedWords.append(entry)
                    }
                    
                    saveListeningHistory()
                    print("💾 Saved matched pair history: \(firstWord) vs \(lastWord) - \(isCorrect ? "✅" : "❌")")
                }
            }
            
            // Track the result
            if isCorrect {
                currentScore += 1
                practiceListSubScreen = .success
            } else {
                practiceListSubScreen = .incorrect
            }
            totalQuestions += 1
        }
        
        func processPracticeListWordAnswer(correctWord: String) {
            // Check if the spoken text matches the correct word
            let normalizedSpoken = spokenText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedCorrect = correctWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Extract main word (remove articles)
            let extractedWord = extractMainWord(from: normalizedSpoken)
            
            let isCorrect = extractedWord == normalizedCorrect
            
            // Track history for words
            if currentQuestionIndex < currentPracticeItems.count {
                let currentItem = currentPracticeItems[currentQuestionIndex]
                
                let entry = WordHistoryEntry(
                    firstWord: correctWord,
                    lastWord: correctWord,  // Single word, not a pair
                    userSaid: spokenText,
                    category: currentItem.category,
                    wasCorrect: isCorrect
                )
                
                // Track to listening history
                listeningHistory.allWordHistory.append(entry)
                listeningHistory.totalWordsAttempted += 1
                
                // Update category breakdown
                let displayCategory = getCategoryDisplayName(currentItem.category)
                if listeningHistory.categoryBreakdown[displayCategory] == nil {
                    listeningHistory.categoryBreakdown[displayCategory] = CategoryStats(
                        categoryName: displayCategory,
                        totalAttempts: 0,
                        correctAttempts: 0,
                        missedWords: [],
                        lastPracticed: Date()
                    )
                }
                
                listeningHistory.categoryBreakdown[displayCategory]!.totalAttempts += 1
                listeningHistory.categoryBreakdown[displayCategory]!.lastPracticed = Date()
                
                if isCorrect {
                    listeningHistory.categoryBreakdown[displayCategory]!.correctAttempts += 1
                    listeningHistory.categoryBreakdown[displayCategory]!.correctWords.append(entry)
                } else {
                    listeningHistory.categoryBreakdown[displayCategory]!.missedWords.append(entry)
                }
                
                saveListeningHistory()
                print("💾 Saved word history: \(correctWord) - User said: '\(spokenText)' - \(isCorrect ? "✅" : "❌")")
            }
            
            // Track the result
            if isCorrect {
                currentScore += 1
                practiceListSubScreen = .success
            } else {
                practiceListSubScreen = .incorrect
            }
            totalQuestions += 1
            
            // Show feedback after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingFeedback = true
            }
        }
        
        func processPracticeListSentenceAnswer(correctSentence: String) {
            // Calculate word match score for sentences
            let spokenWords = spokenText.lowercased().components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            let expectedWords = correctSentence.lowercased().components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            
            var matches = 0
            for word in expectedWords {
                if spokenWords.contains(word) {
                    matches += 1
                }
            }
            
            wordMatchScore = expectedWords.isEmpty ? 0 : Double(matches) / Double(expectedWords.count)
            matchedWords = matches
            totalWords = expectedWords.count
            
            // Consider it correct if they got 70% or more of the words
            let isCorrect = wordMatchScore >= 0.7
            
            // Track history for sentences
            if currentQuestionIndex < currentPracticeItems.count {
                let currentItem = currentPracticeItems[currentQuestionIndex]
                
                let entry = WordHistoryEntry(
                    firstWord: correctSentence,
                    lastWord: correctSentence,  // Single sentence, not a pair
                    userSaid: spokenText,
                    category: currentItem.category,
                    wasCorrect: isCorrect
                )
                
                // Track to listening history
                listeningHistory.allWordHistory.append(entry)
                listeningHistory.totalWordsAttempted += 1
                
                // Update category breakdown
                let displayCategory = getCategoryDisplayName(currentItem.category)
                if listeningHistory.categoryBreakdown[displayCategory] == nil {
                    listeningHistory.categoryBreakdown[displayCategory] = CategoryStats(
                        categoryName: displayCategory,
                        totalAttempts: 0,
                        correctAttempts: 0,
                        missedWords: [],
                        lastPracticed: Date()
                    )
                }
                
                listeningHistory.categoryBreakdown[displayCategory]!.totalAttempts += 1
                listeningHistory.categoryBreakdown[displayCategory]!.lastPracticed = Date()
                
                if isCorrect {
                    listeningHistory.categoryBreakdown[displayCategory]!.correctAttempts += 1
                    listeningHistory.categoryBreakdown[displayCategory]!.correctWords.append(entry)
                } else {
                    listeningHistory.categoryBreakdown[displayCategory]!.missedWords.append(entry)
                }
                
                saveListeningHistory()
                print("💾 Saved sentence history: \(correctSentence) - User said: '\(spokenText)' - \(isCorrect ? "✅" : "❌") (\(Int(wordMatchScore * 100))% match)")
            }
            
            // Track the result
            if isCorrect {
                currentScore += 1
                practiceListSubScreen = .success
            } else {
                practiceListSubScreen = .incorrect
            }
            totalQuestions += 1
            
            // Show feedback after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingFeedback = true
            }
        }
        
        @ViewBuilder
        func practiceListWordSentenceFeedbackScreen(item: PracticeItem, isCorrect: Bool, layout: ResponsiveLayoutHelper) -> some View {
            LazyVStack(spacing: AppTheme.spacingL) {
                ModernCard(padding: AppTheme.spacingL) {
                    VStack(spacing: AppTheme.spacingM) {
                        // Expected
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            Text("Expected:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(item.content.lowercased())
                                .font(.system(size: layout.titleFontSize, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(AppTheme.spacingM)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(12)
                        }
                        
                        // You said
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            Text("You said:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(spokenText.isEmpty ? "No speech detected" : spokenText.lowercased())
                                .font(.system(size: layout.titleFontSize, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(AppTheme.spacingM)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(12)
                        }
                        
                        // Result badge
                        ModernCard(padding: AppTheme.spacingM, backgroundColor: isCorrect ? AppTheme.success.opacity(0.1) : AppTheme.error.opacity(0.1)) {
                            HStack {
                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(isCorrect ? AppTheme.success : AppTheme.error)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(isCorrect ? "Correct!" : "Keep Trying")
                                        .font(.system(size: layout.titleFontSize, weight: .bold))
                                        .foregroundColor(isCorrect ? AppTheme.success : AppTheme.error)
                                    
                                    if item.type == .sentence {
                                        Text("\(matchedWords)/\(totalWords) words matched (\(Int(wordMatchScore * 100))%)")
                                            .font(.system(size: layout.bodyFontSize - 2))
                                            .foregroundColor(AppTheme.textSecondary)
                                    } else {
                                        Text(isCorrect ? "Perfect match!" : "The words don't match")
                                            .font(.system(size: layout.bodyFontSize - 2))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: AppTheme.spacingM) {
                            Button("Try Again") {
                                practiceListSubScreen = .question
                                showingFeedback = false
                                spokenText = ""
                                speechManager.recognizedText = ""
                                speechManager.stopRecording()
                                firstWordDetected = false
                                waitingForRecordingStart = false  // Reset waiting flag to allow replay
                            }
                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacingM)
                            .background(AppTheme.accentOrange)
                            .cornerRadius(12)
                            
                            Button("Next") {
                                moveToNextPracticeItem()
                            }
                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacingM)
                            .background(AppTheme.primaryBlue)
                            .cornerRadius(12)
                        }
                    }
                }
                
                Button("Go Back to Home") {
                    screen = .homescreen
                    practiceListSubScreen = .question
                    showingFeedback = false
                    resetSpeechState()
                }
                .font(.system(size: layout.titleFontSize * 0.9))
                .foregroundColor(.black)
                .frame(width: layout.buttonWidth * 0.7, height: layout.buttonHeight * 0.9)
                .background(Color.gray.opacity(0.7))
                .cornerRadius(8)
            }
        }
        
        func practiceSentenceChoiceButton(choice: String, correctAnswer: String, layout: ResponsiveLayoutHelper) -> some View {
            let isSelected = userAnswer == choice
            let isCorrectChoice = choice == correctAnswer
            
            // Determine colors based on feedback state
            let backgroundColor: Color = {
                if showingFeedback && isSelected {
                    return isAnswerCorrect ? Color.green : Color.red
                } else if isSelected {
                    return AppTheme.accentOrange
                } else if showingFeedback && isCorrectChoice {
                    // Show the correct answer in green after selection
                    return Color.green.opacity(0.3)
                } else {
                    return Color.white
                }
            }()
            
            let textColor: Color = {
                if showingFeedback && (isSelected || isCorrectChoice) {
                    return .white
                } else if isSelected {
                    return .white
                } else {
                    return .black
                }
            }()
            
            let borderColor: Color = {
                if showingFeedback && isSelected {
                    return isAnswerCorrect ? Color.green : Color.red
                } else if isSelected {
                    return AppTheme.accentOrange
                } else if showingFeedback && isCorrectChoice {
                    return Color.green
                } else {
                    return AppTheme.primaryBlue
                }
            }()
            
            return Button(action: {
                checkPracticeAnswer(selectedChoice: choice)
            }) {
                HStack {
                    Text(choice)
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    // Show checkmark or X icon when feedback is showing
                    if showingFeedback && isSelected {
                        Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    } else if showingFeedback && isCorrectChoice && !isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
                .frame(width: layout.buttonWidth, height: layout.buttonHeight * 1.2)
                .background(backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: showingFeedback && (isSelected || isCorrectChoice) ? 2 : 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(showingFeedback) // Disable all buttons while showing feedback
        }
        
        func checkPracticeAnswer(selectedChoice: String) {
            // Don't allow selection if feedback is already showing
            guard !showingFeedback else { return }
            
            let item = currentPracticeItems[currentQuestionIndex]
            userAnswer = selectedChoice
            
            // Check if answer is correct
            isAnswerCorrect = (selectedChoice == item.content)
            showingFeedback = true
            
            if buttonconfirm {
                audioManager.playAudio("buttonpress")
            }
            
            let impactFeedback = UIImpactFeedbackGenerator(style: isAnswerCorrect ? .medium : .light)
            impactFeedback.impactOccurred()
            
            // Auto-advance after showing feedback for 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                moveToNextPracticeItem()
            }
        }
        
        func moveToNextPracticeItem() {
            // Reset state before moving to next question
            spokenText = ""
            speechManager.recognizedText = ""
            showingFeedback = false
            userAnswer = ""
            isAnswerCorrect = false
            wordMatchScore = 0.0
            matchedWords = 0
            totalWords = 0
            playedMatchedPairWord = nil // Reset matched pair tracking
            practiceListSubScreen = .question // Reset to question screen
            practiceListOneOrTwo = 1
            
            currentQuestionIndex += 1
            
            // Loop back to beginning for unlimited practice
            if currentQuestionIndex >= currentPracticeItems.count {
                currentQuestionIndex = 0
                // Reshuffle items for variety
                currentPracticeItems.shuffle()
                // Reshuffle choices for sentences
                practiceItemChoices = currentPracticeItems.map { item in
                    if item.type == .sentence, let choices = item.choices {
                        return choices.shuffled()
                    } else {
                        return []
                    }
                }
            }
            
            // Set up next matched pair word without auto-playing
            if !currentPracticeItems.isEmpty {
                let nextItem = currentPracticeItems[currentQuestionIndex]
                if nextItem.type == .matchedPair, let choices = nextItem.choices, choices.count >= 2 {
                    // Pre-select random word for matched pairs (but don't play it)
                    let wordToPlay = Bool.random() ? choices[0] : choices[1]
                    playedMatchedPairWord = wordToPlay
                    practiceListOneOrTwo = (wordToPlay == choices[0]) ? 1 : 2
                    // User will manually tap the speaker button to play
                }
                // For words and sentences, user will tap "Play Word" or "Play Sentence" button
            }
        }
        
        func saveWrongWordList() {
            // Save to UserDefaults
            if let encoded = try? JSONEncoder().encode(WrongWordList) {
                UserDefaults.standard.set(encoded, forKey: "WrongWordList")
            }
        }
        
        func loadWrongWordList() {
            // Load from UserDefaults
            if let savedData = UserDefaults.standard.data(forKey: "WrongWordList"),
               let decoded = try? JSONDecoder().decode([Word].self, from: savedData) {
                WrongWordList = decoded
            }
        }
        
        func addCurrentWordToPracticeList() {
            guard currentQuestionIndex < currentDemoWords.count else { return }
            
            let currentWord = currentDemoWords[currentQuestionIndex]
            
            // Use new unified practice list
            addWordToPracticeList(word: currentWord.word, category: "Word Recognition")
            
            // Provide haptic feedback
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
        
        func addCurrentSentenceToPracticeList() {
            guard currentQuestionIndex < currentDemoSentences.count else { return }
            
            let currentSentence = currentDemoSentences[currentQuestionIndex]
            let categoryName = currentTrainingCategory == .sentenceComprehension ? "Sentence Comprehension" : "Sentences in Noise"
            
            // Use new unified practice list with sentence and choices
            addSentenceToPracticeList(
                sentence: currentSentence.sentence,
                category: categoryName,
                choices: currentSentence.choices
            )
            
            // Provide haptic feedback
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
        
        // MARK: - Word Matching for Speech Recognition
        
        /// Calculate similarity between two words (0.0 to 1.0)
        /// Returns 1.0 for exact matches, partial credit for similar words
        func wordSimilarity(_ word1: String, _ word2: String) -> Double {
            // Exact match gets full credit
            if word1 == word2 {
                return 1.0
            }
            
            // Very short words require exact match (to avoid false positives)
            if word1.count < 3 || word2.count < 3 {
                return 0.0
            }
            
            // Check for prefix/suffix matches (common in speech recognition errors)
            let minLength = min(word1.count, word2.count)
            let maxLength = max(word1.count, word2.count)
            
            // If one word is a prefix of another and at least 75% of the shorter word
            if minLength >= 3 && maxLength > 0 {
                if word1.hasPrefix(word2) || word2.hasPrefix(word1) {
                    let prefixRatio = Double(minLength) / Double(maxLength)
                    if prefixRatio >= 0.75 {
                        return 0.7 // Give 70% credit for strong prefix matches
                    }
                }
            }
            
            // Calculate character overlap (Jaccard similarity on character sets)
            let chars1 = Set(word1)
            let chars2 = Set(word2)
            let intersection = chars1.intersection(chars2).count
            let union = chars1.union(chars2).count
            
            let charSimilarity = union > 0 ? Double(intersection) / Double(union) : 0.0
            
            // Calculate simple edit distance ratio
            let editDistance = levenshteinDistance(word1, word2)
            let editRatio = 1.0 - (Double(editDistance) / Double(maxLength))
            
            // Combine metrics: weighted average
            let combinedScore = (charSimilarity * 0.4) + (editRatio * 0.6)
            
            // Only give partial credit if similarity is above threshold (60%)
            if combinedScore >= 0.6 {
                // Scale to 0.5-0.8 range for partial matches
                return 0.5 + (combinedScore - 0.6) * 0.75
            }
            
            return 0.0
        }
        
        func calculateWordMatch(spoken: String, expected: String) -> (score: Double, matched: Int, total: Int) {
            // Normalize both strings: lowercase and remove punctuation
            let normalizeString = { (text: String) -> String in
                text.lowercased()
                    .components(separatedBy: CharacterSet.alphanumerics.inverted)
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
            }
            
            let spokenNormalized = normalizeString(spoken)
            let expectedNormalized = normalizeString(expected)
            
            // Split into words
            let spokenWords = spokenNormalized.split(separator: " ").map { String($0) }
            let expectedWords = expectedNormalized.split(separator: " ").map { String($0) }
            
            guard !expectedWords.isEmpty else { return (0.0, 0, 0) }
            
            // Count matching words with partial credit support
            var totalCredit: Double = 0.0
            var usedSpokenIndices = Set<Int>()
            
            for (expectedIndex, expectedWord) in expectedWords.enumerated() {
                var bestMatch: (spokenIndex: Int, similarity: Double)? = nil
                
                // Find best matching spoken word that hasn't been used yet
                for (spokenIndex, spokenWord) in spokenWords.enumerated() {
                    if usedSpokenIndices.contains(spokenIndex) {
                        continue
                    }
                    
                    let similarity = wordSimilarity(spokenWord, expectedWord)
                    
                    // Keep track of best match
                    if similarity > 0 {
                        if let current = bestMatch {
                            if similarity > current.similarity {
                                bestMatch = (spokenIndex, similarity)
                            }
                        } else {
                            bestMatch = (spokenIndex, similarity)
                        }
                    }
                }
                
                // Add credit for best match found
                if let match = bestMatch {
                    usedSpokenIndices.insert(match.spokenIndex)
                    totalCredit += match.similarity
                }
            }
            
            // Calculate score and effective matched count
            let score = totalCredit / Double(expectedWords.count)
            let effectiveMatches = Int(round(totalCredit))
            
            return (score, effectiveMatches, expectedWords.count)
        }
        
        func processSpeechAnswer() {
            guard currentQuestionIndex < currentDemoSentences.count else { return }
            
            let currentSentence = currentDemoSentences[currentQuestionIndex]
            spokenText = speechManager.recognizedText
            
            // Calculate word matching score
            let result = calculateWordMatch(spoken: spokenText, expected: currentSentence.sentence)
            wordMatchScore = result.score
            matchedWords = result.matched
            totalWords = result.total
            
            // Consider it correct if 70% or more words match
            isAnswerCorrect = wordMatchScore >= 0.7
            
            // Record the response
            let response = UserResponse(
                question: currentSentence.sentence,
                userAnswer: spokenText,
                correctAnswer: currentSentence.sentence,
                wasCorrect: isAnswerCorrect
            )
            
            if currentQuestionIndex < userResponses.count {
                userResponses[currentQuestionIndex] = response
            } else {
                userResponses.append(response)
            }
            
            showingFeedback = true
            
            // Save to ProgressTrackingManager for stats dashboard
            let session = PracticeSession(
                exerciseText: currentSentence.sentence,
                exerciseType: .sentence,
                recognizedText: spokenText,
                score: wordMatchScore,
                duration: 10.0,  // Approximate duration per sentence
                phonemeAccuracy: [:]
            )
            progressTrackingManager.addSession(session)
            
            // Save to AnalyticsManager for clinical dashboard
            analyticsManager.recordSessionFromResult(
                exerciseType: "Sentence Comprehension",
                duration: 10.0,
                itemsAttempted: totalWords,
                itemsCorrect: matchedWords
            )
            
            // Save to listening history for Exercise Performance section
            // Use correct category based on whether background noise is enabled
            let categoryName = backgroundNoiseEnabled ? "Sentences in Noise" : "Sentence Comprehension"
            trackTrainingCategoryHistory(
                question: currentSentence.sentence,
                correctAnswer: currentSentence.sentence,
                wasCorrect: isAnswerCorrect,
                category: categoryName,
                userSaid: spokenText
            )
            
            print("📊 Saved Sentence data: '\(currentSentence.sentence)' - Score: \(wordMatchScore), Words: \(matchedWords)/\(totalWords)")
        }
        
        // MARK: - Phoneme Similarity Helpers
        
        /// Extract the main word from speech, removing common articles and filler words
        func extractMainWord(from speech: String) -> String {
            let words = speech.split(separator: " ").map { String($0) }
            let fillerWords = ["the", "a", "an", "um", "uh", "like"]
            
            // Filter out filler words and return the longest remaining word
            let contentWords = words.filter { !fillerWords.contains($0.lowercased()) }
            return contentWords.max(by: { $0.count < $1.count }) ?? speech
        }
        
        /// Calculate phonetic similarity between two words (0.0 to 1.0)
        /// Uses multiple algorithms: Soundex-like encoding, Levenshtein distance, and phonetic rules
        func calculatePhoneticSimilarity(_ word1: String, _ word2: String) -> Double {
            let w1 = word1.lowercased().trimmingCharacters(in: .whitespaces)
            let w2 = word2.lowercased().trimmingCharacters(in: .whitespaces)
            
            // Handle empty strings
            if w1.isEmpty || w2.isEmpty { return 0.0 }
            
            // Exact match
            if w1 == w2 { return 1.0 }
            
            // Get phonetic codes
            let code1 = getPhoneticCode(w1)
            let code2 = getPhoneticCode(w2)
            
            // If phonetic codes match exactly, very high similarity
            if code1 == code2 { return 0.95 }
            
            // Calculate Levenshtein distance on original words
            let levDistance = levenshteinDistance(w1, w2)
            let maxLen = Double(max(w1.count, w2.count))
            let levSimilarity = maxLen > 0 ? 1.0 - (Double(levDistance) / maxLen) : 0.0
            
            // Calculate Levenshtein distance on phonetic codes
            let codeDistance = levenshteinDistance(code1, code2)
            let codeMaxLen = Double(max(code1.count, code2.count))
            let codeSimilarity = codeMaxLen > 0 ? 1.0 - (Double(codeDistance) / codeMaxLen) : 0.0
            
            // Weighted average: 40% original, 60% phonetic code
            let finalSimilarity = (levSimilarity * 0.4) + (codeSimilarity * 0.6)
            
            return max(0.0, min(1.0, finalSimilarity))
        }
        
        /// Get phonetic code for a word (Soundex-like algorithm with enhanced phonetic rules)
        func getPhoneticCode(_ word: String) -> String {
            // Handle empty string
            if word.isEmpty { return "" }
            
            var w = word.lowercased()
            
            // Remove silent letters at end
            if w.hasSuffix("e") && w.count > 2 {
                w = String(w.dropLast())
            }
            
            // Phonetic substitutions (common sound-alikes)
            let substitutions: [(String, String)] = [
                // Vowel reductions
                ("ph", "f"),
                ("gh", "f"),
                ("ck", "k"),
                ("qu", "k"),
                // Consonant equivalents
                ("c", "k"),  // soft c before e,i,y
                // Common endings
                ("tion", "shun"),
                ("sion", "shun"),
                ("ough", "o"),
                ("augh", "o"),
                // Double letters
                ("ll", "l"),
                ("ss", "s"),
                ("tt", "t"),
                ("pp", "p"),
                ("ff", "f"),
                ("mm", "m"),
                ("nn", "n")
            ]
            
            for (pattern, replacement) in substitutions {
                w = w.replacingOccurrences(of: pattern, with: replacement)
            }
            
            // Reduce all vowels to a single character (except first letter)
            if let first = w.first {
                var result = String(first)
                let vowels = Set("aeiou")
                
                for (index, char) in w.enumerated() {
                    if index == 0 { continue }
                    if vowels.contains(char) {
                        // Keep only first vowel of consecutive vowels
                        if result.last.map({ !vowels.contains($0) }) ?? true {
                            result.append("V")  // Represent all vowels as V
                        }
                    } else {
                        result.append(char)
                    }
                }
                return result
            }
            
            return w
        }
        
        /// Calculate Levenshtein distance between two strings
        func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
            // Handle empty strings to prevent Range crash
            if s1.isEmpty { return s2.count }
            if s2.isEmpty { return s1.count }
            
            let s1Array = Array(s1)
            let s2Array = Array(s2)
            let s1Count = s1Array.count
            let s2Count = s2Array.count
            
            var matrix = [[Int]](repeating: [Int](repeating: 0, count: s2Count + 1), count: s1Count + 1)
            
            for i in 0...s1Count {
                matrix[i][0] = i
            }
            
            for j in 0...s2Count {
                matrix[0][j] = j
            }
            
            for i in 1...s1Count {
                for j in 1...s2Count {
                    let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                    matrix[i][j] = min(
                        matrix[i - 1][j] + 1,      // deletion
                        matrix[i][j - 1] + 1,      // insertion
                        matrix[i - 1][j - 1] + cost // substitution
                    )
                }
            }
            
            return matrix[s1Count][s2Count]
        }
        
        func processWordSpeechAnswer() {
            guard currentQuestionIndex < currentDemoWords.count else { return }
            
            let currentWord = currentDemoWords[currentQuestionIndex]
            spokenText = speechManager.recognizedText.lowercased().trimmingCharacters(in: .whitespaces)
            let expectedWord = currentWord.word.lowercased().trimmingCharacters(in: .whitespaces)
            
            // WORD RECOGNITION: Check if expected word appears ANYWHERE in the spoken text
            // This allows for mispronunciations like "um hello there" to still match "hello"
            // Split the spoken text into individual words
            let spokenWords = spokenText.split(separator: " ").map { String($0) }
            
            // Check if any spoken word matches the expected word
            // This is more lenient - allows filler words before/after
            isAnswerCorrect = spokenWords.contains { spokenWord in
                spokenWord == expectedWord
            }
            
            // Also extract the main word for logging purposes
            let extractedWord = extractMainWord(from: spokenText)
            
            print("🎯 Expected: '\(expectedWord)' | Spoken: '\(spokenText)' | Main word: '\(extractedWord)' | Match: \(isAnswerCorrect ? "✅" : "❌")")
            
            // Calculate simple match score (0 or 1 for words)
            wordMatchScore = isAnswerCorrect ? 1.0 : 0.0
            matchedWords = isAnswerCorrect ? 1 : 0
            totalWords = 1
            
            // Record the response
            let response = UserResponse(
                question: currentWord.word,
                userAnswer: spokenText,
                correctAnswer: currentWord.word,
                wasCorrect: isAnswerCorrect
            )
            
            if currentQuestionIndex < userResponses.count {
                userResponses[currentQuestionIndex] = response
            } else {
                userResponses.append(response)
            }
            
            showingFeedback = true
            
            // Save to ProgressTrackingManager for stats dashboard
            let session = PracticeSession(
                exerciseText: currentWord.word,
                exerciseType: .word,
                recognizedText: spokenText,
                score: wordMatchScore,
                duration: 5.0,  // Approximate duration per word
                phonemeAccuracy: [currentWord.word: wordMatchScore]
            )
            progressTrackingManager.addSession(session)
            
            // Save to AnalyticsManager for clinical dashboard
            analyticsManager.recordSessionFromResult(
                exerciseType: "Word Recognition",
                duration: 5.0,
                itemsAttempted: 1,
                itemsCorrect: isAnswerCorrect ? 1 : 0
            )
            
            // Save to listening history for Exercise Performance section
            let categoryToSave = "Word Recognition"
            trackTrainingCategoryHistory(
                question: currentWord.word,
                correctAnswer: currentWord.word,
                wasCorrect: isAnswerCorrect,
                category: categoryToSave,
                userSaid: spokenText
            )
            
            print("📊 Saved Word Recognition data: '\(currentWord.word)' - Category: '\(categoryToSave)' - Score: \(wordMatchScore)")
            
            // UNLIMITED MODE: Update stats and check for next word
            if isUnlimitedMode {
                updateUnlimitedModeStats(wasCorrect: isAnswerCorrect, word: currentWord.word)
            }
        }
        
        // MARK: - Unlimited Practice Mode Functions
        
        func startUnlimitedPractice(type: TrainingCategory) {
            // Reset unlimited mode state
            isUnlimitedMode = true
            unlimitedSessionCorrect = 0
            unlimitedSessionTotal = 0
            unlimitedSessionStartTime = Date()
            currentStreak = 0
            showStatsPanel = true
            showFatigueWarning = false
            showWordCountPicker = false
            showSentenceCountPicker = false
            currentQuestionIndex = 0
            usedSentencesInSession = [] // Reset used sentences
            usedWordsInSession = [] // Reset used words
            currentTrainingCategory = type
            
            print("🔄 Starting unlimited practice for \(type)")
            
            // Don't rotate voices - use selected voice consistently
            audioManager.setVoiceVariation(enabled: false)
            
            // Load first item based on type
            if type == .wordRecognition {
                loadNextUnlimitedWord()
            } else if type == .sentenceComprehension {
                loadNextUnlimitedSentence(withNoise: false)
            } else if type == .sentencesInNoise {
                loadNextUnlimitedSentence(withNoise: true)
            }
        }
        
        func loadNextUnlimitedWord() {
            // Load words excluding already used ones
            let allWords = DemoWord.loadFromCSV(fileName: "WordRecognitionData", count: 1000, excludeWords: usedWordsInSession)
            
            // If we've used all words, reset the pool
            if allWords.isEmpty {
                print("🔄 Resetting word pool - all words used!")
                usedWordsInSession = []
                let freshWords = DemoWord.loadFromCSV(fileName: "WordRecognitionData", count: 1000, excludeWords: Set())
                if let selectedWord = freshWords.randomElement() {
                    currentDemoWords = [selectedWord]
                    selectedChoices = [selectedWord.randomizedChoices()]
                    usedWordsInSession.insert(selectedWord.word)
                    print("📝 Loaded word: \(selectedWord.word)")
                    // Don't auto-play - user must tap play button
                }
            } else {
                // Select random word from unused pool
                if let selectedWord = allWords.randomElement() {
                    currentDemoWords = [selectedWord]
                    selectedChoices = [selectedWord.randomizedChoices()]
                    usedWordsInSession.insert(selectedWord.word)
                    print("📝 Loaded word: \(selectedWord.word) (\(usedWordsInSession.count) words used)")
                    // Don't auto-play - user must tap play button
                }
            }
        }
        
        func loadNextUnlimitedSentence(withNoise: Bool) {
            let category: TrainingCategory = withNoise ? .sentencesInNoise : .sentenceComprehension
            
            // Load sentences excluding already used ones
            let allSentences = DemoSentence.loadFromCSV(fileName: "SentenceComprehensionData", count: 1000, category: category, excludeSentences: usedSentencesInSession)
            
            // If we've used all sentences, reset the pool
            if allSentences.isEmpty {
                print("🔄 Resetting sentence pool - all sentences used!")
                usedSentencesInSession = []
                let freshSentences = DemoSentence.loadFromCSV(fileName: "SentenceComprehensionData", count: 1000, category: category, excludeSentences: Set())
                if let selectedSentence = freshSentences.randomElement() {
                    currentDemoSentences = [selectedSentence]
                    usedSentencesInSession.insert(selectedSentence.sentence)
                    print("📝 Loaded sentence: \(selectedSentence.sentence)")
                    // Don't auto-play - user must tap play button
                }
            } else {
                // Select random sentence from unused pool
                if let selectedSentence = allSentences.randomElement() {
                    currentDemoSentences = [selectedSentence]
                    usedSentencesInSession.insert(selectedSentence.sentence)
                    print("📝 Loaded sentence: \(selectedSentence.sentence) (\(usedSentencesInSession.count) sentences used)")
                    // Don't auto-play - user must tap play button
                }
            }
            
            // Adaptive noise for sentences in noise
            if withNoise {
                backgroundNoiseEnabled = true
                // Adjust noise based on recent performance
                if unlimitedSessionTotal > 0 {
                    let recentAccuracy = Double(unlimitedSessionCorrect) / Double(unlimitedSessionTotal)
                    if recentAccuracy > 0.85 {
                        // Increase difficulty
                        adaptiveNoiseLevel = min(0.6, adaptiveNoiseLevel + 0.05)
                    } else if recentAccuracy < 0.65 {
                        // Decrease difficulty
                        adaptiveNoiseLevel = max(0.2, adaptiveNoiseLevel - 0.05)
                    }
                }
                backgroundNoiseVolume = Float(adaptiveNoiseLevel)
                print("🔊 Adaptive noise level: \(Int(adaptiveNoiseLevel * 100))%")
            }
        }
        
        func updateUnlimitedModeStats(wasCorrect: Bool, word: String) {
            unlimitedSessionTotal += 1
            
            if wasCorrect {
                unlimitedSessionCorrect += 1
                currentStreak += 1
            } else {
                currentStreak = 0
            }
            
            // Save to clinical dashboard (real-time update)
            saveUnlimitedSessionDataToClinicalDashboard(wasCorrect: wasCorrect, word: word)
            
            // Check for fatigue warning (every 50 attempts)
            if unlimitedSessionTotal % 50 == 0 {
                showFatigueWarning = true
            }
            
            let accuracy = unlimitedSessionTotal > 0 ? Double(unlimitedSessionCorrect) / Double(unlimitedSessionTotal) : 0.0
            print("📊 Session Stats: \(unlimitedSessionCorrect)/\(unlimitedSessionTotal) (\(Int(accuracy * 100))%) | Streak: \(currentStreak)")
        }
        
        func saveUnlimitedSessionDataToClinicalDashboard(wasCorrect: Bool, word: String) {
            // Create word history entry
            let category = currentTrainingCategory == .wordRecognition ? "Word Recognition" : "Sentence"
            let entry = WordHistoryEntry(
                firstWord: word,
                lastWord: word,
                userSaid: spokenText,  // What the user actually said
                category: category,
                wasCorrect: wasCorrect,
                timestamp: Date()
            )
            
            // Add to listening history
            listeningHistory.allWordHistory.append(entry)
            
            // Update category stats
            var categoryStats = listeningHistory.categoryBreakdown[category] ?? CategoryStats(
                categoryName: category,
                totalAttempts: 0,
                correctAttempts: 0,
                missedWords: [],
                lastPracticed: Date()
            )
            categoryStats.totalAttempts += 1
            if wasCorrect {
                categoryStats.correctAttempts += 1
                categoryStats.correctWords.append(entry)  // Track correct words too
            } else {
                categoryStats.missedWords.append(entry)
            }
            categoryStats.lastPracticed = Date()
            listeningHistory.categoryBreakdown[category] = categoryStats
            
            // Save to UserDefaults
            saveListeningHistory()
            
            print("💾 Saved to clinical dashboard: \(word) - \(wasCorrect ? "✅" : "❌")")
        }
        
        func stopUnlimitedPractice() {
            guard isUnlimitedMode else { return }
            
            let duration = Date().timeIntervalSince(unlimitedSessionStartTime ?? Date())
            let accuracy = unlimitedSessionTotal > 0 ? Double(unlimitedSessionCorrect) / Double(unlimitedSessionTotal) * 100 : 0.0
            
            print("🏁 Unlimited session ended:")
            print("   Duration: \(Int(duration / 60)) minutes")
            print("   Total: \(unlimitedSessionTotal)")
            print("   Correct: \(unlimitedSessionCorrect)")
            print("   Accuracy: \(Int(accuracy))%")
            print("   Best Streak: \(currentStreak)")
            
            // Reset speech state before leaving
            resetSpeechState()
            
            // Reset state
            isUnlimitedMode = false
            backgroundNoiseEnabled = false
            showFatigueWarning = false
            
            // Return to selection screen
            showWordCountPicker = true
            showSentenceCountPicker = true
        }
        
        // MARK: - Phonetic Difference Analysis
        func analyzePhoneticDifference(word1: String, word2: String) -> PhoneticDifference? {
            let w1 = word1.lowercased()
            let w2 = word2.lowercased()
            
            guard w1.count == w2.count else {
                // Different lengths - likely syllable difference
                return nil
            }
            
            // Find first differing position
            var differingIndex: Int? = nil
            for (index, (char1, char2)) in zip(w1, w2).enumerated() {
                if char1 != char2 {
                    differingIndex = index
                    break
                }
            }
            
            guard let index = differingIndex else { return nil }
            
            let char1 = String(Array(w1)[index])
            let char2 = String(Array(w2)[index])
            
            // Determine position
            let position: String
            let differenceType: PhoneticDifferenceType
            
            if index == 0 {
                position = "initial"
                differenceType = classifyConsonantDifference(char1, char2) ?? .initialConsonant
            } else if index == w1.count - 1 {
                position = "final"
                differenceType = classifyConsonantDifference(char1, char2) ?? .finalConsonant
            } else {
                position = "medial"
                // Check if it's a vowel difference
                let vowels = "aeiou"
                if vowels.contains(char1) || vowels.contains(char2) {
                    differenceType = .vowel
                } else {
                    differenceType = .initialConsonant
                }
            }
            
            return PhoneticDifference(
                word1: word1,
                word2: word2,
                differenceType: differenceType,
                differingPhoneme1: char1,
                differingPhoneme2: char2,
                position: position
            )
        }
        
        func classifyConsonantDifference(_ char1: String, _ char2: String) -> PhoneticDifferenceType? {
            let liquids = ["r", "l"]
            let fricatives = ["f", "v", "s", "z", "sh", "th"]
            let nasals = ["m", "n", "ng"]
            
            // Check for liquid confusion (r/l)
            if liquids.contains(char1) && liquids.contains(char2) {
                return .liquids
            }
            
            // Check for fricative confusion
            if fricatives.contains(char1) || fricatives.contains(char2) {
                return .fricatives
            }
            
            // Check for nasal confusion
            if nasals.contains(char1) && nasals.contains(char2) {
                return .nasals
            }
            
            // Check for voicing pairs
            let voicingPairs: [String: String] = [
                "p": "b", "t": "d", "k": "g",
                "f": "v", "s": "z", "th": "dh"
            ]
            
            for (voiceless, voiced) in voicingPairs {
                if (char1 == voiceless && char2 == voiced) || (char1 == voiced && char2 == voiceless) {
                    return .voicing
                }
            }
            
            return nil
        }
        
        @ViewBuilder
        func settingsScreenContent(layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: 0) {
                // Header Banner
                HStack {
                    Button(action: {
                        screen = .homescreen
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty space for symmetry
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding()
                .background(AppTheme.primaryGradient)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: AppTheme.spacingL) {
                        settingsHeaderSection(layout: layout)
                        audioSettingsSection(layout: layout)
                        // backgroundTrainingSection(layout: layout)  // REMOVED: Background noise is now automatic for Sentences in Noise only
                        trainingSettingsSection(layout: layout)
                        settingsActionSection(layout: layout)
                    }
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.vertical, AppTheme.spacingL)
                }
                
                // Fixed back button at bottom
                settingsNavigationSection(layout: layout)
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.bottom, AppTheme.spacingL)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.backgroundPrimary.ignoresSafeArea())
        }
        
        @ViewBuilder
        func settingsHeaderSection(layout: ResponsiveLayoutHelper) -> some View {
            ModernCard(padding: AppTheme.spacingL) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(AppTheme.primaryBlue)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Settings")
                            .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Customize your training experience")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                }
            }
        }
        
        @ViewBuilder
        func audioSettingsSection(layout: ResponsiveLayoutHelper) -> some View {
            ModernCard(padding: AppTheme.spacingL) {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.accentOrange)
                        
                        Text("Audio Settings")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                    }
                    
                    modernSettingRow(
                        title: "Playback Speed",
                        subtitle: "Controlled by difficulty level (or adjust manually)",
                        value: String(format: "%.1fx", playbackSpeed)
                    ) {
                        Slider(value: $playbackSpeed, in: 0.5...2.0, step: 0.1)
                            .tint(AppTheme.accentOrange)
                    }
                    
                    Divider().background(AppTheme.textTertiary)
                    
                    modernSettingRow(
                        title: "Volume",
                        subtitle: "Adjust master volume level",
                        value: "\(Int(volumeLevel * 100))%"
                    ) {
                        Slider(value: Binding(
                            get: { Double(volumeLevel) },
                            set: { volumeLevel = Float($0) }
                        ), in: 0.0...1.0, step: 0.05)
                        .tint(AppTheme.accentOrange)
                    }
                    
                    Divider().background(AppTheme.textTertiary)
                    
                    voiceSelectionRow(layout: layout)
                }
            }
        }
        
        @ViewBuilder
        func voiceSelectionRow(layout: ResponsiveLayoutHelper) -> some View {
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    Image(systemName: "person.wave.2.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.accentOrange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Voice Type")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Choose male or female voice")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(voiceSettings.selectedVoice.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.accentOrange)
                }
                
                // Voice selection buttons (2 voices)
                VStack(spacing: AppTheme.spacingXS) {
                    ForEach(VoiceType.allCases, id: \.self) { voice in
                        voiceButton(voice: voice)
                    }
                }
            }
        }
        
        @ViewBuilder
        func voiceButton(voice: VoiceType) -> some View {
            Button(action: {
                // Provide haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                voiceSettings.selectedVoice = voice
                // Play a sample audio to test the voice
                audioManager.playAudio("Beet")
            }) {
                HStack(spacing: AppTheme.spacingM) {
                    // Icon
                    Image(systemName: voice == .male ? "person.fill" : "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(voiceSettings.selectedVoice == voice ? AppTheme.accentOrange : AppTheme.textSecondary)
                    
                    // Voice details
                    VStack(alignment: .leading, spacing: 2) {
                        Text(voice.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(voice.description)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Show checkmark for selected voice
                    if voiceSettings.selectedVoice == voice {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.accentOrange)
                    }
                }
                .padding(AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingXS)
                .frame(maxWidth: .infinity)
                .background(
                    voiceSettings.selectedVoice == voice ?
                    AppTheme.accentOrange.opacity(0.2) :
                        AppTheme.backgroundSecondary
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            voiceSettings.selectedVoice == voice ?
                            AppTheme.accentOrange :
                                AppTheme.textTertiary.opacity(0.3),
                            lineWidth: voiceSettings.selectedVoice == voice ? 2 : 1
                        )
                )
                .cornerRadius(8)
            }
            .scaleEffect(voiceSettings.selectedVoice == voice ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: voiceSettings.selectedVoice)
            .disabled(!voice.isAvailable)
            .opacity(voice.isAvailable ? 1.0 : 0.6)
        }
        
        @ViewBuilder
        func backgroundTrainingSection(layout: ResponsiveLayoutHelper) -> some View {
            ModernCard(padding: AppTheme.spacingL) {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    HStack {
                        Image(systemName: "waveform.path")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.info)
                        
                        Text("Background Training")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                    }
                    
                    modernToggleRow(
                        title: "Enable Background Noise",
                        subtitle: "Practice with distracting sounds",
                        isOn: $backgroundNoiseEnabled,
                        color: AppTheme.info
                    )
                    
                    if backgroundNoiseEnabled {
                        backgroundNoiseControls(layout: layout)
                    }
                }
            }
        }
        
        @ViewBuilder
        func backgroundNoiseControls(layout: ResponsiveLayoutHelper) -> some View {
            Divider().background(AppTheme.textTertiary)
            
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                Text("Noise Type")
                    .font(.system(size: layout.bodyFontSize, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                
                Picker("Noise Type", selection: $backgroundNoiseType) {
                    ForEach(BackgroundNoiseType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(AppTheme.cardBackground)
            }
            
            Divider().background(AppTheme.textTertiary)
            
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Signal-to-Noise Ratio (SNR)")
                            .font(.system(size: layout.bodyFontSize, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Higher SNR = easier listening; Lower SNR = more challenging")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("\(getSNRFromVolume(), specifier: "%.0f") dB")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.info)
                }
                
                // SNR Slider (maps to volume internally)
                // Clinical standard: 70% = ~0-2 dB SNR (challenging but realistic)
                Slider(value: Binding(
                    get: { Double(backgroundNoiseVolume) },
                    set: { backgroundNoiseVolume = Float($0) }
                ), in: 0.0...1.0, step: 0.01) {
                    Text("SNR")
                } minimumValueLabel: {
                    VStack(spacing: 2) {
                        Text("0 dB")
                            .font(.system(size: 10))
                        Text("Hard")
                            .font(.system(size: 8))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                } maximumValueLabel: {
                    VStack(spacing: 2) {
                        Text("20+ dB")
                            .font(.system(size: 10))
                        Text("Easy")
                            .font(.system(size: 8))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                .tint(AppTheme.info)
                
                // Clinical standard info
                Text("💡 Clinical standard: 70% (≈0-2 dB SNR) matches QuickSIN/HINT tests")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.info)
                    .padding(.top, 4)
                
                // Visual SNR guide
                HStack(spacing: 4) {
                    ForEach([("0 dB", Color.red), ("5 dB", Color.orange), ("10 dB", Color.yellow), ("20 dB", Color.green)], id: \.0) { label, color in
                        VStack(spacing: 2) {
                            Circle()
                                .fill(color)
                                .frame(width: 8, height: 8)
                            Text(label)
                                .font(.system(size: 9))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        if label != "20 dB" {
                            Spacer()
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        
        @ViewBuilder
        func trainingSettingsSection(layout: ResponsiveLayoutHelper) -> some View {
            ModernCard(padding: AppTheme.spacingL) {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.accentPurple)
                        
                        Text("Training Settings")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Text("Difficulty: \(difficultyLevel.rawValue)")
                            .font(.system(size: layout.bodyFontSize, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(getDifficultyDescription())
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.bottom, AppTheme.spacingXS)
                        
                        Picker("Difficulty", selection: $difficultyLevel) {
                            ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: difficultyLevel) { newDifficulty in
                            // Automatically update playback speed based on difficulty
                            playbackSpeed = Double(newDifficulty.playbackSpeed)
                            audioManager.setPlaybackSpeed(newDifficulty.playbackSpeed)
                            saveSettings()
                            print("🎯 Difficulty: \(newDifficulty.rawValue) - Auto speed: \(newDifficulty.playbackSpeed)x")
                        }
                    }
                    
                    Divider().background(AppTheme.textTertiary)
                    
                    modernToggleRow(
                        title: "Show Progress After Each Word",
                        subtitle: "Display accuracy stats after each attempt",
                        isOn: $showProgressAfterEachWord,
                        color: AppTheme.accentPurple
                    )
                }
            }
        }
        
        @ViewBuilder
        func settingsActionSection(layout: ResponsiveLayoutHelper) -> some View {
            ModernCard(padding: AppTheme.spacingL) {
                VStack(spacing: AppTheme.spacingM) {
                    ResponsiveButton(
                        text: "Manage Word & Sentence Lists",
                        action: {
                            screen = .screen8
                            if buttonconfirm {
                                audioManager.playAudio("buttonpress")
                            }
                        },
                        layout: layout,
                        style: .primary,
                        icon: "list.bullet.rectangle"
                    )
                    
                    ResponsiveButton(
                        text: "Test Audio Settings",
                        action: {
                            testAudioWithCurrentSettings()
                        },
                        layout: layout,
                        style: .primary,
                        icon: "speaker.wave.3.fill"
                    )
                    
                    ResponsiveButton(
                        text: "Reset to Defaults",
                        action: {
                            resetSettingsToDefaults()
                        },
                        layout: layout,
                        style: .warning,
                        icon: "arrow.counterclockwise"
                    )
                    
                    ResponsiveButton(
                        text: "CloudKit Sync Status",
                        action: {
                            showCloudKitDebug = true
                            if buttonconfirm {
                                audioManager.playAudio("buttonpress")
                            }
                        },
                        layout: layout,
                        style: .primary,
                        icon: "icloud.fill"
                    )
                    
                    ResponsiveButton(
                        text: "About Hearify",
                        action: {
                            showAboutScreen = true
                            if buttonconfirm {
                                audioManager.playAudio("buttonpress")
                            }
                        },
                        layout: layout,
                        style: .primary,
                        icon: "info.circle.fill"
                    )
                }
            }
        }
        
        @ViewBuilder
        func settingsNavigationSection(layout: ResponsiveLayoutHelper) -> some View {
            ResponsiveButton(
                text: "Go Back",
                action: {
                    screen = .homescreen
                    saveSettings()
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                },
                layout: layout,
                style: .secondary,
                icon: "arrow.left"
            )
        }
        
        // MARK: - Settings Helper Views
        @ViewBuilder
        func modernSettingRow<Content: View>(
            title: String,
            subtitle: String,
            value: String,
            @ViewBuilder content: () -> Content
        ) -> some View {
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text(title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(value)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.primaryBlue)
                }
                
                content()
            }
        }
        
        @ViewBuilder
        func modernToggleRow(
            title: String,
            subtitle: String,
            isOn: Binding<Bool>,
            color: Color
        ) -> some View {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: isOn)
                    .toggleStyle(SwitchToggleStyle(tint: color))
            }
        }
        
        @ViewBuilder
        func onboardingScreenContent(layout: ResponsiveLayoutHelper) -> some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: layout.spacing * 2) {
                    
                    // Welcome Header
                    VStack(spacing: layout.spacing) {
                        Image("App_Begin_Icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: layout.buttonWidth * 0.4, height: layout.buttonWidth * 0.4)
                        
                        Text("Welcome to Auditory Training!")
                            .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                            .foregroundColor(.cyan)
                            .multilineTextAlignment(.center)
                        
                        Text("Train your brain to distinguish sounds and improve listening skills")
                            .font(.system(size: layout.bodyFontSize))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, layout.padding)
                    }
                    .padding(.top, layout.spacing * 2)
                    
                    // Onboarding Steps
                    VStack(spacing: layout.spacing * 1.5) {
                        
                        // Step 1: Six Training Categories
                        onboardingStepView(
                            stepNumber: 1,
                            title: "🎯 Six Training Categories",
                            description: "• Word Recognition: Identify individual words\n• Sentence Comprehension: Understand full sentences\n• Sentences in Noise: Practice in challenging environments\n• Matched Pairs: Classic minimal pair training\n• Diagnostic Test: Comprehensive assessment\n• AI Analysis: View practice observations and ideas",
                            iconName: "App_Begin_Icon",
                            layout: layout
                        )
                        
                        // Step 2: AI Analysis
                        onboardingStepView(
                            stepNumber: 2,
                            title: "🧠 Practice Pattern Analysis",
                            description: "View observations about your practice patterns, including sounds that came up often and practice ideas you might want to discuss with your audiologist. These are informal insights to complement your professional care.",
                            iconName: "App_Begin_Icon",
                            layout: layout
                        )
                        
                        // Step 3: Custom Practice List
                        onboardingStepView(
                            stepNumber: 3,
                            title: "📝 Smart Practice List",
                            description: "• Add words/sentences from any category during practice\n• Set repetitions (1-10 times per word)\n• Randomized order for effective learning\n• Add custom words manually\n• Export and share your list",
                            iconName: "App_Begin_Icon",
                            layout: layout
                        )
                        
                        // Step 4: Adaptive Settings
                        onboardingStepView(
                            stepNumber: 4,
                            title: "⚙️ Adaptive Training Settings",
                            description: "• Playback speed adjusts with difficulty (0.8x Easy → 1.3x Expert)\n• Background noise control for realistic practice\n• Multiple voice options (more coming soon)\n• Customizable word/sentence counts",
                            iconName: "App_Begin_Icon",
                            layout: layout
                        )
                        
                        // Step 5: Progress Tracking
                        onboardingStepView(
                            stepNumber: 5,
                            title: "📊 Comprehensive Stats & Export",
                            description: "• Track accuracy by category and frequency range\n• View listening history with all attempts\n• See missed words for each category\n• Export results via Email, Messages, or Files\n• Share AI analysis reports with your audiologist",
                            iconName: "App_Check",
                            layout: layout
                        )
                        
                        // Step 6: Flexible Testing
                        onboardingStepView(
                            stepNumber: 6,
                            title: "🎪 Customizable Diagnostic Tests",
                            description: "Create your own diagnostic test by selecting:\n• Up to 20 words from Word Recognition\n• Up to 10 sentences (comprehension)\n• Up to 10 sentences in noise\n• Results include frequency and phonetic analysis",
                            iconName: "App_Begin_Icon",
                            layout: layout
                        )
                    }
                    
                    // Action Buttons
                    VStack(spacing: layout.spacing) {
                        ResponsiveButton(
                            text: "🎯 Start Word Recognition",
                            action: {
                                screen = .homescreen
                                markOnboardingComplete()
                                if buttonconfirm {
                                    audioManager.playAudio("buttonpress")
                                }
                            },
                            layout: layout,
                            style: .success,
                            icon: "textformat.size"
                        )
                        
                        ResponsiveButton(
                            text: "🧠 Explore Practice Insights",
                            action: {
                                screen = .homescreen
                                markOnboardingComplete()
                                if buttonconfirm {
                                    audioManager.playAudio("buttonpress")
                                }
                            },
                            layout: layout,
                            style: .primary,
                            icon: "brain.head.profile"
                        )
                        
                        ResponsiveButton(
                            text: "📊 View All Features",
                            action: {
                                screen = .homescreen
                                markOnboardingComplete()
                                if buttonconfirm {
                                    audioManager.playAudio("buttonpress")
                                }
                            },
                            layout: layout,
                            style: .accent,
                            icon: "square.grid.2x2"
                        )
                        
                        Button(action: {
                            screen = .homescreen
                            markOnboardingComplete()
                        }) {
                            Text("Skip Tutorial")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(.gray)
                                .underline()
                        }
                        .padding(.top, AppTheme.spacingS)
                    }
                    .padding(.top, layout.spacing * 2)
                }
                .padding(.horizontal, layout.padding)
                .padding(.bottom, 100)
            }
        }
        
        @ViewBuilder
        func onboardingStepView(stepNumber: Int, title: String, description: String, iconName: String, layout: ResponsiveLayoutHelper) -> some View {
            HStack(alignment: .top, spacing: layout.spacing) {
                // Step number circle
                ZStack {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 40, height: 40)
                    
                    Text("\(stepNumber)")
                        .font(.system(size: layout.bodyFontSize, weight: .bold))
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: layout.spacing / 2) {
                    Text(title)
                        .font(.system(size: layout.titleFontSize, weight: .semibold))
                        .foregroundColor(.cyan)
                    
                    Text(description)
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        
        @ViewBuilder
        func progressDisplayView(layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: layout.spacing / 2) {
                Text("Progress Update")
                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                    .foregroundColor(.cyan)
                
                HStack(spacing: layout.spacing) {
                    // Session Stats
                    VStack(alignment: .center, spacing: 4) {
                        Text("Session")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(.gray)
                        Text("\(Int(getSessionAccuracy()))%")
                            .font(.system(size: layout.bodyFontSize, weight: .bold))
                            .foregroundColor(.green)
                        Text("\(sessionCorrect)/\(sessionAttempts)")
                            .font(.system(size: layout.bodyFontSize - 4))
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    // Overall Stats
                    VStack(alignment: .center, spacing: 4) {
                        Text("Overall")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(.gray)
                        Text("\(Int(getOverallAccuracy()))%")
                            .font(.system(size: layout.bodyFontSize, weight: .bold))
                            .foregroundColor(.blue)
                        Text("\(correctAttempts)/\(totalAttempts)")
                            .font(.system(size: layout.bodyFontSize - 4))
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    // Streak
                    VStack(alignment: .center, spacing: 4) {
                        Text("Streak")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(.gray)
                        Text("\(dailyStreak)")
                            .font(.system(size: layout.bodyFontSize, weight: .bold))
                            .foregroundColor(.orange)
                        Text("days")
                            .font(.system(size: layout.bodyFontSize - 4))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.05))
            .cornerRadius(8)
        }
        
        @ViewBuilder
        func statsHeaderSection(layout: ResponsiveLayoutHelper) -> some View {
            HStack {
                Spacer()
                
                Text("Statistics")
                    .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                    .foregroundColor(.cyan)
                
                Spacer()
                
                // Clear Data Button
                Button(action: {
                    showingClearDataAlert = true
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.red.opacity(0.7)))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        
        @ViewBuilder
        func statsScreenContent(layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: 0) {
                // Header Banner
                HStack {
                    Button(action: {
                        screen = .homescreen
                        if buttonconfirm {
                            audioManager.playAudio("buttonpress")
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Progress & Statistics")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty space for symmetry
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding()
                .background(AppTheme.primaryGradient)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: layout.spacing) {
                        statsOverallSection(layout: layout)
                        statsSessionSection(layout: layout)
                        
                        // Exercise Type Breakdown - NEW SECTION
                        exerciseTypeBreakdownSection(layout: layout)
                        
                        listeningHistorySection(layout: layout)
                        // statsCategorySection(layout: layout)  // REMOVED: Duplicate of Exercise Performance section
                    }
                    .padding(.horizontal, layout.padding)
                    .padding(.bottom, layout.spacing)
                }
                
                // Fixed back button at bottom
                statsNavigationSection(layout: layout)
                    .padding(.horizontal, layout.padding)
                    .padding(.bottom, AppTheme.spacingL)
            }
            .sheet(isPresented: Binding<Bool>(
                get: { !statsShareItems.isEmpty },
                set: { if !$0 { statsShareItems = [] } }
            )) {
                ShareSheet(items: statsShareItems)
            }
            .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All Data", role: .destructive) {
                    // Clear all data sources
                    clearAllStatsData()
                }
            } message: {
                Text("This will permanently delete all your practice sessions, listening history, and statistics. This action cannot be undone.")
            }
    }
    
    @ViewBuilder
    func statsOverallSection(layout: ResponsiveLayoutHelper) -> some View {
        VStack(alignment: .leading, spacing: layout.spacing) {
            Text("Overall Performance")
                .font(.system(size: layout.titleFontSize, weight: .bold))
                .foregroundColor(.cyan)
            
            HStack(spacing: layout.spacing * 2) {
                VStack(alignment: .center, spacing: 8) {
                    Text("\(Int(getOverallAccuracy()))%")
                        .font(.system(size: layout.titleFontSize * 1.5, weight: .bold))
                        .foregroundColor(.green)
                    Text("Overall Accuracy")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Divider()
                    .frame(height: 60)
                
                VStack(alignment: .center, spacing: 8) {
                    Text("\(totalAttempts)")
                        .font(.system(size: layout.titleFontSize * 1.5, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Total Attempts")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Divider()
                    .frame(height: 60)
                
                VStack(alignment: .center, spacing: 8) {
                    Text("\(dailyStreak)")
                        .font(.system(size: layout.titleFontSize * 1.5, weight: .bold))
                        .foregroundColor(.orange)
                    Text("Day Streak")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    func statsSessionSection(layout: ResponsiveLayoutHelper) -> some View {
        VStack(alignment: .leading, spacing: layout.spacing) {
            Text("Current Session")
                .font(.system(size: layout.titleFontSize, weight: .bold))
                .foregroundColor(.cyan)
            
            HStack(spacing: layout.spacing * 2) {
                VStack(alignment: .center, spacing: 8) {
                    Text("\(Int(getSessionAccuracy()))%")
                        .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                        .foregroundColor(.green)
                    Text("Session Accuracy")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .frame(height: 50)
                
                VStack(alignment: .center, spacing: 8) {
                    Text("\(sessionAttempts)")
                        .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Attempts")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .frame(height: 50)
                
                VStack(alignment: .center, spacing: 8) {
                    Text("\(sessionCorrect)")
                        .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                        .foregroundColor(.purple)
                    Text("Correct")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    func exerciseTypeBreakdownSection(layout: ResponsiveLayoutHelper) -> some View {
        VStack(alignment: .leading, spacing: layout.spacing) {
            Text("Exercise Performance")
                .font(.system(size: layout.titleFontSize, weight: .bold))
                .foregroundColor(.cyan)
                .onAppear {
                    print("📊 Stats Page - Exercise Performance Section")
                    print("   Total categories in breakdown: \(listeningHistory.categoryBreakdown.keys.count)")
                    print("   Categories: \(listeningHistory.categoryBreakdown.keys.sorted())")
                    for (category, stats) in listeningHistory.categoryBreakdown {
                        print("   - \(category): \(stats.totalAttempts) attempts, \(stats.missedWords.count) missed")
                    }
                }
            
            // Word Recognition
            exerciseTypeCard(
                title: "Word Recognition",
                icon: "textformat.size",
                color: .orange,
                stats: listeningHistory.categoryBreakdown["Word Recognition"],
                layout: layout
            )
            .onAppear {
                if let stats = listeningHistory.categoryBreakdown["Word Recognition"] {
                    print("✅ Word Recognition stats found: \(stats.totalAttempts) attempts")
                    print("   Missed words count: \(stats.missedWords.count)")
                    if stats.missedWords.count > 0 {
                        print("   First missed word: \(stats.missedWords[0].firstWord) vs \(stats.missedWords[0].lastWord)")
                        print("   Category: \(stats.missedWords[0].category)")
                    }
                } else {
                    print("❌ No Word Recognition stats found")
                }
            }
            
            // Sentence Comprehension
            exerciseTypeCard(
                title: "Sentence Comprehension",
                icon: "quote.bubble.fill",
                color: .blue,
                stats: listeningHistory.categoryBreakdown["Sentence Comprehension"],
                layout: layout
            )
            
            // Sentences in Noise
            exerciseTypeCard(
                title: "Sentences in Noise",
                icon: "waveform",
                color: .purple,
                stats: listeningHistory.categoryBreakdown["Sentences in Noise"],
                layout: layout
            )
            
            // Diagnostic Test
            exerciseTypeCard(
                title: "Diagnostic Test",
                icon: "stethoscope",
                color: .green,
                stats: listeningHistory.categoryBreakdown["Diagnostic Test"],
                layout: layout
            )
            
            // MATCHED PAIRS SUBCATEGORIES
            Text("Matched Pairs")
                .font(.system(size: layout.bodyFontSize + 2, weight: .semibold))
                .foregroundColor(.cyan.opacity(0.8))
                .padding(.top, 8)
            
            // Syllables
            exerciseTypeCard(
                title: "Syllables",
                icon: "text.bubble",
                color: .pink,
                stats: listeningHistory.categoryBreakdown["Syllables"],
                layout: layout
            )
            .onAppear {
                if let stats = listeningHistory.categoryBreakdown["Syllables"] {
                    print("✅ Syllables stats found: \(stats.totalAttempts) attempts")
                    print("   Missed words count: \(stats.missedWords.count)")
                    if stats.missedWords.count > 0 {
                        print("   First missed word: \(stats.missedWords[0].firstWord) vs \(stats.missedWords[0].lastWord)")
                        print("   Category: \(stats.missedWords[0].category)")
                    }
                } else {
                    print("❌ No Syllables stats found")
                }
            }
            
            // Consonants
            exerciseTypeCard(
                title: "Consonants",
                icon: "c.circle.fill",
                color: .indigo,
                stats: listeningHistory.categoryBreakdown["Consonants"],
                layout: layout
            )
            
            // Final Consonants
            exerciseTypeCard(
                title: "Final Consonants",
                icon: "c.square.fill",
                color: .teal,
                stats: listeningHistory.categoryBreakdown["Final Consonants"],
                layout: layout
            )
            
            // Vowels
            exerciseTypeCard(
                title: "Vowels",
                icon: "v.circle.fill",
                color: .mint,
                stats: listeningHistory.categoryBreakdown["Vowels"],
                layout: layout
            )
            
            // Phonetics
            exerciseTypeCard(
                title: "Phonetics",
                icon: "waveform.circle.fill",
                color: .cyan,
                stats: listeningHistory.categoryBreakdown["Phonetics"],
                layout: layout
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // Helper to convert old categoryStats dict to CategoryStats
    func convertDictToStats(_ category: String) -> CategoryStats? {
        guard let dict = categoryStats[category],
              let attempts = dict["attempts"],
              let correct = dict["correct"] else {
            return nil
        }
        
        return CategoryStats(
            categoryName: category,
            totalAttempts: attempts,
            correctAttempts: correct,
            missedWords: [],
            lastPracticed: Date()
        )
    }
    
    @ViewBuilder
    func exerciseTypeCard(title: String, icon: String, color: Color, stats: CategoryStats?, layout: ResponsiveLayoutHelper) -> some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            .onTapGesture {
                print("🔵 Category card tapped: \(title)")
                if let stats = stats {
                    print("   Stats category name: \(stats.categoryName)")
                    print("   Missed words: \(stats.missedWords.count)")
                }
            }
            
            // Title and Stats
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)  // Use theme color for dark mode support
                
                if let stats = stats {
                    HStack(spacing: 4) {
                        Text("\(stats.correctAttempts)/\(stats.totalAttempts) attempts")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(AppTheme.textSecondary)  // Use theme color
                        
                        if let lastDate = stats.lastPracticed {
                            Text("•")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Last: \(formatShortDate(lastDate))")
                                .font(.system(size: layout.bodyFontSize - 2))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                } else {
                    Text("No data yet")
                        .font(.system(size: layout.bodyFontSize - 2))
                        .foregroundColor(AppTheme.textSecondary)  // Use theme color
                }
            }
            
            Spacer()
            
            // Accuracy
            if let stats = stats {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(stats.accuracy * 100))%")
                        .font(.system(size: layout.titleFontSize, weight: .bold))
                        .foregroundColor(stats.accuracy >= 0.8 ? AppTheme.success : stats.accuracy >= 0.6 ? AppTheme.accentOrange : AppTheme.error)
                    
                    Text("accuracy")
                        .font(.system(size: layout.bodyFontSize - 4))
                        .foregroundColor(AppTheme.textSecondary)  // Use theme color
                }
            } else {
                Image(systemName: "minus.circle")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.textTertiary)  // Use theme color
            }
        }
        .padding()
        .background(AppTheme.cardBackground)  // Use theme color instead of hardcoded white
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2)
    }
    
    func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
    }
    
    @ViewBuilder
    func listeningHistorySection(layout: ResponsiveLayoutHelper) -> some View {
        VStack(alignment: .leading, spacing: layout.spacing) {
            if !listeningHistory.categoryBreakdown.isEmpty {
                Text("Listening History")
                    .font(.system(size: layout.titleFontSize, weight: .bold))
                    .foregroundColor(.cyan)
                
                // Overall stats
                HStack(spacing: layout.spacing) {
                    VStack(alignment: .center, spacing: 4) {
                        Text("\(listeningHistory.totalWordsAttempted)")
                            .font(.system(size: layout.titleFontSize, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Total Words")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider().frame(height: 40)
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text(String(format: "%.1f%%", listeningHistory.overallAccuracy * 100))
                            .font(.system(size: layout.titleFontSize, weight: .bold))
                            .foregroundColor(.green)
                        Text("Accuracy")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider().frame(height: 40)
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("\(listeningHistory.categoryBreakdown.count)")
                            .font(.system(size: layout.titleFontSize, weight: .bold))
                            .foregroundColor(.orange)
                        Text("Categories")
                            .font(.system(size: layout.bodyFontSize - 2))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, layout.spacing / 2)
                
                Divider()
                
                // Category breakdown
                ForEach(Array(listeningHistory.categoryBreakdown.keys.sorted()), id: \.self) { category in
                    if let stats = listeningHistory.categoryBreakdown[category] {
                        categoryHistoryRow(stats: stats, layout: layout)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .sheet(isPresented: Binding<Bool>(
            get: { selectedHistoryCategory != nil },
            set: { if !$0 { selectedHistoryCategory = nil } }
        )) {
            if let selectedCategory = selectedHistoryCategory,
               let stats = listeningHistory.categoryBreakdown[selectedCategory] {
                categoryMissedWordsView(stats: stats, layout: layout)
                    .onAppear {
                        print("🎯 Sheet opened with selected category: '\(selectedCategory)'")
                        print("   Stats category: '\(stats.categoryName)'")
                        print("   Missed words: \(stats.missedWords.count)")
                    }
            }
        }
    }
    
    @ViewBuilder
    func categoryHistoryRow(stats: CategoryStats, layout: ResponsiveLayoutHelper) -> some View {
        VStack(alignment: .leading, spacing: layout.spacing / 2) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(getCategoryDisplayName(stats.categoryName))
                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                        .foregroundColor(.black)
                        .onAppear {
                            print("📌 Category row displayed: '\(stats.categoryName)' → Display: '\(getCategoryDisplayName(stats.categoryName))'")
                            print("   Attempts: \(stats.totalAttempts), Correct: \(stats.correctAttempts), Missed: \(stats.missedWords.count)")
                        }
                    
                    if let lastPracticed = stats.lastPracticed {
                        Text("Last: \(formatDate(lastPracticed))")
                            .font(.system(size: layout.bodyFontSize - 4))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(stats.accuracyPercentage)
                        .font(.system(size: layout.bodyFontSize, weight: .bold))
                        .foregroundColor(getAccuracyColor(stats.accuracy))
                    
                    Text("\(stats.correctAttempts)/\(stats.totalAttempts)")
                        .font(.system(size: layout.bodyFontSize - 4))
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    print("🔍 Chevron button clicked for category: '\(stats.categoryName)'")
                    print("   Display name: '\(getCategoryDisplayName(stats.categoryName))'")
                    print("   Missed words count: \(stats.missedWords.count)")
                    selectedHistoryCategory = stats.categoryName
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                }
            }
            .padding(.vertical, layout.spacing / 3)
            .padding(.horizontal, layout.spacing / 2)
            .background(Color.white)
            .cornerRadius(8)
            
            // Show missed words count
            if !stats.missedWords.isEmpty {
                Text("\(stats.missedWords.count) missed word\(stats.missedWords.count == 1 ? "" : "s")")
                    .font(.system(size: layout.bodyFontSize - 4))
                    .foregroundColor(.red)
                    .padding(.leading, layout.spacing / 2)
            }
        }
    }

    @ViewBuilder
    func categoryMissedWordsView(stats: CategoryStats, layout: ResponsiveLayoutHelper) -> some View {
        NavigationView {
            VStack(spacing: layout.spacing) {
                Text("Practice History - \(getCategoryDisplayName(stats.categoryName))")
                    .font(.system(size: layout.titleFontSize, weight: .bold))
                    .foregroundColor(.cyan)
                    .padding()
                    .onAppear {
                        print("📋 Practice History View Opened")
                        print("   Category: '\(stats.categoryName)'")
                        print("   Display Name: '\(getCategoryDisplayName(stats.categoryName))'")
                        print("   Total missed words: \(stats.missedWords.count)")
                        print("   Total correct words: \(stats.correctWords.count)")
                        if stats.missedWords.count > 0 {
                            for (index, word) in stats.missedWords.prefix(3).enumerated() {
                                print("   [\(index)] \(word.firstWord) vs \(word.lastWord) | Category: \(word.category) | You said: \(word.userSaid)")
                            }
                        }
                    }
                
                // Segmented picker to switch between Missed and Correct words
                Picker("Word Type", selection: $showingMissedWords) {
                    Text("Missed (\(stats.missedWords.count))").tag(true)
                    Text("Correct (\(stats.correctWords.count))").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Check if this is a matched pairs category (Phonetics, etc.)
                // Only true matched pair categories should hide "You said:" - they use button selection, not speech
                let isMatchedPairsCategory = ["Syllables", "Consonants", "Final Consonants", "Vowels", "Phonetics"].contains(stats.categoryName)
                
                // Get the appropriate word list based on selection
                let wordList = showingMissedWords ? stats.missedWords : stats.correctWords
                
                if wordList.isEmpty {
                    Text(showingMissedWords ? "No missed words! Great job!" : "No correct words yet. Keep practicing!")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: layout.spacing / 2) {
                            ForEach(wordList) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        // Show word pair if both words exist (matched pairs)
                                        if !entry.lastWord.isEmpty && entry.lastWord != entry.firstWord {
                                            HStack(spacing: 4) {
                                                Text("Word Pair:")
                                                    .font(.system(size: layout.bodyFontSize - 2))
                                                    .foregroundColor(.gray)
                                                Text("\(entry.firstWord) vs \(entry.lastWord)")
                                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                    .foregroundColor(.blue)
                                            }
                                        } else {
                                            // Single word (Word Recognition, etc.)
                                            HStack(spacing: 4) {
                                                Text(showingMissedWords ? "Expected:" : "Word:")
                                                    .font(.system(size: layout.bodyFontSize - 2))
                                                    .foregroundColor(.gray)
                                                Text(entry.firstWord)
                                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                    .foregroundColor(showingMissedWords ? .orange : .green)
                                            }
                                        }
                                        
                                        // Show "You said:" for all exercises EXCEPT matched pairs categories
                                        // Matched pairs use button selection (ship vs sheep), others use speech recognition
                                        if !isMatchedPairsCategory && !entry.userSaid.isEmpty {
                                            HStack(spacing: 4) {
                                                Text("You said:")
                                                    .font(.system(size: layout.bodyFontSize - 2))
                                                    .foregroundColor(.gray)
                                                Text(entry.userSaid)
                                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                    .foregroundColor(showingMissedWords ? .red : .green)
                                            }
                                        }
                                        
                                        Text(formatDate(entry.timestamp))
                                            .font(.system(size: layout.bodyFontSize - 4))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: showingMissedWords ? "xmark.circle.fill" : "checkmark.circle.fill")
                                        .foregroundColor(showingMissedWords ? .red : .green)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                }
                
                Button("Close") {
                    selectedHistoryCategory = nil
                }
                .font(.system(size: layout.titleFontSize))
                .foregroundColor(.white)
                .frame(width: layout.buttonWidth * 0.6, height: layout.buttonHeight)
                .background(Color.blue)
                .cornerRadius(8)
                .padding()
            }
        }
    }
    
    func getCategoryDisplayName(_ category: String) -> String {
        switch category.lowercased() {
        case "syllables": return "Syllables"
        case "consonants": return "Consonants"
        case "c": return "Consonants"
        case "cm": return "Consonants"
        case "cv": return "Consonants"
        case "cp": return "Consonants"
        case "fc": return "Final Consonants"
        case "nv": return "Vowels"
        case "wv": return "Vowels"
        case "pd": return "Phonetics"  // Added to handle "PD" category
        case "pd1": return "Phonetics"
        case "pd2": return "Phonetics"
        case "word recognition": return "Word Recognition"
        case "sentence comprehension": return "Sentence Comprehension"
        case "sentences in noise": return "Sentences in Noise"
        case "diagnostic test": return "Diagnostic Test"
        case "dailychallenge": return "Daily Challenge"
        case "wrongwordlist": return "Practice List"
        case "matched pairs": return "Matched Pairs"  // Added for clarity
        default: return category.capitalized
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func getAccuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.9 { return .green }
        if accuracy >= 0.7 { return .orange }
        return .red
    }
    
    @ViewBuilder
    func statsCategorySection(layout: ResponsiveLayoutHelper) -> some View {
        if !categoryStats.isEmpty {
            VStack(alignment: .leading, spacing: layout.spacing) {
                Text("Category Performance")
                    .font(.system(size: layout.titleFontSize, weight: .bold))
                    .foregroundColor(.cyan)
                
                ForEach(Array(categoryStats.keys.sorted()), id: \.self) { category in
                    categoryStatsRow(category: category, layout: layout)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    func statsNavigationSection(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: AppTheme.spacingM) {
            // Export Stats Button
            Button(action: {
                exportStatsData()
            }) {
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Export Stats")
                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(width: layout.buttonWidth * 0.6, height: layout.buttonHeight * 0.8)
                .background(AppTheme.accentOrange)
                .cornerRadius(8)
            }
            
            // Back Button
            Button("Go Back") {
                screen = .homescreen
                if buttonconfirm {
                    audioManager.playAudio("buttonpress")
                }
            }
            .font(.system(size: layout.titleFontSize))
            .foregroundColor(.black)
            .frame(width: layout.buttonWidth * 0.6, height: layout.buttonHeight)
            .background(Color.gray.opacity(0.7))
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    func modernAchievementBadge(
        title: String,
        description: String,
        isUnlocked: Bool,
        icon: String,
        layout: ResponsiveLayoutHelper
    ) -> some View {
        VStack(spacing: AppTheme.spacingS) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppTheme.accentOrange.opacity(0.2) : AppTheme.textTertiary.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isUnlocked ? AppTheme.accentOrange : AppTheme.textSecondary)
            }
            
            VStack(spacing: AppTheme.spacingXS) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(AppTheme.spacingM)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                .fill(isUnlocked ? AppTheme.success.opacity(0.1) : AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                        .stroke(isUnlocked ? AppTheme.success.opacity(0.3) : AppTheme.textTertiary.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
    
    @ViewBuilder
    func modernStatCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        layout: ResponsiveLayoutHelper
    ) -> some View {
        VStack(spacing: AppTheme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .frame(width: 30, height: 30)
            
            Text(value)
                .font(.system(size: layout.titleFontSize, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.spacingM)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                .fill(color.opacity(0.1))
        )
    }
    
    @ViewBuilder
    func modernCategoryStatsRow(category: String, layout: ResponsiveLayoutHelper) -> some View {
        HStack {
            Image(systemName: getCategoryIcon(category))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.primaryBlue)
                .frame(width: 20)
            
            Text(category)
                .font(.system(size: layout.bodyFontSize, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            let accuracy = getCategoryAccuracy(category: category)
            let attempts = categoryStats[category]?["attempts"] ?? 0
            let correct = categoryStats[category]?["correct"] ?? 0
            
            VStack(alignment: .trailing, spacing: AppTheme.spacingXS) {
                Text("\(Int(accuracy))%")
                    .font(.system(size: layout.bodyFontSize, weight: .bold))
                    .foregroundColor(accuracy >= 80 ? AppTheme.success : accuracy >= 60 ? AppTheme.warning : AppTheme.error)
                
                Text("\(correct)/\(attempts)")
                    .font(.system(size: layout.bodyFontSize - 2))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.vertical, AppTheme.spacingXS)
    }
    
    func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "vowels": return "a.circle.fill"
        case "consonants": return "c.circle.fill"
        case "phonetics": return "waveform.circle.fill"
        case "syllables": return "s.circle.fill"
        default: return "circle.fill"
        }
    }
    
    @ViewBuilder
    func categoryStatsRow(category: String, layout: ResponsiveLayoutHelper) -> some View {
        HStack {
            Text(getCategoryDisplayName(category))
                .font(.system(size: layout.bodyFontSize, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            let accuracy = getCategoryAccuracy(category: category)
            let attempts = categoryStats[category]?["attempts"] ?? 0
            let correct = categoryStats[category]?["correct"] ?? 0
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(accuracy))%")
                    .font(.system(size: layout.bodyFontSize, weight: .bold))
                    .foregroundColor(accuracy >= 80 ? .green : accuracy >= 60 ? .orange : .red)
                
                Text("\(correct)/\(attempts)")
                    .font(.system(size: layout.bodyFontSize - 2))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func achievementBadge(title: String, description: String, isUnlocked: Bool, layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(isUnlocked ? "🏆" : "🔒")
                    .font(.system(size: 20))
            }
            
            Text(title)
                .font(.system(size: layout.bodyFontSize - 2, weight: .semibold))
                .foregroundColor(isUnlocked ? .primary : .gray)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.system(size: layout.bodyFontSize - 4))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    func weeklyProgressChart(layout: ResponsiveLayoutHelper) -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(weeklyProgressData.indices, id: \.self) { index in
                let data = weeklyProgressData[index]
                VStack(spacing: 4) {
                    // Bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .frame(width: 30, height: max(4, CGFloat(data.accuracy / 100.0 * 80)))
                    
                    // Label
                    Text("\(Calendar.current.component(.day, from: data.date))")
                        .font(.system(size: layout.bodyFontSize - 4))
                        .foregroundColor(.gray)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: data.accuracy)
            }
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func categoryPerformanceChart(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: layout.spacing / 2) {
            ForEach(categoryPerformanceData.indices, id: \.self) { index in
                let data = categoryPerformanceData[index]
                HStack {
                    Text(data.label)
                        .font(.system(size: layout.bodyFontSize - 2))
                        .foregroundColor(.primary)
                        .frame(width: 80, alignment: .leading)
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 16)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(data.color)
                                .frame(width: max(4, geo.size.width * CGFloat(data.value / 100.0)), height: 16)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: data.value)
                        }
                    }
                    .frame(height: 16)
                    
                    Text("\(Int(data.value))%")
                        .font(.system(size: layout.bodyFontSize - 2, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 40, alignment: .trailing)
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    @ViewBuilder
    func accuracyTrendChart(layout: ResponsiveLayoutHelper) -> some View {
        let trendData = generateTrendData()
        
        VStack(spacing: layout.spacing / 2) {
            // Chart area
            GeometryReader { geo in
                ZStack {
                    // Background grid
                    VStack(spacing: 0) {
                        ForEach(0..<5) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                            Spacer()
                        }
                    }
                    
                    // Trend line
                    if trendData.count > 1 {
                        Path { path in
                            let stepX = geo.size.width / CGFloat(trendData.count - 1)
                            
                            for (index, point) in trendData.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = geo.size.height * (1 - CGFloat(point / 100.0))
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(Color.blue, lineWidth: 3)
                        
                        // Data points
                        ForEach(trendData.indices, id: \.self) { index in
                            let point = trendData[index]
                            let x = (geo.size.width / CGFloat(trendData.count - 1)) * CGFloat(index)
                            let y = geo.size.height * (1 - CGFloat(point / 100.0))
                            
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)
                        }
                    }
                }
            }
            .frame(height: 80)
            
            // X-axis labels
            HStack {
                Text("Day 1")
                    .font(.system(size: layout.bodyFontSize - 4))
                    .foregroundColor(.gray)
                Spacer()
                Text("Today")
                    .font(.system(size: layout.bodyFontSize - 4))
                    .foregroundColor(.gray)
            }
        }
    }
    
    @ViewBuilder
    func monthlyOverviewChart(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: layout.spacing) {
            // Month stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: layout.spacing) {
                monthlyStatCard("Total Sessions", value: "\(totalAttempts)", color: .blue, layout: layout)
                monthlyStatCard("Best Streak", value: "\(max(dailyStreak, challengeStreak))", color: .orange, layout: layout)
                monthlyStatCard("Avg Accuracy", value: "\(Int(getOverallAccuracy()))%", color: .green, layout: layout)
                monthlyStatCard("Challenge Wins", value: "\(challengeStreak)", color: .purple, layout: layout)
                monthlyStatCard("Categories", value: "\(categoryStats.count)", color: .cyan, layout: layout)
                monthlyStatCard("Time Saved", value: "⭐", color: .yellow, layout: layout)
            }
        }
    }
    
    @ViewBuilder
    func monthlyStatCard(_ title: String, value: String, color: Color, layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: layout.titleFontSize, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: layout.bodyFontSize - 4))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    func generateTrendData() -> [Double] {
        // Generate sample trend data based on recent performance
        var trend: [Double] = []
        let daysToShow = 7
        
        for i in 0..<daysToShow {
            // Simulate progressive improvement with some variance
            let baseAccuracy = 60.0 + (Double(i) * 5.0)
            let variance = Double.random(in: -10.0...10.0)
            let accuracy = max(20.0, min(100.0, baseAccuracy + variance))
            trend.append(accuracy)
        }
        
        // If we have actual data, use the overall accuracy as the latest point
        if !trend.isEmpty && totalAttempts > 0 {
            trend[trend.count - 1] = getOverallAccuracy()
        }
        
        return trend
    }
    
    func updateAnalyticsData() {
        // Update weekly progress data
        updateWeeklyProgressData()
        
        // Update category performance data
        updateCategoryPerformanceData()
    }
    
    func exportStatsData() {
        // Create PDF
        if let pdfURL = createStatsPDF() {
            statsShareItems = [pdfURL]
            print("📤 Export stats - PDF created and share items set")
            
            // Upload PDF and sync statistics to Firebase for clinician access
            Task {
                do {
                    // Sync patient profile to ensure clinician has latest name/info
                    try await FirebaseManager.shared.savePatientProfile()
                    
                    // Sync category statistics first so clinician has latest data
                    try await FirebaseManager.shared.syncCategoryStatistics(listeningHistory: listeningHistory)
                    
                    // Then upload the PDF
                    let downloadURL = try await FirebaseManager.shared.uploadPDFReport(fileURL: pdfURL)
                    print("✅ Profile, statistics, and PDF uploaded to Firebase: \(downloadURL)")
                } catch {
                    print("❌ Failed to upload to Firebase: \(error)")
                    // Continue with local export even if Firebase upload fails
                }
            }
        }
    }
    
    private func createStatsTextFile(from text: String) -> URL? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = formatter.string(from: Date())
        let fileName = "HearifyStats_\(dateString).txt"
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error creating file: \(error)")
            return nil
        }
    }
    
    private func generateStatsExportText() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: Date())
        
        var exportText = """
    📊 HEARIFY - PROGRESS & STATISTICS REPORT
    ==========================================
    
    Generated: \(dateString)
    
    📈 OVERALL PERFORMANCE
    ----------------------
    Overall Accuracy: \(Int(getOverallAccuracy()))%
    Total Attempts: \(totalAttempts)
    Daily Streak: \(dailyStreak) days
    
    """
        
        // Add category performance with per-pair accuracy
        if !listeningHistory.categoryBreakdown.isEmpty {
            exportText += "\n📝 CATEGORY PERFORMANCE\n"
            exportText += "------------------------\n"
            
            for category in listeningHistory.categoryBreakdown.keys.sorted() {
                guard let stats = listeningHistory.categoryBreakdown[category] else { continue }
                let displayName = getCategoryDisplayName(category)
                
                exportText += "\n\(displayName):"
                exportText += "\n   Overall Accuracy: \(Int(stats.accuracy * 100))%"
                exportText += "\n   Overall Score: \(stats.correctAttempts)/\(stats.totalAttempts)"
                
                // Calculate per-pair accuracy
                let pairStats = calculatePairAccuracy(for: stats)
                
                if !pairStats.isEmpty {
                    // Check if this category contains matched pairs (not just single words/sentences)
                    let hasMatchedPairs = (stats.missedWords + stats.correctWords).contains { entry in
                        entry.firstWord != entry.lastWord
                    }
                    
                    // Use appropriate label based on whether category has matched pairs
                    let breakdownLabel = hasMatchedPairs ? "Matched Pair Breakdown:" : "Item Breakdown:"
                    exportText += "\n   \n   \(breakdownLabel)"
                    for (pairKey, pairData) in pairStats.sorted(by: { $0.key < $1.key }) {
                        let pairAccuracy = pairData.correct > 0 || pairData.total > 0
                        ? Double(pairData.correct) / Double(pairData.total) * 100
                        : 0.0
                        exportText += "\n      • \(pairKey): \(Int(pairAccuracy))% (\(pairData.correct)/\(pairData.total))"
                    }
                }
            }
            exportText += "\n"
        }
        
        // Add listening history
        if !listeningHistory.allWordHistory.isEmpty {
            exportText += "\n\n📚 RECENT LISTENING HISTORY\n"
            exportText += "----------------------------\n"
            
            let recentHistory = listeningHistory.allWordHistory.suffix(100).reversed()
            for (index, entry) in recentHistory.enumerated() {
                let status = entry.wasCorrect ? "✓" : "✗"
                let categoryName = getCategoryDisplayName(entry.category)
                
                // Format item based on whether it's a matched pair or single word/sentence
                let itemText: String
                if entry.firstWord == entry.lastWord {
                    // Single word or sentence - just show the item
                    itemText = entry.firstWord
                } else {
                    // Matched pair - show both words
                    itemText = "\(entry.firstWord) vs \(entry.lastWord)"
                }
                
                exportText += "\n\(index + 1). \(itemText)"
                exportText += "\n   Category: \(categoryName)"
                
                // Show user response if available and incorrect
                if !entry.wasCorrect && !entry.userSaid.isEmpty {
                    exportText += "\n   Your Response: \(entry.userSaid)"
                    exportText += "\n   Result: \(status) INCORRECT"
                } else {
                    exportText += "\n   Result: \(status) \(entry.wasCorrect ? "CORRECT" : "INCORRECT")"
                }
            }
        }
        
        exportText += "\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exportText += "\n📱 Generated by Hearify Auditory Training App"
        exportText += "\n   Improving listening skills through practice"
        
        return exportText
    }
    
    private func createStatsPDF() -> URL? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = formatter.string(from: Date())
        let fileName = "HearifyStats_\(dateString).pdf"
        
        // Use Documents directory for better sharing compatibility
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory")
            return nil
        }
        let pdfURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Create PDF using UIGraphicsPDFRenderer (modern approach)
        let pageWidth: CGFloat = 612 // 8.5 inches
        let pageHeight: CGFloat = 792 // 11 inches
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        do {
            try renderer.writePDF(to: pdfURL) { context in
                context.beginPage()
                
                let margin: CGFloat = 50
                var yPosition: CGFloat = margin
                
                // Title
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
                ]
                let title = "📊 HEARIFY - PROGRESS REPORT"
                let titleSize = title.size(withAttributes: titleAttributes)
                title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
                yPosition += titleSize.height + 20
                
                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let dateText = "Generated: \(dateFormatter.string(from: Date()))"
                let normalAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.darkGray
                ]
                dateText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
                yPosition += 30
                
                // Divider line
                let cgContext = context.cgContext
                cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                cgContext.setLineWidth(1)
                cgContext.move(to: CGPoint(x: margin, y: yPosition))
                cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
                cgContext.strokePath()
                yPosition += 20
                
                // Overall Performance Section
                let sectionAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
                "📈 OVERALL PERFORMANCE".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
                yPosition += 30
                
                let statsAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.black
                ]
                
                "Overall Accuracy: \(Int(getOverallAccuracy()))%".draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: statsAttributes)
                yPosition += 25
                "Total Attempts: \(totalAttempts)".draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: statsAttributes)
                yPosition += 25
                "Daily Streak: \(dailyStreak) days".draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: statsAttributes)
                yPosition += 30
                
                // Category Performance Section
                if !listeningHistory.categoryBreakdown.isEmpty {
                    "📝 CATEGORY PERFORMANCE".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
                    yPosition += 30
                    
                    for category in listeningHistory.categoryBreakdown.keys.sorted() {
                        guard let stats = listeningHistory.categoryBreakdown[category] else { continue }
                        let displayName = getCategoryDisplayName(category)
                        
                        displayName.draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: statsAttributes)
                        yPosition += 20
                        "   Overall Accuracy: \(Int(stats.accuracy * 100))%".draw(at: CGPoint(x: margin + 30, y: yPosition), withAttributes: normalAttributes)
                        yPosition += 18
                        "   Overall Score: \(stats.correctAttempts)/\(stats.totalAttempts)".draw(at: CGPoint(x: margin + 30, y: yPosition), withAttributes: normalAttributes)
                        yPosition += 20
                        
                        // Calculate per-pair accuracy
                        let pairStats = calculatePairAccuracy(for: stats)
                        if !pairStats.isEmpty {
                            // Check if this category contains matched pairs (not just single words/sentences)
                            let hasMatchedPairs = (stats.missedWords + stats.correctWords).contains { entry in
                                entry.firstWord != entry.lastWord
                            }
                            
                            // Use appropriate label based on whether category has matched pairs
                            let breakdownLabel = hasMatchedPairs ? "Matched Pair Breakdown:" : "Item Breakdown:"
                            "   \(breakdownLabel)".draw(at: CGPoint(x: margin + 30, y: yPosition), withAttributes: normalAttributes)
                            yPosition += 18
                            
                            for (pairKey, pairData) in pairStats.sorted(by: { $0.key < $1.key }) {
                                let pairAccuracy = pairData.correct > 0 || pairData.total > 0
                                ? Double(pairData.correct) / Double(pairData.total) * 100
                                : 0.0
                                "      • \(pairKey): \(Int(pairAccuracy))% (\(pairData.correct)/\(pairData.total))".draw(at: CGPoint(x: margin + 40, y: yPosition), withAttributes: normalAttributes)
                                yPosition += 16
                                
                                // Check if we need a new page
                                if yPosition > pageHeight - 100 {
                                    context.beginPage()
                                    yPosition = margin
                                }
                            }
                        }
                        yPosition += 10
                        
                        // Check if we need a new page
                        if yPosition > pageHeight - 100 {
                            context.beginPage()
                            yPosition = margin
                        }
                    }
                }
                
                // Listening History Section
                if !listeningHistory.allWordHistory.isEmpty {
                    if yPosition > pageHeight - 200 {
                        context.beginPage()
                        yPosition = margin
                    }
                    
                    "📚 RECENT LISTENING HISTORY".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
                    yPosition += 30
                    
                    let recentHistory = listeningHistory.allWordHistory.suffix(100).reversed()
                    for (index, entry) in recentHistory.enumerated() {
                        let status = entry.wasCorrect ? "✓" : "✗"
                        let categoryName = getCategoryDisplayName(entry.category)
                        
                        // Format item based on whether it's a matched pair or single word/sentence
                        let itemText: String
                        if entry.firstWord == entry.lastWord {
                            // Single word or sentence - just show the item
                            itemText = entry.firstWord
                        } else {
                            // Matched pair - show both words
                            itemText = "\(entry.firstWord) vs \(entry.lastWord)"
                        }
                        
                        "\(index + 1). \(itemText)".draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: statsAttributes)
                        yPosition += 18
                        "   Category: \(categoryName)".draw(at: CGPoint(x: margin + 30, y: yPosition), withAttributes: normalAttributes)
                        yPosition += 18
                        
                        // Show user response if available and incorrect
                        if !entry.wasCorrect && !entry.userSaid.isEmpty {
                            "   Your Response: \(entry.userSaid)".draw(at: CGPoint(x: margin + 30, y: yPosition), withAttributes: normalAttributes)
                            yPosition += 18
                            "   Result: \(status) INCORRECT".draw(at: CGPoint(x: margin + 30, y: yPosition), withAttributes: normalAttributes)
                        } else {
                            "   Result: \(status) \(entry.wasCorrect ? "CORRECT" : "INCORRECT")".draw(at: CGPoint(x: margin + 30, y: yPosition), withAttributes: normalAttributes)
                        }
                        yPosition += 25
                        
                        // Check if we need a new page
                        if yPosition > pageHeight - 100 {
                            context.beginPage()
                            yPosition = margin
                        }
                    }
                }
                
                // Footer
                yPosition = pageHeight - 60
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                "Generated by Hearify Auditory Training App".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: footerAttributes)
                yPosition += 15
                "Improving listening skills through practice".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: footerAttributes)
            }
            
            // Verify the file was created successfully
            if FileManager.default.fileExists(atPath: pdfURL.path) {
                // Set file attributes to make it readable
                do {
                    let attributes = [FileAttributeKey.posixPermissions: 0o644]
                    try FileManager.default.setAttributes(attributes, ofItemAtPath: pdfURL.path)
                    
                    // Mark for exclusion from iCloud backup
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    var mutableURL = pdfURL
                    try mutableURL.setResourceValues(resourceValues)
                    
                    print("PDF created successfully at: \(pdfURL.path)")
                    return pdfURL
                } catch {
                    print("Error setting file attributes: \(error)")
                    // Still return the URL even if attributes failed
                    return pdfURL
                }
            } else {
                print("PDF file was not created at expected path")
                return nil
            }
        } catch {
            print("Error creating PDF: \(error)")
            return nil
        }
    }
    
    func updateWeeklyProgressData() {
        weeklyProgressData.removeAll()
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // Simulate daily accuracy data
                let accuracy = Double.random(in: 60...95)
                let attempts = Int.random(in: 5...25)
                
                weeklyProgressData.insert(
                    DailyProgressData(date: date, accuracy: accuracy, attempts: attempts),
                    at: 0
                )
            }
        }
    }
    
    func updateCategoryPerformanceData() {
        categoryPerformanceData.removeAll()
        
        let categories = [
            ("Syllables", Color.blue),
            ("Vowels", Color.green),
            ("Consonants", Color.orange),
            ("Phonetics", Color.purple),
            ("Challenges", Color.red)
        ]
        
        for (category, color) in categories {
            let accuracy = getCategoryAccuracy(category: category)
            if accuracy > 0 {
                categoryPerformanceData.append(
                    ChartDataPoint(label: category, value: accuracy, color: color)
                )
            } else {
                // Add placeholder data for categories without attempts
                categoryPerformanceData.append(
                    ChartDataPoint(label: category, value: 0, color: color.opacity(0.3))
                )
            }
        }
    }
    
    // MARK: - AI Analysis Engine (Local Only)
    
    func generateAIAnalysis() {
        isGeneratingAnalysis = true
        
        // Use local analysis only
        let report = performLocalAnalysis()
        currentAIReport = report
        isGeneratingAnalysis = false
        showingAIAnalysis = true
    }
    
    func performLocalAnalysis() -> AIAnalysisReport {
        let report = performAIAnalysis()
        return report
    }
    
    private func performAIAnalysis() -> AIAnalysisReport {
        // Analyze missed words and sentences
        let missedEntries = listeningHistory.allWordHistory.filter { !$0.wasCorrect }
        
        // Separate entries by type
        var wordPairMap: [String: (count: Int, userSaidExamples: [String])] = [:]
        var sentenceMap: [String: (count: Int, userSaidExamples: [String])] = [:]
        var wordMap: [String: (count: Int, userSaidExamples: [String])] = [:]
        var totalMissedSentences = 0
        
        for entry in missedEntries {
            // Determine if this is a sentence (categories contain "sentence" or "Sentence")
            let isSentence = entry.category.lowercased().contains("sentence")
            
            // Determine if this is a matched pair (has both firstWord and lastWord that are different)
            let isMatchedPair = !entry.firstWord.isEmpty && !entry.lastWord.isEmpty &&
            entry.firstWord != entry.lastWord && !isSentence
            
            if isSentence {
                // Sentence handling
                let sentence = entry.firstWord // For sentences, firstWord contains the full sentence
                let key = sentence.lowercased()
                var existing = sentenceMap[key] ?? (count: 0, userSaidExamples: [])
                existing.count += 1
                if !entry.userSaid.isEmpty && existing.userSaidExamples.count < 3 {
                    existing.userSaidExamples.append(entry.userSaid)
                }
                sentenceMap[key] = existing
                totalMissedSentences += 1
            } else if isMatchedPair {
                // Matched pair handling
                let pairKey = "\(entry.firstWord) vs \(entry.lastWord)"
                let key = pairKey.lowercased()
                var existing = wordPairMap[key] ?? (count: 0, userSaidExamples: [])
                existing.count += 1
                if !entry.userSaid.isEmpty && existing.userSaidExamples.count < 3 {
                    existing.userSaidExamples.append(entry.userSaid)
                }
                wordPairMap[key] = existing
            } else {
                // Single word handling
                let word = entry.firstWord.lowercased()
                var existing = wordMap[word] ?? (count: 0, userSaidExamples: [])
                existing.count += 1
                if !entry.userSaid.isEmpty && existing.userSaidExamples.count < 3 {
                    existing.userSaidExamples.append(entry.userSaid)
                }
                wordMap[word] = existing
            }
        }
        
        // Combine all problematic items (excluding sentences from word category display)
        var topProblematicWords: [ProblematicWord] = []
        
        // Add matched pairs
        for (word, data) in wordPairMap.sorted(by: { $0.value.count > $1.value.count }).prefix(5) {
            topProblematicWords.append(ProblematicWord(
                word: word,
                errorCount: data.count,
                contexts: [],
                userSaidExamples: data.userSaidExamples,
                itemType: "matchedPair"
            ))
        }
        
        // Add single words
        for (word, data) in wordMap.sorted(by: { $0.value.count > $1.value.count }).prefix(5) {
            topProblematicWords.append(ProblematicWord(
                word: word,
                errorCount: data.count,
                contexts: [],
                userSaidExamples: data.userSaidExamples,
                itemType: "word"
            ))
        }
        
        // Add sentences separately (with expected vs actual comparison)
        for (sentence, data) in sentenceMap.sorted(by: { $0.value.count > $1.value.count }).prefix(5) {
            topProblematicWords.append(ProblematicWord(
                word: sentence,
                errorCount: data.count,
                contexts: [],
                userSaidExamples: data.userSaidExamples,
                itemType: "sentence"
            ))
        }
        
        // Sort by error count and take top 10
        topProblematicWords = topProblematicWords.sorted { $0.errorCount > $1.errorCount }
        
        // Analyze phonetic patterns
        let phoneticAnalysis = analyzePhoneticPatterns(missedEntries: missedEntries)
        
        // Analyze frequency ranges
        let frequencyAnalysis = analyzeFrequencyRanges(missedEntries: missedEntries)
        
        // Analyze phonetic differences in word pairs
        let phoneticErrors = analyzePhoneticDifferences(missedEntries: missedEntries)
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            missedEntries: missedEntries,
            phoneticAnalysis: phoneticAnalysis,
            frequencyAnalysis: frequencyAnalysis,
            topWords: topProblematicWords
        )
        
        return AIAnalysisReport(
            generatedDate: Date(),
            totalMissedWords: missedEntries.count - totalMissedSentences,
            totalMissedSentences: totalMissedSentences,
            overallAccuracy: getOverallAccuracy() / 100.0,
            recommendations: recommendations,
            frequencyAnalysis: frequencyAnalysis,
            phoneticAnalysis: phoneticAnalysis,
            topProblematicWords: Array(topProblematicWords.prefix(10)),
            phoneticErrors: phoneticErrors,
            aiInsights: nil,  // No AI insights in local analysis
            rawFeatures: nil  // No raw features in local analysis
        )
    }
    
    private func analyzePhoneticDifferences(missedEntries: [WordHistoryEntry]) -> [PhoneticError] {
        var differenceMap: [String: (PhoneticDifference, Int, Date)] = [:]
        
        for entry in missedEntries where !entry.wasCorrect {
            let word1 = entry.firstWord
            let word2 = entry.lastWord
            
            if let difference = analyzePhoneticDifference(word1: word1, word2: word2) {
                let key = difference.id
                if let existing = differenceMap[key] {
                    differenceMap[key] = (existing.0, existing.1 + 1, entry.timestamp)
                } else {
                    differenceMap[key] = (difference, 1, entry.timestamp)
                }
            }
        }
        
        // Convert to PhoneticError array and sort by frequency
        let phoneticErrors = differenceMap.map { key, value in
            PhoneticError(
                difference: value.0,
                missCount: value.1,
                lastMissed: value.2
            )
        }.sorted { $0.missCount > $1.missCount }
        
        return Array(phoneticErrors.prefix(10))  // Top 10 most problematic
    }
    
    private func analyzePhoneticPatterns(missedEntries: [WordHistoryEntry]) -> [PhoneticCategory: Double] {
        var phoneticScores: [PhoneticCategory: (missed: Int, total: Int)] = [:]
        
        for entry in listeningHistory.allWordHistory {
            let phoneticCat = identifyPhoneticCategory(word: entry.firstWord)
            
            if phoneticScores[phoneticCat] == nil {
                phoneticScores[phoneticCat] = (0, 0)
            }
            
            phoneticScores[phoneticCat]!.total += 1
            if !entry.wasCorrect {
                phoneticScores[phoneticCat]!.missed += 1
            }
        }
        
        var analysis: [PhoneticCategory: Double] = [:]
        for (category, counts) in phoneticScores {
            let errorRate = counts.total > 0 ? Double(counts.missed) / Double(counts.total) * 100.0 : 0.0
            analysis[category] = errorRate
        }
        
        return analysis
    }
    
    private func analyzeFrequencyRanges(missedEntries: [WordHistoryEntry]) -> [FrequencyRange: Double] {
        var frequencyScores: [FrequencyRange: (missed: Int, total: Int)] = [:]
        
        for entry in listeningHistory.allWordHistory {
            let freqRange = identifyFrequencyRange(word: entry.firstWord)
            
            if frequencyScores[freqRange] == nil {
                frequencyScores[freqRange] = (0, 0)
            }
            
            frequencyScores[freqRange]!.total += 1
            if !entry.wasCorrect {
                frequencyScores[freqRange]!.missed += 1
            }
        }
        
        var analysis: [FrequencyRange: Double] = [:]
        for (range, counts) in frequencyScores {
            let errorRate = counts.total > 0 ? Double(counts.missed) / Double(counts.total) * 100.0 : 0.0
            analysis[range] = errorRate
        }
        
        return analysis
    }
    
    private func identifyPhoneticCategory(word: String) -> PhoneticCategory {
        let lowercased = word.lowercased()
        
        // Fricatives: s, sh, f, th, v, z
        if lowercased.contains(where: { "sšfθvz".contains($0) }) ||
            lowercased.contains("sh") || lowercased.contains("th") {
            return .fricatives
        }
        
        // Plosives: p, t, k, b, d, g
        if lowercased.contains(where: { "ptkbdg".contains($0) }) {
            return .plosives
        }
        
        // Nasals: m, n, ng
        if lowercased.contains(where: { "mn".contains($0) }) ||
            lowercased.contains("ng") {
            return .nasals
        }
        
        // Liquids: l, r
        if lowercased.contains(where: { "lr".contains($0) }) {
            return .liquids
        }
        
        // Vowels
        if lowercased.contains(where: { "aeiou".contains($0) }) {
            return .vowels
        }
        
        return .consonants
    }
    
    private func identifyFrequencyRange(word: String) -> FrequencyRange {
        let lowercased = word.lowercased()
        
        // High frequency sounds: s, sh, f, th
        if lowercased.contains(where: { "sšf".contains($0) }) ||
            lowercased.contains("sh") || lowercased.contains("th") {
            return .highFrequency
        }
        
        // Very high frequency: certain consonant combinations
        if lowercased.contains("st") || lowercased.contains("sp") || lowercased.contains("sk") {
            return .veryHighFrequency
        }
        
        // Low frequency: vowels and voiced sounds
        if lowercased.contains(where: { "aeiou".contains($0) }) ||
            lowercased.contains(where: { "mn".contains($0) }) {
            return .lowFrequency
        }
        
        return .midFrequency
    }
    
    private func generateRecommendations(
        missedEntries: [WordHistoryEntry],
        phoneticAnalysis: [PhoneticCategory: Double],
        frequencyAnalysis: [FrequencyRange: Double],
        topWords: [ProblematicWord]
    ) -> [AudiologistRecommendation] {
        var recommendations: [AudiologistRecommendation] = []
        
        // Analyze high-frequency hearing
        if let highFreqError = frequencyAnalysis[.highFrequency], highFreqError > 40.0 {
            recommendations.append(AudiologistRecommendation(
                title: "High-Frequency Sound Observation",
                description: "Your results show some challenges with high-frequency sounds (2000-8000 Hz), with about \(Int(highFreqError))% difficulty in this range. When you see your audiologist next, you might want to mention this pattern—they can check if any adjustments to your hearing aid settings might be helpful for sounds like 's', 'sh', 'f', and 'th'. This is just an observation from your practice sessions.",
                priority: .high,
                category: .hearingAidProgramming,
                specificWords: topWords.filter { identifyFrequencyRange(word: $0.word) == .highFrequency }.map { $0.word },
                frequencies: [.highFrequency],
                phoneticTargets: [.fricatives]
            ))
        }
        
        // Analyze fricative difficulties
        if let fricativeError = phoneticAnalysis[.fricatives], fricativeError > 35.0 {
            recommendations.append(AudiologistRecommendation(
                title: "Fricative Sound Practice Idea",
                description: "We noticed fricative sounds (s, sh, f, th) came up as tricky about \(Int(fricativeError))% of the time. If you're interested, you could try some extra practice with minimal pairs that include these sounds—but only if it feels right for you. Some people find starting in quiet helpful before adding noise. Feel free to discuss this pattern with your audiologist if you'd like their input.",
                priority: .high,
                category: .focusedTraining,
                specificWords: topWords.filter { identifyPhoneticCategory(word: $0.word) == .fricatives }.map { $0.word },
                frequencies: [.highFrequency],
                phoneticTargets: [.fricatives]
            ))
        }
        
        // Analyze consonant difficulties
        if let consonantError = phoneticAnalysis[.consonants], consonantError > 30.0 {
            recommendations.append(AudiologistRecommendation(
                title: "Consonant Practice Suggestion",
                description: "Consonant sounds showed some difficulty in your sessions (around \(Int(consonantError))%). If you'd like, you could explore the 'Matched Pairs' and 'Word Recognition' exercises that focus on consonants. Practice whenever it fits your schedule—there's no pressure on timing or duration. Your audiologist can provide guidance on what might work best for your specific situation.",
                priority: .medium,
                category: .focusedTraining,
                specificWords: [],
                frequencies: [.midFrequency, .highFrequency],
                phoneticTargets: [.consonants, .plosives]
            ))
        }
        
        // Environmental recommendations
        if missedEntries.count > 20 {
            let noiseCategories = missedEntries.filter { $0.category.lowercased().contains("noise") }
            if Double(noiseCategories.count) / Double(missedEntries.count) > 0.5 {
                recommendations.append(AudiologistRecommendation(
                    title: "Noisy Environment Observations",
                    description: "We noticed that noisy settings seemed more challenging in your practice. Some users find certain positioning helpful in restaurants (like sitting with their back to walls or in booths), though everyone's different. Your audiologist might have specific suggestions based on your hearing aids, like microphone settings or accessories that could be worth exploring—but only if that interests you.",
                    priority: .medium,
                    category: .environmentalStrategies,
                    specificWords: [],
                    frequencies: [],
                    phoneticTargets: []
                ))
            }
        }
        
        // Specific word patterns
        if !topWords.isEmpty && topWords[0].missCount >= 3 {
            let problematicWords = topWords.prefix(5).map { $0.word }
            recommendations.append(AudiologistRecommendation(
                title: "Words That Came Up Often",
                description: "These words appeared multiple times in your sessions. If you're curious, you could try practicing them using the 'Matched Pairs' selector to focus on just these pairs. Sometimes paying attention to the differences between similar sounds can be interesting. This is completely optional based on your comfort and interest.",
                priority: .low,
                category: .focusedTraining,
                specificWords: problematicWords,
                frequencies: [],
                phoneticTargets: []
            ))
        }
        
        // Medical referral if overall accuracy is very low
        if getOverallAccuracy() < 50.0 {
            recommendations.append(AudiologistRecommendation(
                title: "Audiologist Check-In",
                description: "Your practice results showed some patterns that might be worth mentioning to your audiologist at your next appointment. They can take a look at your current settings and let you know if any adjustments might be helpful. These practice sessions are just one piece of information, and your audiologist will have the full picture of what's best for you.",
                priority: .high,
                category: .medicalReferral,
                specificWords: [],
                frequencies: [],
                phoneticTargets: []
            ))
        }
        
        return recommendations.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }
    
    func resetSessionStats() {
        sessionAttempts = 0
        sessionCorrect = 0
    }
    
    func resetSpeechState() {
        // IMPORTANT: Stop recording first if it's running
        if speechManager.isRecording {
            speechManager.stopRecording()
            print("🛑 Stopped recording during speech state reset")
        }
        
        // Reset speech-related state variables to prevent glitches
        spokenText = ""
        speechManager.recognizedText = ""
        showingFeedback = false
        isAnswerCorrect = false
        wordMatchScore = 0.0
        matchedWords = 0
        totalWords = 0
        waitingForRecordingStart = false // Reset audio callback wait flag
        firstWordDetected = false // Reset word detection flag
        
        // Cancel any pending timeout
        recordingTimeoutTask?.cancel()
        recordingTimeoutTask = nil
        
        print("🔄 Speech state reset - ready for new exercise")
    }
    
    func startRecordingWithTimeout(timeoutSeconds: Double = 20.0, onTimeout: @escaping () -> Void) {
        // Cancel any existing timeout
        recordingTimeoutTask?.cancel()
        
        // Start recording
        speechManager.startRecording()
        print("⏰ Recording started with \(timeoutSeconds)s timeout")
        
        // Create timeout task (no weak self needed for struct)
        let task = DispatchWorkItem {
            if self.speechManager.isRecording && !self.firstWordDetected {
                print("⏰ Recording timeout reached - auto-stopping")
                self.speechManager.stopRecording()
                onTimeout()
            }
        }
        
        recordingTimeoutTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutSeconds, execute: task)
    }
    
    func showResetConfirmation() {
        // For now, just reset immediately. In a full app, this would show an alert
        resetAllProgress()
    }
    
    func resetAllProgress() {
        totalAttempts = 0
        correctAttempts = 0
        sessionAttempts = 0
        sessionCorrect = 0
        dailyStreak = 0
        categoryStats = [:]
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "totalAttempts")
        UserDefaults.standard.removeObject(forKey: "correctAttempts")
        UserDefaults.standard.removeObject(forKey: "dailyStreak")
        UserDefaults.standard.removeObject(forKey: "lastPlayDate")
        UserDefaults.standard.removeObject(forKey: "categoryStats")
    }
    
    func clearAllStatsData() {
        // Clear local stats
        resetAllProgress()
        
        // Clear listening history
        listeningHistory = ListeningHistory()
        UserDefaults.standard.removeObject(forKey: "listeningHistory")
        
        // Clear shared managers
        progressTrackingManager.clearAllSessions()
        analyticsManager.clearAllData()
        ProgressManager.shared.resetProgress()
        
        print("🗑️ All stats data cleared from statistics page")
    }
    
    @ViewBuilder
    func dailyChallengeScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: AppTheme.spacingL) {
                if let challenge = currentChallenge {
                    challengeHeaderSection(challenge: challenge, layout: layout)
                    challengeDetailsSection(challenge: challenge, layout: layout)
                    challengeProgressSection(challenge: challenge, layout: layout)
                    challengeStreakSection(layout: layout)
                    challengeActionSection(challenge: challenge, layout: layout)
                } else {
                    noChallengeAvailableSection(layout: layout)
                }
                
                challengeNavigationSection(layout: layout)
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, AppTheme.spacingL)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundPrimary.ignoresSafeArea())
    }
    
    @ViewBuilder
    func challengeHeaderSection(challenge: DailyChallenge, layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(
            backgroundColor: getChallengeColor(challenge.type).opacity(0.1)
        ) {
            VStack(spacing: AppTheme.spacingL) {
                HStack {
                    Image(systemName: getChallengeIcon(challenge.type))
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(getChallengeColor(challenge.type))
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Daily Challenge")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text(challenge.title)
                            .font(.system(size: layout.titleFontSize * 1.1, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    if challengeCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.success)
                    }
                }
                
                Text(challenge.description)
                    .font(.system(size: layout.bodyFontSize))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    @ViewBuilder
    func challengeDetailsSection(challenge: DailyChallenge, layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(spacing: AppTheme.spacingL) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppTheme.info)
                    
                    Text("Challenge Details")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                }
                
                VStack(spacing: AppTheme.spacingM) {
                    modernChallengeDetailRow("Target", value: "\(Int(challenge.targetAccuracy ?? 0))% accuracy", icon: "target", color: AppTheme.success, layout: layout)
                    
                    Divider().background(AppTheme.textTertiary)
                    
                    modernChallengeDetailRow("Words", value: "\(challenge.wordCount) words", icon: "textformat.abc", color: AppTheme.primaryBlue, layout: layout)
                    
                    if let timeLimit = challenge.timeLimit {
                        Divider().background(AppTheme.textTertiary)
                        modernChallengeDetailRow("Time Limit", value: formatTime(timeLimit), icon: "clock.fill", color: AppTheme.warning, layout: layout)
                    }
                    
                    Divider().background(AppTheme.textTertiary)
                    
                    modernChallengeDetailRow("Difficulty", value: challenge.difficulty.rawValue, icon: "slider.horizontal.3", color: AppTheme.accentPurple, layout: layout)
                    
                    Divider().background(AppTheme.textTertiary)
                    
                    modernChallengeDetailRow("Bonus Points", value: "\(challenge.bonusPoints) pts", icon: "star.fill", color: AppTheme.accentOrange, layout: layout)
                }
            }
        }
    }
    
    @ViewBuilder
    func challengeProgressSection(challenge: DailyChallenge, layout: ResponsiveLayoutHelper) -> some View {
        if challengeAttempts > 0 {
            challengeProgressCard(challenge: challenge, layout: layout)
        }
    }
    
    private var currentAccuracy: Double {
        challengeAttempts > 0 ? Double(challengeCorrect) / Double(challengeAttempts) * 100 : 0
    }
    
    @ViewBuilder
    func challengeProgressCard(challenge: DailyChallenge, layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(
            backgroundColor: AppTheme.primaryBlue.opacity(0.05)
        ) {
            VStack(spacing: AppTheme.spacingL) {
                challengeProgressHeader(layout: layout)
                challengeProgressStats(challenge: challenge, accuracy: currentAccuracy, layout: layout)
            }
        }
    }
    
    @ViewBuilder
    func challengeProgressHeader(layout: ResponsiveLayoutHelper) -> some View {
        HStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppTheme.primaryBlue)
            
            Text("Current Progress")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func challengeProgressStats(challenge: DailyChallenge, accuracy: Double, layout: ResponsiveLayoutHelper) -> some View {
        HStack(spacing: AppTheme.spacingL) {
            modernStatCard(
                title: "Attempts",
                value: "\(challengeAttempts)",
                icon: "arrow.clockwise",
                color: AppTheme.primaryBlue,
                layout: layout
            )
            
            modernStatCard(
                title: "Correct",
                value: "\(challengeCorrect)",
                icon: "checkmark.circle.fill",
                color: AppTheme.success,
                layout: layout
            )
            
            modernStatCard(
                title: "Accuracy",
                value: "\(Int(accuracy))%",
                icon: "target",
                color: accuracy >= (challenge.targetAccuracy ?? 0) ? AppTheme.success : AppTheme.warning,
                layout: layout
            )
        }
    }
    
    @ViewBuilder
    func challengeStreakSection(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(
            backgroundColor: AppTheme.accentOrange.opacity(0.1)
        ) {
            HStack(spacing: AppTheme.spacingL) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(AppTheme.accentOrange)
                
                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                    Text("\(challengeStreak) day streak")
                        .font(.system(size: layout.titleFontSize, weight: .bold))
                        .foregroundColor(AppTheme.accentOrange)
                    
                    Text("Keep completing daily challenges to build your streak!")
                        .font(.system(size: layout.bodyFontSize - 2))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func challengeActionSection(challenge: DailyChallenge, layout: ResponsiveLayoutHelper) -> some View {
        if challengeCompleted {
            challengeCompletedCard(layout: layout)
        } else {
            challengeStartButton(challenge: challenge, layout: layout)
        }
    }
    
    @ViewBuilder
    func challengeCompletedCard(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(
            backgroundColor: AppTheme.success.opacity(0.1)
        ) {
            VStack(spacing: AppTheme.spacingL) {
                challengeCompletedHeader(layout: layout)
                challengeCompletedButton(layout: layout)
            }
        }
    }
    
    @ViewBuilder
    func challengeCompletedHeader(layout: ResponsiveLayoutHelper) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.success)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text("Challenge Completed!")
                    .font(.system(size: layout.titleFontSize, weight: .bold))
                    .foregroundColor(AppTheme.success)
                
                Text("Great job! Come back tomorrow for a new challenge.")
                    .font(.system(size: layout.bodyFontSize - 2))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func challengeCompletedButton(layout: ResponsiveLayoutHelper) -> some View {
        ResponsiveButton(
            text: "Return Home",
            action: {
                screen = .homescreen
                if buttonconfirm {
                    audioManager.playAudio("buttonpress")
                }
            },
            layout: layout,
            style: .success,
            icon: "house.fill"
        )
    }
    
    @ViewBuilder
    func challengeStartButton(challenge: DailyChallenge, layout: ResponsiveLayoutHelper) -> some View {
        ResponsiveButton(
            text: challengeAttempts > 0 ? "Continue Challenge" : "Start Challenge",
            action: {
                startDailyChallenge(challenge)
            },
            layout: layout,
            style: .primary,
            icon: challengeAttempts > 0 ? "play.fill" : "flag.fill"
        )
    }
    
    @ViewBuilder
    func noChallengeAvailableSection(layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(padding: AppTheme.spacingXL) {
            VStack(spacing: AppTheme.spacingXL) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                
                VStack(spacing: AppTheme.spacingM) {
                    Text("No Challenge Available")
                        .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Check back daily for new challenges!")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    @ViewBuilder
    func challengeNavigationSection(layout: ResponsiveLayoutHelper) -> some View {
        ResponsiveButton(
            text: "Go Back",
            action: {
                screen = .homescreen
                if buttonconfirm {
                    audioManager.playAudio("buttonpress")
                }
            },
            layout: layout,
            style: .secondary,
            icon: "arrow.left"
        )
    }
    
    // MARK: - Daily Challenge Helper Views
    @ViewBuilder
    func modernChallengeDetailRow(
        _ title: String,
        value: String,
        icon: String,
        color: Color,
        layout: ResponsiveLayoutHelper
    ) -> some View {
        HStack(spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: layout.bodyFontSize, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.vertical, AppTheme.spacingXS)
    }
    
    @ViewBuilder
    func challengeDetailRow(_ label: String, value: String, layout: ResponsiveLayoutHelper) -> some View {
        HStack {
            Text(label)
                .font(.system(size: layout.bodyFontSize))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: layout.bodyFontSize, weight: .medium))
                .foregroundColor(.primary)
        }
    }
    
    func getChallengeIcon(_ type: ChallengeType) -> String {
        switch type {
        case .speedChallenge: return "bolt.fill"
        case .accuracyChallenge: return "target"
        case .enduranceChallenge: return "figure.walk"
        case .mixedChallenge: return "shuffle"
        }
    }
    
    func getChallengeColor(_ type: ChallengeType) -> Color {
        switch type {
        case .speedChallenge: return .yellow
        case .accuracyChallenge: return .green
        case .enduranceChallenge: return .blue
        case .mixedChallenge: return .purple
        }
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
    
    func loadDailyChallenge() {
        let today = Date()
        let calendar = Calendar.current
        
        // Check if we already have today's challenge
        if let lastChallengeDate = UserDefaults.standard.object(forKey: "lastChallengeDate") as? Date,
           calendar.isDate(lastChallengeDate, inSameDayAs: today) {
            // Load existing challenge data
            loadChallengeProgress()
        } else {
            // Generate new challenge for today
            currentChallenge = DailyChallenge.generateDailyChallenge()
            challengeAttempts = 0
            challengeCorrect = 0
            challengeCompleted = false
            lastChallengeDate = today
            
            // Save new challenge
            saveChallengeProgress()
        }
    }
    
    func startDailyChallenge(_ challenge: DailyChallenge) {
        // Set up word list for challenge category
        WordList.removeAll()
        
        switch challenge.category {
        case "cm":
            convertCSVIntoArray(CSV: "Consonants")
            mainCategory = "consonants"
        case "cv":
            convertCSVIntoArray(CSV: "Consonants")
            mainCategory = "consonants"
        case "cp":
            convertCSVIntoArray(CSV: "Consonants")
            mainCategory = "consonants"
        case "nv":
            convertCSVIntoArray(CSV: "Vowels")
            mainCategory = "nv"
        case "wv":
            convertCSVIntoArray(CSV: "Vowels")
            mainCategory = "wv"
        default:
            convertCSVIntoArray(CSV: "Consonants")
            mainCategory = "consonants"
        }
        
        topCategory = "DailyChallenge"
        sectiontitle.text = challenge.title
        randomize()
        screen = .screen1
        
        // Apply challenge difficulty settings
        applyChallengeDifficulty(challenge.difficulty)
        
        if buttonconfirm {
            audioManager.playAudio("buttonpress")
        }
        
        // Start background noise if enabled
        startBackgroundNoiseIfEnabled()
    }
    
    func applyChallengeDifficulty(_ difficulty: DifficultyLevel) {
        switch difficulty {
        case .easy, .easy:
            playbackSpeed = 0.8 // Slower speed
        case .medium, .medium:
            playbackSpeed = 1.0 // Normal speed
        case .hard, .hard:
            playbackSpeed = 1.2 // Faster speed
        case .hard:
            playbackSpeed = 1.3 // Expert speed
        }
        
        // Apply audio settings
        updateAudioSettings()
        
        // Note: backgroundNoiseEnabled is a separate user preference
        // and should not be automatically changed by difficulty level
    }
    
    func updateChallengeProgress(correct: Bool) {
        guard currentChallenge != nil else { return }
        
        challengeAttempts += 1
        if correct {
            challengeCorrect += 1
        }
        
        // Check if challenge is completed
        if let challenge = currentChallenge {
            let accuracy = Double(challengeCorrect) / Double(challengeAttempts) * 100
            
            if challengeAttempts >= challenge.wordCount {
                // Challenge completed - check if target met
                if accuracy >= (challenge.targetAccuracy ?? 0) {
                    challengeCompleted = true
                    updateChallengeStreak()
                    
                    // Award bonus points (add to total score if implemented)
                    print("Challenge completed! Awarded \(challenge.bonusPoints) bonus points")
                }
            }
        }
        
        saveChallengeProgress()
    }
    
    func updateChallengeStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(lastChallengeDate, inSameDayAs: today) {
            // Same day, maintain streak
            return
        } else if calendar.isDate(lastChallengeDate, equalTo: calendar.date(byAdding: .day, value: -1, to: today) ?? today, toGranularity: .day) {
            // Yesterday, increment streak
            challengeStreak += 1
        } else {
            // Break in streak, reset to 1
            challengeStreak = 1
        }
        
        lastChallengeDate = today
    }
    
    func saveChallengeProgress() {
        UserDefaults.standard.set(challengeAttempts, forKey: "challengeAttempts")
        UserDefaults.standard.set(challengeCorrect, forKey: "challengeCorrect")
        UserDefaults.standard.set(challengeCompleted, forKey: "challengeCompleted")
        UserDefaults.standard.set(challengeStreak, forKey: "challengeStreak")
        UserDefaults.standard.set(lastChallengeDate, forKey: "lastChallengeDate")
        
        // Save current challenge data
        if let challenge = currentChallenge,
           let challengeData = try? JSONEncoder().encode(challenge) {
            UserDefaults.standard.set(challengeData, forKey: "currentChallenge")
        }
    }
    
    func loadChallengeProgress() {
        challengeAttempts = UserDefaults.standard.integer(forKey: "challengeAttempts")
        challengeCorrect = UserDefaults.standard.integer(forKey: "challengeCorrect")
        challengeCompleted = UserDefaults.standard.bool(forKey: "challengeCompleted")
        challengeStreak = UserDefaults.standard.integer(forKey: "challengeStreak")
        
        if let savedDate = UserDefaults.standard.object(forKey: "lastChallengeDate") as? Date {
            lastChallengeDate = savedDate
        }
        
        // Load current challenge
        if let challengeData = UserDefaults.standard.data(forKey: "currentChallenge"),
           let challenge = try? JSONDecoder().decode(DailyChallenge.self, from: challengeData) {
            currentChallenge = challenge
        }
    }
    
    func startBackgroundNoiseIfEnabled() {
        if backgroundNoiseEnabled {
            backgroundNoise.startBackgroundNoise(
                type: backgroundNoiseType,
                volume: backgroundNoiseVolume
            )
        }
    }
    
    func stopBackgroundNoise() {
        backgroundNoise.stopBackgroundNoise()
    }
    
    func updateBackgroundNoiseSettings() {
        if backgroundNoiseEnabled {
            backgroundNoise.updateBackgroundVolume(backgroundNoiseVolume)
            backgroundNoise.startBackgroundNoise(
                type: backgroundNoiseType,
                volume: backgroundNoiseVolume
            )
        } else {
            backgroundNoise.stopBackgroundNoise()
        }
    }
    
    func updateAudioSettings() {
        // Apply current settings to audio player
        audioManager.setVolume(volumeLevel)
        audioManager.setPlaybackSpeed(Float(playbackSpeed))
    }
    
    func testAudioWithCurrentSettings() {
        // Apply settings to test audio
        updateAudioSettings()
        
        audioManager.playAudio("buttonpress") { success in
            if success {
                print("Audio test successful with volume: \(self.volumeLevel), speed: \(self.playbackSpeed)")
            } else {
                print("Audio test failed")
            }
        }
    }
    
    // Helper functions
    func setupInitialData() {
        // FORCE background noise OFF on app start
        backgroundNoiseEnabled = false
        UserDefaults.standard.set(false, forKey: "backgroundNoiseEnabled")
        backgroundNoise.stopBackgroundNoise()
        
        // Load saved settings
        loadSettings()
        
        // FORCE background noise OFF again after loading settings
        backgroundNoiseEnabled = false
        UserDefaults.standard.set(false, forKey: "backgroundNoiseEnabled")
        backgroundNoise.stopBackgroundNoise()
        
        // Load progress stats
        loadProgressStats()
        
        // Load challenge progress
        loadChallengeProgress()
        
        // Apply audio settings to player
        updateAudioSettings()
        
        // Check if this is the first app launch
        checkFirstLaunch()
        
        // Initialize app data if needed
        print("App initialized with settings, progress, and challenges loaded")
        print("Background noise forced OFF")
    }
    
    func checkFirstLaunch() {
        isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if isFirstLaunch {
            // Skip onboarding - always start at begin screen
            // Users can access tutorial from the main menu if needed
            
            // Set default settings for first launch
            backgroundNoiseEnabled = false
            UserDefaults.standard.set(false, forKey: "backgroundNoiseEnabled")
            
            // Mark as launched so we don't check again
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        isFirstLaunch = false
    }
    
    func updateProgressStats(correct: Bool, category: String) {
        // Update session stats
        sessionAttempts += 1
        if correct {
            sessionCorrect += 1
        }
        
        // Update total stats
        totalAttempts += 1
        if correct {
            correctAttempts += 1
        }
        
        // Convert category code to display name
        let displayCategory = getCategoryDisplayName(category)
        
        // Update category stats
        if categoryStats[displayCategory] == nil {
            categoryStats[displayCategory] = ["attempts": 0, "correct": 0]
        }
        categoryStats[displayCategory]!["attempts"]! += 1
        if correct {
            categoryStats[displayCategory]!["correct"]! += 1
        }
        
        // Update daily streak
        updateDailyStreak()
        
        // Save progress
        saveProgressStats()
    }
    
    func updateDailyStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(lastPlayDate, inSameDayAs: today) {
            // Same day, keep current streak
            return
        } else if calendar.isDate(lastPlayDate, equalTo: calendar.date(byAdding: .day, value: -1, to: today) ?? today, toGranularity: .day) {
            // Yesterday, increment streak
            dailyStreak += 1
        } else {
            // Break in streak, reset to 1
            dailyStreak = 1
        }
        
        lastPlayDate = today
    }
    
    func trackWordHistory(word: Word, wasCorrect: Bool, category: String, userSaid: String = "") {
        // Convert category code to display name
        let displayCategory = getCategoryDisplayName(category)
        
        let entry = WordHistoryEntry(
            firstWord: word.firstWord,
            lastWord: word.lastWord,
            userSaid: userSaid,
            category: displayCategory,
            wasCorrect: wasCorrect
        )
        
        listeningHistory.allWordHistory.append(entry)
        listeningHistory.totalWordsAttempted += 1
        
        // Update category breakdown
        if listeningHistory.categoryBreakdown[displayCategory] == nil {
            listeningHistory.categoryBreakdown[displayCategory] = CategoryStats(
                categoryName: displayCategory,
                totalAttempts: 0,
                correctAttempts: 0,
                missedWords: [],
                lastPracticed: Date()
            )
        }
        
        listeningHistory.categoryBreakdown[displayCategory]!.totalAttempts += 1
        listeningHistory.categoryBreakdown[displayCategory]!.lastPracticed = Date()
        
        if wasCorrect {
            listeningHistory.categoryBreakdown[displayCategory]!.correctAttempts += 1
            listeningHistory.categoryBreakdown[displayCategory]!.correctWords.append(entry)  // Track correct words too
        } else {
            listeningHistory.categoryBreakdown[displayCategory]!.missedWords.append(entry)
        }
        
        // Update overall accuracy
        let totalCorrect = listeningHistory.categoryBreakdown.values.reduce(0) { $0 + $1.correctAttempts }
        listeningHistory.overallAccuracy = Double(totalCorrect) / Double(listeningHistory.totalWordsAttempted)
        
        // Save to UserDefaults
        saveListeningHistory()
    }
    
    func trackTrainingCategoryHistory(question: String, correctAnswer: String, wasCorrect: Bool, category: String, userSaid: String = "") {
        // Convert category code to display name
        let displayCategory = getCategoryDisplayName(category)
        
        let entry = WordHistoryEntry(
            firstWord: question,
            lastWord: correctAnswer,
            userSaid: userSaid,
            category: displayCategory,
            wasCorrect: wasCorrect
        )
        
        listeningHistory.allWordHistory.append(entry)
        listeningHistory.totalWordsAttempted += 1
        
        // Update category breakdown
        if listeningHistory.categoryBreakdown[displayCategory] == nil {
            listeningHistory.categoryBreakdown[displayCategory] = CategoryStats(
                categoryName: displayCategory,
                totalAttempts: 0,
                correctAttempts: 0,
                missedWords: [],
                lastPracticed: Date()
            )
        }
        
        listeningHistory.categoryBreakdown[displayCategory]!.totalAttempts += 1
        listeningHistory.categoryBreakdown[displayCategory]!.lastPracticed = Date()
        
        if wasCorrect {
            listeningHistory.categoryBreakdown[displayCategory]!.correctAttempts += 1
            listeningHistory.categoryBreakdown[displayCategory]!.correctWords.append(entry)  // Track correct words too
        } else {
            listeningHistory.categoryBreakdown[displayCategory]!.missedWords.append(entry)
        }
        
        // Update overall accuracy
        let totalCorrect = listeningHistory.categoryBreakdown.values.reduce(0) { $0 + $1.correctAttempts }
        listeningHistory.overallAccuracy = Double(totalCorrect) / Double(listeningHistory.totalWordsAttempted)
        
        // Save to UserDefaults
        saveListeningHistory()
    }
    
    func saveListeningHistory() {
        if let encoded = try? JSONEncoder().encode(listeningHistory) {
            UserDefaults.standard.set(encoded, forKey: "listeningHistory")
        }
    }
    
    func loadListeningHistory() {
        if let data = UserDefaults.standard.data(forKey: "listeningHistory"),
           let decoded = try? JSONDecoder().decode(ListeningHistory.self, from: data) {
            listeningHistory = decoded
        }
    }
    
    func saveProgressStats() {
        UserDefaults.standard.set(totalAttempts, forKey: "totalAttempts")
        UserDefaults.standard.set(correctAttempts, forKey: "correctAttempts")
        UserDefaults.standard.set(dailyStreak, forKey: "dailyStreak")
        UserDefaults.standard.set(lastPlayDate, forKey: "lastPlayDate")
        
        // Save category stats as JSON
        if let data = try? JSONSerialization.data(withJSONObject: categoryStats) {
            UserDefaults.standard.set(data, forKey: "categoryStats")
        }
    }
    
    func loadProgressStats() {
        totalAttempts = UserDefaults.standard.integer(forKey: "totalAttempts")
        correctAttempts = UserDefaults.standard.integer(forKey: "correctAttempts")
        dailyStreak = UserDefaults.standard.integer(forKey: "dailyStreak")
        
        if let savedDate = UserDefaults.standard.object(forKey: "lastPlayDate") as? Date {
            lastPlayDate = savedDate
        }
        
        // Load category stats
        if let data = UserDefaults.standard.data(forKey: "categoryStats"),
           let stats = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Int]] {
            categoryStats = stats
        }
        
        // Validate streak on app load - reset if last activity was more than 1 day ago
        validateStreakOnLoad()
    }
    
    func validateStreakOnLoad() {
        let calendar = Calendar.current
        let today = Date()
        
        // Get days since last activity
        let daysSinceActivity = calendar.dateComponents([.day], from: lastPlayDate, to: today).day ?? 0
        
        // If more than 1 day has passed since last activity, reset streak
        if daysSinceActivity > 1 {
            print("🔥 Streak reset: \(daysSinceActivity) days since last activity")
            dailyStreak = 0
            saveProgressStats()
        } else if daysSinceActivity == 1 {
            // If exactly 1 day, that's fine - streak continues
            print("✅ Streak maintained: last activity was yesterday")
        } else {
            // Same day, streak continues
            print("✅ Streak continues: active today")
        }
    }
    
    func getOverallAccuracy() -> Double {
        guard totalAttempts > 0 else { return 0.0 }
        return Double(correctAttempts) / Double(totalAttempts) * 100
    }
    
    func getSessionAccuracy() -> Double {
        guard sessionAttempts > 0 else { return 0.0 }
        return Double(sessionCorrect) / Double(sessionAttempts) * 100
    }
    
    func getCategoryAccuracy(category: String) -> Double {
        guard let stats = categoryStats[category],
              let attempts = stats["attempts"],
              let correct = stats["correct"],
              attempts > 0 else { return 0.0 }
        return Double(correct) / Double(attempts) * 100
    }
    
    // Helper function to calculate accuracy for each matched pair within a category
    func calculatePairAccuracy(for stats: CategoryStats) -> [String: (correct: Int, total: Int)] {
        var pairStats: [String: (correct: Int, total: Int)] = [:]
        
        // Combine all words (missed and correct) to get full picture
        let allWords = stats.missedWords + stats.correctWords
        
        for entry in allWords {
            // Create pair key based on whether it's a matched pair or single word
            let pairKey: String
            if entry.firstWord == entry.lastWord {
                // Single word or sentence - use as-is
                pairKey = entry.firstWord
            } else {
                // Matched pair - create consistent key
                pairKey = "\(entry.firstWord) vs \(entry.lastWord)"
            }
            
            // Initialize if needed
            if pairStats[pairKey] == nil {
                pairStats[pairKey] = (correct: 0, total: 0)
            }
            
            // Update stats
            pairStats[pairKey]?.total += 1
            if entry.wasCorrect {
                pairStats[pairKey]?.correct += 1
            }
        }
        
        return pairStats
    }
    
    func addCurrentWordToCustomList() {
        guard currentWordLocation >= 0 && currentWordLocation < tempWordList.count else {
            print("Error: Invalid currentWordLocation for adding to custom list")
            return
        }
        
        let currentWord = tempWordList[currentWordLocation]
        
        // Check if word already exists in WrongWordList
        if !WrongWordList.contains(where: { $0.firstWord == currentWord.firstWord && $0.lastWord == currentWord.lastWord }) {
            WrongWordList.append(currentWord)
            
            // Save to UserDefaults
            jsonlistobject.jsonlist = WrongWordList
            UserDefaults.standard.setCodableObject(jsonlistobject, forKey: key)
            
            // Set up confirmation dialog
            addedWordPair = "'\(currentWord.firstWord)' vs '\(currentWord.lastWord)'"
            showingWordAddedAlert = true
            
            print("Added word pair '\(currentWord.firstWord)' vs '\(currentWord.lastWord)' to practice list")
            
            // Play feedback sound
            if buttonconfirm {
                audioManager.playAudio("buttonpress")
            }
        } else {
            // Word already exists - show different dialog
            addedWordPair = "'\(currentWord.firstWord)' vs '\(currentWord.lastWord)'"
            alerttext.text = "\(addedWordPair) is already in your practice list!"
            showingAlert = true
        }
    }
    
    func removeWordFromCustomList(at index: Int) {
        guard index >= 0 && index < WrongWordList.count else {
            print("Error: Invalid index for removing word from custom list")
            return
        }
        
        let removedWord = WrongWordList[index]
        WrongWordList.remove(at: index)
        
        // Save to UserDefaults
        jsonlistobject.jsonlist = WrongWordList
        UserDefaults.standard.setCodableObject(jsonlistobject, forKey: key)
        
        print("Removed word pair '\(removedWord.firstWord)' vs '\(removedWord.lastWord)' from practice list")
        
        // Play feedback sound
        if buttonconfirm {
            audioManager.playAudio("buttonpress")
        }
    }
    
    func clearAllWordsFromCustomList() {
        WrongWordList.removeAll()
        
        // Save to UserDefaults
        jsonlistobject.jsonlist = WrongWordList
        UserDefaults.standard.setCodableObject(jsonlistobject, forKey: key)
        
        print("Cleared all words from practice list")
        
        // Play feedback sound
        if buttonconfirm {
            audioManager.playAudio("buttonpress")
        }
    }
    
    func exportWordList() {
        if WrongWordList.isEmpty {
            print("No words to export")
            return
        }
        
        var exportText = "My Practice List - \(WrongWordList.count) words\n\n"
        
        for (index, word) in WrongWordList.enumerated() {
            // Format item based on whether it's a matched pair or single word
            let itemText: String
            if word.firstWord == word.lastWord {
                // Single word - just show the word
                itemText = word.firstWord
            } else {
                // Matched pair - show both words
                itemText = "\(word.firstWord) vs \(word.lastWord)"
            }
            exportText += "\(index + 1). \(itemText) (Category: \(word.category))\n"
        }
        
        // For now, just print to console. In a full app, this could export to Files app or share sheet
        print("Export content:\n\(exportText)")
        
        // Play feedback sound
        if buttonconfirm {
            audioManager.playAudio("buttonpress")
        }
    }
    
    func testAudioSettings() {
        // Test current audio settings with a sample word
        audioManager.setVolume(volumeLevel)
        
        // Apply playback speed (would need enhanced audio player for this)
        audioManager.playAudio("buttonpress") { success in
            if success {
                print("Audio test successful with volume: \(volumeLevel), speed: \(playbackSpeed)")
            } else {
                print("Audio test failed")
            }
        }
    }
    
    func resetSettingsToDefaults() {
        // WIPE ALL USER DATA - Complete reset
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            print("🗑️ All user data wiped!")
        }
        
        // Reset to default values
        playbackSpeed = 1.0
        volumeLevel = 1.0
        backgroundNoiseEnabled = false
        backgroundNoiseType = .cafe
        backgroundNoiseVolume = 0.7  // Clinical standard: ~0-5 dB SNR
        difficultyLevel = .medium
        showProgressAfterEachWord = true
        buttonconfirm = true
        
        // Reset voice to default
        voiceSettings.selectedVoice = .male
        
        // Save defaults
        saveSettings()
        
        print("✅ Settings reset to defaults - Speed now tied to difficulty!")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(playbackSpeed, forKey: "playbackSpeed")
        UserDefaults.standard.set(volumeLevel, forKey: "volumeLevel")
        UserDefaults.standard.set(backgroundNoiseEnabled, forKey: "backgroundNoiseEnabled")
        UserDefaults.standard.set(backgroundNoiseType.rawValue, forKey: "backgroundNoiseType")
        UserDefaults.standard.set(backgroundNoiseVolume, forKey: "backgroundNoiseVolume")
        UserDefaults.standard.set(difficultyLevel.rawValue, forKey: "difficultyLevel")
        UserDefaults.standard.set(showProgressAfterEachWord, forKey: "showProgressAfterEachWord")
        UserDefaults.standard.set(buttonconfirm, forKey: key2)
    }
    
    // MARK: - New Training Category Handlers
    
    func handleTrainingCategorySelection(_ category: TrainingCategory) {
        // COMPLETE RESET - clean slate every time
        currentTrainingCategory = category
        currentQuestionIndex = 0
        showingAnswer = false
        userAnswer = ""
        selectedChoices = []
        showingFeedback = false
        isAnswerCorrect = false
        
        print("🎯 Training Category Selected: \(category.rawValue)")
        
        // Initialize scoring system
        initializeTestSession(for: category)
        
        switch category {
        case .matchedPairs:
            // Use existing auditory hierarchy system
            finaldisable = false
            screen = .screen3
            print("📍 Navigating to: .screen3 (Matched Pairs/Auditory Hierarchy)")
        case .wordRecognition:
            // COMPLETE RESET for word recognition
            showWordCountPicker = true
            currentDemoWords = []
            currentQuestionIndex = 0
            selectedChoices = []
            showingFeedback = false
            userAnswer = ""
            isAnswerCorrect = false
            usedWords.removeAll() // Clear the exclusion list
            isCustomPracticeMode = false // Not custom practice
            screen = .wordRecognitionScreen
            print("📍 Navigating to: .wordRecognitionScreen (Word Recognition)")
        case .sentenceComprehension:
            // COMPLETE RESET for sentence comprehension
            showSentenceCountPicker = true
            currentDemoSentences = []
            currentQuestionIndex = 0
            showingFeedback = false
            userAnswer = ""
            isAnswerCorrect = false
            usedSentences.removeAll() // Clear the exclusion list
            isCustomPracticeMode = false // Not custom practice
            screen = .sentenceComprehensionScreen
        case .sentencesInNoise:
            // COMPLETE RESET for sentences in noise
            showSentenceCountPicker = true
            currentDemoSentences = []
            currentQuestionIndex = 0
            showingFeedback = false
            userAnswer = ""
            isAnswerCorrect = false
            usedSentences.removeAll() // Clear the exclusion list
            screen = .sentencesInNoiseScreen
        case .diagnosticTest:
            // Show diagnostic selection screen
            showDiagnosticSelection = true
            currentDiagnosticItems = []
            currentQuestionIndex = 0
            showingFeedback = false
            userAnswer = ""
            isAnswerCorrect = false
            screen = .diagnosticTestScreen
        case .aiAnalysis:
            // Don't auto-generate - let user click Generate button with toggle option
            screen = .aiAnalysisScreen
        case .customPractice:
            // Navigate to custom practice screen
            currentQuestionIndex = 0
            showingFeedback = false
            userAnswer = ""
            isAnswerCorrect = false
            screen = .customPracticeScreen
            print("📍 Navigating to: .customPracticeScreen (Custom Practice)")
        }
    }
    
    func initializeTestSession(for category: TrainingCategory) {
        testResults = []
        currentScore = 0
        testStartTime = Date()
        testCompletionTime = nil
        questionStartTime = Date()
        currentTestSummary = nil
        
        switch category {
        case .wordRecognition:
            totalQuestions = 100  // Based on WordRecognitionData.csv
        case .sentenceComprehension:
            totalQuestions = 20  // Based on SentenceComprehensionData.csv
        case .sentencesInNoise:
            totalQuestions = 20  // Based on SentencesInNoiseData.csv
        case .diagnosticTest:
            totalQuestions = DiagnosticItem.diagnosticItems.count
        default:
            totalQuestions = 0
        }
    }
    
    func startDiagnosticTest() {
        var diagnosticItems: [DiagnosticItem] = []
        
        // Add word recognition items
        if diagnosticWordCount > 0 {
            let words = DemoWord.loadFromCSV(fileName: "WordRecognitionData", count: diagnosticWordCount)
            for word in words {
                let wordItem = DiagnosticItem(
                    content: word.word,
                    type: .word,
                    difficulty: .medium,
                    choices: word.randomizedChoices()
                )
                diagnosticItems.append(wordItem)
            }
        }
        
        // Add sentence comprehension items
        if diagnosticSentenceCount > 0 {
            let sentences = DemoSentence.loadFromCSV(fileName: "SentenceComprehensionData", count: diagnosticSentenceCount, category: .sentenceComprehension)
            
            for sentence in sentences {
                let sentenceItem = DiagnosticItem(
                    content: sentence.sentence,
                    type: .sentence,
                    difficulty: .medium,
                    choices: sentence.choices
                )
                diagnosticItems.append(sentenceItem)
            }
        }
        
        // Add sentences in noise items
        if diagnosticNoiseSentenceCount > 0 {
            let noiseSentences = DemoSentence.loadFromCSV(fileName: "SentencesInNoiseData", count: diagnosticNoiseSentenceCount, category: .sentencesInNoise)
            
            for sentence in noiseSentences {
                let sentenceItem = DiagnosticItem(
                    content: sentence.sentence,
                    type: .sentenceInNoise,
                    difficulty: .medium,
                    choices: sentence.choices
                )
                diagnosticItems.append(sentenceItem)
            }
        }
        
        // Shuffle all items together
        currentDiagnosticItems = diagnosticItems.shuffled()
        
        // Reset state
        currentQuestionIndex = 0
        showDiagnosticSelection = false
        testResults = []
        currentScore = 0
        testStartTime = Date()
        questionStartTime = Date()
        userAnswer = ""
        showingFeedback = false
        isAnswerCorrect = false
        
        // Don't auto-play - user must tap play button
    }
    
    // MARK: - Custom Practice Functions
    
    func startCustomWordsPractice(customWords: [DemoWord]) {
        // Set up word recognition with custom words ONLY
        currentDemoWords = customWords
        currentQuestionIndex = 0
        selectedChoices = customWords.map { $0.randomizedChoices() }
        showingFeedback = false
        userAnswer = ""
        isAnswerCorrect = false
        usedWords.removeAll()
        
        // Enable custom practice mode (prevents loading from CSV)
        isCustomPracticeMode = true
        showWordCountPicker = false  // Skip the count picker
        
        // Navigate to word recognition screen
        screen = .wordRecognitionScreen
        
        print("✅ Started custom words practice with \(customWords.count) words (CUSTOM MODE)")
    }
    
    func startCustomSentencesPractice(customSentences: [DemoSentence]) {
        // Set up sentence comprehension with custom sentences ONLY
        currentDemoSentences = customSentences
        currentQuestionIndex = 0
        showingFeedback = false
        userAnswer = ""
        isAnswerCorrect = false
        usedSentences.removeAll()
        
        // Enable custom practice mode (prevents loading from CSV)
        isCustomPracticeMode = true
        showSentenceCountPicker = false  // Skip the count picker
        
        // Navigate to sentence comprehension screen
        screen = .sentenceComprehensionScreen
        
        print("✅ Started custom sentences practice with \(customSentences.count) sentences (CUSTOM MODE)")
    }
    
    func startCustomMatchedPairsPractice(customMatchedPairs: [Word]) {
        // Convert custom matched pairs to PracticeItems
        let practiceItems = customMatchedPairs.map { word in
            PracticeItem(
                content: "\(word.firstWord) vs \(word.lastWord)",
                type: .matchedPair,
                category: word.category,
                choices: [word.firstWord, word.lastWord]
            )
        }
        
        // Set up practice session
        currentPracticeItems = practiceItems
        currentQuestionIndex = 0
        showingFeedback = false
        userAnswer = ""
        isAnswerCorrect = false
        
        // Set up first matched pair word
        if !currentPracticeItems.isEmpty {
            let firstItem = currentPracticeItems[0]
            if firstItem.type == .matchedPair, let choices = firstItem.choices, choices.count >= 2 {
                let wordToPlay = Bool.random() ? choices[0] : choices[1]
                playedMatchedPairWord = wordToPlay
                practiceListOneOrTwo = (wordToPlay == choices[0]) ? 1 : 2
            }
        }
        
        // Navigate to practice list session screen
        screen = .practiceListSessionScreen
        
        print("✅ Started custom matched pairs practice with \(customMatchedPairs.count) pairs")
    }
    
    // TODO: Remove if not needed - just logging, no actual functionality
    /*
     func prepareAudioFiles(for contentList: [String]) {
     // This function prepares the expected audio file names for the new voice system
     // Audio files should be named: {content}{voiceType}.mp3
     // e.g., "catMale1.mp3", "houseFemale2.mp3", etc.
     
     // For now, this just logs what files would be needed
     for content in contentList {
     for voiceType in VoiceType.allCases {
     let expectedFileName = "\(content.replacingOccurrences(of: " ", with: ""))\(voiceType.rawValue).mp3"
     print("Expected audio file: \(expectedFileName)")
     }
     }
     }
     */
    
    func loadSettings() {
        playbackSpeed = UserDefaults.standard.double(forKey: "playbackSpeed")
        if playbackSpeed == 0 { playbackSpeed = 1.0 } // Default if not set
        
        volumeLevel = UserDefaults.standard.float(forKey: "volumeLevel")
        if volumeLevel == 0 { volumeLevel = 1.0 } // Default if not set
        
        // Background noise is always OFF by default - don't load from UserDefaults
        // backgroundNoiseEnabled = UserDefaults.standard.bool(forKey: "backgroundNoiseEnabled")
        
        if let noiseTypeString = UserDefaults.standard.string(forKey: "backgroundNoiseType"),
           let noiseType = BackgroundNoiseType(rawValue: noiseTypeString) {
            backgroundNoiseType = noiseType
        }
        
        backgroundNoiseVolume = UserDefaults.standard.float(forKey: "backgroundNoiseVolume")
        if backgroundNoiseVolume == 0 { backgroundNoiseVolume = 0.7 } // Clinical standard: ~0-5 dB SNR
        
        if let difficultyString = UserDefaults.standard.string(forKey: "difficultyLevel"),
           let difficulty = DifficultyLevel(rawValue: difficultyString) {
            difficultyLevel = difficulty
        }
        
        showProgressAfterEachWord = UserDefaults.standard.bool(forKey: "showProgressAfterEachWord")
        if UserDefaults.standard.object(forKey: "showProgressAfterEachWord") == nil {
            showProgressAfterEachWord = true // Default if not set
        }
        
        buttonconfirm = UserDefaults.standard.bool(forKey: key2)
    }
    
    func getDifficultyDescription() -> String {
        return difficultyLevel.displayDescription
    }
    
    func setupUserSettings() {
        if UserDefaults.standard.bool(forKey: key2) {
            buttonconfirm = true
        } else {
            buttonconfirm = false
        }
        
        // Load listening history
        loadListeningHistory()
        
        // Load practice list
        loadPracticeList()
        
        if buttonconfirm {
            audioManager.playAudio("buttonpress")
        }
        if let retrievedCodableObject = UserDefaults.standard.codableObject(dataType: JSONWORDLIST.self, key: key) {
            WrongWordList = retrievedCodableObject.jsonlist
            jsonlistobject.jsonlist = WrongWordList
        } else {
            WrongWordList = []
            jsonlistobject.jsonlist = []
        }
    }
    
    func handlePracticeChoice(isFirst: Bool) {
        let isCorrect = (isFirst && oneortwo == 1) || (!isFirst && oneortwo == 2)
        
        // Track progress
        updateProgressStats(correct: isCorrect, category: topCategory)
        
        // Track word history
        if currentWordLocation < tempWordList.count {
            let currentWord = tempWordList[currentWordLocation]
            trackWordHistory(word: currentWord, wasCorrect: isCorrect, category: topCategory)
        }
        
        // Track daily challenge progress if applicable
        if topCategory == "DailyChallenge" {
            updateChallengeProgress(correct: isCorrect)
        }
        
        if topCategory == "WrongWordList" {
            screen = isCorrect ? .screen8 : .screen5
        } else {
            screen = isCorrect ? .screen2 : .screen5
        }
        nextdisable = false
        wrongnextdisable = false
    }
    
    func navigateBack() {
        cleanup()
        finaldisable = false
        
        if topCategory == "WrongWordList" {
            screen = .homescreen
        } else {
            screen = .screen3
        }
        
        tempWordList.removeAll()
        WordList.removeAll()
    }
    
    // MARK: - New Training Category Screen Content
    
    @ViewBuilder
    func wordRecognitionScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .homescreen
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Word Recognition")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            if !isCustomPracticeMode && (showWordCountPicker || currentDemoWords.isEmpty) {
                // Word count selection screen (skip if in custom practice mode)
                ScrollView {
                    VStack(spacing: AppTheme.spacingL) {
                        ModernCard(padding: AppTheme.spacingL) {
                            VStack(spacing: AppTheme.spacingM) {
                                HStack {
                                    Image(systemName: TrainingCategory.wordRecognition.icon)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(TrainingCategory.wordRecognition.color)
                                    Text("Word Recognition")
                                        .font(.system(size: layout.titleFontSize, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                }
                                
                                Text("Listen to each word and speak it back. We'll check if it matches!")
                                    .font(.system(size: layout.bodyFontSize))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.leading)
                                
                                Divider()
                                    .padding(.vertical, AppTheme.spacingS)
                                
                                Text("Select Number of Words")
                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Grid of number buttons
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacingS), count: 4), spacing: AppTheme.spacingS) {
                                    ForEach([5, 10, 15, 20, 25, 50, 75, 100], id: \.self) { count in
                                        Button(action: {
                                            isUnlimitedMode = false
                                            selectedWordCount = count
                                            showWordCountPicker = false
                                            currentDemoWords = DemoWord.loadFromCSV(fileName: "WordRecognitionData", count: count, excludeWords: usedWords)
                                            // Track used words
                                            for word in currentDemoWords {
                                                usedWords.insert(word.word.lowercased())
                                            }
                                            currentQuestionIndex = 0
                                            selectedChoices = currentDemoWords.map { $0.randomizedChoices() }
                                            // Don't auto-play - user must tap play button
                                        }) {
                                            Text("\(count)")
                                                .font(.system(size: layout.bodyFontSize + 2, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, AppTheme.spacingM)
                                                .background(AppTheme.primaryBlue)
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                                
                                // Unlimited Practice Button
                                Button(action: {
                                    startUnlimitedPractice(type: .wordRecognition)
                                }) {
                                    HStack {
                                        Image(systemName: "infinity.circle.fill")
                                            .font(.system(size: 24))
                                        Text("Unlimited Practice")
                                            .font(.system(size: layout.bodyFontSize + 2, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.spacingL)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [AppTheme.accentOrange, Color.orange.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: AppTheme.accentOrange.opacity(0.3), radius: 8, y: 4)
                                }
                                .padding(.top, AppTheme.spacingM)
                            }
                        }
                    }
                    .padding(AppTheme.spacingM)
                }
                
                // Back button at bottom
                navigationButtons(layout: layout)
            } else if currentQuestionIndex < currentDemoWords.count || isUnlimitedMode {
                // Training screen
                LazyVStack(spacing: AppTheme.spacingL) {
                    // UNLIMITED MODE: Stats Panel & Stop Button
                    if isUnlimitedMode {
                        VStack(spacing: AppTheme.spacingS) {
                            // Stop Button (always visible)
                            HStack {
                                Button(action: {
                                    stopUnlimitedPractice()
                                }) {
                                    HStack {
                                        Image(systemName: "stop.circle.fill")
                                        Text("Stop Practice")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.error)
                                    .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                // Toggle Stats Panel
                                Button(action: {
                                    withAnimation {
                                        showStatsPanel.toggle()
                                    }
                                }) {
                                    Image(systemName: showStatsPanel ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppTheme.primaryBlue)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Collapsible Stats Panel
                            if showStatsPanel {
                                ModernCard(padding: AppTheme.spacingM, backgroundColor: AppTheme.primaryBlue.opacity(0.1)) {
                                    VStack(spacing: AppTheme.spacingS) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Session Stats")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                let accuracy = unlimitedSessionTotal > 0 ? Double(unlimitedSessionCorrect) / Double(unlimitedSessionTotal) * 100 : 0.0
                                                Text("\(Int(accuracy))% Accuracy")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(AppTheme.primaryBlue)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("\(unlimitedSessionCorrect)/\(unlimitedSessionTotal)")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text("Correct")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                            
                                            VStack(alignment: .trailing, spacing: 4) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "flame.fill")
                                                        .foregroundColor(.orange)
                                                    Text("\(currentStreak)")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                }
                                                Text("Streak")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                        }
                                        
                                        // Progress bar
                                        if unlimitedSessionTotal > 0 {
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(height: 8)
                                                        .cornerRadius(4)
                                                    
                                                    let accuracy = Double(unlimitedSessionCorrect) / Double(unlimitedSessionTotal)
                                                    Rectangle()
                                                        .fill(AppTheme.success)
                                                        .frame(width: geo.size.width * accuracy, height: 8)
                                                        .cornerRadius(4)
                                                }
                                            }
                                            .frame(height: 8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                    }
                    
                    ModernCard(padding: AppTheme.spacingL) {
                        VStack(spacing: AppTheme.spacingM) {
                            HStack {
                                Image(systemName: TrainingCategory.wordRecognition.icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(TrainingCategory.wordRecognition.color)
                                Text(isUnlimitedMode ? "Unlimited Practice" : "Word Recognition")
                                    .font(.system(size: layout.titleFontSize, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            
                            Text("Listen to the word and speak it back. We'll check if it matches!")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.leading)
                            
                            let currentWord = currentDemoWords[currentQuestionIndex]
                            
                            VStack(spacing: AppTheme.spacingM) {
                                ResponsiveButton(
                                    text: "🔊 Play Word",
                                    action: {
                                        // Prevent double-tap if already waiting for recording
                                        guard !waitingForRecordingStart else {
                                            print("⚠️ Already waiting for recording")
                                            return
                                        }
                                        
                                        // If currently recording, stop it temporarily
                                        let wasRecording = speechManager.isRecording
                                        if wasRecording {
                                            print("🔄 Temporarily stopping recording to play word")
                                            speechManager.stopRecording()
                                            // Cancel any existing timeout since we're pausing
                                            recordingTimeoutTask?.cancel()
                                            recordingTimeoutTask = nil
                                        }
                                        
                                        waitingForRecordingStart = true
                                        
                                        // Timeout fallback: Start recording after max 3 seconds even if callback doesn't fire
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                            guard waitingForRecordingStart, !speechManager.isRecording else { return }
                                            print("⚠️ Audio callback timeout - starting recording anyway")
                                            waitingForRecordingStart = false
                                            
                                            // Force UI update
                                            audioManager.isSpeaking = false
                                            
                                            speechManager.requestAuthorization()
                                            firstWordDetected = false
                                            speechManager.onFirstWordDetected = {
                                                let generator = UINotificationFeedbackGenerator()
                                                generator.notificationOccurred(.success)
                                                firstWordDetected = true
                                                print("✅ First word detected in Word Recognition!")
                                            }
                                            
                                            // Start recording with 15-second timeout for words
                                            startRecordingWithTimeout(timeoutSeconds: 15.0) {
                                                print("⏰ Word recognition timeout (fallback) - auto-submitting")
                                                processWordSpeechAnswer()
                                                showingFeedback = true
                                            }
                                        }
                                        
                                        // Play audio and start recording when it finishes
                                        audioManager.playAudio(currentWord.word) { success in
                                            // Audio finished - wait for audio session to fully release
                                            // Longer delay needed to avoid "Abandoning I/O cycle" error
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                guard waitingForRecordingStart, !speechManager.isRecording else {
                                                    print("⚠️ Recording already started - skipping duplicate start")
                                                    return
                                                }
                                                
                                                waitingForRecordingStart = false
                                                
                                                speechManager.requestAuthorization()
                                                firstWordDetected = false // Reset detection state
                                                
                                                // Set up first word detection callback
                                                speechManager.onFirstWordDetected = {
                                                    // Trigger haptic feedback
                                                    let generator = UINotificationFeedbackGenerator()
                                                    generator.notificationOccurred(.success)
                                                    
                                                    // Update state
                                                    firstWordDetected = true
                                                    print("✅ First word detected in Word Recognition!")
                                                }
                                                
                                                // Force UI update by ensuring isSpeaking is false
                                                audioManager.isSpeaking = false
                                                
                                                // Start recording with 15-second timeout for words
                                                startRecordingWithTimeout(timeoutSeconds: 15.0) {
                                                    print("⏰ Word recognition timeout - auto-submitting")
                                                    processWordSpeechAnswer()
                                                    showingFeedback = true
                                                }
                                                print("🎤 Started recording after word finished playing")
                                            }
                                        }
                                    },
                                    layout: layout,
                                    style: .primary,
                                    icon: "play.fill"
                                )
                                
                                // Speech Recognition UI - AUTO-DETECTION
                                if !showingFeedback {
                                    VStack(spacing: AppTheme.spacingM) {
                                        // Dynamic status text based on recording state
                                        if audioManager.isSpeaking {
                                            HStack(spacing: 6) {
                                                Image(systemName: "speaker.wave.3.fill")
                                                    .foregroundColor(AppTheme.primaryBlue)
                                                Text("🔊 Playing word... Listen carefully!")
                                            }
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(AppTheme.primaryBlue)
                                        } else if speechManager.isRecording {
                                            if firstWordDetected {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                    Text("Word detected! Tap STOP when done")
                                                }
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(.green)
                                            } else {
                                                HStack(spacing: 6) {
                                                    Circle()
                                                        .fill(AppTheme.error)
                                                        .frame(width: 8, height: 8)
                                                    Text("Listening... Start speaking!")
                                                }
                                                .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                .foregroundColor(AppTheme.error)
                                            }
                                        } else {
                                            Text("Tap 'Play Word' to begin")
                                                .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                        
                                        // Microphone Status Display (AUTO - no tap required)
                                        VStack(spacing: AppTheme.spacingS) {
                                            Image(systemName: speechManager.isRecording ? "waveform" : "mic.slash.circle")
                                                .font(.system(size: 64))
                                                .foregroundColor(speechManager.isRecording ? (firstWordDetected ? .green : .blue) : AppTheme.textSecondary)
                                                .scaleEffect(speechManager.isRecording ? 1.2 : 1.0)
                                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechManager.isRecording)
                                            
                                            Text(firstWordDetected ? "✅ Ready to stop!" : (speechManager.isRecording ? "🎤 Auto-detecting your speech..." : "Ready to listen"))
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(firstWordDetected ? .green : (speechManager.isRecording ? .blue : AppTheme.textSecondary))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppTheme.spacingL)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(speechManager.isRecording ? (firstWordDetected ? Color.green.opacity(0.1) : Color.blue.opacity(0.1)) : Color.gray.opacity(0.05))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(speechManager.isRecording ? (firstWordDetected ? Color.green : Color.blue) : Color.gray.opacity(0.3), lineWidth: 2)
                                        )
                                        
                                        // Show recognized text in real-time - ABOVE stop button for visibility
                                        if speechManager.isRecording && !speechManager.recognizedText.isEmpty {
                                            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                                HStack {
                                                    Text("YOU SAID:")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.white)
                                                }
                                                .padding(.horizontal, AppTheme.spacingM)
                                                .padding(.vertical, AppTheme.spacingS)
                                                .background(AppTheme.success)
                                                
                                                Text(speechManager.recognizedText)
                                                    .font(.system(size: layout.bodyFontSize + 4, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                    .padding(AppTheme.spacingL)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .background(Color.white)
                                            }
                                            .background(Color.white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(AppTheme.success, lineWidth: 3)
                                            )
                                            .shadow(color: AppTheme.success.opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                        
                                        // BIG STOP BUTTON - Below recognized text
                                        if speechManager.isRecording {
                                            Button(action: {
                                                // Trigger haptic feedback
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                
                                                // IMPORTANT: Save recognized text BEFORE stopping
                                                spokenText = speechManager.recognizedText
                                                print("📝 [Word Recognition] Saved: '\(spokenText)'")
                                                
                                                speechManager.stopRecording()
                                                print("🛑 Recording stopped by user via STOP button")
                                                
                                                // Process the answer immediately
                                                processWordSpeechAnswer()
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    showingFeedback = true
                                                }
                                            }) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "stop.circle.fill")
                                                        .font(.system(size: 28))
                                                    Text("STOP & GET FEEDBACK")
                                                        .font(.system(size: 18, weight: .bold))
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 20)
                                                .background(
                                                    LinearGradient(
                                                        colors: [AppTheme.error, AppTheme.error.opacity(0.8)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(16)
                                                .shadow(color: AppTheme.error.opacity(0.4), radius: 8, x: 0, y: 4)
                                            }
                                        }
                                    }
                                } else {
                                    // Show results after speaking
                                    VStack(spacing: AppTheme.spacingM) {
                                        // Expected word
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("Expected:")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            Text(currentWord.word.lowercased())
                                                .font(.system(size: layout.titleFontSize, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .padding(AppTheme.spacingM)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .background(AppTheme.backgroundSecondary)
                                                .cornerRadius(12)
                                        }
                                        
                                        // Spoken word
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("You said:")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            Text(spokenText.isEmpty ? "No speech detected" : spokenText.lowercased())
                                                .font(.system(size: layout.titleFontSize, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .padding(AppTheme.spacingM)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .background(AppTheme.backgroundSecondary)
                                                .cornerRadius(12)
                                        }
                                        
                                        // Result badge
                                        ModernCard(padding: AppTheme.spacingM, backgroundColor: isAnswerCorrect ? AppTheme.success.opacity(0.1) : AppTheme.error.opacity(0.1)) {
                                            HStack {
                                                Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .font(.system(size: 48))
                                                    .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(isAnswerCorrect ? "Correct!" : "Keep Trying")
                                                        .font(.system(size: layout.titleFontSize, weight: .bold))
                                                        .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                                    
                                                    Text(isAnswerCorrect ? "Perfect match!" : "The words don't match")
                                                        .font(.system(size: layout.bodyFontSize - 2))
                                                        .foregroundColor(AppTheme.textSecondary)
                                                }
                                                
                                                Spacer()
                                            }
                                        }
                                        
                                        // Add to Practice List button (only for wrong answers)
                                        if !isAnswerCorrect {
                                            ResponsiveButton(
                                                text: "Add to Practice List",
                                                action: {
                                                    addCurrentWordToPracticeList()
                                                },
                                                layout: layout,
                                                style: .secondary,
                                                icon: "plus.circle"
                                            )
                                        }
                                        
                                        // Next button (auto-advance in unlimited mode)
                                        ResponsiveButton(
                                            text: isUnlimitedMode ? "Continue" : "Next",
                                            action: {
                                                if isUnlimitedMode {
                                                    // Auto-advance: reset and load next word
                                                    showingFeedback = false
                                                    loadNextUnlimitedWord()
                                                } else {
                                                    moveToNextQuestion()
                                                }
                                            },
                                            layout: layout,
                                            style: .primary,
                                            icon: "arrow.right"
                                        )
                                    }
                                }
                                
                                progressView(current: currentQuestionIndex + 1, total: currentDemoWords.count, layout: layout)
                            }
                            .onChange(of: currentQuestionIndex) { _ in
                                // Reset state when question changes
                                waitingForRecordingStart = false
                                resetSpeechState()
                                // Don't auto-play - user must tap play button
                            }
                        }
                    }
                    
                    navigationButtons(layout: layout)
                }
            } else {
                // Quiz completed - show results
                VStack(spacing: AppTheme.spacingL) {
                    ModernCard(padding: AppTheme.spacingL) {
                        VStack(spacing: AppTheme.spacingM) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(AppTheme.success)
                            
                            Text("Quiz Complete!")
                                .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            let correctCount = userResponses.filter { $0.wasCorrect }.count
                            let accuracy = Double(correctCount) / Double(currentDemoWords.count)
                            
                            Text("\(correctCount) / \(currentDemoWords.count) Correct")
                                .font(.system(size: layout.titleFontSize, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text("Accuracy: \(Int(accuracy * 100))%")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            ResponsiveButton(
                                text: "Submit & Return",
                                action: {
                                    // Record session
                                    ProgressManager.shared.recordSession(
                                        phase: 1,
                                        exerciseType: "Word Recognition",
                                        phoneme: "mixed",
                                        score: accuracy,
                                        duration: 0
                                    )
                                    
                                    // Reset state
                                    currentDemoWords = []
                                    currentQuestionIndex = 0
                                    showWordCountPicker = true
                                    userResponses = []
                                    
                                    // Go back to home
                                    screen = .homescreen
                                },
                                layout: layout,
                                style: .success,
                                icon: "checkmark"
                            )
                            
                            ResponsiveButton(
                                text: "Try Again",
                                action: {
                                    currentQuestionIndex = 0
                                    userResponses = []
                                    if !currentDemoWords.isEmpty {
                                        audioManager.playAudio(currentDemoWords[0].word)
                                    }
                                },
                                layout: layout,
                                style: .secondary,
                                icon: "arrow.counterclockwise"
                            )
                        }
                    }
                }
                .padding(AppTheme.spacingM)
            }
        }
        .alert("Take a Break?", isPresented: $showFatigueWarning) {
            Button("Continue") {
                showFatigueWarning = false
            }
            Button("Stop Practice", role: .destructive) {
                stopUnlimitedPractice()
            }
        } message: {
            Text("You've completed \(unlimitedSessionTotal) words! Consider taking a short break to maintain focus.")
        }
    }
    
    @ViewBuilder
    func sentenceComprehensionScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .homescreen
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Sentence Comprehension")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            if !isCustomPracticeMode && (showSentenceCountPicker || currentDemoSentences.isEmpty) {
                // Sentence count selection screen (skip if in custom practice mode)
                ScrollView {
                    VStack(spacing: AppTheme.spacingL) {
                        ModernCard(padding: AppTheme.spacingL) {
                            VStack(spacing: AppTheme.spacingM) {
                                HStack {
                                    Image(systemName: TrainingCategory.sentenceComprehension.icon)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(TrainingCategory.sentenceComprehension.color)
                                    Text("Sentence Comprehension")
                                        .font(.system(size: layout.titleFontSize, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                }
                                
                                Text("Listen to the sentence and speak it back. We'll match your words and give you a score!")
                                    .font(.system(size: layout.bodyFontSize))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.leading)
                                
                                Divider()
                                    .padding(.vertical, AppTheme.spacingS)
                                
                                Text("Select Number of Sentences")
                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Grid of number buttons
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacingS), count: 4), spacing: AppTheme.spacingS) {
                                    ForEach([5, 10, 15, 20], id: \.self) { count in
                                        Button(action: {
                                            isUnlimitedMode = false
                                            selectedSentenceCount = count
                                            showSentenceCountPicker = false
                                            // Reset state
                                            currentQuestionIndex = 0
                                            showingFeedback = false
                                            userAnswer = ""
                                            isAnswerCorrect = false
                                            // Load sentences
                                            currentDemoSentences = DemoSentence.loadFromCSV(fileName: "SentenceComprehensionData", count: count, category: .sentenceComprehension, excludeSentences: usedSentences)
                                            // Track used sentences
                                            for sentence in currentDemoSentences {
                                                usedSentences.insert(sentence.sentence.lowercased())
                                            }
                                            // Don't auto-play - user must click Play Sentence button
                                        }) {
                                            Text("\(count)")
                                                .font(.system(size: layout.bodyFontSize + 2, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, AppTheme.spacingM)
                                                .background(AppTheme.accentOrange)
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                                
                                // Unlimited Practice Button
                                Button(action: {
                                    startUnlimitedPractice(type: .sentenceComprehension)
                                }) {
                                    HStack {
                                        Image(systemName: "infinity.circle.fill")
                                            .font(.system(size: 24))
                                        Text("Unlimited Practice")
                                            .font(.system(size: layout.bodyFontSize + 2, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.spacingL)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [AppTheme.accentOrange, Color.orange.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: AppTheme.accentOrange.opacity(0.3), radius: 8, y: 4)
                                }
                                .padding(.top, AppTheme.spacingM)
                            }
                        }
                    }
                    .padding(AppTheme.spacingM)
                }
                
                // Back button at bottom
                navigationButtons(layout: layout)
            } else if currentQuestionIndex < currentDemoSentences.count {
                // Training screen
                LazyVStack(spacing: AppTheme.spacingL) {
                    ModernCard(padding: AppTheme.spacingL) {
                        VStack(spacing: AppTheme.spacingM) {
                            HStack {
                                Image(systemName: TrainingCategory.sentenceComprehension.icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(TrainingCategory.sentenceComprehension.color)
                                Text("Sentence Comprehension")
                                    .font(.system(size: layout.titleFontSize, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            
                            Text("Listen to the sentence and speak it back. We'll match your words and give you a score!")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.leading)
                            
                            let currentSentence = currentDemoSentences[currentQuestionIndex]
                            
                            VStack(spacing: AppTheme.spacingM) {
                                ResponsiveButton(
                                    text: "🔊 Play Sentence",
                                    action: {
                                        // Prevent double-tap if already waiting for recording
                                        guard !waitingForRecordingStart else {
                                            print("⚠️ Already waiting for recording")
                                            return
                                        }
                                        
                                        // If currently recording, stop it temporarily
                                        let wasRecording = speechManager.isRecording
                                        if wasRecording {
                                            print("🔄 Temporarily stopping recording to play sentence")
                                            speechManager.stopRecording()
                                            // Cancel any existing timeout since we're pausing
                                            recordingTimeoutTask?.cancel()
                                            recordingTimeoutTask = nil
                                        }
                                        
                                        waitingForRecordingStart = true
                                        
                                        // Timeout fallback: Start recording after max 5 seconds (sentences are longer)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                            guard waitingForRecordingStart, !speechManager.isRecording else { return }
                                            print("⚠️ Audio callback timeout - starting recording anyway")
                                            waitingForRecordingStart = false
                                            
                                            // Force UI update
                                            audioManager.isSpeaking = false
                                            
                                            speechManager.requestAuthorization()
                                            firstWordDetected = false
                                            speechManager.onFirstWordDetected = {
                                                let generator = UINotificationFeedbackGenerator()
                                                generator.notificationOccurred(.success)
                                                firstWordDetected = true
                                                print("✅ First word detected in Sentence Comprehension!")
                                            }
                                            
                                            // Start recording with 30-second timeout for sentences
                                            startRecordingWithTimeout(timeoutSeconds: 30.0) {
                                                print("⏰ Sentence comprehension timeout (fallback) - auto-submitting")
                                                processSpeechAnswer()
                                                showingFeedback = true
                                            }
                                        }
                                        
                                        // Play audio and start recording when it finishes
                                        audioManager.playAudio(currentSentence.sentence) { success in
                                            // Audio finished - wait for audio session to fully release
                                            // Longer delay needed to avoid "Abandoning I/O cycle" error
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                guard waitingForRecordingStart, !speechManager.isRecording else {
                                                    print("⚠️ Recording already started - skipping duplicate start")
                                                    return
                                                }
                                                
                                                waitingForRecordingStart = false
                                                
                                                speechManager.requestAuthorization()
                                                firstWordDetected = false // Reset detection state
                                                
                                                // Set up first word detection callback
                                                speechManager.onFirstWordDetected = {
                                                    // Trigger haptic feedback
                                                    let generator = UINotificationFeedbackGenerator()
                                                    generator.notificationOccurred(.success)
                                                    
                                                    // Update state
                                                    firstWordDetected = true
                                                    print("✅ First word detected in Sentence Comprehension!")
                                                }
                                                
                                                // Force UI update by ensuring isSpeaking is false
                                                audioManager.isSpeaking = false
                                                
                                                // Start recording with 30-second timeout for sentences
                                                startRecordingWithTimeout(timeoutSeconds: 30.0) {
                                                    print("⏰ Sentence comprehension timeout - auto-submitting")
                                                    processSpeechAnswer()
                                                    showingFeedback = true
                                                }
                                                print("🎤 Started recording after sentence finished playing")
                                            }
                                        }
                                    },
                                    layout: layout,
                                    style: .primary,
                                    icon: "play.fill"
                                )
                                
                                // Speech Recognition UI - AUTO-DETECTION
                                if !showingFeedback {
                                    VStack(spacing: AppTheme.spacingM) {
                                        // Dynamic status text based on recording state
                                        if audioManager.isSpeaking {
                                            HStack(spacing: 6) {
                                                Image(systemName: "speaker.wave.3.fill")
                                                    .foregroundColor(AppTheme.primaryBlue)
                                                Text("🔊 Playing sentence... Listen carefully!")
                                            }
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(AppTheme.primaryBlue)
                                        } else if speechManager.isRecording {
                                            if firstWordDetected {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                    Text("Word detected! Tap STOP when done")
                                                }
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(.green)
                                            } else {
                                                HStack(spacing: 6) {
                                                    Circle()
                                                        .fill(AppTheme.error)
                                                        .frame(width: 8, height: 8)
                                                    Text("Listening... Start speaking!")
                                                }
                                                .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                .foregroundColor(AppTheme.error)
                                            }
                                        } else {
                                            Text("Tap 'Play Sentence' to begin")
                                                .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                        
                                        // Microphone Status Display (AUTO - no tap required)
                                        VStack(spacing: AppTheme.spacingS) {
                                            Image(systemName: speechManager.isRecording ? "waveform" : "mic.slash.circle")
                                                .font(.system(size: 64))
                                                .foregroundColor(speechManager.isRecording ? (firstWordDetected ? .green : .blue) : AppTheme.textSecondary)
                                                .scaleEffect(speechManager.isRecording ? 1.2 : 1.0)
                                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechManager.isRecording)
                                            
                                            Text(firstWordDetected ? "✅ Ready to stop!" : (speechManager.isRecording ? "🎤 Auto-detecting your speech..." : "Ready to listen"))
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(firstWordDetected ? .green : (speechManager.isRecording ? .blue : AppTheme.textSecondary))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppTheme.spacingL)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(speechManager.isRecording ? (firstWordDetected ? Color.green.opacity(0.1) : Color.blue.opacity(0.1)) : Color.gray.opacity(0.05))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(speechManager.isRecording ? (firstWordDetected ? Color.green : Color.blue) : Color.gray.opacity(0.3), lineWidth: 2)
                                        )
                                        
                                        // Show recognized text in real-time - ABOVE stop button for visibility
                                        if speechManager.isRecording && !speechManager.recognizedText.isEmpty {
                                            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                                HStack {
                                                    Text("YOU SAID:")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.white)
                                                }
                                                .padding(.horizontal, AppTheme.spacingM)
                                                .padding(.vertical, AppTheme.spacingS)
                                                .background(AppTheme.success)
                                                
                                                Text(speechManager.recognizedText)
                                                    .font(.system(size: layout.bodyFontSize + 4, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                    .padding(AppTheme.spacingL)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .background(Color.white)
                                            }
                                            .background(Color.white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(AppTheme.success, lineWidth: 3)
                                            )
                                            .shadow(color: AppTheme.success.opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                        
                                        // BIG STOP BUTTON - Below recognized text
                                        if speechManager.isRecording {
                                            Button(action: {
                                                // Trigger haptic feedback
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                
                                                // IMPORTANT: Save recognized text BEFORE stopping
                                                spokenText = speechManager.recognizedText
                                                print("📝 [Sentence/Noise] Saved: '\(spokenText)'")
                                                
                                                speechManager.stopRecording()
                                                print("🛑 Recording stopped by user via STOP button")
                                                
                                                // Process the answer immediately
                                                processSpeechAnswer()
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    showingFeedback = true
                                                }
                                            }) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "stop.circle.fill")
                                                        .font(.system(size: 28))
                                                    Text("STOP & GET FEEDBACK")
                                                        .font(.system(size: 18, weight: .bold))
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 20)
                                                .background(
                                                    LinearGradient(
                                                        colors: [AppTheme.error, AppTheme.error.opacity(0.8)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(16)
                                                .shadow(color: AppTheme.error.opacity(0.4), radius: 8, x: 0, y: 4)
                                            }
                                        }
                                    }
                                } else {
                                    // Show results after speaking
                                    VStack(spacing: AppTheme.spacingM) {
                                        // Expected sentence
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("Expected:")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            Text(currentSentence.sentence.lowercased())
                                                .font(.system(size: layout.bodyFontSize))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .padding(AppTheme.spacingM)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(AppTheme.backgroundSecondary)
                                                .cornerRadius(12)
                                        }
                                        
                                        // Spoken sentence
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("You said:")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            Text(spokenText.isEmpty ? "No speech detected" : spokenText.lowercased())
                                                .font(.system(size: layout.bodyFontSize))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .padding(AppTheme.spacingM)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(AppTheme.backgroundSecondary)
                                                .cornerRadius(12)
                                        }
                                        
                                        // Word matching score
                                        ModernCard(padding: AppTheme.spacingM, backgroundColor: isAnswerCorrect ? AppTheme.success.opacity(0.1) : AppTheme.error.opacity(0.1)) {
                                            VStack(spacing: AppTheme.spacingS) {
                                                HStack {
                                                    Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                        .font(.system(size: 32))
                                                        .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                                    
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(isAnswerCorrect ? "Great Job!" : "Keep Practicing")
                                                            .font(.system(size: layout.bodyFontSize + 2, weight: .bold))
                                                            .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                                        
                                                        Text("\(matchedWords) / \(totalWords) words matched")
                                                            .font(.system(size: layout.bodyFontSize - 2))
                                                            .foregroundColor(AppTheme.textSecondary)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(Int(wordMatchScore * 100))%")
                                                        .font(.system(size: 28, weight: .bold))
                                                        .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Show buttons after answer is selected
                                if showingFeedback {
                                    VStack(spacing: AppTheme.spacingS) {
                                        // Add to Practice List button (only for wrong answers)
                                        if !isAnswerCorrect {
                                            ResponsiveButton(
                                                text: "Add to Practice List",
                                                action: {
                                                    addCurrentSentenceToPracticeList()
                                                },
                                                layout: layout,
                                                style: .secondary,
                                                icon: "plus.circle"
                                            )
                                        }
                                        
                                        // Next button - always shows for infinite practice
                                        ResponsiveButton(
                                            text: "Next",
                                            action: {
                                                moveToNextQuestion()
                                            },
                                            layout: layout,
                                            style: .primary,
                                            icon: "arrow.right"
                                        )
                                    }
                                    .padding(.top, AppTheme.spacingM)
                                }
                                
                                progressView(current: currentQuestionIndex + 1, total: currentDemoSentences.count, layout: layout)
                            }
                            .onChange(of: currentQuestionIndex) { _ in
                                // Reset state when question changes
                                waitingForRecordingStart = false
                                resetSpeechState()
                                // Don't auto-play - user must tap play button
                            }
                        }
                    }
                    
                    navigationButtons(layout: layout)
                }
            } else {
                // Quiz completed - show results
                VStack(spacing: AppTheme.spacingL) {
                    ModernCard(padding: AppTheme.spacingL) {
                        VStack(spacing: AppTheme.spacingM) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(AppTheme.success)
                            
                            Text("Quiz Complete!")
                                .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            let correctCount = userResponses.filter { $0.wasCorrect }.count
                            let accuracy = Double(correctCount) / Double(currentDemoSentences.count)
                            
                            Text("\(correctCount) / \(currentDemoSentences.count) Correct")
                                .font(.system(size: layout.titleFontSize, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text("Accuracy: \(Int(accuracy * 100))%")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            ResponsiveButton(
                                text: "Submit & Return",
                                action: {
                                    // Record session
                                    ProgressManager.shared.recordSession(
                                        phase: 1,
                                        exerciseType: "Sentence Comprehension",
                                        phoneme: "mixed",
                                        score: accuracy,
                                        duration: 0
                                    )
                                    
                                    // Reset state
                                    currentDemoSentences = []
                                    currentQuestionIndex = 0
                                    showSentenceCountPicker = true
                                    userResponses = []
                                    
                                    // Go back to home
                                    screen = .homescreen
                                },
                                layout: layout,
                                style: .success,
                                icon: "checkmark"
                            )
                            
                            ResponsiveButton(
                                text: "Try Again",
                                action: {
                                    currentQuestionIndex = 0
                                    userResponses = []
                                    if !currentDemoSentences.isEmpty {
                                        audioManager.playAudio(currentDemoSentences[0].sentence)
                                    }
                                },
                                layout: layout,
                                style: .secondary,
                                icon: "arrow.counterclockwise"
                            )
                        }
                    }
                }
                .padding(AppTheme.spacingM)
            }
        }
    }
    
    @ViewBuilder
    func sentencesInNoiseScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .homescreen
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Sentences in Noise")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            if showSentenceCountPicker || currentDemoSentences.isEmpty {
                // Sentence count selection screen
                ScrollView {
                    VStack(spacing: AppTheme.spacingL) {
                        ModernCard(padding: AppTheme.spacingL) {
                            VStack(spacing: AppTheme.spacingM) {
                                HStack {
                                    Image(systemName: TrainingCategory.sentencesInNoise.icon)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(TrainingCategory.sentencesInNoise.color)
                                    Text("Sentences in Noise")
                                        .font(.system(size: layout.titleFontSize, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                }
                                
                                Text("Listen carefully to the sentence with background noise and speak it back!")
                                    .font(.system(size: layout.bodyFontSize))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.leading)
                                
                                Divider()
                                    .padding(.vertical, AppTheme.spacingS)
                                
                                Text("Select Number of Sentences")
                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Grid of number buttons
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacingS), count: 4), spacing: AppTheme.spacingS) {
                                    ForEach([5, 10, 15, 20], id: \.self) { count in
                                        Button(action: {
                                            selectedSentenceCount = count
                                            showSentenceCountPicker = false
                                            // Reset state
                                            currentQuestionIndex = 0
                                            showingFeedback = false
                                            userAnswer = ""
                                            isAnswerCorrect = false
                                            // Load sentences
                                            currentDemoSentences = DemoSentence.loadFromCSV(fileName: "SentencesInNoiseData", count: count, category: .sentencesInNoise, excludeSentences: usedSentences)
                                            // Track used sentences
                                            for sentence in currentDemoSentences {
                                                usedSentences.insert(sentence.sentence.lowercased())
                                            }
                                            // Don't auto-play - user must click Play Sentence button
                                        }) {
                                            Text("\(count)")
                                                .font(.system(size: layout.bodyFontSize + 2, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, AppTheme.spacingM)
                                                .background(AppTheme.warning)
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(AppTheme.spacingM)
                }
                
                // Back button at bottom
                navigationButtons(layout: layout)
            } else if currentQuestionIndex < currentDemoSentences.count {
                // Training screen
                LazyVStack(spacing: AppTheme.spacingL) {
                    ModernCard(padding: AppTheme.spacingL) {
                        VStack(spacing: AppTheme.spacingM) {
                            HStack {
                                Image(systemName: TrainingCategory.sentencesInNoise.icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(TrainingCategory.sentencesInNoise.color)
                                Text("Sentences in Noise")
                                    .font(.system(size: layout.titleFontSize, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            
                            Text("Listen carefully to the sentence with background noise and speak it back!")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.leading)
                            
                            let currentSentence = currentDemoSentences[currentQuestionIndex]
                            
                            VStack(spacing: AppTheme.spacingM) {
                                ResponsiveButton(
                                    text: "🔊 Play Sentence",
                                    action: {
                                        // Prevent double-tap if already waiting for recording
                                        guard !waitingForRecordingStart else {
                                            print("⚠️ Already waiting for recording")
                                            return
                                        }
                                        
                                        // If currently recording, stop it temporarily
                                        let wasRecording = speechManager.isRecording
                                        if wasRecording {
                                            print("🔄 Temporarily stopping recording to play sentence")
                                            speechManager.stopRecording()
                                            // Cancel any existing timeout since we're pausing
                                            recordingTimeoutTask?.cancel()
                                            recordingTimeoutTask = nil
                                        }
                                        
                                        waitingForRecordingStart = true
                                        
                                        // Background noise is ALWAYS enabled for Sentences in Noise
                                        startBackgroundNoiseIfEnabled()
                                        
                                        // Timeout fallback: Start recording after max 5 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                            guard waitingForRecordingStart, !speechManager.isRecording else { return }
                                            print("⚠️ Audio callback timeout - starting recording anyway")
                                            waitingForRecordingStart = false
                                            
                                            // Force UI update
                                            audioManager.isSpeaking = false
                                            
                                            speechManager.requestAuthorization()
                                            firstWordDetected = false
                                            speechManager.onFirstWordDetected = {
                                                let generator = UINotificationFeedbackGenerator()
                                                generator.notificationOccurred(.success)
                                                firstWordDetected = true
                                                print("✅ First word detected in Noise Exercise!")
                                            }
                                            speechManager.startRecording()
                                        }
                                        
                                        // Play audio and start recording when it finishes
                                        audioManager.playAudio(currentSentence.sentence) { success in
                                            // Audio finished - wait for audio session to fully release
                                            // Extra long delay needed when background noise is also playing
                                            // The audio system needs time to handle 3 simultaneous components
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                guard waitingForRecordingStart, !speechManager.isRecording else { return }
                                                waitingForRecordingStart = false
                                                
                                                speechManager.requestAuthorization()
                                                firstWordDetected = false // Reset detection state
                                                
                                                // Set up first word detection callback
                                                speechManager.onFirstWordDetected = {
                                                    // Trigger haptic feedback
                                                    let generator = UINotificationFeedbackGenerator()
                                                    generator.notificationOccurred(.success)
                                                    
                                                    // Update state
                                                    firstWordDetected = true
                                                    print("✅ First word detected in Noise Exercise!")
                                                }
                                                
                                                // Force UI update by ensuring isSpeaking is false
                                                audioManager.isSpeaking = false
                                                
                                                speechManager.startRecording()
                                                print("🎤 Started recording after sentence with noise finished playing")
                                            }
                                        }
                                    },
                                    layout: layout,
                                    style: .primary,
                                    icon: "play.fill"
                                )
                                
                                // Speech Recognition UI - AUTO-DETECTION
                                if !showingFeedback {
                                    VStack(spacing: AppTheme.spacingM) {
                                        // Dynamic status text based on recording state
                                        if speechManager.isRecording {
                                            if firstWordDetected {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                    Text("Word detected! Tap STOP when done")
                                                }
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(.green)
                                            } else {
                                                HStack(spacing: 6) {
                                                    Circle()
                                                        .fill(AppTheme.error)
                                                        .frame(width: 8, height: 8)
                                                    Text("Listening... Start speaking!")
                                                }
                                                .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                .foregroundColor(AppTheme.error)
                                            }
                                        } else {
                                            Text("Tap 'Play with Noise' to begin")
                                                .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                        
                                        // Microphone Status Display (AUTO - no tap required)
                                        VStack(spacing: AppTheme.spacingS) {
                                            Image(systemName: speechManager.isRecording ? "waveform" : "mic.slash.circle")
                                                .font(.system(size: 64))
                                                .foregroundColor(speechManager.isRecording ? (firstWordDetected ? .green : .blue) : AppTheme.textSecondary)
                                                .scaleEffect(speechManager.isRecording ? 1.2 : 1.0)
                                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechManager.isRecording)
                                            
                                            Text(firstWordDetected ? "✅ Ready to stop!" : (speechManager.isRecording ? "🎤 Auto-detecting your speech..." : "Ready to listen"))
                                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                .foregroundColor(firstWordDetected ? .green : (speechManager.isRecording ? .blue : AppTheme.textSecondary))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppTheme.spacingL)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(speechManager.isRecording ? (firstWordDetected ? Color.green.opacity(0.1) : Color.blue.opacity(0.1)) : Color.gray.opacity(0.05))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(speechManager.isRecording ? (firstWordDetected ? Color.green : Color.blue) : Color.gray.opacity(0.3), lineWidth: 2)
                                        )
                                        
                                        // Show recognized text in real-time - ABOVE stop button for visibility
                                        if speechManager.isRecording && !speechManager.recognizedText.isEmpty {
                                            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                                HStack {
                                                    Text("YOU SAID:")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.white)
                                                }
                                                .padding(.horizontal, AppTheme.spacingM)
                                                .padding(.vertical, AppTheme.spacingS)
                                                .background(AppTheme.success)
                                                
                                                Text(speechManager.recognizedText)
                                                    .font(.system(size: layout.bodyFontSize + 4, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                    .padding(AppTheme.spacingL)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .background(Color.white)
                                            }
                                            .background(Color.white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(AppTheme.success, lineWidth: 3)
                                            )
                                            .shadow(color: AppTheme.success.opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                        
                                        // BIG STOP BUTTON - Below recognized text
                                        if speechManager.isRecording {
                                            Button(action: {
                                                // Trigger haptic feedback
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                
                                                // IMPORTANT: Save recognized text BEFORE stopping
                                                spokenText = speechManager.recognizedText
                                                print("📝 [Sentence/Noise] Saved: '\(spokenText)'")
                                                
                                                speechManager.stopRecording()
                                                print("🛑 Recording stopped by user via STOP button")
                                                
                                                // Process the answer immediately
                                                processSpeechAnswer()
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    showingFeedback = true
                                                }
                                            }) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "stop.circle.fill")
                                                        .font(.system(size: 28))
                                                    Text("STOP & GET FEEDBACK")
                                                        .font(.system(size: 18, weight: .bold))
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 20)
                                                .background(
                                                    LinearGradient(
                                                        colors: [AppTheme.error, AppTheme.error.opacity(0.8)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(16)
                                                .shadow(color: AppTheme.error.opacity(0.4), radius: 8, x: 0, y: 4)
                                            }
                                        }
                                    }
                                } else {
                                    // Show results after speaking
                                    VStack(spacing: AppTheme.spacingM) {
                                        // Expected sentence
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("Expected:")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            Text(currentSentence.sentence.lowercased())
                                                .font(.system(size: layout.bodyFontSize))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .padding(AppTheme.spacingM)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(AppTheme.backgroundSecondary)
                                                .cornerRadius(12)
                                        }
                                        
                                        // Spoken sentence
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("You said:")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            Text(spokenText.isEmpty ? "No speech detected" : spokenText.lowercased())
                                                .font(.system(size: layout.bodyFontSize))
                                                .foregroundColor(AppTheme.textPrimary)
                                                .padding(AppTheme.spacingM)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(AppTheme.backgroundSecondary)
                                                .cornerRadius(12)
                                        }
                                        
                                        // Word matching score
                                        ModernCard(padding: AppTheme.spacingM, backgroundColor: isAnswerCorrect ? AppTheme.success.opacity(0.1) : AppTheme.error.opacity(0.1)) {
                                            VStack(spacing: AppTheme.spacingS) {
                                                HStack {
                                                    Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                        .font(.system(size: 32))
                                                        .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                                    
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(isAnswerCorrect ? "Great Job!" : "Keep Practicing")
                                                            .font(.system(size: layout.bodyFontSize + 2, weight: .bold))
                                                            .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                                        
                                                        Text("\(matchedWords) / \(totalWords) words matched")
                                                            .font(.system(size: layout.bodyFontSize - 2))
                                                            .foregroundColor(AppTheme.textSecondary)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(Int(wordMatchScore * 100))%")
                                                        .font(.system(size: 28, weight: .bold))
                                                        .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Show buttons after answer is selected
                                if showingFeedback {
                                    VStack(spacing: AppTheme.spacingS) {
                                        // Add to Practice List button (only for wrong answers)
                                        if !isAnswerCorrect {
                                            ResponsiveButton(
                                                text: "Add to Practice List",
                                                action: {
                                                    addCurrentSentenceToPracticeList()
                                                },
                                                layout: layout,
                                                style: .secondary,
                                                icon: "plus.circle"
                                            )
                                        }
                                        
                                        // Next button - always shows for infinite practice
                                        ResponsiveButton(
                                            text: "Next",
                                            action: {
                                                moveToNextQuestion()
                                            },
                                            layout: layout,
                                            style: .primary,
                                            icon: "arrow.right"
                                        )
                                    }
                                    .padding(.top, AppTheme.spacingM)
                                }
                                
                                progressView(current: currentQuestionIndex + 1, total: currentDemoSentences.count, layout: layout)
                            }
                            .onChange(of: currentQuestionIndex) { _ in
                                // Reset state when question changes
                                waitingForRecordingStart = false
                                resetSpeechState()
                                // Don't auto-play - user must tap play button
                            }
                        }
                    }
                    
                    navigationButtons(layout: layout)
                }
            } else {
                // Quiz completed - show results
                VStack(spacing: AppTheme.spacingL) {
                    ModernCard(padding: AppTheme.spacingL) {
                        VStack(spacing: AppTheme.spacingM) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(AppTheme.success)
                            
                            Text("Quiz Complete!")
                                .font(.system(size: layout.titleFontSize * 1.2, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            let correctCount = userResponses.filter { $0.wasCorrect }.count
                            let accuracy = Double(correctCount) / Double(currentDemoSentences.count)
                            
                            Text("\(correctCount) / \(currentDemoSentences.count) Correct")
                                .font(.system(size: layout.titleFontSize, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text("Accuracy: \(Int(accuracy * 100))%")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            ResponsiveButton(
                                text: "Submit & Return",
                                action: {
                                    // Stop background noise
                                    stopBackgroundNoise()
                                    
                                    // Record session
                                    ProgressManager.shared.recordSession(
                                        phase: 1,
                                        exerciseType: "Sentences in Noise",
                                        phoneme: "mixed",
                                        score: accuracy,
                                        duration: 0
                                    )
                                    
                                    // Reset state
                                    currentDemoSentences = []
                                    currentQuestionIndex = 0
                                    showSentenceCountPicker = true
                                    userResponses = []
                                    
                                    // Go back to home
                                    screen = .homescreen
                                },
                                layout: layout,
                                style: .success,
                                icon: "checkmark"
                            )
                            
                            ResponsiveButton(
                                text: "Try Again",
                                action: {
                                    currentQuestionIndex = 0
                                    userResponses = []
                                    if !currentDemoSentences.isEmpty {
                                        if backgroundNoiseEnabled {
                                            startBackgroundNoiseIfEnabled()
                                        }
                                        audioManager.playAudio(currentDemoSentences[0].sentence)
                                    }
                                },
                                layout: layout,
                                style: .secondary,
                                icon: "arrow.counterclockwise"
                            )
                        }
                    }
                }
                .padding(AppTheme.spacingM)
            }
        }
    }
    
    @ViewBuilder
    func diagnosticTestScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .homescreen
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Diagnostic Test")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            ScrollView {
                LazyVStack(spacing: AppTheme.spacingL) {
                    ModernCard(padding: AppTheme.spacingL) {
                        VStack(spacing: AppTheme.spacingM) {
                            HStack {
                                Image(systemName: TrainingCategory.diagnosticTest.icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(TrainingCategory.diagnosticTest.color)
                                Text("Diagnostic Test")
                                    .font(.system(size: layout.titleFontSize, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            
                            Text("Comprehensive assessment across difficulty levels.")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.leading)
                            
                            if showDiagnosticSelection {
                                VStack(spacing: AppTheme.spacingL) {
                                    // Word Recognition Selection
                                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                        Text("Word Recognition")
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text("Select number of words (up to 20)")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                        
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacingS), count: 5), spacing: AppTheme.spacingS) {
                                            ForEach([0, 5, 10, 15, 20], id: \.self) { count in
                                                Button(action: {
                                                    diagnosticWordCount = count
                                                }) {
                                                    Text("\(count)")
                                                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                        .foregroundColor(diagnosticWordCount == count ? .white : AppTheme.textPrimary)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, AppTheme.spacingS)
                                                        .background(diagnosticWordCount == count ? AppTheme.accentOrange : AppTheme.backgroundSecondary)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Sentence Comprehension Selection
                                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                        Text("Sentence Comprehension")
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text("Select number of sentences (up to 10)")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                        
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacingS), count: 4), spacing: AppTheme.spacingS) {
                                            ForEach([0, 5, 10], id: \.self) { count in
                                                Button(action: {
                                                    diagnosticSentenceCount = count
                                                }) {
                                                    Text("\(count)")
                                                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                        .foregroundColor(diagnosticSentenceCount == count ? .white : AppTheme.textPrimary)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, AppTheme.spacingS)
                                                        .background(diagnosticSentenceCount == count ? AppTheme.accentOrange : AppTheme.backgroundSecondary)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Sentences in Noise Selection
                                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                        Text("Sentences in Noise")
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text("Select number of sentences (up to 10)")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                        
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.spacingS), count: 4), spacing: AppTheme.spacingS) {
                                            ForEach([0, 5, 10], id: \.self) { count in
                                                Button(action: {
                                                    diagnosticNoiseSentenceCount = count
                                                }) {
                                                    Text("\(count)")
                                                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                        .foregroundColor(diagnosticNoiseSentenceCount == count ? .white : AppTheme.textPrimary)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, AppTheme.spacingS)
                                                        .background(diagnosticNoiseSentenceCount == count ? AppTheme.accentOrange : AppTheme.backgroundSecondary)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Start Test Button
                                    if diagnosticWordCount > 0 || diagnosticSentenceCount > 0 || diagnosticNoiseSentenceCount > 0 {
                                        ResponsiveButton(
                                            text: "Start Diagnostic Test",
                                            action: {
                                                startDiagnosticTest()
                                            },
                                            layout: layout,
                                            style: .primary,
                                            icon: "play.fill"
                                        )
                                        .padding(.top, AppTheme.spacingM)
                                    }
                                }
                            } else if currentQuestionIndex < currentDiagnosticItems.count {
                                let currentItem = currentDiagnosticItems[currentQuestionIndex]
                                
                                Group {
                                    if !showingFeedback {
                                        // MATCH PRACTICE SCREENS EXACTLY - Speech Recognition UI
                                        VStack(spacing: AppTheme.spacingM) {
                                            HStack {
                                                Text("Difficulty:")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                Text(currentItem.difficulty.label)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(getDifficultyColor(currentItem.difficulty))
                                                Spacer()
                                            }
                                            .padding(.horizontal, AppTheme.spacingS)
                                            .padding(.vertical, AppTheme.spacingXS)
                                            .background(AppTheme.backgroundSecondary)
                                            .cornerRadius(8)
                                            
                                            // Play button - matches practice screens - AUTO-STARTS RECORDING
                                            ResponsiveButton(
                                                text: currentItem.type == .word ? "🔊 Play Word" : "🔊 Play Sentence",
                                                action: {
                                                    print("🔵 [DIAGNOSTIC] Play button clicked!")
                                                    print("   waitingForRecordingStart: \(waitingForRecordingStart)")
                                                    print("   speechManager.isRecording: \(speechManager.isRecording)")
                                                    print("   speechManager.isAuthorized: \(speechManager.isAuthorized)")
                                                    print("   audioManager.isSpeaking: \(audioManager.isSpeaking)")
                                                    
                                                    // Prevent double-tap if already waiting for recording
                                                    guard !waitingForRecordingStart else {
                                                        print("⚠️ Already waiting for recording - BLOCKING CLICK")
                                                        return
                                                    }
                                                    
                                                    // If currently recording, stop it temporarily
                                                    let wasRecording = speechManager.isRecording
                                                    if wasRecording {
                                                        print("🔄 Temporarily stopping recording to play audio")
                                                        speechManager.stopRecording()
                                                        // Cancel any existing timeout since we're pausing
                                                        recordingTimeoutTask?.cancel()
                                                        recordingTimeoutTask = nil
                                                    }
                                                    
                                                    print("✅ [DIAGNOSTIC] Starting audio playback process")
                                                    waitingForRecordingStart = true
                                                    
                                                    // Handle background noise for sentences in noise
                                                    if currentItem.type == .sentenceInNoise {
                                                        backgroundNoiseEnabled = true
                                                        if backgroundNoiseVolume < 0.6 {
                                                            backgroundNoiseVolume = 0.7
                                                        }
                                                        startBackgroundNoiseIfEnabled()
                                                    } else {
                                                        stopBackgroundNoise()
                                                    }
                                                    
                                                    // Timeout fallback: Start recording after max time (3s for words, 5s for sentences)
                                                    let timeoutDelay = currentItem.type == .word ? 3.0 : 5.0
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + timeoutDelay) {
                                                        guard waitingForRecordingStart, !speechManager.isRecording else { return }
                                                        print("⚠️ Audio callback timeout - starting recording anyway")
                                                        waitingForRecordingStart = false
                                                        
                                                        // Force UI update
                                                        audioManager.isSpeaking = false
                                                        
                                                        speechManager.requestAuthorization()
                                                        firstWordDetected = false
                                                        speechManager.onFirstWordDetected = {
                                                            let generator = UINotificationFeedbackGenerator()
                                                            generator.notificationOccurred(.success)
                                                            firstWordDetected = true
                                                            print("✅ First word detected in Diagnostic Test!")
                                                        }
                                                        print("🎤 [TIMEOUT FALLBACK] Starting recording")
                                                        print("   Authorization status: \(speechManager.isAuthorized)")
                                                        speechManager.startRecording()
                                                        print("   isRecording after call: \(speechManager.isRecording)")
                                                        
                                                        // WORKAROUND: If recording didn't start due to auth, check again after delay
                                                        if !speechManager.isRecording {
                                                            print("⚠️ [TIMEOUT] Recording didn't start - likely authorization issue")
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                                if !speechManager.isRecording && speechManager.isAuthorized {
                                                                    print("🔄 [TIMEOUT] Retrying startRecording after authorization granted")
                                                                    speechManager.startRecording()
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    // Play audio and start recording when it finishes
                                                    audioManager.playAudio(currentItem.content) { success in
                                                        // Audio finished - wait for audio session to fully release
                                                        // Extra long delay needed when background noise is also playing
                                                        // The audio system needs time to handle 3 simultaneous components
                                                        let delayTime = currentItem.type == .sentenceInNoise ? 1.0 : 0.4
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                                                            guard waitingForRecordingStart, !speechManager.isRecording else {
                                                                print("⚠️ Recording already started - skipping duplicate start")
                                                                return
                                                            }
                                                            
                                                            waitingForRecordingStart = false
                                                            
                                                            speechManager.requestAuthorization()
                                                            firstWordDetected = false
                                                            
                                                            // Set up first word detection callback
                                                            speechManager.onFirstWordDetected = {
                                                                let generator = UINotificationFeedbackGenerator()
                                                                generator.notificationOccurred(.success)
                                                                firstWordDetected = true
                                                                print("✅ First word detected in Diagnostic Test!")
                                                            }
                                                            
                                                            // Force UI update by ensuring isSpeaking is false
                                                            // This prevents UI from getting stuck showing "Playing..." when recording starts
                                                            audioManager.isSpeaking = false
                                                            
                                                            print("🎤 [DIAGNOSTIC] About to start recording (delay: \(delayTime)s)")
                                                            print("   Authorization status: \(speechManager.isAuthorized)")
                                                            speechManager.startRecording()
                                                            print("✅ [DIAGNOSTIC] startRecording() called")
                                                            print("   isRecording after call: \(speechManager.isRecording)")
                                                            
                                                            // WORKAROUND: If recording didn't start due to auth, check again after delay
                                                            if !speechManager.isRecording {
                                                                print("⚠️ [DIAGNOSTIC] Recording didn't start - likely authorization issue")
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                                    if !speechManager.isRecording && speechManager.isAuthorized {
                                                                        print("🔄 [DIAGNOSTIC] Retrying startRecording after authorization granted")
                                                                        speechManager.startRecording()
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                },
                                                layout: layout,
                                                style: .primary,
                                                icon: "play.fill"
                                            )
                                            
                                            // Speech Recognition UI - MATCHES PRACTICE SCREENS EXACTLY
                                            VStack(spacing: AppTheme.spacingM) {
                                                // Dynamic status text based on recording state
                                                if audioManager.isSpeaking {
                                                    HStack(spacing: 6) {
                                                        Image(systemName: "speaker.wave.3.fill")
                                                            .foregroundColor(AppTheme.primaryBlue)
                                                        Text(currentItem.type == .word ? "🔊 Playing word... Listen carefully!" : "🔊 Playing sentence... Listen carefully!")
                                                    }
                                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                    .foregroundColor(AppTheme.primaryBlue)
                                                } else if waitingForRecordingStart {
                                                    HStack(spacing: 6) {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                                        Text("⏳ Preparing microphone...")
                                                    }
                                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                    .foregroundColor(.orange)
                                                } else if speechManager.isRecording {
                                                    if firstWordDetected {
                                                        HStack(spacing: 6) {
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .foregroundColor(.green)
                                                            Text("Word detected! Tap STOP when done")
                                                        }
                                                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                        .foregroundColor(.green)
                                                    } else {
                                                        HStack(spacing: 6) {
                                                            Circle()
                                                                .fill(AppTheme.error)
                                                                .frame(width: 8, height: 8)
                                                            Text("Listening... Start speaking!")
                                                        }
                                                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                        .foregroundColor(AppTheme.error)
                                                    }
                                                } else {
                                                    Text(currentItem.type == .word ? "Tap 'Play Word' to begin" : "Tap 'Play Sentence' to begin")
                                                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                }
                                                
                                                // Microphone Status Display (MATCHES PRACTICE SCREENS)
                                                VStack(spacing: AppTheme.spacingS) {
                                                    Image(systemName: speechManager.isRecording ? "waveform" : "mic.slash.circle")
                                                        .font(.system(size: 64))
                                                        .foregroundColor(speechManager.isRecording ? (firstWordDetected ? .green : .blue) : AppTheme.textSecondary)
                                                        .scaleEffect(speechManager.isRecording ? 1.2 : 1.0)
                                                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechManager.isRecording)
                                                    
                                                    Text(firstWordDetected ? "✅ Ready to stop!" : (speechManager.isRecording ? "🎤 Auto-detecting your speech..." : "Ready to listen"))
                                                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                                        .foregroundColor(firstWordDetected ? .green : (speechManager.isRecording ? .blue : AppTheme.textSecondary))
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, AppTheme.spacingL)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(speechManager.isRecording ? (firstWordDetected ? Color.green.opacity(0.1) : Color.blue.opacity(0.1)) : Color.gray.opacity(0.05))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(speechManager.isRecording ? (firstWordDetected ? Color.green : Color.blue) : Color.gray.opacity(0.3), lineWidth: 2)
                                                )
                                                
                                                // Show recognized text in real-time - MATCHES PRACTICE SCREENS
                                                if speechManager.isRecording && !speechManager.recognizedText.isEmpty {
                                                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                                        HStack {
                                                            Text("YOU SAID:")
                                                                .font(.system(size: 14, weight: .bold))
                                                                .foregroundColor(.white)
                                                            Spacer()
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .foregroundColor(.white)
                                                        }
                                                        .padding(.horizontal, AppTheme.spacingM)
                                                        .padding(.vertical, AppTheme.spacingS)
                                                        .background(AppTheme.success)
                                                        
                                                        Text(speechManager.recognizedText)
                                                            .font(.system(size: layout.bodyFontSize + 4, weight: .bold))
                                                            .foregroundColor(AppTheme.textPrimary)
                                                            .padding(AppTheme.spacingL)
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .background(Color.white)
                                                    }
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(AppTheme.success, lineWidth: 3)
                                                    )
                                                    .shadow(color: AppTheme.success.opacity(0.3), radius: 8, x: 0, y: 4)
                                                }
                                                
                                                // BIG STOP BUTTON - MATCHES PRACTICE SCREENS
                                                if speechManager.isRecording {
                                                    Button(action: {
                                                        // Trigger haptic feedback
                                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                                        generator.impactOccurred()
                                                        
                                                        // Save recognized text BEFORE stopping
                                                        spokenText = speechManager.recognizedText
                                                        print("📝 [Diagnostic] Saved: '\(spokenText)'")
                                                        
                                                        speechManager.stopRecording()
                                                        print("🛑 Recording stopped by user via STOP button")
                                                        
                                                        // Submit diagnostic answer (checks if correct)
                                                        submitDiagnosticAnswer()
                                                    }) {
                                                        HStack(spacing: 12) {
                                                            Image(systemName: "stop.circle.fill")
                                                                .font(.system(size: 28))
                                                            Text("STOP & GET FEEDBACK")
                                                                .font(.system(size: 18, weight: .bold))
                                                        }
                                                        .foregroundColor(.white)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 20)
                                                        .background(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [AppTheme.error, Color.red.opacity(0.8)]),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .cornerRadius(16)
                                                        .shadow(color: AppTheme.error.opacity(0.4), radius: 12, x: 0, y: 6)
                                                    }
                                                }
                                            }
                                            
                                            progressView(current: currentQuestionIndex + 1, total: currentDiagnosticItems.count, layout: layout)
                                        }
                                    } else {
                                        // FEEDBACK SCREEN (like other exercises)
                                        diagnosticFeedbackView(currentItem: currentItem, layout: layout)
                                    }
                                }
                                .onChange(of: currentQuestionIndex) { _ in
                                    // Reset feedback state when question changes
                                    userAnswer = ""
                                    showingFeedback = false
                                    isAnswerCorrect = false
                                    waitingForRecordingStart = false // Reset waiting flag
                                    resetSpeechState()
                                    print("🔄 [DIAGNOSTIC] Question changed - all states reset")
                                    
                                    // Don't auto-play - user must tap play button
                                }
                            } else {
                                diagnosticCompletionView(layout: layout)
                            }
                        }
                    }
                    
                    navigationButtons(layout: layout)
                }
                .padding()
            }
        }
    }
    
    // MARK: - Custom Practice Screen
    @ViewBuilder
    func customPracticeScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .homescreen
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Custom Practice")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    // Header Card
                    ModernCard(padding: AppTheme.spacingL) {
                        VStack(spacing: AppTheme.spacingM) {
                            HStack {
                                Image(systemName: TrainingCategory.customPractice.icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(TrainingCategory.customPractice.color)
                                Text("Custom Practice")
                                    .font(.system(size: layout.titleFontSize, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            
                            Text("Practice with your own uploaded words and sentences")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    // Load custom items from UserDefaults
                    let customWords: [DemoWord] = {
                        guard let data = UserDefaults.standard.data(forKey: "customWords"),
                              let words = try? JSONDecoder().decode([DemoWord].self, from: data) else {
                            return []
                        }
                        return words
                    }()
                    
                    let customSentences: [DemoSentence] = {
                        guard let data = UserDefaults.standard.data(forKey: "customSentences"),
                              let sentences = try? JSONDecoder().decode([DemoSentence].self, from: data) else {
                            return []
                        }
                        return sentences
                    }()
                    
                    let customMatchedPairs: [Word] = {
                        guard let data = UserDefaults.standard.data(forKey: "customMatchedPairs"),
                              let pairs = try? JSONDecoder().decode([Word].self, from: data) else {
                            return []
                        }
                        return pairs
                    }()
                    
                    // Custom Words Section with Selection
                    customWordsSection(customWords: customWords, layout: layout)
                    
                    // Custom Sentences Section with Selection
                    customSentencesSection(customSentences: customSentences, layout: layout)
                    
                    // Custom Matched Pairs Section with Selection
                    customMatchedPairsSection(customMatchedPairs: customMatchedPairs, layout: layout)
                    
                    // Clear All Data Button (for testing/debugging)
                    if !customWords.isEmpty || !customSentences.isEmpty || !customMatchedPairs.isEmpty {
                        ModernCard(padding: AppTheme.spacingL) {
                            Button(action: {
                                clearAllCustomData()
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Clear All Custom Data")
                                }
                                .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    navigationButtons(layout: layout)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingL)
                .id(customItemsRefreshTrigger) // Force refresh when items are deleted
            }
        }
        
        // Custom Words Section with Selection
        @ViewBuilder
        func customWordsSection(customWords: [DemoWord], layout: ResponsiveLayoutHelper) -> some View {
            ModernCard(padding: AppTheme.spacingL) {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    // Header with Select and Add buttons
                    HStack {
                        Image(systemName: "textformat.size")
                            .foregroundColor(AppTheme.success)
                        Text("Custom Words")
                            .font(.system(size: layout.bodyFontSize + 2, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        
                        if isCustomWordsSelectionMode && !selectedCustomWordIndices.isEmpty {
                            Text("\(selectedCustomWordIndices.count) selected")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.accentOrange)
                        } else if !customWords.isEmpty {
                            Text("\(customWords.count) items")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        // Add button (green plus)
                        Button(action: {
                            uploadType = .words
                            showCustomUploadSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.success)
                        }
                        
                        // Select button
                        if !customWords.isEmpty {
                            Button(action: {
                                isCustomWordsSelectionMode.toggle()
                                if !isCustomWordsSelectionMode {
                                    selectedCustomWordIndices.removeAll()
                                }
                            }) {
                                Text(isCustomWordsSelectionMode ? "Cancel" : "Select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryBlue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.primaryBlue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    if customWords.isEmpty {
                        Text("No custom words uploaded yet")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(8)
                    } else {
                        // List of words
                        LazyVStack(spacing: AppTheme.spacingS) {
                            ForEach(Array(customWords.enumerated()), id: \.offset) { index, word in
                                customWordRow(word: word, index: index, layout: layout)
                            }
                        }
                        
                        // Actions
                        if isCustomWordsSelectionMode && !selectedCustomWordIndices.isEmpty {
                            VStack(spacing: AppTheme.spacingS) {
                                ResponsiveButton(
                                    text: "Practice Selected (\(selectedCustomWordIndices.count))",
                                    action: {
                                        let selectedWords = customWords.enumerated().filter { selectedCustomWordIndices.contains($0.offset) }.map { $0.element }
                                        startCustomWordsPractice(customWords: selectedWords)
                                        isCustomWordsSelectionMode = false
                                        selectedCustomWordIndices.removeAll()
                                    },
                                    layout: layout,
                                    style: .success,
                                    icon: "play.fill"
                                )
                                
                                Button(action: {
                                    deleteSelectedCustomWords(selectedIndices: Array(selectedCustomWordIndices))
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("Delete Selected")
                                    }
                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(8)
                                }
                            }
                        } else if !isCustomWordsSelectionMode {
                            ResponsiveButton(
                                text: "Practice All Words",
                                action: {
                                    startCustomWordsPractice(customWords: customWords)
                                },
                                layout: layout,
                                style: .primary,
                                icon: "play.fill"
                            )
                        }
                    }
                }
            }
        }
        
        @ViewBuilder
        func customWordRow(word: DemoWord, index: Int, layout: ResponsiveLayoutHelper) -> some View {
            HStack(spacing: AppTheme.spacingS) {
                if isCustomWordsSelectionMode {
                    Button(action: {
                        if selectedCustomWordIndices.contains(index) {
                            selectedCustomWordIndices.remove(index)
                        } else {
                            selectedCustomWordIndices.insert(index)
                        }
                    }) {
                        Image(systemName: selectedCustomWordIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(selectedCustomWordIndices.contains(index) ? AppTheme.success : AppTheme.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.word)
                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                if !isCustomWordsSelectionMode {
                    Button(action: {
                        deleteCustomWord(at: index)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(AppTheme.spacingM)
            .background(
                isCustomWordsSelectionMode && selectedCustomWordIndices.contains(index)
                ? AppTheme.primaryBlue.opacity(0.1)
                : AppTheme.backgroundSecondary
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isCustomWordsSelectionMode && selectedCustomWordIndices.contains(index)
                        ? AppTheme.primaryBlue
                        : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        
        // Custom Sentences Section
        @ViewBuilder
        func customSentencesSection(customSentences: [DemoSentence], layout: ResponsiveLayoutHelper) -> some View {
            ModernCard(padding: AppTheme.spacingL) {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    // Header with Select and Add buttons
                    HStack {
                        Image(systemName: "quote.bubble")
                            .foregroundColor(AppTheme.accentOrange)
                        Text("Custom Sentences")
                            .font(.system(size: layout.bodyFontSize + 2, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        
                        if isCustomSentencesSelectionMode && !selectedCustomSentenceIndices.isEmpty {
                            Text("\(selectedCustomSentenceIndices.count) selected")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.accentOrange)
                        } else if !customSentences.isEmpty {
                            Text("\(customSentences.count) items")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        // Add button (green plus)
                        Button(action: {
                            uploadType = .sentences
                            showCustomUploadSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.success)
                        }
                        
                        // Select button
                        if !customSentences.isEmpty {
                            Button(action: {
                                isCustomSentencesSelectionMode.toggle()
                                if !isCustomSentencesSelectionMode {
                                    selectedCustomSentenceIndices.removeAll()
                                }
                            }) {
                                Text(isCustomSentencesSelectionMode ? "Cancel" : "Select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryBlue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.primaryBlue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    if customSentences.isEmpty {
                        Text("No custom sentences uploaded yet")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(8)
                    } else {
                        LazyVStack(spacing: AppTheme.spacingS) {
                            ForEach(Array(customSentences.enumerated()), id: \.offset) { index, sentence in
                                customSentenceRow(sentence: sentence, index: index, layout: layout)
                            }
                        }
                        
                        if isCustomSentencesSelectionMode && !selectedCustomSentenceIndices.isEmpty {
                            VStack(spacing: AppTheme.spacingS) {
                                ResponsiveButton(
                                    text: "Practice Selected (\(selectedCustomSentenceIndices.count))",
                                    action: {
                                        let selectedSentences = customSentences.enumerated().filter { selectedCustomSentenceIndices.contains($0.offset) }.map { $0.element }
                                        startCustomSentencesPractice(customSentences: selectedSentences)
                                        isCustomSentencesSelectionMode = false
                                        selectedCustomSentenceIndices.removeAll()
                                    },
                                    layout: layout,
                                    style: .success,
                                    icon: "play.fill"
                                )
                                
                                Button(action: {
                                    deleteSelectedCustomSentences(selectedIndices: Array(selectedCustomSentenceIndices))
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("Delete Selected")
                                    }
                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(8)
                                }
                            }
                        } else if !isCustomSentencesSelectionMode {
                            ResponsiveButton(
                                text: "Practice All Sentences",
                                action: {
                                    startCustomSentencesPractice(customSentences: customSentences)
                                },
                                layout: layout,
                                style: .primary,
                                icon: "play.fill"
                            )
                        }
                    }
                }
            }
        }
        
        @ViewBuilder
        func customSentenceRow(sentence: DemoSentence, index: Int, layout: ResponsiveLayoutHelper) -> some View {
            HStack(spacing: AppTheme.spacingS) {
                if isCustomSentencesSelectionMode {
                    Button(action: {
                        if selectedCustomSentenceIndices.contains(index) {
                            selectedCustomSentenceIndices.remove(index)
                        } else {
                            selectedCustomSentenceIndices.insert(index)
                        }
                    }) {
                        Image(systemName: selectedCustomSentenceIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(selectedCustomSentenceIndices.contains(index) ? AppTheme.success : AppTheme.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sentence.sentence)
                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if !isCustomSentencesSelectionMode {
                    Button(action: {
                        deleteCustomSentence(at: index)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(AppTheme.spacingM)
            .background(
                isCustomSentencesSelectionMode && selectedCustomSentenceIndices.contains(index)
                ? AppTheme.primaryBlue.opacity(0.1)
                : AppTheme.backgroundSecondary
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isCustomSentencesSelectionMode && selectedCustomSentenceIndices.contains(index)
                        ? AppTheme.primaryBlue
                        : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        
        // Custom Matched Pairs Section
        @ViewBuilder
        func customMatchedPairsSection(customMatchedPairs: [Word], layout: ResponsiveLayoutHelper) -> some View {
            ModernCard(padding: AppTheme.spacingL) {
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    // Header with Select and Add buttons
                    HStack {
                        Image(systemName: "square.grid.2x2")
                            .foregroundColor(AppTheme.primaryBlue)
                        Text("Custom Matched Pairs")
                            .font(.system(size: layout.bodyFontSize + 2, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        
                        if isCustomMatchedPairsSelectionMode && !selectedCustomMatchedPairIndices.isEmpty {
                            Text("\(selectedCustomMatchedPairIndices.count) selected")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.accentOrange)
                        } else if !customMatchedPairs.isEmpty {
                            Text("\(customMatchedPairs.count) items")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        // Add button (green plus)
                        Button(action: {
                            uploadType = .matchedPairs
                            showCustomUploadSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.success)
                        }
                        
                        // Select button
                        if !customMatchedPairs.isEmpty {
                            Button(action: {
                                isCustomMatchedPairsSelectionMode.toggle()
                                if !isCustomMatchedPairsSelectionMode {
                                    selectedCustomMatchedPairIndices.removeAll()
                                }
                            }) {
                                Text(isCustomMatchedPairsSelectionMode ? "Cancel" : "Select")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryBlue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.primaryBlue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    if customMatchedPairs.isEmpty {
                        Text("No custom matched pairs uploaded yet")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(8)
                    } else {
                        LazyVStack(spacing: AppTheme.spacingS) {
                            ForEach(Array(customMatchedPairs.enumerated()), id: \.offset) { index, pair in
                                customMatchedPairRow(pair: pair, index: index, layout: layout)
                            }
                        }
                        
                        if isCustomMatchedPairsSelectionMode && !selectedCustomMatchedPairIndices.isEmpty {
                            VStack(spacing: AppTheme.spacingS) {
                                ResponsiveButton(
                                    text: "Practice Selected (\(selectedCustomMatchedPairIndices.count))",
                                    action: {
                                        let selectedPairs = customMatchedPairs.enumerated().filter { selectedCustomMatchedPairIndices.contains($0.offset) }.map { $0.element }
                                        startCustomMatchedPairsPractice(customMatchedPairs: selectedPairs)
                                        isCustomMatchedPairsSelectionMode = false
                                        selectedCustomMatchedPairIndices.removeAll()
                                    },
                                    layout: layout,
                                    style: .success,
                                    icon: "play.fill"
                                )
                                
                                Button(action: {
                                    deleteSelectedCustomMatchedPairs(selectedIndices: Array(selectedCustomMatchedPairIndices))
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("Delete Selected")
                                    }
                                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(8)
                                }
                            }
                        } else if !isCustomMatchedPairsSelectionMode {
                            ResponsiveButton(
                                text: "Practice All Matched Pairs",
                                action: {
                                    startCustomMatchedPairsPractice(customMatchedPairs: customMatchedPairs)
                                },
                                layout: layout,
                                style: .primary,
                                icon: "play.fill"
                            )
                        }
                    }
                }
            }
        }
        
        @ViewBuilder
        func customMatchedPairRow(pair: Word, index: Int, layout: ResponsiveLayoutHelper) -> some View {
            HStack(spacing: AppTheme.spacingS) {
                if isCustomMatchedPairsSelectionMode {
                    Button(action: {
                        if selectedCustomMatchedPairIndices.contains(index) {
                            selectedCustomMatchedPairIndices.remove(index)
                        } else {
                            selectedCustomMatchedPairIndices.insert(index)
                        }
                    }) {
                        Image(systemName: selectedCustomMatchedPairIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(selectedCustomMatchedPairIndices.contains(index) ? AppTheme.success : AppTheme.textSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(pair.firstWord) vs \(pair.lastWord)")
                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                if !isCustomMatchedPairsSelectionMode {
                    Button(action: {
                        deleteCustomMatchedPair(at: index)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(AppTheme.spacingM)
            .background(
                isCustomMatchedPairsSelectionMode && selectedCustomMatchedPairIndices.contains(index)
                ? AppTheme.primaryBlue.opacity(0.1)
                : AppTheme.backgroundSecondary
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isCustomMatchedPairsSelectionMode && selectedCustomMatchedPairIndices.contains(index)
                        ? AppTheme.primaryBlue
                        : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        
        // MARK: - Custom Item Management Functions
        
        func deleteCustomWord(at index: Int) {
            guard var customWords = loadCustomWords() else { return }
            guard index >= 0 && index < customWords.count else {
                print("⚠️ Invalid index \(index) for customWords array of size \(customWords.count)")
                return
            }
            customWords.remove(at: index)
            saveCustomWords(customWords)
            customItemsRefreshTrigger = UUID() // Force view refresh
            print("✅ Deleted custom word at index \(index)")
        }
        
        func deleteCustomSentence(at index: Int) {
            guard var customSentences = loadCustomSentences() else { return }
            guard index >= 0 && index < customSentences.count else {
                print("⚠️ Invalid index \(index) for customSentences array of size \(customSentences.count)")
                return
            }
            customSentences.remove(at: index)
            saveCustomSentences(customSentences)
            customItemsRefreshTrigger = UUID() // Force view refresh
            print("✅ Deleted custom sentence at index \(index)")
        }
        
        func deleteSelectedCustomWords(selectedIndices: [Int]) {
            guard var customWords = loadCustomWords() else { return }
            let sortedIndices = selectedIndices.sorted(by: >)
            for index in sortedIndices {
                if index >= 0 && index < customWords.count {
                    customWords.remove(at: index)
                }
            }
            saveCustomWords(customWords)
            selectedCustomWordIndices.removeAll()
            isCustomWordsSelectionMode = false
            customItemsRefreshTrigger = UUID() // Force view refresh
            print("✅ Deleted \(sortedIndices.count) custom words")
        }
        
        func deleteSelectedCustomSentences(selectedIndices: [Int]) {
            guard var customSentences = loadCustomSentences() else { return }
            let sortedIndices = selectedIndices.sorted(by: >)
            for index in sortedIndices {
                if index >= 0 && index < customSentences.count {
                    customSentences.remove(at: index)
                }
            }
            saveCustomSentences(customSentences)
            selectedCustomSentenceIndices.removeAll()
            isCustomSentencesSelectionMode = false
            customItemsRefreshTrigger = UUID() // Force view refresh
            print("✅ Deleted \(sortedIndices.count) custom sentences")
        }
        
        func loadCustomWords() -> [DemoWord]? {
            guard let data = UserDefaults.standard.data(forKey: "customWords"),
                  let words = try? JSONDecoder().decode([DemoWord].self, from: data) else {
                return nil
            }
            return words
        }
        
        func loadCustomSentences() -> [DemoSentence]? {
            guard let data = UserDefaults.standard.data(forKey: "customSentences"),
                  let sentences = try? JSONDecoder().decode([DemoSentence].self, from: data) else {
                return nil
            }
            return sentences
        }
        
        func saveCustomWords(_ words: [DemoWord]) {
            if let encoded = try? JSONEncoder().encode(words) {
                UserDefaults.standard.set(encoded, forKey: "customWords")
            }
        }
        
        func saveCustomSentences(_ sentences: [DemoSentence]) {
            if let encoded = try? JSONEncoder().encode(sentences) {
                UserDefaults.standard.set(encoded, forKey: "customSentences")
            }
        }
        
        func loadCustomMatchedPairs() -> [Word]? {
            guard let data = UserDefaults.standard.data(forKey: "customMatchedPairs"),
                  let pairs = try? JSONDecoder().decode([Word].self, from: data) else {
                return nil
            }
            return pairs
        }
        
        func saveCustomMatchedPairs(_ pairs: [Word]) {
            if let encoded = try? JSONEncoder().encode(pairs) {
                UserDefaults.standard.set(encoded, forKey: "customMatchedPairs")
            }
        }
        
        func deleteCustomMatchedPair(at index: Int) {
            guard var customMatchedPairs = loadCustomMatchedPairs() else { return }
            guard index >= 0 && index < customMatchedPairs.count else {
                print("⚠️ Invalid index \(index) for customMatchedPairs array of size \(customMatchedPairs.count)")
                return
            }
            customMatchedPairs.remove(at: index)
            saveCustomMatchedPairs(customMatchedPairs)
            customItemsRefreshTrigger = UUID() // Force view refresh
            print("✅ Deleted custom matched pair at index \(index)")
        }
        
        func deleteSelectedCustomMatchedPairs(selectedIndices: [Int]) {
            guard var customMatchedPairs = loadCustomMatchedPairs() else { return }
            let sortedIndices = selectedIndices.sorted(by: >)
            for index in sortedIndices {
                if index >= 0 && index < customMatchedPairs.count {
                    customMatchedPairs.remove(at: index)
                }
            }
            saveCustomMatchedPairs(customMatchedPairs)
            selectedCustomMatchedPairIndices.removeAll()
            isCustomMatchedPairsSelectionMode = false
            customItemsRefreshTrigger = UUID() // Force view refresh
            print("✅ Deleted \(sortedIndices.count) custom matched pairs")
        }
        
        // Clear all custom data
        func clearAllCustomData() {
            UserDefaults.standard.removeObject(forKey: "customWords")
            UserDefaults.standard.removeObject(forKey: "customSentences")
            UserDefaults.standard.removeObject(forKey: "customMatchedPairs")
            selectedCustomWordIndices.removeAll()
            selectedCustomSentenceIndices.removeAll()
            selectedCustomMatchedPairIndices.removeAll()
            isCustomWordsSelectionMode = false
            isCustomSentencesSelectionMode = false
            isCustomMatchedPairsSelectionMode = false
            customItemsRefreshTrigger = UUID() // Force view refresh
            print("✅ Cleared all custom words and sentences")
        }
        
        // MARK: - Helper Views
        
        @ViewBuilder
        func choiceButton(choice: String, layout: ResponsiveLayoutHelper) -> some View {
            let isSelected = userAnswer == choice
            let correctAnswer = getCurrentCorrectAnswer()
            let isCorrectChoice = choice == correctAnswer
            
            // Determine colors based on feedback state
            let backgroundColor: Color = {
                if showingFeedback && isSelected {
                    return isAnswerCorrect ? Color.green : Color.red
                } else if isSelected {
                    return AppTheme.accentOrange
                } else if showingFeedback && isCorrectChoice {
                    return Color.green.opacity(0.3)
                } else {
                    return AppTheme.backgroundSecondary
                }
            }()
            
            let textColor: Color = {
                if showingFeedback && (isSelected || isCorrectChoice) {
                    return .white
                } else if isSelected {
                    return .white
                } else {
                    return AppTheme.textPrimary
                }
            }()
            
            let borderColor: Color = {
                if showingFeedback && isSelected {
                    return isAnswerCorrect ? Color.green : Color.red
                } else if isSelected {
                    return AppTheme.accentOrange
                } else if showingFeedback && isCorrectChoice {
                    return Color.green
                } else {
                    return AppTheme.textTertiary.opacity(0.3)
                }
            }()
            
            Button(action: {
                handleChoiceSelection(choice)
            }) {
                HStack {
                    Text(choice)
                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    // Show checkmark or X icon when feedback is showing
                    if showingFeedback && isSelected {
                        Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    } else if showingFeedback && isCorrectChoice && !isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingS)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: showingFeedback && (isSelected || isCorrectChoice) ? 2 : 1)
                )
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(showingFeedback) // Disable all buttons while showing feedback
        }
        
        @ViewBuilder
        func sentenceChoiceButton(choice: String, layout: ResponsiveLayoutHelper) -> some View {
            let isSelected = userAnswer == choice
            let correctAnswer = getCurrentCorrectAnswer()
            let isCorrectChoice = choice == correctAnswer
            
            // Determine colors based on feedback state
            let backgroundColor: Color = {
                if showingFeedback && isSelected {
                    return isAnswerCorrect ? Color.green : Color.red
                } else if isSelected {
                    return AppTheme.accentOrange
                } else if showingFeedback && isCorrectChoice {
                    // Show the correct answer in green after selection
                    return Color.green.opacity(0.3)
                } else {
                    return AppTheme.backgroundSecondary
                }
            }()
            
            let textColor: Color = {
                if showingFeedback && (isSelected || isCorrectChoice) {
                    return .white
                } else if isSelected {
                    return .white
                } else {
                    return AppTheme.textPrimary
                }
            }()
            
            let borderColor: Color = {
                if showingFeedback && isSelected {
                    return isAnswerCorrect ? Color.green : Color.red
                } else if isSelected {
                    return AppTheme.accentOrange
                } else if showingFeedback && isCorrectChoice {
                    return Color.green
                } else {
                    return AppTheme.textTertiary.opacity(0.3)
                }
            }()
            
            Button(action: {
                handleChoiceSelection(choice)
            }) {
                HStack {
                    Text(choice)
                        .font(.system(size: layout.bodyFontSize - 1, weight: .medium))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Show checkmark or X icon when feedback is showing
                    if showingFeedback && isSelected {
                        Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    } else if showingFeedback && isCorrectChoice && !isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
                .padding(AppTheme.spacingS)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: showingFeedback && (isSelected || isCorrectChoice) ? 2 : 1)
                )
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(showingFeedback) // Disable all buttons while showing feedback
        }
        
        @ViewBuilder
        func progressView(current: Int, total: Int, layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: AppTheme.spacingXS) {
                HStack {
                    Text("Question \(current) of \(total)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(Int((Double(current) / Double(total)) * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.accentOrange)
                }
                
                ProgressView(value: Double(current), total: Double(total))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.accentOrange))
                    .scaleEffect(y: 1.5)
            }
        }
        
        @ViewBuilder
        func completionView(categoryName: String, layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: AppTheme.spacingM) {
                // Results summary card
                if let summary = currentTestSummary {
                    scoreDisplayCard(summary: summary, layout: layout)
                } else {
                    // Fallback for demo mode
                    demoCompletionView(categoryName: categoryName, layout: layout)
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let summary = currentTestSummary {
                    ExportResultsView(summary: summary, showingExportSheet: $showingExportSheet)
                }
            }
        }
        
        @ViewBuilder
        func scoreDisplayCard(summary: TestSummary, layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: AppTheme.spacingL) {
                // Header with score
                VStack(spacing: AppTheme.spacingS) {
                    Image(systemName: summary.accuracy >= 0.8 ? "star.fill" : summary.accuracy >= 0.6 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(summary.accuracy >= 0.8 ? AppTheme.accentOrange : summary.accuracy >= 0.6 ? AppTheme.success : AppTheme.warning)
                    
                    Text("Test Complete!")
                        .font(.system(size: layout.titleFontSize, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(summary.category.rawValue) Results")
                        .font(.system(size: layout.bodyFontSize))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                // Score summary
                VStack(spacing: AppTheme.spacingM) {
                    HStack(spacing: AppTheme.spacingL) {
                        VStack {
                            Text("\(summary.score)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppTheme.accentOrange)
                            Text("Correct")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        VStack {
                            Text("\(summary.totalQuestions)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Total")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        VStack {
                            Text(summary.accuracyPercentage)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(summary.accuracy >= 0.8 ? AppTheme.success : summary.accuracy >= 0.6 ? AppTheme.accentOrange : AppTheme.warning)
                            Text("Accuracy")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingL)
                    
                    // Additional stats
                    HStack(spacing: AppTheme.spacingL) {
                        VStack {
                            Text(summary.testDurationFormatted)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Duration")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        VStack {
                            Text(summary.averageResponseTime)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Avg Time")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        VStack {
                            Text(summary.voiceUsed.displayName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(1)
                            Text("Voice")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(AppTheme.spacingM)
                .background(AppTheme.backgroundSecondary)
                .cornerRadius(12)
                
                // Action buttons
                VStack(spacing: AppTheme.spacingS) {
                    ResponsiveButton(
                        text: "📤 Export Results",
                        action: {
                            showingExportSheet = true
                        },
                        layout: layout,
                        style: .primary,
                        icon: "square.and.arrow.up"
                    )
                    
                    ResponsiveButton(
                        text: "Try Again",
                        action: {
                            restartTest()
                        },
                        layout: layout,
                        style: .accent,
                        icon: "arrow.clockwise"
                    )
                    
                    ResponsiveButton(
                        text: "← Home",
                        action: {
                            screen = .homescreen
                        },
                        layout: layout,
                        style: .secondary,
                        icon: "house"
                    )
                }
            }
        }
        
        @ViewBuilder
        func demoCompletionView(categoryName: String, layout: ResponsiveLayoutHelper) -> some View {
            VStack(spacing: AppTheme.spacingM) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(AppTheme.success)
                
                Text("Training Complete!")
                    .font(.system(size: layout.titleFontSize, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("You've completed the \(categoryName) training session!")
                    .font(.system(size: layout.bodyFontSize))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                ResponsiveButton(
                    text: "Practice Again",
                    action: {
                        restartTest()
                    },
                    layout: layout,
                    style: .accent,
                    icon: "arrow.clockwise"
                )
            }
        }
    }
    
    
    func restartTest() {
        currentQuestionIndex = 0
        userAnswer = ""
        testResults = []
        currentScore = 0
        currentTestSummary = nil
        questionStartTime = Date()
        testStartTime = Date()
    }
    
    @ViewBuilder
    func diagnosticCompletionView(layout: ResponsiveLayoutHelper) -> some View {
        let totalQuestions = currentDiagnosticItems.count
        let correctAnswers = testResults.filter { $0.isCorrect }.count
        let percentageScore = totalQuestions > 0 ? (Double(correctAnswers) / Double(totalQuestions)) * 100 : 0
        
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: "stethoscope")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(AppTheme.primaryBlue)
            
            Text("Assessment Complete!")
                .font(.system(size: layout.titleFontSize, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            // Score Display
            VStack(spacing: AppTheme.spacingS) {
                Text("\(Int(percentageScore))%")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(percentageScore >= 80 ? AppTheme.success : percentageScore >= 60 ? AppTheme.accentOrange : AppTheme.error)
                
                Text("\(correctAnswers) out of \(totalQuestions) correct")
                    .font(.system(size: layout.bodyFontSize))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.vertical, AppTheme.spacingM)
            
            // Performance breakdown
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    Text("Word Recognition:")
                        .font(.system(size: layout.bodyFontSize - 2))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    let wordResults = testResults.filter { result in
                        currentDiagnosticItems.first(where: { $0.content == result.question })?.type == .word
                    }
                    let wordCorrect = wordResults.filter { $0.isCorrect }.count
                    let wordTotal = wordResults.count
                    Text("\(wordCorrect)/\(wordTotal)")
                        .font(.system(size: layout.bodyFontSize - 2, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                HStack {
                    Text("Sentence Comprehension:")
                        .font(.system(size: layout.bodyFontSize - 2))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    let sentenceResults = testResults.filter { result in
                        currentDiagnosticItems.first(where: { $0.content == result.question })?.type == .sentence
                    }
                    let sentenceCorrect = sentenceResults.filter { $0.isCorrect }.count
                    let sentenceTotal = sentenceResults.count
                    Text("\(sentenceCorrect)/\(sentenceTotal)")
                        .font(.system(size: layout.bodyFontSize - 2, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                HStack {
                    Text("Sentences in Noise:")
                        .font(.system(size: layout.bodyFontSize - 2))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    let noiseResults = testResults.filter { result in
                        currentDiagnosticItems.first(where: { $0.content == result.question })?.type == .sentenceInNoise
                    }
                    let noiseCorrect = noiseResults.filter { $0.isCorrect }.count
                    let noiseTotal = noiseResults.count
                    Text("\(noiseCorrect)/\(noiseTotal)")
                        .font(.system(size: layout.bodyFontSize - 2, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(AppTheme.spacingM)
            .background(AppTheme.backgroundSecondary)
            .cornerRadius(12)
            
            ResponsiveButton(
                text: "View Detailed Stats",
                action: {
                    screen = .statsscreen
                },
                layout: layout,
                style: .primary,
                icon: "chart.bar.fill"
            )
        }
    }
    
    // MARK: - AI Analysis Screen
    
    @ViewBuilder
    func aiAnalysisScreenContent(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: 0) {
            // Header Banner
            HStack {
                Button(action: {
                    screen = .homescreen
                    if buttonconfirm {
                        audioManager.playAudio("buttonpress")
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Practice Insights")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Empty space for symmetry
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    if isGeneratingAnalysis {
                        // Loading State
                        VStack(spacing: AppTheme.spacingL) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.purple))
                            
                            Text("Looking at Your Practice Patterns...")
                                .font(.system(size: layout.titleFontSize, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("We're reviewing your training sessions to share some observations and ideas that you can discuss with your audiologist.")
                                .font(.system(size: layout.bodyFontSize))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppTheme.spacingL)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppTheme.spacingXL * 2)
                    } else if let report = currentAIReport {
                        // Analysis Results
                        ModernCard(padding: AppTheme.spacingL) {
                            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(.purple)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("AI Analysis Complete")
                                            .font(.system(size: layout.titleFontSize, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text("Generated \(formatDate(report.generatedDate))")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                }
                                
                                Divider()
                                
                                // Overall Summary
                                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                    Text("Summary")
                                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    HStack(spacing: AppTheme.spacingL) {
                                        VStack(alignment: .leading) {
                                            Text("\(report.totalMissedWords)")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.orange)
                                            Text("Errors")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text("\(String(format: "%.0f%%", report.overallAccuracy * 100))")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.green)
                                            Text("Accuracy")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text("\(report.recommendations.count)")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.purple)
                                            Text("Recommendations")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // AI Insights Section (NEW - ChatGPT-generated insights)
                        if let aiInsights = report.aiInsights {
                            ModernCard(padding: AppTheme.spacingL, backgroundColor: Color.purple.opacity(0.05)) {
                                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 24))
                                            .foregroundColor(.purple)
                                        
                                        Text("AI-Generated Insights")
                                            .font(.system(size: layout.titleFontSize, weight: .bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Spacer()
                                    }
                                    
                                    Divider()
                                    
                                    // AI Summary
                                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                        Text("Summary")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(AppTheme.textSecondary)
                                        
                                        Text(aiInsights.summary)
                                            .font(.system(size: layout.bodyFontSize))
                                            .foregroundColor(AppTheme.textPrimary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    // Identified Trends
                                    if !aiInsights.identifiedTrends.isEmpty {
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("Identified Trends")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            ForEach(Array(aiInsights.identifiedTrends.enumerated()), id: \.offset) { index, trend in
                                                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                                                    Text("\(index + 1).")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(AppTheme.textSecondary)
                                                        .frame(width: 20, alignment: .leading)
                                                    
                                                    Text(trend)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Hypotheses
                                    if !aiInsights.hypotheses.isEmpty {
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("Possible Explanations")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            ForEach(Array(aiInsights.hypotheses.enumerated()), id: \.offset) { index, hypothesis in
                                                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                                                    Image(systemName: "lightbulb.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.yellow)
                                                        .frame(width: 20, alignment: .center)
                                                    
                                                    Text(hypothesis)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Possible Adjustments
                                    if !aiInsights.possibleAdjustments.isEmpty {
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            Text("Possible Areas to Explore with Audiologist")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.textSecondary)
                                            
                                            ForEach(Array(aiInsights.possibleAdjustments.enumerated()), id: \.offset) { index, adjustment in
                                                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                                                    Image(systemName: "arrow.right.circle.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.purple)
                                                        .frame(width: 20, alignment: .center)
                                                    
                                                    Text(adjustment)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(AppTheme.textPrimary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Disclaimer
                                    ModernCard(padding: AppTheme.spacingS, backgroundColor: AppTheme.warning.opacity(0.1)) {
                                        HStack(alignment: .top, spacing: AppTheme.spacingS) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.warning)
                                            
                                            Text("These are AI-generated suggestions for discussion, not medical advice. Your audiologist will provide personalized guidance.")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.textSecondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Recommendations Section
                        if !report.recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                Text("Observations & Ideas to Discuss")
                                    .font(.system(size: layout.titleFontSize, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                ForEach(report.recommendations) { recommendation in
                                    recommendationCard(recommendation: recommendation, layout: layout)
                                }
                            }
                        }
                        
                        // Frequency Analysis
                        if !report.frequencyAnalysis.isEmpty {
                            ModernCard(padding: AppTheme.spacingL) {
                                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                    Text("Frequency Range Analysis")
                                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    ForEach(Array(report.frequencyAnalysis.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { frequency in
                                        if let errorRate = report.frequencyAnalysis[frequency] {
                                            HStack {
                                                Text(frequency.rawValue)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                
                                                Spacer()
                                                
                                                Text("\(Int(errorRate))% error")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(errorRate > 40 ? .red : errorRate > 25 ? .orange : .green)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Phonetic Analysis
                        if !report.phoneticAnalysis.isEmpty {
                            ModernCard(padding: AppTheme.spacingL) {
                                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                    Text("Phonetic Pattern Analysis")
                                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    ForEach(Array(report.phoneticAnalysis.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { phonetic in
                                        if let errorRate = report.phoneticAnalysis[phonetic] {
                                            HStack {
                                                Text(phonetic.rawValue)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                
                                                Spacer()
                                                
                                                Text("\(Int(errorRate))% error")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(errorRate > 35 ? .red : errorRate > 20 ? .orange : .green)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Top Problematic Words
                        if !report.topProblematicWords.isEmpty {
                            ModernCard(padding: AppTheme.spacingL) {
                                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                    Text("Items That Need More Practice")
                                        .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    ForEach(Array(report.topProblematicWords.enumerated()), id: \.offset) { index, wordData in
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            HStack(alignment: .top) {
                                                Text("\(index + 1).")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                    .frame(width: 30, alignment: .leading)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    // Display item based on type
                                                    HStack {
                                                        if wordData.itemType == "sentence" {
                                                            Image(systemName: "text.quote")
                                                                .font(.system(size: 12))
                                                                .foregroundColor(.purple)
                                                        } else if wordData.itemType == "matchedPair" {
                                                            Image(systemName: "square.grid.2x2")
                                                                .font(.system(size: 12))
                                                                .foregroundColor(.blue)
                                                        } else {
                                                            Image(systemName: "textformat.size")
                                                                .font(.system(size: 12))
                                                                .foregroundColor(.green)
                                                        }
                                                        
                                                        Text(wordData.word)
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(AppTheme.textPrimary)
                                                    }
                                                    
                                                    // Show what user said vs what was expected (for sentences)
                                                    if wordData.itemType == "sentence" && !wordData.userSaidExamples.isEmpty {
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            ForEach(Array(wordData.userSaidExamples.prefix(2).enumerated()), id: \.offset) { exampleIndex, userSaid in
                                                                VStack(alignment: .leading, spacing: 2) {
                                                                    HStack {
                                                                        Text("Expected:")
                                                                            .font(.system(size: 11, weight: .medium))
                                                                            .foregroundColor(.green)
                                                                        Text(wordData.word)
                                                                            .font(.system(size: 11))
                                                                            .foregroundColor(AppTheme.textSecondary)
                                                                            .lineLimit(2)
                                                                    }
                                                                    HStack {
                                                                        Text("You said:")
                                                                            .font(.system(size: 11, weight: .medium))
                                                                            .foregroundColor(.red)
                                                                        Text(userSaid.isEmpty ? "(no response)" : userSaid)
                                                                            .font(.system(size: 11))
                                                                            .foregroundColor(AppTheme.textSecondary)
                                                                            .lineLimit(2)
                                                                    }
                                                                }
                                                                .padding(8)
                                                                .background(Color.orange.opacity(0.05))
                                                                .cornerRadius(6)
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                Text("\(wordData.missCount) miss\(wordData.missCount == 1 ? "" : "es")")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.red)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.red.opacity(0.1))
                                                    .cornerRadius(4)
                                            }
                                        }
                                        
                                        if index < report.topProblematicWords.count - 1 {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Phonetic Error Patterns - NEW!
                        if !report.phoneticErrors.isEmpty {
                            ModernCard(padding: AppTheme.spacingL, backgroundColor: AppTheme.warning.opacity(0.05)) {
                                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                                    HStack {
                                        Image(systemName: "waveform.path.badge.minus")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppTheme.warning)
                                        
                                        Text("Sound Confusion Patterns")
                                            .font(.system(size: layout.bodyFontSize, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                    }
                                    
                                    Text("These sound differences gave you the most trouble:")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    ForEach(Array(report.phoneticErrors.prefix(5).enumerated()), id: \.offset) { index, error in
                                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                            HStack {
                                                // Rank badge
                                                ZStack {
                                                    Circle()
                                                        .fill(AppTheme.warning.opacity(0.2))
                                                        .frame(width: 28, height: 28)
                                                    
                                                    Text("\(index + 1)")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(AppTheme.warning)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    // Word pair with highlighted difference
                                                    HStack(spacing: 4) {
                                                        Text(error.difference.word1)
                                                            .font(.system(size: 15, weight: .semibold))
                                                            .foregroundColor(AppTheme.textPrimary)
                                                        
                                                        Text("vs")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(AppTheme.textSecondary)
                                                        
                                                        Text(error.difference.word2)
                                                            .font(.system(size: 15, weight: .semibold))
                                                            .foregroundColor(AppTheme.textPrimary)
                                                    }
                                                    
                                                    // Phoneme difference highlight
                                                    HStack(spacing: 4) {
                                                        Text("Sound:")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(AppTheme.textSecondary)
                                                        
                                                        Text("\(error.difference.differingPhoneme1)")
                                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                            .foregroundColor(.red)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color.red.opacity(0.1))
                                                            .cornerRadius(4)
                                                        
                                                        Text("vs")
                                                            .font(.system(size: 11))
                                                            .foregroundColor(AppTheme.textSecondary)
                                                        
                                                        Text("\(error.difference.differingPhoneme2)")
                                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                            .foregroundColor(.blue)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color.blue.opacity(0.1))
                                                            .cornerRadius(4)
                                                        
                                                        Text("(\(error.difference.position))")
                                                            .font(.system(size: 11, design: .monospaced))
                                                            .foregroundColor(AppTheme.textSecondary)
                                                    }
                                                    
                                                    // Difference type and count
                                                    HStack(spacing: AppTheme.spacingS) {
                                                        Text(error.difference.differenceType.rawValue)
                                                            .font(.system(size: 11))
                                                            .foregroundColor(AppTheme.textSecondary)
                                                        
                                                        Text("•")
                                                            .foregroundColor(AppTheme.textSecondary)
                                                        
                                                        Text("\(error.missCount) time\(error.missCount == 1 ? "" : "s")")
                                                            .font(.system(size: 11, weight: .medium))
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                                
                                                Spacer()
                                            }
                                            
                                            if index < report.phoneticErrors.prefix(5).count - 1 {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // Initial State - No report yet
                        VStack(spacing: AppTheme.spacingL) {
                            ModernCard(padding: AppTheme.spacingL) {
                                VStack(spacing: AppTheme.spacingM) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 64))
                                        .foregroundColor(.purple)
                                    
                                    Text("Practice Insights")
                                        .font(.system(size: layout.titleFontSize, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Text("Get personalized insights about your training patterns and areas to focus on.")
                                        .font(.system(size: layout.bodyFontSize))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                    
                                    Divider()
                                        .padding(.vertical, AppTheme.spacingS)
                                    
                                    // Generate Button
                                    ResponsiveButton(
                                        text: "Generate Insights",
                                        action: {
                                            generateAIAnalysis()
                                        },
                                        layout: layout,
                                        style: .primary,
                                        icon: "chart.bar.fill"
                                    )
                                    .padding(.top, AppTheme.spacingS)
                                }
                            }
                        }
                        .padding(.top, AppTheme.spacingXL)
                    }
                    
                    // Disclaimer
                    if currentAIReport != nil {
                        ModernCard(padding: AppTheme.spacingM, backgroundColor: AppTheme.backgroundSecondary.opacity(0.5)) {
                            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppTheme.primaryBlue)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("About These Observations")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text("These are informal observations based on your practice sessions, not medical advice. Your audiologist has the expertise and full context to provide personalized guidance. Please share these results with them if you find them helpful.")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        
                        // Regenerate Button
                        ResponsiveButton(
                            text: "Regenerate Analysis",
                            action: {
                                generateAIAnalysis()
                            },
                            layout: layout,
                            style: .secondary,
                            icon: "arrow.clockwise"
                        )
                        .padding(.top, AppTheme.spacingS)
                    }
                    
                    // Back Button
                    ResponsiveButton(
                        text: "← Back to Home",
                        action: {
                            screen = .homescreen
                        },
                        layout: layout,
                        style: .secondary,
                        icon: "house"
                    )
                    .padding(.top, AppTheme.spacingM)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.bottom, AppTheme.spacingL)
            }
        }
    }
    
    @ViewBuilder
    func recommendationCard(recommendation: AudiologistRecommendation, layout: ResponsiveLayoutHelper) -> some View {
        ModernCard(padding: AppTheme.spacingM) {
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    // Priority Badge
                    Text(recommendation.priority.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(recommendation.priority.color)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Category Badge
                    Text(recommendation.category.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(4)
                }
                
                Text(recommendation.title)
                    .font(.system(size: layout.bodyFontSize, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(recommendation.description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Show specific words if any
                if !recommendation.specificWords.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Focus Words:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(recommendation.specificWords.prefix(5).joined(separator: ", "))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 4)
                }
                
                // Show frequencies if any
                if !recommendation.frequencies.isEmpty {
                    HStack {
                        Image(systemName: "waveform")
                            .font(.system(size: 12))
                            .foregroundColor(.purple)
                        
                        Text(recommendation.frequencies.map { $0.rawValue }.joined(separator: ", "))
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
    
    @ViewBuilder
    func navigationButtons(layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: AppTheme.spacingS) {
            // Only show Next/Submit buttons for training modes that don't have inline next buttons
            // (Sentence modes and Diagnostic Test have their own Next button after feedback)
            if currentTrainingCategory != .sentenceComprehension &&
                currentTrainingCategory != .sentencesInNoise &&
                currentTrainingCategory != .diagnosticTest {
                if currentQuestionIndex < getCurrentQuestionTotal() - 1 && !userAnswer.isEmpty {
                    ResponsiveButton(
                        text: "Next →",
                        action: {
                            handleNextQuestion()
                        },
                        layout: layout,
                        style: .accent,
                        icon: "arrow.right"
                    )
                } else if currentQuestionIndex == getCurrentQuestionTotal() - 1 && !userAnswer.isEmpty {
                    ResponsiveButton(
                        text: "Submit & Get Score",
                        action: {
                            // Test is already completed in recordTestResult, now just advance
                            handleNextQuestion()
                        },
                        layout: layout,
                        style: .success,
                        icon: "checkmark"
                    )
                }
            }
            
            ResponsiveButton(
                text: "← Back",
                action: {
                    // Reset speech state first to stop any ongoing recording
                    resetSpeechState()
                    
                    // Reset pickers for training categories
                    showWordCountPicker = true
                    showSentenceCountPicker = true
                    showDiagnosticSelection = true
                    diagnosticWordCount = 0
                    diagnosticSentenceCount = 0
                    diagnosticNoiseSentenceCount = 0
                    currentDemoWords = []
                    currentDemoSentences = []
                    currentDiagnosticItems = []
                    selectedChoices = []
                    currentQuestionIndex = 0
                    // Reset feedback state
                    showingFeedback = false
                    userAnswer = ""
                    isAnswerCorrect = false
                    // Reset custom practice mode
                    isCustomPracticeMode = false
                    screen = .homescreen
                },
                layout: layout,
                style: .secondary,
                icon: "arrow.left"
            )
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.bottom, AppTheme.spacingL)
    }
    
    // MARK: - Helper Functions
    
    func handleChoiceSelection(_ choice: String) {
        // Don't allow selection if feedback is already showing
        guard !showingFeedback else { return }
        
        userAnswer = choice
        
        // Check if answer is correct
        let correctAnswer = getCurrentCorrectAnswer()
        isAnswerCorrect = (choice == correctAnswer)
        showingFeedback = true
        
        if buttonconfirm {
            audioManager.playAudio("buttonpress")
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: isAnswerCorrect ? .medium : .light)
        impactFeedback.impactOccurred()
        
        // Record test result
        recordTestResult(userAnswer: choice)
        
        // Don't auto-advance - let user add to practice list or click Next
    }
    
    func moveToNextQuestion() {
        // Reset feedback state first
        showingFeedback = false
        userAnswer = ""
        isAnswerCorrect = false
        
        // Reset speech recognition state
        spokenText = ""
        wordMatchScore = 0.0
        matchedWords = 0
        totalWords = 0
        speechManager.recognizedText = ""
        
        questionStartTime = Date()
        
        // Check if we need to loop back for training modes BEFORE incrementing
        let needsLoop: Bool
        if currentTrainingCategory == .wordRecognition {
            needsLoop = currentQuestionIndex >= currentDemoWords.count - 1
        } else if currentTrainingCategory == .sentenceComprehension || currentTrainingCategory == .sentencesInNoise {
            needsLoop = currentQuestionIndex >= currentDemoSentences.count - 1
        } else {
            needsLoop = false
        }
        
        if needsLoop {
            // Reshuffle and restart
            if currentTrainingCategory == .wordRecognition {
                currentDemoWords.shuffle()
                selectedChoices = currentDemoWords.map { $0.randomizedChoices() }
                currentQuestionIndex = 0
                // Manually play audio since onChange might not trigger if already at 0
                if !currentDemoWords.isEmpty {
                    audioManager.playAudio(currentDemoWords[0].word)
                }
            } else if currentTrainingCategory == .sentenceComprehension || currentTrainingCategory == .sentencesInNoise {
                currentDemoSentences.shuffle()
                currentQuestionIndex = 0
                // Manually play audio since onChange might not trigger if already at 0
                if !currentDemoSentences.isEmpty {
                    audioManager.playAudio(currentDemoSentences[0].sentence)
                }
            }
        } else {
            // Normal increment
            currentQuestionIndex += 1
        }
        
        // Audio will be played automatically by .onChange(of: currentQuestionIndex) for normal increments
    }
    
    func recordTestResult(userAnswer: String) {
        let responseTime = Date().timeIntervalSince(questionStartTime)
        let correctAnswer = getCurrentCorrectAnswer()
        let isCorrect = userAnswer == correctAnswer
        let categoryName = currentTrainingCategory.rawValue
        
        if isCorrect {
            currentScore += 1
        }
        
        let result = TestResult(
            question: getCurrentQuestionText(),
            correctAnswer: correctAnswer,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            responseTime: responseTime,
            timestamp: Date(),
            category: categoryName
        )
        
        testResults.append(result)
        
        // Track user responses for completion screen
        let response = UserResponse(
            question: getCurrentQuestionText(),
            userAnswer: userAnswer,
            correctAnswer: correctAnswer,
            wasCorrect: isCorrect
        )
        userResponses.append(response)
        
        // Track word history for training categories
        trackTrainingCategoryHistory(question: getCurrentQuestionText(), correctAnswer: correctAnswer, wasCorrect: isCorrect, category: categoryName, userSaid: userAnswer)
        
        // Check if test is complete
        if currentQuestionIndex >= getCurrentQuestionTotal() - 1 {
            completeTest()
        }
    }
    
    func getCurrentQuestionText() -> String {
        switch currentTrainingCategory {
        case .wordRecognition:
            if currentQuestionIndex < currentDemoWords.count {
                return currentDemoWords[currentQuestionIndex].word
            }
        case .sentenceComprehension, .sentencesInNoise:
            if currentQuestionIndex < currentDemoSentences.count {
                return currentDemoSentences[currentQuestionIndex].sentence
            }
        case .diagnosticTest:
            if currentQuestionIndex < currentDiagnosticItems.count {
                return currentDiagnosticItems[currentQuestionIndex].content
            }
        default:
            break
        }
        return ""
    }
    
    func getCurrentCorrectAnswer() -> String {
        switch currentTrainingCategory {
        case .wordRecognition:
            if currentQuestionIndex < currentDemoWords.count {
                return currentDemoWords[currentQuestionIndex].correctAnswer
            }
        case .sentenceComprehension, .sentencesInNoise:
            if currentQuestionIndex < currentDemoSentences.count {
                return currentDemoSentences[currentQuestionIndex].sentence
            }
        case .diagnosticTest:
            if currentQuestionIndex < currentDiagnosticItems.count {
                return currentDiagnosticItems[currentQuestionIndex].content
            }
        default:
            break
        }
        return ""
    }
    
    func completeTest() {
        testCompletionTime = Date()
        let testDuration = testCompletionTime!.timeIntervalSince(testStartTime)
        let accuracy = Double(currentScore) / Double(totalQuestions)
        
        currentTestSummary = TestSummary(
            category: currentTrainingCategory,
            score: currentScore,
            totalQuestions: totalQuestions,
            accuracy: accuracy,
            testDuration: testDuration,
            voiceUsed: voiceSettings.selectedVoice,
            results: testResults,
            timestamp: testCompletionTime!
        )
        
        // Record analytics for clinical dashboard
        recordSessionAnalytics(
            exerciseType: currentTrainingCategory.rawValue,
            duration: testDuration,
            itemsAttempted: totalQuestions,
            itemsCorrect: currentScore
        )
    }
    
    func recordSessionAnalytics(exerciseType: String, duration: TimeInterval, itemsAttempted: Int, itemsCorrect: Int) {
        // Extract phonetic errors from test results
        var phoneticErrors: [String] = []
        
        // Analyze phonetic differences for word recognition
        if currentTrainingCategory == .wordRecognition {
            for result in testResults {
                if !result.isCorrect {
                    // Track the phonetic pattern
                    phoneticErrors.append("\(result.question) (heard as: \(result.userAnswer))")
                }
            }
        }
        
        // Determine background noise level
        let noiseLevel: String
        if currentTrainingCategory == .sentencesInNoise || backgroundNoiseEnabled {
            // Format the noise type and volume level
            let volumePercent = Int(backgroundNoiseVolume * 100)
            noiseLevel = "\(backgroundNoiseType.rawValue) noise at \(volumePercent)%"
        } else {
            noiseLevel = "Silent"
        }
        
        // Record session to analytics
        AnalyticsManager.shared.recordSessionFromResult(
            exerciseType: exerciseType,
            duration: duration,
            itemsAttempted: itemsAttempted,
            itemsCorrect: itemsCorrect,
            backgroundNoiseLevel: noiseLevel,
            phoneticErrors: phoneticErrors
        )
    }
    
    func handleNextQuestion() {
        userAnswer = ""
        showingAnswer = false
        showingFeedback = false
        isAnswerCorrect = false
        
        // Increment to next question or completion screen
        currentQuestionIndex += 1
        questionStartTime = Date()
    }
    
    func getCurrentQuestionTotal() -> Int {
        switch currentTrainingCategory {
        case .wordRecognition:
            return currentDemoWords.count
        case .sentenceComprehension, .sentencesInNoise:
            return currentDemoSentences.count
        case .diagnosticTest:
            return currentDiagnosticItems.count
        default:
            return 0
        }
    }
    
    func getDifficultyColor(_ difficulty: DiagnosticItem.DiagnosticDifficulty) -> Color {
        switch difficulty {
        case .easy: return AppTheme.success
        case .medium: return AppTheme.accentOrange
        case .hard: return AppTheme.warning
            
        }
    }
    
    // MARK: - Diagnostic Test Speech Recognition
    
    func submitDiagnosticAnswer() {
        guard currentQuestionIndex < currentDiagnosticItems.count else { return }
        
        let currentItem = currentDiagnosticItems[currentQuestionIndex]
        let spokenText = speechManager.recognizedText
        let correctAnswer = currentItem.content
        
        // Calculate similarity score
        let similarity = calculateSimilarityScore(target: correctAnswer, recognized: spokenText)
        
        // Store the spoken text as user answer for feedback
        userAnswer = spokenText
        
        // Determine if correct (>= 80% similarity)
        isAnswerCorrect = similarity >= 0.8
        
        // Record the result
        recordTestResult(userAnswer: spokenText)
        
        // Show feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showingFeedback = true
        }
        
        // Save to analytics
        ProgressTrackingManager.shared.addSession(
            PracticeSession(
                exerciseText: correctAnswer,
                exerciseType: currentItem.type == .word ? .word : .sentence,
                recognizedText: spokenText,
                score: similarity,
                duration: 10.0,
                phonemeAccuracy: [:]
            )
        )
    }
    
    @ViewBuilder
    func diagnosticFeedbackView(currentItem: DiagnosticItem, layout: ResponsiveLayoutHelper) -> some View {
        VStack(spacing: AppTheme.spacingL) {
            ModernCard(padding: AppTheme.spacingL) {
                VStack(spacing: AppTheme.spacingM) {
                    // Expected answer
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Text("Expected:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text(currentItem.content.lowercased())
                            .font(.system(size: layout.titleFontSize, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(AppTheme.spacingM)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(12)
                    }
                    
                    // Your answer
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Text("You said:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text(userAnswer.isEmpty ? "Nothing detected" : userAnswer.lowercased())
                            .font(.system(size: layout.titleFontSize, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(AppTheme.spacingM)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(12)
                    }
                    
                    // Result badge (matching practice exercises)
                    ModernCard(padding: AppTheme.spacingM, backgroundColor: isAnswerCorrect ? AppTheme.success.opacity(0.1) : AppTheme.error.opacity(0.1)) {
                        HStack {
                            Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isAnswerCorrect ? "Correct!" : "Keep Trying")
                                    .font(.system(size: layout.titleFontSize, weight: .bold))
                                    .foregroundColor(isAnswerCorrect ? AppTheme.success : AppTheme.error)
                                
                                Text(isAnswerCorrect ? "Perfect match!" : "The words don't match")
                                    .font(.system(size: layout.bodyFontSize - 2))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Next button
                    ResponsiveButton(
                        text: currentQuestionIndex < currentDiagnosticItems.count - 1 ? "Next Question" : "Finish Test",
                        action: {
                            showingFeedback = false
                            resetSpeechState()
                            
                            if currentQuestionIndex < currentDiagnosticItems.count - 1 {
                                currentQuestionIndex += 1
                            } else {
                                // Test complete - stay on current index to show completion view
                                currentQuestionIndex += 1
                            }
                        },
                        layout: layout,
                        style: .primary,
                        icon: "arrow.right"
                    )
                }
            }
            
            progressView(current: currentQuestionIndex + 1, total: currentDiagnosticItems.count, layout: layout)
        }
    }
    
    // MARK: - Phase 2 Helper Functions
    
    // Helper function for calculating similarity between spoken and target text
    func calculateSimilarityScore(target: String, recognized: String) -> Double {
        // Normalize both strings: lowercase, trim whitespace, remove punctuation
        let normalizedTarget = target.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .punctuationCharacters).joined()
        
        let normalizedRecognized = recognized.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .punctuationCharacters).joined()
        
        print("🔍 Similarity check:")
        print("   Target: '\(target)' → normalized: '\(normalizedTarget)'")
        print("   Recognized: '\(recognized)' → normalized: '\(normalizedRecognized)'")
        
        // For single words, do exact match after normalization
        let targetWords = normalizedTarget.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let recognizedWords = normalizedRecognized.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        print("   Target words: \(targetWords)")
        print("   Recognized words: \(recognizedWords)")
        
        // If both are single words, check for exact match
        if targetWords.count == 1 && recognizedWords.count == 1 {
            let exactMatch = targetWords[0] == recognizedWords[0]
            print("   Single word match: \(exactMatch ? "✅" : "❌")")
            return exactMatch ? 1.0 : 0.0
        }
        
        // For multi-word, use word-by-word matching
        let matchingWords = targetWords.filter { recognizedWords.contains($0) }
        let similarity = Double(matchingWords.count) / Double(max(targetWords.count, 1))
        
        print("   Matched words: \(matchingWords.count)/\(targetWords.count) = \(Int(similarity * 100))%")
        
        return similarity
    }
    
    // OLD Speaking Practice helper functions (no longer used with new SpeakingPracticeView)
    /*
     func toggleSpeechRecording() {
     if speechManager.isRecording {
     stopSpeechRecording()
     } else {
     speechManager.startRecording()
     }
     }
     
     func stopSpeechRecording() {
     speechManager.stopRecording()
     
     // Calculate pronunciation score
     if !speechManager.recognizedText.isEmpty {
     speechScore = calculateSimilarityScore(target: targetSpeechText, recognized: speechManager.recognizedText)
     showSpeechResults = true
     }
     }
     
     func getSpeechFeedback() -> String {
     if speechScore >= 0.9 {
     return "Excellent pronunciation! Perfect match!"
     } else if speechScore >= 0.7 {
     return "Good job! Most words were correct."
     } else if speechScore >= 0.5 {
     return "Nice try! Keep practicing."
     } else {
     return "Try again and speak more clearly."
     }
     }
     
     func resetSpeechPractice() {
     speechManager.recognizedText = ""
     speechScore = 0.0
     showSpeechResults = false
     }
     */
    
    // MARK: - Export Results View
    
    struct ExportResultsView: View {
        let summary: TestSummary
        @Binding var showingExportSheet: Bool
        @State private var showingShareSheet = false
        @State private var exportText = ""
        @State private var shareItems: [Any] = []
        
        // Generate a temporary file URL for sharing
        private func createTextFile(from text: String) -> URL? {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let dateString = formatter.string(from: summary.timestamp)
            let fileName = "HearifyResults_\(dateString).txt"
            
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(fileName)
            
            do {
                try text.write(to: fileURL, atomically: true, encoding: .utf8)
                return fileURL
            } catch {
                print("Error creating file: \(error)")
                return nil
            }
        }
        
        private func prepareShareItems() {
            let text = summary.generateExportText()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: summary.timestamp)
            let subject = "Hearify Results - \(summary.category.rawValue) (\(dateString))"
            
            // Use custom activity item source for better email metadata
            let textSource = TextActivityItemSource(text: text, subject: subject)
            var items: [Any] = [textSource]
            
            // Add file URL if successfully created
            if let fileURL = createTextFile(from: text) {
                items.append(fileURL)
            }
            
            shareItems = items
        }
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                        // Header
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            Text("Test Results Summary")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("\(summary.category.rawValue) - \(DateFormatter().string(from: summary.timestamp))")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        // Quick stats
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppTheme.spacingM) {
                            statCard(title: "Score", value: "\(summary.score)/\(summary.totalQuestions)", color: AppTheme.accentOrange)
                            statCard(title: "Accuracy", value: summary.accuracyPercentage, color: AppTheme.success)
                            statCard(title: "Duration", value: summary.testDurationFormatted, color: AppTheme.primaryBlue)
                            statCard(title: "Voice", value: summary.voiceUsed.displayName, color: AppTheme.textPrimary)
                        }
                        
                        Divider()
                        
                        // Detailed results
                        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                            Text("Question by Question Results")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            ForEach(Array(summary.results.enumerated()), id: \.offset) { index, result in
                                resultRow(index: index + 1, result: result)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Export Results")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            showingExportSheet = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            prepareShareItems()
                            showingShareSheet = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.system(size: 17, weight: .semibold))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(items: shareItems)
                }
            }
        }
        
        @ViewBuilder
        func statCard(title: String, value: String, color: Color) -> some View {
            VStack(spacing: AppTheme.spacingXS) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.backgroundSecondary)
            .cornerRadius(12)
        }
        
        @ViewBuilder
        func resultRow(index: Int, result: TestResult) -> some View {
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                HStack {
                    Text("Question \(index)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(result.isCorrect ? AppTheme.success : AppTheme.error)
                    
                    Text(result.formattedResponseTime)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Text(result.question)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                
                HStack {
                    Text("Your answer:")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(result.userAnswer)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(result.isCorrect ? AppTheme.success : AppTheme.error)
                }
                
                if !result.isCorrect {
                    HStack {
                        Text("Correct answer:")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text(result.correctAnswer)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.success)
                    }
                }
            }
            .padding()
            .background(AppTheme.backgroundSecondary)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Custom Upload Processing
    
    func processCustomUpload() {
        let items = customWordsText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !items.isEmpty else { return }
        
        switch uploadType {
        case .words:
            // Create custom word list
            let customWords = items.map { word in
                DemoWord(word: word, choices: [word, "---", "---", "---"], category: .wordRecognition, correctAnswer: word)
            }
            // Store in a custom category
            UserDefaults.standard.set(try? JSONEncoder().encode(customWords), forKey: "customWords")
            print("✅ Uploaded \(customWords.count) custom words")
            
        case .sentences:
            // Create custom sentence list
            let customSentences = items.map { sentence in
                DemoSentence(sentence: sentence, choices: [sentence, "---", "---"], category: .sentenceComprehension)
            }
            // Store in a custom category
            UserDefaults.standard.set(try? JSONEncoder().encode(customSentences), forKey: "customSentences")
            print("✅ Uploaded \(customSentences.count) custom sentences")
            
        case .matchedPairs:
            // Parse matched pairs (format: word1,word2)
            let customMatchedPairs = items.compactMap { line -> Word? in
                let components = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                guard components.count == 2, !components[0].isEmpty, !components[1].isEmpty else {
                    print("⚠️ Invalid matched pair format: \(line)")
                    return nil
                }
                return Word(firstWord: components[0], lastWord: components[1], category: "Custom")
            }
            // Store in a custom category
            UserDefaults.standard.set(try? JSONEncoder().encode(customMatchedPairs), forKey: "customMatchedPairs")
            print("✅ Uploaded \(customMatchedPairs.count) custom matched pairs")
        }
        
        // Clear the text
        customWordsText = ""
        customItemsRefreshTrigger = UUID() // Force view refresh
    }
    
    // MARK: - Word Pair Selection
    func loadWordPairsForSelection(csvFile: String, category: String) {
        print("📋 Loading word pairs for selection - CSV: \(csvFile), Category: \(category)")
        WordList.removeAll()
        convertCSVIntoArray(CSV: csvFile)
        availableWordPairs = WordList
        wordPairCategory = category
        selectedWordPairs.removeAll()
        print("✅ Loaded \(availableWordPairs.count) word pairs for \(category)")
        print("📝 First 3 pairs: \(availableWordPairs.prefix(3).map { "\($0.firstWord) vs \($0.lastWord)" })")
        showWordPairSelector = true
    }
    
    // MARK: - SNR Conversion
    func getSNRFromVolume() -> Double {
        // Map volume (0.0-1.0) to SNR based on clinical audiological standards
        // SNR = Signal-to-Noise Ratio (how much louder speech is than noise)
        // 0 dB SNR = speech and noise equal (most challenging)
        // +5 dB SNR = speech 5 dB louder than noise (moderate)
        // +10 dB SNR = speech 10 dB louder than noise (easier)
        
        let volume = Double(backgroundNoiseVolume)
        
        // Clinical standard mapping (inverted - higher noise volume = lower SNR = harder)
        if volume >= 0.85 {
            return 0    // 0 dB SNR - Very challenging (QuickSIN standard)
        } else if volume >= 0.7 {
            return 2    // +2 dB SNR - Challenging
        } else if volume >= 0.55 {
            return 5    // +5 dB SNR - Moderate (HINT standard)
        } else if volume >= 0.4 {
            return 10   // +10 dB SNR - Easier
        } else if volume >= 0.25 {
            return 15   // +15 dB SNR - Easy
        } else {
            return 20   // +20 dB SNR - Very easy
        }
    }
    
    func startPracticeWithSelectedPairs(count: Int = 1) {
        print("🔵 startPracticeWithSelectedPairs called with count: \(count)")
        
        // Get the pairs to practice
        var pairsToUse: [Word] = []
        
        if selectedWordPairs.isEmpty {
            // If no pairs selected, use all pairs
            pairsToUse = availableWordPairs
        } else {
            // Filter to only include selected pairs
            pairsToUse = availableWordPairs.filter { word in
                let pairID = "\(word.firstWord)-\(word.lastWord)"
                return selectedWordPairs.contains(pairID)
            }
        }
        
        print("   Pairs to practice: \(pairsToUse.count)")
        print("   Repetitions per pair: \(count)")
        
        // Create WordList with each pair repeated 'count' times
        WordList.removeAll()
        for _ in 0..<count {
            WordList.append(contentsOf: pairsToUse)
        }
        
        print("   Total practice items: \(WordList.count)")
        
        finaldisable = true
        topCategory = wordPairCategory
        
        // FIX: Set mainCategory from the first word's category
        if let firstWord = WordList.first {
            mainCategory = firstWord.category
            sectiontitle.text = getCategoryDisplayName(firstWord.category)
            print("   mainCategory set to: '\(mainCategory)'")
            print("   sectiontitle set to: '\(sectiontitle.text)'")
        } else {
            sectiontitle.text = getCategoryDisplayName(wordPairCategory)
        }
        
        // Check if randomize() succeeded before navigating
        if !randomize() {
            print("❌ Failed to randomize - category mismatch")
            alerttext.text = "Error starting practice. Please try again."
            showingAlert = true
            return
        }
        
        screen = .screen1
        if buttonconfirm {
            audioManager.playAudio("buttonpress")
        }
        // Removed auto-play - user must click play button
        showWordPairSelector = false
    }
    
    func startSinglePairPractice(pair: Word, count: Int) {
        print("🎯 startSinglePairPractice called!")
        print("   Pair: \(pair.firstWord) vs \(pair.lastWord)")
        print("   Count: \(count)")
        print("   Category: \(wordPairCategory)")
        
        // Create a list with the pair repeated 'count' times
        // Each repetition will randomly select firstWord or lastWord during randomize()
        WordList.removeAll()
        
        for _ in 0..<count {
            WordList.append(pair)
        }
        
        print("   WordList size: \(WordList.count)")
        
        finaldisable = true
        topCategory = wordPairCategory
        mainCategory = pair.category  // FIX: Set mainCategory to match the pair's category
        sectiontitle.text = "\(getCategoryDisplayName(pair.category)): \(pair.firstWord) vs \(pair.lastWord)"
        
        print("   mainCategory set to: '\(mainCategory)'")
        print("   sectiontitle set to: '\(sectiontitle.text)'")
        print("   About to call randomize()")
        
        // Check if randomize() succeeded before navigating
        if !randomize() {
            print("❌ Failed to randomize - category mismatch")
            alerttext.text = "Error starting practice for \(getCategoryDisplayName(pair.category)). Please try again."
            showingAlert = true
            return
        }
        
        print("   After randomize - audioname: \(audioname.text)")
        
        screen = .screen1
        print("   Screen set to .screen1")
        
        if buttonconfirm {
            audioManager.playAudio("buttonpress")
        }
        // Removed auto-play - user must click play button
        
        print("✅ Single pair practice started: \(pair.firstWord) vs \(pair.lastWord) - \(count) times")
    }
    
    // MARK: - Share Sheet
    
    // Custom Activity Item Source for better email metadata
    class TextActivityItemSource: NSObject, UIActivityItemSource {
        let text: String
        let subject: String
        
        init(text: String, subject: String) {
            self.text = text
            self.subject = subject
        }
        
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return text
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            return text
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            return subject
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .previewDevice("iPhone 15 Pro")
        }
    }
    
    // MARK: - Custom Upload Sheet View (Compact & Aesthetic)
    struct CustomUploadSheetView: View {
        @Binding var uploadType: CustomUploadType
        @Binding var customWordsText: String
        var onSubmit: () -> Void
        @Environment(\.presentationMode) var presentationMode
        
        private var isWords: Bool { uploadType == .words }
        private var title: String {
            switch uploadType {
            case .words: return "Add Words"
            case .sentences: return "Add Sentences"
            case .matchedPairs: return "Add Matched Pairs"
            }
        }
        private var icon: String {
            switch uploadType {
            case .words: return "textformat.size"
            case .sentences: return "quote.bubble"
            case .matchedPairs: return "square.grid.2x2"
            }
        }
        private var color: Color {
            switch uploadType {
            case .words: return AppTheme.success
            case .sentences: return AppTheme.accentOrange
            case .matchedPairs: return AppTheme.primaryBlue
            }
        }
        private var placeholder: String {
            switch uploadType {
            case .words: return "apple\nbanana\norange"
            case .sentences: return "I went to the store.\nThe weather is nice.\nHow are you today?"
            case .matchedPairs: return "cat,bat\nship,chip\ntree,three"
            }
        }
        private var instructionText: String {
            switch uploadType {
            case .words, .sentences: return "One per line"
            case .matchedPairs: return "Format: word1,word2 (one pair per line)"
            }
        }
        private var buttonText: String {
            switch uploadType {
            case .words: return "Words"
            case .sentences: return "Sentences"
            case .matchedPairs: return "Matched Pairs"
            }
        }
        private var tipText: String {
            switch uploadType {
            case .words: return "Tip: Add 5-10 words for best results"
            case .sentences: return "Tip: Keep sentences short and clear"
            case .matchedPairs: return "Tip: Use similar sounding words for better practice"
            }
        }
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: AppTheme.spacingL) {
                        // Header with icon
                        HStack {
                            Image(systemName: icon)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text(instructionText)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.spacingL)
                        .padding(.top, AppTheme.spacingM)
                        
                        // Compact text editor
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            ZStack(alignment: .topLeading) {
                                if customWordsText.isEmpty {
                                    Text(placeholder)
                                        .font(.system(size: 15))
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 12)
                                }
                                
                                TextEditor(text: $customWordsText)
                                    .font(.system(size: 15))
                                    .frame(height: 150)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(color.opacity(0.3), lineWidth: 2)
                            )
                        }
                        .padding(.horizontal, AppTheme.spacingL)
                        
                        // Quick tip
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(color)
                            
                            Text(tipText)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.spacingL)
                        
                        // Add button
                        Button(action: {
                            // Dismiss keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onSubmit()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                
                                Text("Add \(buttonText)")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(customWordsText.trimmingCharacters(in: .whitespaces).isEmpty)
                        .padding(.horizontal, AppTheme.spacingL)
                        .padding(.bottom, AppTheme.spacingXL)
                    }
                }
                .background(AppTheme.backgroundPrimary)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                Text("Cancel")
                            }
                            .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    // Keyboard dismiss button
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Word Pair Selector View
    struct WordPairSelectorView: View {
        @Binding var availableWordPairs: [Word]
        @Binding var selectedWordPairs: Set<String>
        @Binding var practiceCount: Int  // How many times to practice each pair
        let category: String
        let onStart: () -> Void
        let onSelectSinglePair: (Word) -> Void  // NEW: Callback for single pair selection
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Text("Select Word Pairs")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("\(getCategoryDisplayName(category)) - \(selectedWordPairs.count) of \(availableWordPairs.count) selected")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        // Quick selection buttons
                        HStack(spacing: AppTheme.spacingS) {
                            Button(action: selectAll) {
                                Label("Select All", systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.success)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: deselectAll) {
                                Label("Deselect All", systemImage: "circle")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.error)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.backgroundSecondary)
                    
                    Divider()
                    
                    // Word pairs list
                    List {
                        ForEach(Array(availableWordPairs.enumerated()), id: \.offset) { index, wordPair in
                            let pairID = "\(wordPair.firstWord)-\(wordPair.lastWord)"
                            let isSelected = selectedWordPairs.contains(pairID)
                            
                            HStack(spacing: AppTheme.spacingM) {
                                // Checkbox for multi-select
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    if isSelected {
                                        selectedWordPairs.remove(pairID)
                                        print("❌ Deselected: \(pairID)")
                                    } else {
                                        selectedWordPairs.insert(pairID)
                                        print("✅ Selected: \(pairID)")
                                    }
                                    print("📋 Total selected: \(selectedWordPairs.count)")
                                }) {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 22))
                                        .foregroundColor(isSelected ? AppTheme.success : AppTheme.textTertiary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(wordPair.firstWord)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text("vs")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textSecondary)
                                        
                                        Text(wordPair.lastWord)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                    }
                                    
                                    if !wordPair.category.isEmpty {
                                        Text(getCategoryDisplayName(wordPair.category))
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // NEW: Practice this pair button
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    onSelectSinglePair(wordPair)
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Practice")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.accentOrange)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    // Practice count selector and Start button
                    VStack(spacing: AppTheme.spacingM) {
                        // Count selector
                        VStack(spacing: AppTheme.spacingS) {
                            Text("Repetitions per pair")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            // Quick selection buttons
                            HStack(spacing: AppTheme.spacingS) {
                                ForEach([5, 10, 20, 30], id: \.self) { count in
                                    Button(action: {
                                        practiceCount = count
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                    }) {
                                        Text("\(count)")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(practiceCount == count ? .white : AppTheme.primaryBlue)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(practiceCount == count ? AppTheme.primaryBlue : AppTheme.backgroundSecondary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, AppTheme.spacingS)
                        
                        // Start button
                        Button(action: {
                            onStart()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(selectedWordPairs.isEmpty ? "Practice All Pairs" : "Start Practice (\(selectedWordPairs.count) pairs)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primaryBlue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(AppTheme.backgroundPrimary)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        
        func selectAll() {
            selectedWordPairs = Set(availableWordPairs.map { "\($0.firstWord)-\($0.lastWord)" })
        }
        
        func deselectAll() {
            selectedWordPairs.removeAll()
        }
        
        // Helper function to convert internal category codes to user-friendly names
        private func getCategoryDisplayName(_ category: String) -> String {
            switch category.lowercased() {
            case "syllables": return "Syllables"
            case "consonants": return "Consonants"
            case "c": return "Consonants"
            case "cm": return "Consonants"
            case "cv": return "Consonants"
            case "cp": return "Consonants"
            case "fc": return "Final Consonants"
            case "nv": return "Vowels"
            case "wv": return "Vowels"
            case "pd": return "Phonetics"
            case "pd1": return "Phonetics"
            case "pd2": return "Phonetics"
            case "word recognition": return "Word Recognition"
            case "sentence comprehension": return "Sentence Comprehension"
            case "sentences in noise": return "Sentences in Noise"
            case "diagnostic test": return "Diagnostic Test"
            case "dailychallenge": return "Daily Challenge"
            case "wrongwordlist": return "Practice List"
            case "matched pairs": return "Matched Pairs"
            default: return category.capitalized
            }
        }
    }
    
    // MARK: - Pair Practice Configuration View
    struct PairPracticeConfigView: View {
        let pair: Word
        @Binding var practiceCount: Int
        let onStart: () -> Void
        let onCancel: () -> Void
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                VStack(spacing: AppTheme.spacingL) {
                    // Header
                    VStack(spacing: AppTheme.spacingM) {
                        Image(systemName: "headphones.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.accentOrange)
                        
                        Text("Practice This Pair")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        // Show the pair
                        HStack(spacing: 12) {
                            Text(pair.firstWord)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.primaryBlue)
                            
                            Text("vs")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(pair.lastWord)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.accentOrange)
                        }
                        .padding()
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(12)
                    }
                    .padding(.top, AppTheme.spacingL)
                    
                    // Description
                    Text("The app will randomly play one word from the pair each time. Listen carefully and choose the correct word!")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    // Practice count selector
                    VStack(spacing: AppTheme.spacingM) {
                        Text("How many times?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        // Large number display
                        Text("\(practiceCount)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(AppTheme.primaryBlue)
                        
                        Text("repetitions")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        // Stepper
                        Stepper("", value: $practiceCount, in: 1...50)
                            .labelsHidden()
                            .padding(.horizontal, 40)
                        
                        // Quick selection buttons
                        HStack(spacing: AppTheme.spacingS) {
                            ForEach([5, 10, 20, 30], id: \.self) { count in
                                Button(action: {
                                    practiceCount = count
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }) {
                                    Text("\(count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(practiceCount == count ? .white : AppTheme.primaryBlue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(practiceCount == count ? AppTheme.primaryBlue : AppTheme.backgroundSecondary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: AppTheme.spacingM) {
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            onStart()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18))
                                Text("Start Practice")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.success)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            onCancel()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
