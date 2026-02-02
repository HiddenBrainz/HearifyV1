//
//  Analytics.swift
//  HearifyV1
//
//  Clinical analytics and patient outcome tracking
//  For audiologist dashboard and clinical validation
//

import Foundation
import SwiftUI

// MARK: - Session Analytics
struct SessionAnalytics: Codable, Identifiable {
    let id: UUID
    let userId: String
    let sessionDate: Date
    let exerciseType: String  // "Word Recognition", "Sentence Comprehension", etc.
    let duration: TimeInterval  // seconds
    let itemsAttempted: Int
    let itemsCorrect: Int
    let accuracy: Double
    let averageResponseTime: TimeInterval
    let backgroundNoiseLevel: String  // "Silent", "20dB SNR", etc.
    let phoneticErrors: [String]  // e.g., ["c-h initial", "r-l initial"]

    init(id: UUID = UUID(), userId: String, sessionDate: Date, exerciseType: String, duration: TimeInterval, itemsAttempted: Int, itemsCorrect: Int, accuracy: Double, averageResponseTime: TimeInterval, backgroundNoiseLevel: String, phoneticErrors: [String]) {
        self.id = id
        self.userId = userId
        self.sessionDate = sessionDate
        self.exerciseType = exerciseType
        self.duration = duration
        self.itemsAttempted = itemsAttempted
        self.itemsCorrect = itemsCorrect
        self.accuracy = accuracy
        self.averageResponseTime = averageResponseTime
        self.backgroundNoiseLevel = backgroundNoiseLevel
        self.phoneticErrors = phoneticErrors
    }

    var scoreGrade: String {
        if accuracy >= 0.9 { return "Excellent" }
        else if accuracy >= 0.8 { return "Good" }
        else if accuracy >= 0.7 { return "Fair" }
        else { return "Needs Practice" }
    }

    var scoreColor: Color {
        if accuracy >= 0.9 { return .green }
        else if accuracy >= 0.8 { return .blue }
        else if accuracy >= 0.7 { return .orange }
        else { return .red }
    }
}

// MARK: - Patient Metrics
struct PatientMetrics: Codable, Identifiable {
    let id: UUID
    let userId: String
    let patientName: String
    let enrollmentDate: Date
    let clinicianId: String?

    // Baseline Assessment
    var baselineWordRecognition: Double?
    var baselineSentenceComprehension: Double?
    var baselineNoisePerformance: Double?

    // Current Performance
    var currentWordRecognition: Double
    var currentSentenceComprehension: Double
    var currentNoisePerformance: Double

    // Engagement Metrics
    var totalSessions: Int
    var totalPracticeTime: TimeInterval  // minutes
    var averageSessionsPerWeek: Double
    var lastActiveDate: Date
    var streakDays: Int

    // Clinical Outcomes
    var improvementWordRecognition: Double {
        guard let baseline = baselineWordRecognition else { return 0 }
        return currentWordRecognition - baseline
    }

    var improvementSentenceComprehension: Double {
        guard let baseline = baselineSentenceComprehension else { return 0 }
        return currentSentenceComprehension - baseline
    }

    var improvementNoisePerformance: Double {
        guard let baseline = baselineNoisePerformance else { return 0 }
        return currentNoisePerformance - baseline
    }

    var engagementLevel: String {
        if averageSessionsPerWeek >= 5 { return "Highly Engaged" }
        else if averageSessionsPerWeek >= 3 { return "Engaged" }
        else if averageSessionsPerWeek >= 1 { return "Moderately Engaged" }
        else { return "Low Engagement" }
    }

    var daysSinceEnrollment: Int {
        Calendar.current.dateComponents([.day], from: enrollmentDate, to: Date()).day ?? 0
    }

    var weeksSinceEnrollment: Int {
        daysSinceEnrollment / 7
    }

