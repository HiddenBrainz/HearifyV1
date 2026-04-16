//
//  ProgressManager.swift
//  HearifyV1
//
//  Manages user progress, sessions, achievements, and streaks
//  High Priority Feature: Progress Tracking System
//

import Foundation
import SwiftUI

class ProgressManager: ObservableObject {
    static let shared = ProgressManager()

    @Published var userProgress: UserProgress

    private let saveKey = "com.hearify.userProgress"
    private let fileManager = FileManager.default

    private init() {
        // Load existing progress or create new
        if let loaded = ProgressManager.loadProgress() {
            self.userProgress = loaded
            print("✅ Loaded existing progress: \(loaded.totalExercises) exercises, \(loaded.streak.currentStreak) day streak")
        } else {
            self.userProgress = UserProgress()
            print("📝 Created new progress tracking")
        }
    }

    // MARK: - Add Session
    func recordSession(phase: Int, exerciseType: String, phoneme: String?, score: Double, duration: TimeInterval, attempts: Int = 1) {
        let session = UserPracticeSession(
            phase: phase,
            exerciseType: exerciseType,
            phoneme: phoneme,
            score: score,
            duration: duration,
            attempts: attempts
        )

        userProgress.addSession(session)
        saveProgress()

        print("📊 Session recorded: Phase \(phase), Score: \(Int(score * 100))%, Streak: \(userProgress.streak.currentStreak)")

        // Check for newly unlocked achievements
        checkNewlyUnlockedAchievements()
    }

    // MARK: - Getters
    func getCurrentStreak() -> Int {
        return userProgress.streak.currentStreak
    }

    func getLongestStreak() -> Int {
        return userProgress.streak.longestStreak
    }

    func getTotalExercises() -> Int {
        return userProgress.totalExercises
    }

    func getAverageScore() -> Double {
        guard !userProgress.sessions.isEmpty else { return 0 }
        let total = userProgress.sessions.map { $0.score }.reduce(0, +)
        return total / Double(userProgress.sessions.count)
    }

    func getRecentSessions(limit: Int = 10) -> [UserPracticeSession] {
        return Array(userProgress.sessions.suffix(limit).reversed())
    }

    func getPhonemeStats() -> [PhonemeStats] {
        return Array(userProgress.phonemeStats.values).sorted { $0.averageScore > $1.averageScore }
    }

    func getUnlockedAchievements() -> [Achievement] {
        return userProgress.achievements.filter { $0.isUnlocked }
    }

    func getLockedAchievements() -> [Achievement] {
        return userProgress.achievements.filter { !$0.isUnlocked }
    }

