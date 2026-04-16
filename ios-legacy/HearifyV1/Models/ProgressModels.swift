//
//  ProgressModels.swift
//  HearifyV1
//
//  Data models for tracking user progress, scores, and achievements
//  High Priority Feature: Progress Tracking System
//

import Foundation
import SwiftUI

// MARK: - Matched Pair Statistics
struct MatchedPairStat: Identifiable {
    let id = UUID()
    let pairName: String
    let practiceCount: Int
    let accuracy: Double
}

// MARK: - User Practice Session
struct UserPracticeSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let phase: Int // 1, 2, or 3
    let exerciseType: String
    let phoneme: String?
    let score: Double // 0.0 to 1.0
    let duration: TimeInterval // seconds
    let attempts: Int

    init(phase: Int, exerciseType: String, phoneme: String? = nil, score: Double, duration: TimeInterval, attempts: Int = 1) {
        self.id = UUID()
        self.date = Date()
        self.phase = phase
        self.exerciseType = exerciseType
        self.phoneme = phoneme
        self.score = score
        self.duration = duration
        self.attempts = attempts
    }
}

// MARK: - Daily Progress
struct DailyProgress: Codable, Identifiable {
    let id: UUID
    let date: Date
    var sessions: [UserPracticeSession]
    var totalDuration: TimeInterval
    var averageScore: Double
    var exercisesCompleted: Int

    init(date: Date) {
        self.id = UUID()
        self.date = date
        self.sessions = []
        self.totalDuration = 0
        self.averageScore = 0
        self.exercisesCompleted = 0
    }

    mutating func addSession(_ session: UserPracticeSession) {
        sessions.append(session)
        exercisesCompleted += 1
        totalDuration += session.duration

        // Recalculate average
        averageScore = sessions.map { $0.score }.reduce(0, +) / Double(sessions.count)
    }
}

// MARK: - Streak Data
struct StreakData: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastPracticeDate: Date?
    var totalPracticeDays: Int

    init() {
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastPracticeDate = nil
        self.totalPracticeDays = 0
    }

    mutating func updateStreak(for date: Date) {
        guard let lastDate = lastPracticeDate else {
            // First time practicing
            currentStreak = 1
            longestStreak = 1
            lastPracticeDate = date
            totalPracticeDays = 1
            return
        }

        let calendar = Calendar.current
        let daysSinceLastPractice = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: date)).day ?? 0

        if daysSinceLastPractice == 0 {
            // Same day, no streak change
            return
        } else if daysSinceLastPractice == 1 {
            // Consecutive day
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            // Streak broken
            currentStreak = 1
        }

        lastPracticeDate = date
        totalPracticeDays += 1
    }
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    var progress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?

    enum AchievementCategory: String, Codable {
        case streak
        case score
        case practice
        case phoneme
        case milestone
    }

    var progressPercentage: Double {
        return min(Double(progress) / Double(requirement), 1.0)
    }

    mutating func updateProgress(_ newProgress: Int) {
        progress = newProgress
        if progress >= requirement && !isUnlocked {
            isUnlocked = true
            unlockedDate = Date()
        }
    }
}

// MARK: - Phoneme Statistics
struct PhonemeStats: Codable {
    let phoneme: String
    var attemptCount: Int
    var totalScore: Double
    var bestScore: Double
    var lastPracticed: Date

    var averageScore: Double {
        return attemptCount > 0 ? totalScore / Double(attemptCount) : 0
    }

    init(phoneme: String, score: Double) {
        self.phoneme = phoneme
        self.attemptCount = 1
        self.totalScore = score
        self.bestScore = score
        self.lastPracticed = Date()
    }

    mutating func addAttempt(score: Double) {
        attemptCount += 1
        totalScore += score
        if score > bestScore {
            bestScore = score
        }
        lastPracticed = Date()
    }
}

// MARK: - User Progress (Main Container)
struct UserProgress: Codable {
    var streak: StreakData
    var dailyProgress: [String: DailyProgress] // Date string as key
    var sessions: [UserPracticeSession]
    var achievements: [Achievement]
    var phonemeStats: [String: PhonemeStats] // Phoneme as key
    var totalExercises: Int
    var totalDuration: TimeInterval