    init(id: UUID = UUID(), userId: String, patientName: String, enrollmentDate: Date, clinicianId: String? = nil, baselineWordRecognition: Double? = nil, baselineSentenceComprehension: Double? = nil, baselineNoisePerformance: Double? = nil, currentWordRecognition: Double = 0, currentSentenceComprehension: Double = 0, currentNoisePerformance: Double = 0, totalSessions: Int = 0, totalPracticeTime: TimeInterval = 0, averageSessionsPerWeek: Double = 0, lastActiveDate: Date = Date(), streakDays: Int = 0) {
        self.id = id
        self.userId = userId
        self.patientName = patientName
        self.enrollmentDate = enrollmentDate
        self.clinicianId = clinicianId
        self.baselineWordRecognition = baselineWordRecognition
        self.baselineSentenceComprehension = baselineSentenceComprehension
        self.baselineNoisePerformance = baselineNoisePerformance
        self.currentWordRecognition = currentWordRecognition
        self.currentSentenceComprehension = currentSentenceComprehension
        self.currentNoisePerformance = currentNoisePerformance
        self.totalSessions = totalSessions
        self.totalPracticeTime = totalPracticeTime
        self.averageSessionsPerWeek = averageSessionsPerWeek
        self.lastActiveDate = lastActiveDate
        self.streakDays = streakDays
    }
}

// MARK: - Clinician Profile
struct ClinicianProfile: Codable, Identifiable {
    let id: UUID
    let name: String
    let credentials: String  // "AuD", "PhD", etc.
    let clinicName: String
    let email: String
    let phone: String?
    let joinDate: Date
    let isActive: Bool

    var displayName: String {
        "\(name), \(credentials)"
    }

    init(id: UUID = UUID(), name: String, credentials: String, clinicName: String, email: String, phone: String? = nil, joinDate: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.name = name
        self.credentials = credentials
        self.clinicName = clinicName
        self.email = email
        self.phone = phone
        self.joinDate = joinDate
        self.isActive = isActive
    }
}

// MARK: - Progress Snapshot
struct ProgressSnapshot: Codable, Identifiable {
    let id: UUID
    let userId: String
    let date: Date
    let wordRecognitionScore: Double
    let sentenceComprehensionScore: Double
    let noisePerformanceScore: Double
    let sessionsThisWeek: Int
    let totalPracticeMinutes: Double

    init(id: UUID = UUID(), userId: String, date: Date, wordRecognitionScore: Double, sentenceComprehensionScore: Double, noisePerformanceScore: Double, sessionsThisWeek: Int, totalPracticeMinutes: Double) {
        self.id = id
        self.userId = userId
        self.date = date
        self.wordRecognitionScore = wordRecognitionScore
        self.sentenceComprehensionScore = sentenceComprehensionScore
        self.noisePerformanceScore = noisePerformanceScore
        self.sessionsThisWeek = sessionsThisWeek
        self.totalPracticeMinutes = totalPracticeMinutes
    }
}

