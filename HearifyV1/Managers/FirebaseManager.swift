//
//  FirebaseManager.swift
//  HearifyV1
//
//  Firebase manager for patient data sync
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    @Published var currentUser: User?
    @Published var isSignedIn = false

    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private let storage = Storage.storage()

    private init() {
        // Check if already signed in with email/password (not anonymous)
        if let user = auth.currentUser {
            if user.isAnonymous {
                // Sign out anonymous users - require proper authentication
                try? auth.signOut()
                print("⚠️ Signed out anonymous user - login required")
            } else {
                // User has proper email/password authentication
                self.currentUser = user
                self.isSignedIn = true
                print("✅ Firebase: User already signed in: \(user.uid)")
            }
        }
    }

    // MARK: - Authentication

    /// Anonymous sign-in for patients (no email/password needed)
    func signInAnonymously() async throws {
        let result = try await auth.signInAnonymously()
        await MainActor.run {
            self.currentUser = result.user
            self.isSignedIn = true
        }
        print("✅ Patient signed in anonymously: \(result.user.uid)")
    }

    /// Sign up with email and password
    func signUp(email: String, password: String, name: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        await MainActor.run {
            self.currentUser = result.user
            self.isSignedIn = true
        }

        // Create patient profile with name
        let uid = result.user.uid
        let data: [String: Any] = [
            "patientName": name,
            "email": email,
            "enrollmentDate": Timestamp(date: Date()),
            "totalSessions": 0,
            "currentWordRecognition": 0.0,
            "currentSentenceComprehension": 0.0,
            "currentNoisePerformance": 0.0,
            "lastActiveDate": Timestamp(date: Date()),
            "streakDays": 0,
            "totalPracticeTime": 0.0,
            "averageSessionsPerWeek": 0.0
        ]

        try await db.collection("patients").document(uid).setData(data)

        // Initialize patient metrics locally on main thread
        let patientMetrics = PatientMetrics(
            userId: uid,
            patientName: name,
            enrollmentDate: Date()
        )

        await MainActor.run {
            AnalyticsManager.shared.patientMetrics = patientMetrics
        }

        print("✅ Patient signed up: \(name) (\(uid))")
    }

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        let result = try await auth.signIn(withEmail: email, password: password)
        await MainActor.run {
            self.currentUser = result.user
            self.isSignedIn = true
        }

        // Load patient profile and ALL user data from Firebase
        let uid = result.user.uid
        let document = try await db.collection("patients").document(uid).getDocument()

        if let data = document.data(),
           let name = data["patientName"] as? String,
           let enrollmentTimestamp = data["enrollmentDate"] as? Timestamp {

            // Create patient metrics object
            let patientMetrics = PatientMetrics(
                userId: uid,
                patientName: name,
                enrollmentDate: enrollmentTimestamp.dateValue(),
                baselineWordRecognition: data["baselineWordRecognition"] as? Double,
                baselineSentenceComprehension: data["baselineSentenceComprehension"] as? Double,
                baselineNoisePerformance: data["baselineNoisePerformance"] as? Double,
                currentWordRecognition: data["currentWordRecognition"] as? Double ?? 0.0,
                currentSentenceComprehension: data["currentSentenceComprehension"] as? Double ?? 0.0,
                currentNoisePerformance: data["currentNoisePerformance"] as? Double ?? 0.0,
                totalSessions: data["totalSessions"] as? Int ?? 0,
                totalPracticeTime: data["totalPracticeTime"] as? Double ?? 0.0,
                averageSessionsPerWeek: data["averageSessionsPerWeek"] as? Double ?? 0.0,
                lastActiveDate: (data["lastActiveDate"] as? Timestamp)?.dateValue() ?? Date(),
                streakDays: data["streakDays"] as? Int ?? 0
            )

            // Update on main thread
            await MainActor.run {
                AnalyticsManager.shared.patientMetrics = patientMetrics
            }

            // Load gamification data from Firebase
            if let gamificationData = data["gamification"] as? [String: Any] {
                await MainActor.run {
                    GamificationManager.shared.currentStreak = gamificationData["currentStreak"] as? Int ?? 0
                    GamificationManager.shared.longestStreak = gamificationData["longestStreak"] as? Int ?? 0
                    GamificationManager.shared.currentLevel = gamificationData["currentLevel"] as? Int ?? 1
                    GamificationManager.shared.totalPoints = gamificationData["totalPoints"] as? Int ?? 0
                    GamificationManager.shared.currentXP = gamificationData["currentXP"] as? Int ?? 0
                    GamificationManager.shared.totalWordsCompleted = gamificationData["totalWordsCompleted"] as? Int ?? 0
                    GamificationManager.shared.totalSentencesCompleted = gamificationData["totalSentencesCompleted"] as? Int ?? 0
                    GamificationManager.shared.totalConversationsCompleted = gamificationData["totalConversationsCompleted"] as? Int ?? 0
                    GamificationManager.shared.perfectScoreCount = gamificationData["perfectScoreCount"] as? Int ?? 0
                    GamificationManager.shared.dailyGoalProgress = gamificationData["dailyGoalProgress"] as? Int ?? 0

                    if let lastPracticeTimestamp = gamificationData["lastPracticeDate"] as? Timestamp {
                        GamificationManager.shared.lastPracticeDate = lastPracticeTimestamp.dateValue()
                    }

                    print("✅ Gamification data restored from Firebase")
                }
            }

            // Load session history from Firebase (last 100 sessions)
            try? await loadRecentSessions(uid: uid)

            // Sync profile to ensure clinician has latest data
            try? await savePatientProfile()
            print("✅ Patient profile synced for clinician access")
        }

        print("✅ Patient signed in: \(uid)")
    }

    /// Sign out
    func signOut() throws {
        try auth.signOut()

        // Clear authentication session
        currentUser = nil
        isSignedIn = false

        // Clear ALL local data to prevent data leakage to next user
        // Data is preserved in Firebase and will be restored when user logs back in
        // Ensure all manager updates happen on main thread since they update @Published properties
        DispatchQueue.main.async {
            AnalyticsManager.shared.clearAllData()
            GamificationManager.shared.clearAllData()
            ProgressManager.shared.resetProgress()
            ProgressTrackingManager.shared.clearAllSessions()
        }

        print("✅ Patient signed out (local data cleared, cloud data preserved)")
    }

    // MARK: - Patient Profile

    /// Save patient profile to Firebase
    func savePatientProfile() async throws {
        guard let uid = currentUser?.uid else {
            throw NSError(domain: "Not signed in", code: -1)
        }

        guard let metrics = AnalyticsManager.shared.patientMetrics else {
            // Create minimal profile if no metrics
            let minimalData: [String: Any] = [
                "patientName": "New Patient",
                "enrollmentDate": Timestamp(date: Date()),
                "totalSessions": 0,
                "currentWordRecognition": 0.0,
                "currentSentenceComprehension": 0.0,
                "currentNoisePerformance": 0.0,
                "lastActiveDate": Timestamp(date: Date()),
                "streakDays": 0,
                "totalPracticeTime": 0.0,
                "averageSessionsPerWeek": 0.0
            ]

            try await db.collection("patients").document(uid).setData(minimalData, merge: true)
            print("ℹ️ Created minimal patient profile")
            return
        }

        // Include gamification data in profile
        let gamificationData: [String: Any] = [
            "currentStreak": GamificationManager.shared.currentStreak,
            "longestStreak": GamificationManager.shared.longestStreak,
            "currentLevel": GamificationManager.shared.currentLevel,
            "totalPoints": GamificationManager.shared.totalPoints,
            "currentXP": GamificationManager.shared.currentXP,
            "totalWordsCompleted": GamificationManager.shared.totalWordsCompleted,
            "totalSentencesCompleted": GamificationManager.shared.totalSentencesCompleted,
            "totalConversationsCompleted": GamificationManager.shared.totalConversationsCompleted,
            "perfectScoreCount": GamificationManager.shared.perfectScoreCount,
            "dailyGoalProgress": GamificationManager.shared.dailyGoalProgress,
            "lastPracticeDate": GamificationManager.shared.lastPracticeDate.map { Timestamp(date: $0) } ?? Timestamp(date: Date())
        ]

        let data: [String: Any] = [
            "patientName": metrics.patientName,
            "enrollmentDate": Timestamp(date: metrics.enrollmentDate),
            "baselineWordRecognition": metrics.baselineWordRecognition ?? 0.0,
            "baselineSentenceComprehension": metrics.baselineSentenceComprehension ?? 0.0,
            "baselineNoisePerformance": metrics.baselineNoisePerformance ?? 0.0,
            "currentWordRecognition": metrics.currentWordRecognition,
            "currentSentenceComprehension": metrics.currentSentenceComprehension,
            "currentNoisePerformance": metrics.currentNoisePerformance,
            "totalSessions": metrics.totalSessions,
            "totalPracticeTime": metrics.totalPracticeTime,
            "averageSessionsPerWeek": metrics.averageSessionsPerWeek,
            "lastActiveDate": Timestamp(date: metrics.lastActiveDate),
            "streakDays": metrics.streakDays,
            "gamification": gamificationData,
            "updatedAt": Timestamp(date: Date())
        ]

        try await db.collection("patients").document(uid).setData(data, merge: true)
        print("✅ Saved patient profile and gamification data to Firebase")
    }

    // MARK: - Linking Code

    /// Generate 6-digit linking code
    func generateLinkingCode() async throws -> String {
        guard let uid = currentUser?.uid else {
            throw NSError(domain: "Not signed in", code: -1)
        }

        // Ensure patient profile exists
        do {
            try await savePatientProfile()
        } catch {
            print("⚠️ Warning: Could not save patient profile: \(error)")
        }

        // Generate unique code
        let code = String(format: "%06d", Int.random(in: 100000...999999))

        let linkingData: [String: Any] = [
            "code": code,
            "patientUID": uid,
            "createdDate": Timestamp(date: Date()),
            "expiryDate": Timestamp(date: Date().addingTimeInterval(24 * 60 * 60)), // 24 hours
            "isUsed": false
        ]

        try await db.collection("linkingCodes").document(code).setData(linkingData)
        print("✅ Generated linking code: \(code)")

        return code
    }

    // MARK: - Session Sync

    /// Sync session data to Firebase
    func syncSession(_ session: SessionAnalytics) async throws {
        guard let uid = currentUser?.uid else {
            throw NSError(domain: "Not signed in", code: -1)
        }

        let sessionData: [String: Any] = [
            "patientUID": uid,
            "sessionDate": Timestamp(date: session.sessionDate),
            "exerciseType": session.exerciseType,
            "duration": session.duration,
            "itemsAttempted": session.itemsAttempted,
            "itemsCorrect": session.itemsCorrect,
            "accuracy": session.accuracy,
            "averageResponseTime": session.averageResponseTime,
            "backgroundNoiseLevel": session.backgroundNoiseLevel,
            "phoneticErrors": session.phoneticErrors
        ]

        try await db.collection("sessions").addDocument(data: sessionData)
        print("✅ Synced session to Firebase")

        // Also update patient profile
        try await savePatientProfile()
    }

    // MARK: - Category Statistics Sync

    /// Sync category statistics to Firebase for clinician access
    func syncCategoryStatistics(listeningHistory: ListeningHistory) async throws {
        guard let uid = currentUser?.uid else {
            throw NSError(domain: "Not signed in", code: -1)
        }

        print("📊 Syncing category statistics to Firebase...")

        // Convert category breakdown to Firebase-friendly format
        for (categoryName, stats) in listeningHistory.categoryBreakdown {
            let categoryData: [String: Any] = [
                "patientUID": uid,
                "categoryName": categoryName,
                "totalAttempts": stats.totalAttempts,
                "correctAttempts": stats.correctAttempts,
                "accuracy": stats.accuracy,
                "lastPracticed": stats.lastPracticed.map { Timestamp(date: $0) } ?? Timestamp(date: Date()),
                "updatedAt": Timestamp(date: Date()),
                "missedWords": stats.missedWords.map { entry in
                    return [
                        "firstWord": entry.firstWord,
                        "lastWord": entry.lastWord,
                        "userSaid": entry.userSaid,
                        "category": entry.category,
                        "wasCorrect": entry.wasCorrect,
                        "timestamp": Timestamp(date: entry.timestamp)
                    ]
                },
                "correctWords": stats.correctWords.map { entry in
                    return [
                        "firstWord": entry.firstWord,
                        "lastWord": entry.lastWord,
                        "userSaid": entry.userSaid,
                        "category": entry.category,
                        "wasCorrect": entry.wasCorrect,
                        "timestamp": Timestamp(date: entry.timestamp)
                    ]
                }
            ]

            // Use category name as document ID for easy updates
            try await db.collection("category_statistics")
                .document("\(uid)_\(categoryName)")
                .setData(categoryData, merge: true)
        }

        print("✅ Category statistics synced to Firebase")
    }

    // MARK: - PDF Upload

    /// Upload PDF report to Firebase Storage
    func uploadPDFReport(fileURL: URL) async throws -> String {
        guard let uid = currentUser?.uid else {
            throw NSError(domain: "Not signed in", code: -1)
        }

        print("📄 Uploading PDF report to Firebase Storage...")

        // Read PDF data
        let pdfData = try Data(contentsOf: fileURL)

        // Create storage reference
        let fileName = "report_\(Date().timeIntervalSince1970).pdf"
        let storageRef = storage.reference()
            .child("patient_reports")
            .child(uid)
            .child(fileName)

        // Upload PDF
        let metadata = StorageMetadata()
        metadata.contentType = "application/pdf"
        metadata.customMetadata = [
            "generatedBy": "patient"
        ]

        do {
            // Upload the data
            _ = try await storageRef.putData(pdfData, metadata: metadata)
            print("✅ PDF uploaded to Storage: \(storageRef.fullPath)")

            // Wait a moment for Firebase to process
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            // Get download URL after upload completes
            let downloadURL = try await storageRef.downloadURL()

            // Save PDF metadata to Firestore
            let pdfMetadata: [String: Any] = [
                "patientUID": uid,
                "fileName": fileName,
                "downloadURL": downloadURL.absoluteString,
                "uploadDate": Timestamp(date: Date()),
                "fileSize": pdfData.count,
                "generatedBy": "patient"
            ]

            try await db.collection("patient_reports").addDocument(data: pdfMetadata)

            print("✅ PDF uploaded successfully: \(downloadURL.absoluteString)")
            return downloadURL.absoluteString

        } catch let error as NSError {
            print("❌ Storage upload error: \(error)")
            print("❌ Error domain: \(error.domain), code: \(error.code)")
            print("❌ Error description: \(error.localizedDescription)")

            // If Storage fails, store as base64 in Firestore as fallback
            print("⚠️ Attempting fallback: storing PDF in Firestore")
            let base64String = pdfData.base64EncodedString()

            let docRef = db.collection("patient_reports").document()
            let firestoreURL = "firestore://\(docRef.documentID)"

            let pdfMetadata: [String: Any] = [
                "patientUID": uid,
                "fileName": fileName,
                "downloadURL": firestoreURL, // Add placeholder URL for consistency
                "pdfData": base64String, // Store PDF directly
                "uploadDate": Timestamp(date: Date()),
                "fileSize": pdfData.count,
                "generatedBy": "patient",
                "storageType": "firestore" // Mark as stored in Firestore
            ]

            try await docRef.setData(pdfMetadata)
            print("✅ PDF stored in Firestore as fallback: \(docRef.documentID)")
            return docRef.documentID // Return document ID as "URL"
        }
    }

    /// Get all PDF reports for current patient
    func getPatientReports() async throws -> [[String: Any]] {
        guard let uid = currentUser?.uid else {
            throw NSError(domain: "Not signed in", code: -1)
        }

        let query = db.collection("patient_reports")
            .whereField("patientUID", isEqualTo: uid)
            .order(by: "uploadDate", descending: true)

        let snapshot = try await query.getDocuments()

        return snapshot.documents.map { $0.data() }
    }

    // MARK: - Load User Data

    /// Load recent sessions from Firebase when user logs in
    private func loadRecentSessions(uid: String) async throws {
        print("📥 Loading session history from Firebase...")

        let query = db.collection("sessions")
            .whereField("patientUID", isEqualTo: uid)
            .order(by: "sessionDate", descending: true)
            .limit(to: 100) // Load last 100 sessions

        let snapshot = try await query.getDocuments()

        var loadedSessions: [SessionAnalytics] = []
        for document in snapshot.documents {
            let data = document.data()

            if let sessionTimestamp = data["sessionDate"] as? Timestamp,
               let exerciseType = data["exerciseType"] as? String,
               let duration = data["duration"] as? TimeInterval,
               let itemsAttempted = data["itemsAttempted"] as? Int,
               let itemsCorrect = data["itemsCorrect"] as? Int,
               let accuracy = data["accuracy"] as? Double,
               let averageResponseTime = data["averageResponseTime"] as? TimeInterval,
               let backgroundNoiseLevel = data["backgroundNoiseLevel"] as? String {

                let session = SessionAnalytics(
                    userId: uid,
                    sessionDate: sessionTimestamp.dateValue(),
                    exerciseType: exerciseType,
                    duration: duration,
                    itemsAttempted: itemsAttempted,
                    itemsCorrect: itemsCorrect,
                    accuracy: accuracy,
                    averageResponseTime: averageResponseTime,
                    backgroundNoiseLevel: backgroundNoiseLevel,
                    phoneticErrors: data["phoneticErrors"] as? [String] ?? []
                )

                loadedSessions.append(session)
            }
        }

        await MainActor.run {
            AnalyticsManager.shared.sessions = loadedSessions
            print("✅ Loaded \(loadedSessions.count) sessions from Firebase")
        }
    }
}