    func getScoreHistory(days: Int = 30) -> [(Date, Double)] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            return []
        }

        var history: [(Date, Double)] = []
        for (dateKey, daily) in userProgress.dailyProgress {
            if let date = keyToDate(dateKey), date >= startDate {
                history.append((date, daily.averageScore))
            }
        }

        return history.sorted { $0.0 < $1.0 }
    }

    // MARK: - Save/Load
    private func saveProgress() {
        do {
            let data = try JSONEncoder().encode(userProgress)
            let url = Self.getProgressFileURL()
            try data.write(to: url)
            print("💾 Progress saved")
        } catch {
            print("❌ Failed to save progress: \(error)")
        }
    }

    private static func loadProgress() -> UserProgress? {
        do {
            let url = Self.getProgressFileURL()
            let data = try Data(contentsOf: url)
            let progress = try JSONDecoder().decode(UserProgress.self, from: data)
            return progress
        } catch {
            print("⚠️ No existing progress found or failed to load: \(error)")
            return nil
        }
    }

    private static func getProgressFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("userProgress.json")
    }

    // MARK: - Export
    func exportProgressReport() -> String {
        var report = "# Hearify Progress Report\n\n"
        report += "Generated: \(Date())\n\n"

        report += "## Overall Statistics\n"
        report += "- Total Exercises: \(userProgress.totalExercises)\n"
        report += "- Total Practice Time: \(Int(userProgress.totalDuration / 60)) minutes\n"
        report += "- Average Score: \(Int(getAverageScore() * 100))%\n"
        report += "- Current Streak: \(userProgress.streak.currentStreak) days\n"
        report += "- Longest Streak: \(userProgress.streak.longestStreak) days\n\n"

        report += "## Achievements Unlocked (\(getUnlockedAchievements().count))\n"
        for achievement in getUnlockedAchievements() {
            report += "- ✅ \(achievement.title): \(achievement.description)\n"
        }
        report += "\n"

        // NEW: Matched Pairs Section
        report += "## Matched Pairs Practice\n"
        let matchedPairsStats = getMatchedPairsStats()
        if !matchedPairsStats.isEmpty {
            for pair in matchedPairsStats {
                report += "- \(pair.pairName): \(pair.practiceCount) practice items, \(Int(pair.accuracy * 100))% correct\n"
            }
        } else {
            report += "- No matched pairs practiced yet\n"
        }
        report += "\n"

        report += "## Phoneme Statistics\n"
        for stat in getPhonemeStats().prefix(10) {
            report += "- \(stat.phoneme): \(stat.attemptCount) attempts, \(Int(stat.averageScore * 100))% avg, \(Int(stat.bestScore * 100))% best\n"
        }
        report += "\n"

        report += "## Recent Sessions\n"
        for session in getRecentSessions(limit: 20) {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            report += "- \(formatter.string(from: session.date)): Phase \(session.phase), \(Int(session.score * 100))%\n"
        }

        return report
    }
    
    // MARK: - Matched Pairs Statistics
    private func getMatchedPairsStats() -> [MatchedPairStat] {
        // Group sessions by phoneme (which represents minimal pairs)
        var pairStats: [String: (totalPractice: Int, totalScore: Double, attempts: Int)] = [:]
        
        for session in userProgress.sessions {
            guard let phoneme = session.phoneme else { continue }
            
            // Generate pair name from phoneme
            let pairName = generatePairName(from: phoneme, exerciseType: session.exerciseType)
            
            if var existing = pairStats[pairName] {
                existing.totalPractice += session.attempts
                existing.totalScore += session.score
                existing.attempts += 1
                pairStats[pairName] = existing
            } else {
                pairStats[pairName] = (session.attempts, session.score, 1)
            }
        }
        
        // Convert to array and sort by practice count
        return pairStats.map { key, value in
            let avgScore = value.totalScore / Double(value.attempts)
            return MatchedPairStat(
                pairName: key,
                practiceCount: value.totalPractice,
                accuracy: avgScore
            )
        }.sorted { $0.practiceCount > $1.practiceCount }
    }
    
    private func generatePairName(from phoneme: String, exerciseType: String) -> String {
        // Map common phonemes to their minimal pair names
        let phonemeToPair: [String: String] = [
            "i:": "sheep vs ship (long i vs short i)",
            "ɪ": "sheep vs ship (long i vs short i)",
            "u:": "food vs book (long u vs short u)",
            "ʊ": "food vs book (long u vs short u)",
            "æ": "cat vs bat (vowel discrimination)",
            "ɛ": "bed vs bad (vowel discrimination)",
            "θ": "think vs sink (th vs s)",
            "ð": "this vs dis (voiced th)",
            "r": "rice vs lice (r vs l)",
            "l": "rice vs lice (r vs l)",
            "w": "wine vs vine (w vs v)",
            "v": "wine vs vine (w vs v)",
            "p": "pen vs ben (p vs b)",
            "b": "pen vs ben (p vs b)",
            "t": "two vs do (t vs d)",
            "d": "two vs do (t vs d)",
            "k": "came vs game (k vs g)",
            "g": "came vs game (k vs g)",
            "s": "see vs she (s vs sh)",
            "ʃ": "see vs she (s vs sh)",
            "f": "fan vs van (f vs v)",
            "z": "zoo vs sue (z vs s)",
            "tʃ": "chin vs shin (ch vs sh)",
            "dʒ": "jug vs chug (j vs ch)"
        ]
        
        return phonemeToPair[phoneme] ?? phoneme
    }

    // MARK: - Achievement Notifications
    private func checkNewlyUnlockedAchievements() {
        let newlyUnlocked = userProgress.achievements.filter { achievement in
            achievement.isUnlocked &&
            achievement.unlockedDate != nil &&
            Date().timeIntervalSince(achievement.unlockedDate!) < 1.0
        }

        for achievement in newlyUnlocked {
            print("🏆 Achievement Unlocked: \(achievement.title)")
            // Could trigger notification here
        }
    }

    // MARK: - Helpers
    private func keyToDate(_ key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: key)
    }

    // MARK: - Reset (for testing)
    /// Completely resets all progress data
    /// Call this when a user logs out to prevent data leakage to the next user
    func resetProgress() {
        userProgress = UserProgress()

        // Delete the progress file to ensure complete cleanup
        do {
            let url = Self.getProgressFileURL()
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("✅ ProgressManager: Progress file deleted")
            }
        } catch {
            print("⚠️ Failed to delete progress file: \(error)")
        }

        print("✅ ProgressManager: All progress data cleared")
    }
}