// MARK: - Analytics Manager
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()

    @Published var sessions: [SessionAnalytics] = []
    @Published var patientMetrics: PatientMetrics?
    @Published var progressSnapshots: [ProgressSnapshot] = []
    @Published var cloudSyncEnabled = true // Enable CloudKit sync

    private let sessionsKey = "analytics_sessions"
    private let metricsKey = "patient_metrics"
    private let snapshotsKey = "progress_snapshots"

    init() {
        loadData()
    }

    // MARK: - Session Tracking
    func recordSession(_ session: SessionAnalytics) {
        sessions.append(session)
        saveSessionsData()
        updatePatientMetrics()

        // Sync to both CloudKit and Firebase
        if cloudSyncEnabled {
            Task {
                // CloudKit sync
                do {
                    try await CloudKitManager.shared.syncSession(session)
                } catch {
                    print("⚠️ CloudKit sync failed: \(error.localizedDescription)")
                }

                // Firebase sync
                do {
                    try await FirebaseManager.shared.syncSession(session)
                } catch {
                    print("⚠️ Firebase session sync failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func recordSessionFromResult(
        exerciseType: String,
        duration: TimeInterval,
        itemsAttempted: Int,
        itemsCorrect: Int,
        backgroundNoiseLevel: String = "Silent",
        phoneticErrors: [String] = []
    ) {
        let accuracy = itemsAttempted > 0 ? Double(itemsCorrect) / Double(itemsAttempted) : 0.0

        let session = SessionAnalytics(
            userId: getCurrentUserId(),
            sessionDate: Date(),
            exerciseType: exerciseType,
            duration: duration,
            itemsAttempted: itemsAttempted,
            itemsCorrect: itemsCorrect,
            accuracy: accuracy,
            averageResponseTime: duration / Double(max(itemsAttempted, 1)),
            backgroundNoiseLevel: backgroundNoiseLevel,
            phoneticErrors: phoneticErrors
        )

        print("📊 Analytics: Recording session - \(exerciseType), \(itemsCorrect)/\(itemsAttempted) (\(Int(accuracy * 100))%)")
        recordSession(session)
    }

    // MARK: - Patient Metrics
    func initializePatient(name: String, clinicianId: String? = nil) {
        let metrics = PatientMetrics(
            userId: getCurrentUserId(),
            patientName: name,
            enrollmentDate: Date(),
            clinicianId: clinicianId
        )
        patientMetrics = metrics
        saveMetricsData()
    }

    func setBaseline(wordRecognition: Double, sentenceComprehension: Double, noisePerformance: Double) {
        guard var metrics = patientMetrics else { return }

        var updatedMetrics = PatientMetrics(
            id: metrics.id,
            userId: metrics.userId,
            patientName: metrics.patientName,
            enrollmentDate: metrics.enrollmentDate,
            clinicianId: metrics.clinicianId,
            baselineWordRecognition: wordRecognition,
            baselineSentenceComprehension: sentenceComprehension,
            baselineNoisePerformance: noisePerformance,
            currentWordRecognition: wordRecognition,
            currentSentenceComprehension: sentenceComprehension,
            currentNoisePerformance: noisePerformance,
            totalSessions: metrics.totalSessions,
            totalPracticeTime: metrics.totalPracticeTime,
            averageSessionsPerWeek: metrics.averageSessionsPerWeek,
            lastActiveDate: metrics.lastActiveDate,
            streakDays: metrics.streakDays
        )

        patientMetrics = updatedMetrics
        saveMetricsData()
    }

    private func updatePatientMetrics() {
        // Initialize if doesn't exist
        if patientMetrics == nil {
            initializePatient(name: "Patient")
        }

        guard let metrics = patientMetrics else { return }

        // Calculate current performance from recent sessions
        let recentSessions = sessions.suffix(20)  // Last 20 sessions

        let wordSessions = recentSessions.filter { $0.exerciseType == "Word Recognition" }
        let sentenceSessions = recentSessions.filter { $0.exerciseType == "Sentence Comprehension" }
        let noiseSessions = recentSessions.filter { $0.exerciseType == "Sentences in Noise" }

        let currentWord = wordSessions.isEmpty ? metrics.currentWordRecognition : wordSessions.map { $0.accuracy }.reduce(0, +) / Double(wordSessions.count)
        let currentSentence = sentenceSessions.isEmpty ? metrics.currentSentenceComprehension : sentenceSessions.map { $0.accuracy }.reduce(0, +) / Double(sentenceSessions.count)
        let currentNoise = noiseSessions.isEmpty ? metrics.currentNoisePerformance : noiseSessions.map { $0.accuracy }.reduce(0, +) / Double(noiseSessions.count)

        // Calculate engagement metrics
        let totalTime = sessions.map { $0.duration }.reduce(0, +) / 60.0  // Convert to minutes
        let weeksSince = max(metrics.weeksSinceEnrollment, 1)
        let sessionsPerWeek = Double(sessions.count) / Double(weeksSince)

        let updatedMetrics = PatientMetrics(
            id: metrics.id,
            userId: metrics.userId,
            patientName: metrics.patientName,
            enrollmentDate: metrics.enrollmentDate,
            clinicianId: metrics.clinicianId,
            baselineWordRecognition: metrics.baselineWordRecognition,
            baselineSentenceComprehension: metrics.baselineSentenceComprehension,
            baselineNoisePerformance: metrics.baselineNoisePerformance,
            currentWordRecognition: currentWord,
            currentSentenceComprehension: currentSentence,
            currentNoisePerformance: currentNoise,
            totalSessions: sessions.count,
            totalPracticeTime: totalTime,
            averageSessionsPerWeek: sessionsPerWeek,
            lastActiveDate: Date(),
            streakDays: calculateStreak()
        )

        patientMetrics = updatedMetrics
        saveMetricsData()

        // Sync to both CloudKit and Firebase
        if cloudSyncEnabled {
            Task {
                // CloudKit sync
                do {
                    try await CloudKitManager.shared.savePatientProfile()
                } catch {
                    print("⚠️ CloudKit patient metrics sync failed: \(error.localizedDescription)")
                }

                // Firebase sync
                do {
                    try await FirebaseManager.shared.savePatientProfile()
                } catch {
                    print("⚠️ Firebase patient metrics sync failed: \(error.localizedDescription)")
                }
            }
        }

        // Create weekly snapshot
        createWeeklySnapshot()
    }

    // MARK: - Progress Snapshots
    private func createWeeklySnapshot() {
        guard let metrics = patientMetrics else { return }

        // Check if we already have a snapshot this week
        let calendar = Calendar.current
        let thisWeek = calendar.component(.weekOfYear, from: Date())

        if let lastSnapshot = progressSnapshots.last {
            let lastWeek = calendar.component(.weekOfYear, from: lastSnapshot.date)
            if thisWeek == lastWeek { return }  // Already have snapshot this week
        }

        let snapshot = ProgressSnapshot(
            userId: getCurrentUserId(),
            date: Date(),
            wordRecognitionScore: metrics.currentWordRecognition,
            sentenceComprehensionScore: metrics.currentSentenceComprehension,
            noisePerformanceScore: metrics.currentNoisePerformance,
            sessionsThisWeek: getSessionsThisWeek(),
            totalPracticeMinutes: metrics.totalPracticeTime
        )

        progressSnapshots.append(snapshot)
        saveSnapshotsData()

        // CloudKit sync
        if cloudSyncEnabled {
            Task {
                do {
                    try await CloudKitManager.shared.syncProgressSnapshot(snapshot)
                } catch {
                    print("⚠️ CloudKit snapshot sync failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Helper Functions
    private func getCurrentUserId() -> String {
        // Get user ID from Firebase auth
        if let firebaseUser = FirebaseManager.shared.currentUser {
            return firebaseUser.uid
        }
        // Fallback to device ID
        return UIDevice.current.identifierForVendor?.uuidString ?? "anonymous"
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Get unique days where user practiced (count days, not sessions)
        var uniqueDays = Set<Date>()
        for session in sessions {
            let sessionDay = calendar.startOfDay(for: session.sessionDate)
            uniqueDays.insert(sessionDay)
        }

        // Sort unique days in descending order
        let sortedDays = uniqueDays.sorted(by: >)

        // Count consecutive days from today backwards
        for dayDate in sortedDays {
            let daysDifference = calendar.dateComponents([.day], from: dayDate, to: checkDate).day ?? 0

            if daysDifference <= 1 {
                // This day is part of the streak (today or consecutive)
                if daysDifference == 0 || daysDifference == 1 {
                    streak += 1
                    checkDate = calendar.date(byAdding: .day, value: -1, to: dayDate) ?? dayDate
                }
            } else {
                // Gap found, streak is broken
                break
            }
        }

        return streak
    }

    private func getSessionsThisWeek() -> Int {
        let calendar = Calendar.current
        let thisWeek = calendar.component(.weekOfYear, from: Date())
        return sessions.filter { calendar.component(.weekOfYear, from: $0.sessionDate) == thisWeek }.count
    }

    // NEW: Calculate unique days with practice sessions
    func getUniquePracticeDays() -> Int {
        let calendar = Calendar.current
        var uniqueDays = Set<Date>()

        for session in sessions {
            let sessionDay = calendar.startOfDay(for: session.sessionDate)
            uniqueDays.insert(sessionDay)
        }

        return uniqueDays.count
    }

    // NEW: Calculate total errors across all sessions
    func getTotalErrors() -> Int {
        return sessions.reduce(0) { total, session in
            total + (session.itemsAttempted - session.itemsCorrect)
        }
    }

    // NEW: Calculate error rate
    func getErrorRate() -> Double {
        let totalAttempted = sessions.reduce(0) { $0 + $1.itemsAttempted }
        let totalErrors = getTotalErrors()

        return totalAttempted > 0 ? Double(totalErrors) / Double(totalAttempted) : 0.0
    }

    // MARK: - Persistence
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([SessionAnalytics].self, from: data) {
            sessions = decoded
        }

        if let data = UserDefaults.standard.data(forKey: metricsKey),
           let decoded = try? JSONDecoder().decode(PatientMetrics.self, from: data) {
            patientMetrics = decoded
        }

        if let data = UserDefaults.standard.data(forKey: snapshotsKey),
           let decoded = try? JSONDecoder().decode([ProgressSnapshot].self, from: data) {
            progressSnapshots = decoded
        }
    }

    private func saveSessionsData() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }

    private func saveMetricsData() {
        if let encoded = try? JSONEncoder().encode(patientMetrics) {
            UserDefaults.standard.set(encoded, forKey: metricsKey)
        }
    }

    private func saveSnapshotsData() {
        if let encoded = try? JSONEncoder().encode(progressSnapshots) {
            UserDefaults.standard.set(encoded, forKey: snapshotsKey)
        }
    }

    // MARK: - Analytics Queries
    func getAverageAccuracy(for exerciseType: String, last days: Int = 30) -> Double {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let filtered = sessions.filter { $0.exerciseType == exerciseType && $0.sessionDate >= cutoffDate }
        guard !filtered.isEmpty else { return 0 }
        return filtered.map { $0.accuracy }.reduce(0, +) / Double(filtered.count)
    }

    // MARK: - Demo/Testing Functions
    func generateSampleData() {
        // Initialize patient if needed
        if patientMetrics == nil {
            initializePatient(name: "Demo Patient")
        }

        // Set baseline scores
        setBaseline(wordRecognition: 0.60, sentenceComprehension: 0.55, noisePerformance: 0.45)

        // Generate sample sessions over past 2 weeks
        let now = Date()
        for dayOffset in (0..<14).reversed() {
            let sessionDate = Calendar.current.date(byAdding: .day, value: -dayOffset, to: now) ?? now

            // 1-2 sessions per day
            let sessionsThisDay = Int.random(in: 1...2)

            for _ in 0..<sessionsThisDay {
                let exerciseTypes = ["Word Recognition", "Sentence Comprehension", "Sentences in Noise"]
                let exerciseType = exerciseTypes.randomElement() ?? "Word Recognition"

                // Simulate improving accuracy over time
                let baseAccuracy: Double
                switch exerciseType {
                case "Word Recognition":
                    baseAccuracy = 0.60 + Double(14 - dayOffset) * 0.015 // Improve from 60% to 80%
                case "Sentence Comprehension":
                    baseAccuracy = 0.55 + Double(14 - dayOffset) * 0.018 // Improve from 55% to 80%
                case "Sentences in Noise":
                    baseAccuracy = 0.45 + Double(14 - dayOffset) * 0.020 // Improve from 45% to 75%
                default:
                    baseAccuracy = 0.60
                }

                let accuracy = min(0.95, baseAccuracy + Double.random(in: -0.05...0.10))
                let itemsAttempted = Int.random(in: 15...25)
                let itemsCorrect = Int(Double(itemsAttempted) * accuracy)

                let session = SessionAnalytics(
                    userId: getCurrentUserId(),
                    sessionDate: sessionDate,
                    exerciseType: exerciseType,
                    duration: TimeInterval.random(in: 300...600), // 5-10 minutes
                    itemsAttempted: itemsAttempted,
                    itemsCorrect: itemsCorrect,
                    accuracy: accuracy,
                    averageResponseTime: TimeInterval.random(in: 2...5),
                    backgroundNoiseLevel: exerciseType == "Sentences in Noise" ? "Cafe noise at 30%" : "Silent",
                    phoneticErrors: []
                )

                sessions.append(session)
            }
        }

        saveSessionsData()
        updatePatientMetrics()
    }

    /// Completely clears all analytics data from UserDefaults and memory
    /// Call this when a user logs out to prevent data leakage to the next user
    func clearAllData() {
        // Clear in-memory data
        sessions = []
        patientMetrics = nil
        progressSnapshots = []

        // Remove all UserDefaults keys
        UserDefaults.standard.removeObject(forKey: sessionsKey)
        UserDefaults.standard.removeObject(forKey: metricsKey)
        UserDefaults.standard.removeObject(forKey: snapshotsKey)

        print("✅ AnalyticsManager: All data cleared")
    }

    func getTotalPracticeTime(last days: Int = 30) -> TimeInterval {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return sessions.filter { $0.sessionDate >= cutoffDate }.map { $0.duration }.reduce(0, +)
    }

    func getSessionCount(last days: Int = 30) -> Int {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return sessions.filter { $0.sessionDate >= cutoffDate }.count
    }
}
