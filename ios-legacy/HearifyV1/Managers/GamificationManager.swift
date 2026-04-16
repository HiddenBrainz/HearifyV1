//
//  GamificationManager.swift
//  HearifyV1
//
//  Gamification system: levels, streaks, badges, XP
//  Phase 2: Speaking/Pronunciation Module
//

import Foundation
import SwiftUI

// MARK: - Exercise Type
enum ExerciseType: String, Codable {
    case word = "Word Pronunciation"
    case sentence = "Sentence Pronunciation"
    case conversation = "Conversation Practice"
}

// MARK: - Badge Model
struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: String
    var isUnlocked: Bool
    let unlockedDate: Date?

    init(id: String, name: String, description: String, icon: String, requirement: String, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.requirement = requirement
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

// MARK: - Gamification Manager
class GamificationManager: ObservableObject {
    static let shared = GamificationManager()

    // MARK: - Published Properties
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var currentLevel: Int = 1
    @Published var totalPoints: Int = 0
    @Published var currentXP: Int = 0
    @Published var xpForNextLevel: Int = 100
    @Published var unlockedBadges: [Badge] = []
    @Published var totalWordsCompleted: Int = 0
    @Published var totalSentencesCompleted: Int = 0
    @Published var totalConversationsCompleted: Int = 0
    @Published var perfectScoreCount: Int = 0
    @Published var dailyGoalCompleted: Bool = false
    @Published var dailyGoalProgress: Int = 0
    @Published var dailyGoalTarget: Int = 5
    @Published var lastPracticeDate: Date?
    @Published var newlyUnlockedBadges: [Badge] = []

    // MARK: - Constants
    private let xpMultiplier: Double = 1.5
    private let streakKey = "gamification_streak"
    private let longestStreakKey = "gamification_longest_streak"
    private let levelKey = "gamification_level"
    private let totalPointsKey = "gamification_total_points"
    private let currentXPKey = "gamification_current_xp"
    private let badgesKey = "gamification_badges"
    private let wordsCompletedKey = "gamification_words_completed"
    private let sentencesCompletedKey = "gamification_sentences_completed"
    private let conversationsCompletedKey = "gamification_conversations_completed"
    private let perfectScoreCountKey = "gamification_perfect_score_count"
    private let dailyGoalProgressKey = "gamification_daily_goal_progress"
    private let lastPracticeDateKey = "gamification_last_practice_date"

    // MARK: - Initialization
    init() {
        loadData()
        updateStreak()
        checkDailyGoal()
    }

    // MARK: - Add Points for Exercise
    func addPoints(for score: Double, exerciseType: ExerciseType) {
        // Base points
        var basePoints = 0
        switch exerciseType {
        case .word:
            basePoints = 10
            totalWordsCompleted += 1
        case .sentence:
            basePoints = 20
            totalSentencesCompleted += 1
        case .conversation:
            basePoints = 30
            totalConversationsCompleted += 1
        }

        // Score multiplier (1.0x to 1.5x)
        let scoreMultiplier = 1.0 + (score * 0.5)

        // Streak bonus
        let streakMultiplier = currentStreak >= 7 ? 1.2 : 1.0

        // Calculate total points
        let totalEarnedPoints = Int(Double(basePoints) * scoreMultiplier * streakMultiplier)

        // Add points and XP
        totalPoints += totalEarnedPoints
        currentXP += totalEarnedPoints

        // Check for perfect score
        if score >= 0.95 {
            perfectScoreCount += 1
        }

        // Update daily goal
        dailyGoalProgress += 1
        if dailyGoalProgress >= dailyGoalTarget {
            dailyGoalCompleted = true
        }

        // Update last practice date
        lastPracticeDate = Date()
        updateStreak()

        // Check for level up
        checkLevelUp()

        // Check for badge unlocks
        checkBadgeUnlocks()

        // Save data
        saveData()
    }

    // MARK: - Check Level Up
    private func checkLevelUp() {
        while currentXP >= xpForNextLevel {
            currentXP -= xpForNextLevel
            currentLevel += 1
            xpForNextLevel = Int(Double(xpForNextLevel) * xpMultiplier)
        }
    }

    // MARK: - Update Streak
    private func updateStreak() {
        guard let lastDate = lastPracticeDate else {
            currentStreak = 0
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastPractice = calendar.startOfDay(for: lastDate)

        let daysDifference = calendar.dateComponents([.day], from: lastPractice, to: today).day ?? 0

        if daysDifference == 0 {
            // Same day, streak continues
            return
        } else if daysDifference == 1 {
            // Consecutive day, increment streak
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            // Streak broken
            currentStreak = 0
        }
    }

    // MARK: - Check Daily Goal
    private func checkDailyGoal() {
        guard let lastDate = lastPracticeDate else {
            dailyGoalProgress = 0
            dailyGoalCompleted = false
            return
        }

        let calendar = Calendar.current
        if !calendar.isDateInToday(lastDate) {
            dailyGoalProgress = 0
            dailyGoalCompleted = false
        }
    }

    // MARK: - Check Badge Unlocks
    private func checkBadgeUnlocks() {
        newlyUnlockedBadges = []
        let allBadges = getAllBadges()

        for (index, badge) in allBadges.enumerated() {
            if !badge.isUnlocked && checkBadgeRequirement(badge) {
                let unlockedBadge = Badge(
                    id: badge.id,
                    name: badge.name,
                    description: badge.description,
                    icon: badge.icon,
                    requirement: badge.requirement,
                    isUnlocked: true,
                    unlockedDate: Date()
                )

                // Safely update the badge in the array
                if index >= 0 && index < unlockedBadges.count {
                    unlockedBadges[index] = unlockedBadge
                } else {
                    // Ensure array is large enough
                    while unlockedBadges.count <= index {
                        if unlockedBadges.count < allBadges.count {
                            unlockedBadges.append(allBadges[unlockedBadges.count])
                        } else {
                            break
                        }
                    }
                    if index >= 0 && index < unlockedBadges.count {
                        unlockedBadges[index] = unlockedBadge
                    }
                }

                newlyUnlockedBadges.append(unlockedBadge)
            }
        }
    }

    // MARK: - Check Badge Requirement
    private func checkBadgeRequirement(_ badge: Badge) -> Bool {
        switch badge.id {
        // Streak badges
        case "streak_3": return currentStreak >= 3
        case "streak_7": return currentStreak >= 7
        case "streak_14": return currentStreak >= 14
        case "streak_30": return currentStreak >= 30
        case "streak_100": return currentStreak >= 100

        // Completion badges
        case "words_10": return totalWordsCompleted >= 10
        case "words_50": return totalWordsCompleted >= 50
        case "words_100": return totalWordsCompleted >= 100
        case "sentences_10": return totalSentencesCompleted >= 10
        case "sentences_50": return totalSentencesCompleted >= 50
        case "conversations_10": return totalConversationsCompleted >= 10

        // Perfect score badges
        case "perfect_5": return perfectScoreCount >= 5
        case "perfect_20": return perfectScoreCount >= 20
        case "perfect_50": return perfectScoreCount >= 50

        // Daily goal badges
        case "daily_goal_7": return currentStreak >= 7 && dailyGoalCompleted
        case "daily_goal_30": return currentStreak >= 30 && dailyGoalCompleted

        default: return false
        }
    }

    // MARK: - Get All Badges
    private func getAllBadges() -> [Badge] {
        if unlockedBadges.isEmpty {
            unlockedBadges = createDefaultBadges()
        }
        return unlockedBadges
    }

    // MARK: - Create Default Badges
    private func createDefaultBadges() -> [Badge] {
        return [
            // Streak badges
            Badge(id: "streak_3", name: "3-Day Streak", description: "Practice for 3 consecutive days", icon: "flame.fill", requirement: "3 days"),
            Badge(id: "streak_7", name: "Week Warrior", description: "Practice for 7 consecutive days", icon: "flame.fill", requirement: "7 days"),
            Badge(id: "streak_14", name: "Two-Week Champion", description: "Practice for 14 consecutive days", icon: "flame.fill", requirement: "14 days"),
            Badge(id: "streak_30", name: "Month Master", description: "Practice for 30 consecutive days", icon: "flame.fill", requirement: "30 days"),
            Badge(id: "streak_100", name: "Century", description: "Practice for 100 consecutive days", icon: "crown.fill", requirement: "100 days"),

            // Word completion badges
            Badge(id: "words_10", name: "First Steps", description: "Complete 10 word exercises", icon: "textformat.size", requirement: "10 words"),
            Badge(id: "words_50", name: "Word Explorer", description: "Complete 50 word exercises", icon: "textformat.size", requirement: "50 words"),
            Badge(id: "words_100", name: "Word Master", description: "Complete 100 word exercises", icon: "textformat.size", requirement: "100 words"),

            // Sentence completion badges
            Badge(id: "sentences_10", name: "Sentence Starter", description: "Complete 10 sentence exercises", icon: "quote.bubble.fill", requirement: "10 sentences"),
            Badge(id: "sentences_50", name: "Sentence Pro", description: "Complete 50 sentence exercises", icon: "quote.bubble.fill", requirement: "50 sentences"),

            // Conversation badges
            Badge(id: "conversations_10", name: "Conversationalist", description: "Complete 10 conversations", icon: "bubble.left.and.bubble.right.fill", requirement: "10 conversations"),

            // Perfect score badges
            Badge(id: "perfect_5", name: "Perfectionist", description: "Achieve 5 perfect scores", icon: "star.fill", requirement: "5 perfect"),
            Badge(id: "perfect_20", name: "Excellence", description: "Achieve 20 perfect scores", icon: "star.fill", requirement: "20 perfect"),
            Badge(id: "perfect_50", name: "Flawless", description: "Achieve 50 perfect scores", icon: "crown.fill", requirement: "50 perfect"),

            // Daily goal badges
            Badge(id: "daily_goal_7", name: "Goal Getter", description: "Complete daily goal for 7 days", icon: "target", requirement: "7 days"),
            Badge(id: "daily_goal_30", name: "Dedicated", description: "Complete daily goal for 30 days", icon: "target", requirement: "30 days"),
        ]
    }

    // MARK: - Progress to Next Level
    func getProgressToNextLevel() -> Double {
        return Double(currentXP) / Double(xpForNextLevel)
    }

    // MARK: - Weekly Average
    func getWeeklyAverage() -> Double {
        // Simplified calculation
        let avgExercisesPerDay = Double(dailyGoalProgress) / 7.0
        return avgExercisesPerDay
    }

    // MARK: - Save Data
    private func saveData() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
        UserDefaults.standard.set(currentLevel, forKey: levelKey)
        UserDefaults.standard.set(totalPoints, forKey: totalPointsKey)
        UserDefaults.standard.set(currentXP, forKey: currentXPKey)
        UserDefaults.standard.set(totalWordsCompleted, forKey: wordsCompletedKey)
        UserDefaults.standard.set(totalSentencesCompleted, forKey: sentencesCompletedKey)
        UserDefaults.standard.set(totalConversationsCompleted, forKey: conversationsCompletedKey)
        UserDefaults.standard.set(perfectScoreCount, forKey: perfectScoreCountKey)
        UserDefaults.standard.set(dailyGoalProgress, forKey: dailyGoalProgressKey)

        if let lastDate = lastPracticeDate {
            UserDefaults.standard.set(lastDate, forKey: lastPracticeDateKey)
        }

        // Save badges
        if let encoded = try? JSONEncoder().encode(unlockedBadges) {
            UserDefaults.standard.set(encoded, forKey: badgesKey)
        }
    }

    // MARK: - Load Data
    private func loadData() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)
        currentLevel = max(1, UserDefaults.standard.integer(forKey: levelKey))
        totalPoints = UserDefaults.standard.integer(forKey: totalPointsKey)
        currentXP = UserDefaults.standard.integer(forKey: currentXPKey)
        totalWordsCompleted = UserDefaults.standard.integer(forKey: wordsCompletedKey)
        totalSentencesCompleted = UserDefaults.standard.integer(forKey: sentencesCompletedKey)
        totalConversationsCompleted = UserDefaults.standard.integer(forKey: conversationsCompletedKey)
        perfectScoreCount = UserDefaults.standard.integer(forKey: perfectScoreCountKey)
        dailyGoalProgress = UserDefaults.standard.integer(forKey: dailyGoalProgressKey)
        lastPracticeDate = UserDefaults.standard.object(forKey: lastPracticeDateKey) as? Date

        // Load badges
        if let data = UserDefaults.standard.data(forKey: badgesKey),
           let decoded = try? JSONDecoder().decode([Badge].self, from: data) {
            unlockedBadges = decoded
        } else {
            unlockedBadges = createDefaultBadges()
        }

        // Calculate XP for next level
        if currentLevel > 1 {
            xpForNextLevel = Int(100 * pow(xpMultiplier, Double(currentLevel - 1)))
        }
    }

    // MARK: - Reset (for testing)
    func resetProgress() {
        currentStreak = 0
        longestStreak = 0
        currentLevel = 1
        totalPoints = 0
        currentXP = 0
        xpForNextLevel = 100
        unlockedBadges = createDefaultBadges()
        totalWordsCompleted = 0
        totalSentencesCompleted = 0
        totalConversationsCompleted = 0
        perfectScoreCount = 0
        dailyGoalCompleted = false
        dailyGoalProgress = 0
        lastPracticeDate = nil
        newlyUnlockedBadges = []
        saveData()
    }

    // MARK: - Clear All Data (for logout)
    /// Completely clears all gamification data from UserDefaults and resets all properties
    /// Call this when a user logs out to prevent data leakage to the next user
    func clearAllData() {
        // Remove all UserDefaults keys
        UserDefaults.standard.removeObject(forKey: streakKey)
        UserDefaults.standard.removeObject(forKey: longestStreakKey)
        UserDefaults.standard.removeObject(forKey: levelKey)
        UserDefaults.standard.removeObject(forKey: totalPointsKey)
        UserDefaults.standard.removeObject(forKey: currentXPKey)
        UserDefaults.standard.removeObject(forKey: badgesKey)
        UserDefaults.standard.removeObject(forKey: wordsCompletedKey)
        UserDefaults.standard.removeObject(forKey: sentencesCompletedKey)
        UserDefaults.standard.removeObject(forKey: conversationsCompletedKey)
        UserDefaults.standard.removeObject(forKey: perfectScoreCountKey)
        UserDefaults.standard.removeObject(forKey: dailyGoalProgressKey)
        UserDefaults.standard.removeObject(forKey: lastPracticeDateKey)

        // Reset all in-memory properties
        currentStreak = 0
        longestStreak = 0
        currentLevel = 1
        totalPoints = 0
        currentXP = 0
        xpForNextLevel = 100
        unlockedBadges = []
        totalWordsCompleted = 0
        totalSentencesCompleted = 0
        totalConversationsCompleted = 0
        perfectScoreCount = 0
        dailyGoalCompleted = false
        dailyGoalProgress = 0
        lastPracticeDate = nil
        newlyUnlockedBadges = []

        print("✅ GamificationManager: All data cleared")
    }
}