    init() {
        self.streak = StreakData()
        self.dailyProgress = [:]
        self.sessions = []
        self.achievements = Achievement.defaultAchievements
        self.phonemeStats = [:]
        self.totalExercises = 0
        self.totalDuration = 0
    }

    // Add a session and update all stats
    mutating func addSession(_ session: UserPracticeSession) {
        sessions.append(session)
        totalExercises += 1
        totalDuration += session.duration

        // Update daily progress
        let dateKey = dateToKey(session.date)
        if dailyProgress[dateKey] == nil {
            dailyProgress[dateKey] = DailyProgress(date: session.date)
        }
        dailyProgress[dateKey]?.addSession(session)

        // Update streak
        streak.updateStreak(for: session.date)

        // Update phoneme stats
        if let phoneme = session.phoneme {
            if phonemeStats[phoneme] == nil {
                phonemeStats[phoneme] = PhonemeStats(phoneme: phoneme, score: session.score)
            } else {
                phonemeStats[phoneme]?.addAttempt(score: session.score)
            }
        }

        // Check achievements
        checkAchievements()
    }

    private mutating func checkAchievements() {
        for index in achievements.indices {
            switch achievements[index].category {
            case .streak:
                achievements[index].updateProgress(streak.currentStreak)
            case .practice:
                achievements[index].updateProgress(totalExercises)
            case .score:
                let perfectScores = sessions.filter { $0.score >= 0.95 }.count
                achievements[index].updateProgress(perfectScores)
            case .phoneme:
                achievements[index].updateProgress(phonemeStats.count)
            case .milestone:
                achievements[index].updateProgress(Int(totalDuration / 60)) // minutes
            }
        }
    }

    private func dateToKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Default Achievements
extension Achievement {
    static var defaultAchievements: [Achievement] {
        return [
            // Streak achievements
            Achievement(id: "streak_3", title: "Getting Started", description: "Practice 3 days in a row", icon: "flame.fill", category: .streak, requirement: 3, progress: 0, isUnlocked: false),
            Achievement(id: "streak_7", title: "Week Warrior", description: "Practice 7 days in a row", icon: "flame.fill", category: .streak, requirement: 7, progress: 0, isUnlocked: false),
            Achievement(id: "streak_30", title: "Monthly Master", description: "Practice 30 days in a row", icon: "flame.fill", category: .streak, requirement: 30, progress: 0, isUnlocked: false),

            // Score achievements
            Achievement(id: "perfect_10", title: "Perfectionist", description: "Get 10 perfect scores (95%+)", icon: "star.fill", category: .score, requirement: 10, progress: 0, isUnlocked: false),
            Achievement(id: "perfect_50", title: "Excellence", description: "Get 50 perfect scores", icon: "star.fill", category: .score, requirement: 50, progress: 0, isUnlocked: false),

            // Practice achievements
            Achievement(id: "exercises_25", title: "Dedicated Learner", description: "Complete 25 exercises", icon: "checkmark.circle.fill", category: .practice, requirement: 25, progress: 0, isUnlocked: false),
            Achievement(id: "exercises_100", title: "Committed", description: "Complete 100 exercises", icon: "checkmark.circle.fill", category: .practice, requirement: 100, progress: 0, isUnlocked: false),
            Achievement(id: "exercises_500", title: "Master Practitioner", description: "Complete 500 exercises", icon: "checkmark.circle.fill", category: .practice, requirement: 500, progress: 0, isUnlocked: false),

            // Phoneme achievements
            Achievement(id: "phoneme_10", title: "Sound Explorer", description: "Practice 10 different phonemes", icon: "waveform", category: .phoneme, requirement: 10, progress: 0, isUnlocked: false),
            Achievement(id: "phoneme_all", title: "Phoneme Master", description: "Practice all 34 phonemes", icon: "waveform.circle.fill", category: .phoneme, requirement: 34, progress: 0, isUnlocked: false),

            // Time achievements
            Achievement(id: "time_60", title: "Hour of Practice", description: "Practice for 60 minutes total", icon: "clock.fill", category: .milestone, requirement: 60, progress: 0, isUnlocked: false),
            Achievement(id: "time_600", title: "10 Hour Club", description: "Practice for 10 hours total", icon: "clock.fill", category: .milestone, requirement: 600, progress: 0, isUnlocked: false),
        ]
    }
}
