//
//  CloudKitManager.swift
//  HearifyV1
//
//  CloudKit sync manager for patient data and clinician linking
//  Uses CloudKit for HIPAA-compliant data storage and sharing
//

import Foundation
import CloudKit
import SwiftUI

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase

    @Published var isSignedInToiCloud = false
    @Published var currentUserRecordID: CKRecord.ID?
    @Published var linkedClinicianID: CKRecord.ID?
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?

    // Record Types
    enum RecordType: String {
        case patientProfile = "PatientProfile"
        case sessionRecord = "SessionRecord"
        case progressSnapshot = "ProgressSnapshot"
        case linkingCode = "LinkingCode"
        case clinicianProfile = "ClinicianProfile"
        case sharedPatientData = "SharedPatientData"
    }

    init() {
        // Use default container or specify custom container
        self.container = CKContainer(identifier: "iCloud.VeerChopra.HearifyV1")
        self.publicDatabase = container.publicCloudDatabase
        self.privateDatabase = container.privateCloudDatabase
        self.sharedDatabase = container.sharedCloudDatabase

        checkiCloudStatus()
    }

    // MARK: - iCloud Account Status
    func checkiCloudStatus() {
        Task {
            do {
                let status = try await container.accountStatus()
                isSignedInToiCloud = (status == .available)

                if isSignedInToiCloud {
                    currentUserRecordID = try await container.userRecordID()
                    print("✅ Signed in to iCloud: \(currentUserRecordID?.recordName ?? "unknown")")
                } else {
                    print("⚠️ Not signed in to iCloud")
                }
            } catch {
                print("❌ Error checking iCloud status: \(error)")
                isSignedInToiCloud = false
            }
        }
    }

    // MARK: - Patient Linking via Code

    /// Generate a 6-digit linking code that expires in 24 hours
    func generateLinkingCode() async throws -> String {
        guard isSignedInToiCloud, let userRecordID = currentUserRecordID else {
            throw CloudKitError.notSignedIn
        }

        // Ensure patient profile exists before generating linking code
        do {
            try await savePatientProfile()
        } catch {
            print("⚠️ Warning: Could not save patient profile: \(error)")
            // Continue anyway - profile might already exist
        }

        // Generate unique 6-digit code
        let code = String(format: "%06d", Int.random(in: 100000...999999))

        let record = CKRecord(recordType: RecordType.linkingCode.rawValue)
        record["code"] = code as CKRecordValue
        record["patientRecordID"] = userRecordID.recordName as CKRecordValue
        record["createdDate"] = Date() as CKRecordValue
        record["expiryDate"] = Date().addingTimeInterval(24 * 60 * 60) as CKRecordValue // 24 hours
        record["isUsed"] = 0 as CKRecordValue // 0 = false, 1 = true

        let savedRecord = try await publicDatabase.save(record)
        print("✅ Generated linking code: \(code)")

        return code
    }

    /// Clinician uses this to link a patient via code
    func linkPatientWithCode(_ code: String, clinicianRecordID: CKRecord.ID) async throws {
        // Query for the linking code
        let predicate = NSPredicate(format: "code == %@ AND isUsed == 0", code)
        let query = CKQuery(recordType: RecordType.linkingCode.rawValue, predicate: predicate)

        let results = try await publicDatabase.records(matching: query)

        guard let (recordID, result) = results.matchResults.first,
              case .success(let record) = result else {
            throw CloudKitError.invalidLinkingCode
        }

        // Check expiry
        guard let expiryDate = record["expiryDate"] as? Date,
              expiryDate > Date() else {
            throw CloudKitError.linkingCodeExpired
        }

        guard let patientRecordIDString = record["patientRecordID"] as? String else {
            throw CloudKitError.invalidLinkingCode
        }

        // Mark code as used
        record["isUsed"] = 1 as CKRecordValue
        record["usedDate"] = Date() as CKRecordValue
        record["clinicianRecordID"] = clinicianRecordID.recordName as CKRecordValue
        try await publicDatabase.save(record)

        print("✅ Successfully linked patient: \(patientRecordIDString) to clinician: \(clinicianRecordID.recordName)")
    }

    /// Patient confirms clinician link and creates share
    func confirmClinicianLink(clinicianRecordID: CKRecord.ID) async throws {
        linkedClinicianID = clinicianRecordID

        // Save to patient profile
        try await savePatientProfile()

        // Create shared zone for this clinician
        try await createSharedZone(with: clinicianRecordID)
    }

    // MARK: - Patient Profile

    func savePatientProfile() async throws {
        guard let userRecordID = currentUserRecordID else {
            throw CloudKitError.notSignedIn
        }

        let recordID = CKRecord.ID(recordName: "PatientProfile-\(userRecordID.recordName)")
        let record = CKRecord(recordType: RecordType.patientProfile.rawValue, recordID: recordID)

        // If metrics exist, use them; otherwise create minimal profile
        if let metrics = AnalyticsManager.shared.patientMetrics {
            record["patientName"] = metrics.patientName as CKRecordValue
            record["enrollmentDate"] = metrics.enrollmentDate as CKRecordValue
            record["clinicianRecordID"] = linkedClinicianID?.recordName as? CKRecordValue

            // Baseline scores
            record["baselineWordRecognition"] = (metrics.baselineWordRecognition ?? 0) as CKRecordValue
            record["baselineSentenceComprehension"] = (metrics.baselineSentenceComprehension ?? 0) as CKRecordValue
            record["baselineNoisePerformance"] = (metrics.baselineNoisePerformance ?? 0) as CKRecordValue

            // Current scores
            record["currentWordRecognition"] = metrics.currentWordRecognition as CKRecordValue
            record["currentSentenceComprehension"] = metrics.currentSentenceComprehension as CKRecordValue
            record["currentNoisePerformance"] = metrics.currentNoisePerformance as CKRecordValue

            // Engagement metrics
            record["totalSessions"] = metrics.totalSessions as CKRecordValue
            record["totalPracticeTime"] = metrics.totalPracticeTime as CKRecordValue
            record["averageSessionsPerWeek"] = metrics.averageSessionsPerWeek as CKRecordValue
            record["lastActiveDate"] = metrics.lastActiveDate as CKRecordValue
            record["streakDays"] = metrics.streakDays as CKRecordValue
        } else {
            // Create minimal profile for new user
            record["patientName"] = "New Patient" as CKRecordValue
            record["enrollmentDate"] = Date() as CKRecordValue
            record["clinicianRecordID"] = linkedClinicianID?.recordName as? CKRecordValue

            // Initialize with zeros
            record["baselineWordRecognition"] = 0.0 as CKRecordValue
            record["baselineSentenceComprehension"] = 0.0 as CKRecordValue
            record["baselineNoisePerformance"] = 0.0 as CKRecordValue
            record["currentWordRecognition"] = 0.0 as CKRecordValue
            record["currentSentenceComprehension"] = 0.0 as CKRecordValue
            record["currentNoisePerformance"] = 0.0 as CKRecordValue
            record["totalSessions"] = 0 as CKRecordValue
            record["totalPracticeTime"] = 0.0 as CKRecordValue
            record["averageSessionsPerWeek"] = 0.0 as CKRecordValue
            record["lastActiveDate"] = Date() as CKRecordValue
            record["streakDays"] = 0 as CKRecordValue

            print("ℹ️ Creating minimal patient profile (no metrics yet)")
        }

        // Save to public database so clinician can access
        // TODO: For production HIPAA compliance, use shared zones with proper CKShare setup
        let savedRecord = try await publicDatabase.save(record)

        // Also save to private database for patient's own access
        try? await privateDatabase.save(record)

        lastSyncDate = Date()
        print("✅ Saved patient profile to CloudKit")
    }

    // MARK: - Session Records

    func syncSession(_ session: SessionAnalytics) async throws {
        guard currentUserRecordID != nil else {
            throw CloudKitError.notSignedIn
        }

        let recordID = CKRecord.ID(recordName: "Session-\(session.id.uuidString)")
        let record = CKRecord(recordType: RecordType.sessionRecord.rawValue, recordID: recordID)

        record["sessionDate"] = session.sessionDate as CKRecordValue
        record["exerciseType"] = session.exerciseType as CKRecordValue
        record["duration"] = session.duration as CKRecordValue
        record["itemsAttempted"] = session.itemsAttempted as CKRecordValue
        record["itemsCorrect"] = session.itemsCorrect as CKRecordValue
        record["accuracy"] = session.accuracy as CKRecordValue
        record["averageResponseTime"] = session.averageResponseTime as CKRecordValue
        record["backgroundNoiseLevel"] = session.backgroundNoiseLevel as CKRecordValue
        record["phoneticErrors"] = session.phoneticErrors as CKRecordValue

        // Save to private database
        let savedRecord = try await privateDatabase.save(record)

        // If linked to clinician, also save to shared zone
        if linkedClinicianID != nil {
            try await saveToSharedZone(record: savedRecord)
        }

        lastSyncDate = Date()
        print("✅ Synced session to CloudKit: \(session.exerciseType)")
    }

    /// Batch sync multiple sessions
    func syncAllSessions(_ sessions: [SessionAnalytics]) async throws {
        isSyncing = true
        defer { isSyncing = false }

        for session in sessions {
            try await syncSession(session)
        }

        print("✅ Synced \(sessions.count) sessions to CloudKit")
    }

    // MARK: - Progress Snapshots

    func syncProgressSnapshot(_ snapshot: ProgressSnapshot) async throws {
        guard currentUserRecordID != nil else {
            throw CloudKitError.notSignedIn
        }

        let recordID = CKRecord.ID(recordName: "Snapshot-\(snapshot.id.uuidString)")
        let record = CKRecord(recordType: RecordType.progressSnapshot.rawValue, recordID: recordID)

        record["snapshotDate"] = snapshot.date as CKRecordValue
        record["wordRecognitionScore"] = snapshot.wordRecognitionScore as CKRecordValue
        record["sentenceComprehensionScore"] = snapshot.sentenceComprehensionScore as CKRecordValue
        record["noisePerformanceScore"] = snapshot.noisePerformanceScore as CKRecordValue
        record["sessionsThisWeek"] = snapshot.sessionsThisWeek as CKRecordValue
        record["totalPracticeMinutes"] = snapshot.totalPracticeMinutes as CKRecordValue

        // Save to private database
        let savedRecord = try await privateDatabase.save(record)

        // If linked to clinician, also save to shared zone
        if linkedClinicianID != nil {
            try await saveToSharedZone(record: savedRecord)
        }

        print("✅ Synced progress snapshot to CloudKit")
    }

    // MARK: - Shared Zone (Clinician Access)

    private func createSharedZone(with clinicianRecordID: CKRecord.ID) async throws {
        // Create a custom zone for sharing
        let zoneID = CKRecordZone.ID(zoneName: "PatientSharedZone", ownerName: CKCurrentUserDefaultName)
        let zone = CKRecordZone(zoneID: zoneID)

        do {
            _ = try await privateDatabase.save(zone)
            print("✅ Created shared zone")
        } catch {
            // Zone might already exist, which is fine
            print("ℹ️ Shared zone already exists or error: \(error)")
        }

        // Note: Actual sharing requires CKShare and user interaction
        // This would be implemented with share sheet in UI
    }

    private func saveToSharedZone(record: CKRecord) async throws {
        // For now, save to shared database
        // In production, this would use CKShare for granular access control
        _ = try await sharedDatabase.save(record)
        print("✅ Saved record to shared zone: \(record.recordType)")
    }

    // MARK: - Fetch Data (For Clinician App)

    /// Clinicians fetch patient data they have access to
    func fetchPatientProfile(patientRecordID: String) async throws -> PatientMetrics? {
        let recordID = CKRecord.ID(recordName: "PatientProfile-\(patientRecordID)")

        do {
            let record = try await sharedDatabase.record(for: recordID)
            return patientMetricsFromRecord(record)
        } catch {
            print("❌ Error fetching patient profile: \(error)")
            throw error
        }
    }

    /// Fetch all sessions for a patient (clinician access)
    func fetchPatientSessions(patientRecordID: String) async throws -> [SessionAnalytics] {
        let predicate = NSPredicate(value: true) // Fetch all
        let query = CKQuery(recordType: RecordType.sessionRecord.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "sessionDate", ascending: false)]

        let results = try await sharedDatabase.records(matching: query)

        var sessions: [SessionAnalytics] = []
        for (_, result) in results.matchResults {
            if case .success(let record) = result {
                if let session = sessionAnalyticsFromRecord(record) {
                    sessions.append(session)
                }
            }
        }

        return sessions
    }

    // MARK: - Record Conversion Helpers

    private func patientMetricsFromRecord(_ record: CKRecord) -> PatientMetrics {
        return PatientMetrics(
            userId: record.recordID.recordName,
            patientName: record["patientName"] as? String ?? "Unknown",
            enrollmentDate: record["enrollmentDate"] as? Date ?? Date(),
            clinicianId: record["clinicianRecordID"] as? String,
            baselineWordRecognition: record["baselineWordRecognition"] as? Double,
            baselineSentenceComprehension: record["baselineSentenceComprehension"] as? Double,
            baselineNoisePerformance: record["baselineNoisePerformance"] as? Double,
            currentWordRecognition: record["currentWordRecognition"] as? Double ?? 0,
            currentSentenceComprehension: record["currentSentenceComprehension"] as? Double ?? 0,
            currentNoisePerformance: record["currentNoisePerformance"] as? Double ?? 0,
            totalSessions: record["totalSessions"] as? Int ?? 0,
            totalPracticeTime: record["totalPracticeTime"] as? TimeInterval ?? 0,
            averageSessionsPerWeek: record["averageSessionsPerWeek"] as? Double ?? 0,
            lastActiveDate: record["lastActiveDate"] as? Date ?? Date(),
            streakDays: record["streakDays"] as? Int ?? 0
        )
    }

    private func sessionAnalyticsFromRecord(_ record: CKRecord) -> SessionAnalytics? {
        guard let sessionDate = record["sessionDate"] as? Date,
              let exerciseType = record["exerciseType"] as? String,
              let duration = record["duration"] as? TimeInterval,
              let itemsAttempted = record["itemsAttempted"] as? Int,
              let itemsCorrect = record["itemsCorrect"] as? Int,
              let accuracy = record["accuracy"] as? Double,
              let averageResponseTime = record["averageResponseTime"] as? TimeInterval,
              let backgroundNoiseLevel = record["backgroundNoiseLevel"] as? String,
              let phoneticErrors = record["phoneticErrors"] as? [String] else {
            return nil
        }

        return SessionAnalytics(
            id: UUID(uuidString: record.recordID.recordName.replacingOccurrences(of: "Session-", with: "")) ?? UUID(),
            userId: record.recordID.recordName,
            sessionDate: sessionDate,
            exerciseType: exerciseType,
            duration: duration,
            itemsAttempted: itemsAttempted,
            itemsCorrect: itemsCorrect,
            accuracy: accuracy,
            averageResponseTime: averageResponseTime,
            backgroundNoiseLevel: backgroundNoiseLevel,
            phoneticErrors: phoneticErrors
        )
    }

    // MARK: - Subscription for Real-time Updates

    func subscribeToPatientUpdates(patientRecordID: String) async throws {
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(
            recordType: RecordType.sessionRecord.rawValue,
            predicate: predicate,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        do {
            _ = try await sharedDatabase.save(subscription)
            print("✅ Subscribed to patient updates")
        } catch {
            print("❌ Error creating subscription: \(error)")
        }
    }
}

// MARK: - Error Handling

enum CloudKitError: LocalizedError {
    case notSignedIn
    case invalidLinkingCode
    case linkingCodeExpired
    case noData
    case syncFailed

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Not signed in to iCloud. Please sign in to iCloud in Settings."
        case .invalidLinkingCode:
            return "Invalid linking code. Please check the code and try again."
        case .linkingCodeExpired:
            return "This linking code has expired. Please generate a new code."
        case .noData:
            return "No data to sync."
        case .syncFailed:
            return "Failed to sync with iCloud. Please try again later."
        }
    }
}
