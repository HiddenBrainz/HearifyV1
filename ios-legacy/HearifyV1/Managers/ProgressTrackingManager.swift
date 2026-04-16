//
//  ProgressTrackingManager.swift
//  HearifyV1
//
//  Progress tracking for pronunciation practice
//  Tracks scores, streaks, and improvement over time
//

import Foundation
import SwiftUI

// MARK: - Practice Session Model
struct PracticeSession: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let exerciseText: String
    let exerciseType: ExerciseType
    let recognizedText: String
    let score: Double
    let duration: TimeInterval
    let phonemeAccuracy: [String: Double]  // word: accuracy

    init(id: UUID = UUID(), date: Date = Date(), exerciseText: String, exerciseType: ExerciseType, recognizedText: String, score: Double, duration: TimeInterval, phonemeAccuracy: [String: Double] = [:]) {
        self.id = id
        self.date = date
        self.exerciseText = exerciseText
        self.exerciseType = exerciseType
        self.recognizedText = recognizedText
        self.score = score
        self.duration = duration
        self.phonemeAccuracy = phonemeAccuracy
    }
    
    // Equatable conformance - compare by ID
    static func == (lhs: PracticeSession, rhs: PracticeSession) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Daily Stats
struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let averageScore: Double
    let sessionsCount: Int
    let totalDuration: TimeInterval
}

// MARK: - Progress Tracking Manager
class ProgressTrackingManager: ObservableObject {
    static let shared = ProgressTrackingManager()

    @Published var allSessions: [PracticeSession] = []
    @Published var dailyStats: [DailyStats] = []

    private let sessionsKey = "practice_sessions"
    private let maxStoredSessions = 500  // Keep last 500 sessions

    init() {
        loadSessions()
        // Don't calculate daily stats on init - calculate lazily when needed
    }

    // MARK: - Add Session
    func addSession(_ session: PracticeSession) {
        allSessions.insert(session, at: 0)  // Most recent first

        // Keep only recent sessions
        if allSessions.count > maxStoredSessions {
            allSessions = Array(allSessions.prefix(maxStoredSessions))
        }

        saveSessions()
        // Don't recalculate stats on every add - too expensive! Calculate lazily when viewing dashboard
    }

    // MARK: - Get Sessions by Date Range
    func getSessions(from startDate: Date, to endDate: Date) -> [PracticeSession] {
        return allSessions.filter { session in
            session.date >= startDate && session.date <= endDate
        }
    }

    // MARK: - Get Sessions by Type
    func getSessions(ofType type: ExerciseType) -> [PracticeSession] {
        return allSessions.filter { $0.exerciseType == type }
    }

    // MARK: - Calculate Average Score
    func getAverageScore(for period: TimePeriod = .allTime) -> Double {
        let sessions = getSessionsForPeriod(period)
        guard !sessions.isEmpty else { return 0 }

        let total = sessions.reduce(0.0) { $0 + $1.score }
        return total / Double(sessions.count)
    }

    // MARK: - Get Best/Worst Exercises
    func getBestExercises(limit: Int = 5) -> [PracticeSession] {
        return allSessions.sorted { $0.score > $1.score }.prefix(limit).map { $0 }
    }

    func getWorstExercises(limit: Int = 5) -> [PracticeSession] {
        return allSessions.sorted { $0.score < $1.score }.prefix(limit).map { $0 }
    }

    // MARK: - Get Most Practiced
    func getMostPracticedExercises(limit: Int = 5) -> [(text: String, count: Int)] {
        let grouped = Dictionary(grouping: allSessions) { $0.exerciseText }
        let sorted = grouped.map { (text: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
        return Array(sorted.prefix(limit))
    }

    // MARK: - Get Improvement Rate
    func getImprovementRate(for exerciseText: String) -> Double? {
        let sessions = allSessions.filter { $0.exerciseText == exerciseText }
            .sorted { $0.date < $1.date }

        guard sessions.count >= 2 else { return nil }

        let firstScore = sessions.first?.score ?? 0
        let lastScore = sessions.last?.score ?? 0

        return lastScore - firstScore
    }

    // MARK: - Get Score Trend
    func getScoreTrend(for period: TimePeriod) -> [DailyStats] {
        let sessions = getSessionsForPeriod(period)

        // Group by day
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }

        // Calculate daily averages
        return grouped.map { date, sessions in
            let avgScore = sessions.reduce(0.0) { $0 + $1.score } / Double(sessions.count)
            let totalDuration = sessions.reduce(0.0) { $0 + $1.duration }
            return DailyStats(date: date, averageScore: avgScore, sessionsCount: sessions.count, totalDuration: totalDuration)
        }.sorted { $0.date < $1.date }
    }

    // MARK: - Get Stats by Exercise Type
    func getStatsByType() -> [(type: ExerciseType, avgScore: Double, count: Int)] {
        let types: [ExerciseType] = [.word, .sentence, .conversation]

        return types.map { type in
            let sessions = getSessions(ofType: type)
            let avgScore = sessions.isEmpty ? 0 : sessions.reduce(0.0) { $0 + $1.score } / Double(sessions.count)
            return (type: type, avgScore: avgScore, count: sessions.count)
        }
    }

    // MARK: - Helper Methods
    func getSessionsForPeriod(_ period: TimePeriod) -> [PracticeSession] {
        let calendar = Calendar.current
        let now = Date()

        let startDate: Date
        switch period {
        case .today:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .allTime:
            return allSessions
        }

        return allSessions.filter { $0.date >= startDate }
    }

    private func calculateDailyStats() {
        dailyStats = getScoreTrend(for: .month)
    }

    // MARK: - Persistence
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(allSessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([PracticeSession].self, from: data) {
            allSessions = decoded
        }
    }

    // MARK: - Clear History
    /// Completely clears all session data from UserDefaults and memory
    /// Call this when a user logs out to prevent data leakage to the next user
    func clearAllSessions() {
        allSessions = []
        dailyStats = []

        // Remove UserDefaults key to ensure complete cleanup
        UserDefaults.standard.removeObject(forKey: sessionsKey)

        print("✅ ProgressTrackingManager: All sessions cleared")
    }
}

// MARK: - Time Period Enum
enum TimePeriod {
    case today
    case week
    case month
    case year
    case allTime
}
