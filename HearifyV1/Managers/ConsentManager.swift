//
//  ConsentManager.swift
//  HearifyV1
//
//  Manages user consent for data collection and clinical use
//

import Foundation
import Combine

/// Types of data collection consent
enum ConsentType: String, Codable, CaseIterable {
    case clinicalResearch = "clinical_research"
    case anonymizedAnalytics = "anonymized_analytics"
    case progressSharing = "progress_sharing"
    case performanceData = "performance_data"
    case usageStatistics = "usage_statistics"

    var title: String {
        switch self {
        case .clinicalResearch:
            return "Clinical Research"
        case .anonymizedAnalytics:
            return "Anonymized Analytics"
        case .progressSharing:
            return "Progress Data Sharing"
        case .performanceData:
            return "Performance Metrics"
        case .usageStatistics:
            return "Usage Statistics"
        }
    }

    var description: String {
        switch self {
        case .clinicalResearch:
            return "Allow your de-identified data to be used for research studies to improve auditory rehabilitation methods. Your personal information will never be shared."
        case .anonymizedAnalytics:
            return "Share anonymized usage data to help us improve the app experience. All personal identifiers are removed before analysis."
        case .progressSharing:
            return "Allow your progress and performance data to be shared with healthcare providers and researchers for clinical studies (with your explicit permission each time)."
        case .performanceData:
            return "Collect detailed performance metrics during exercises to provide better personalized recommendations and track your improvement."
        case .usageStatistics:
            return "Collect basic usage statistics (time spent, features used) to help prioritize improvements and new features."
        }
    }

    var isRequired: Bool {
        switch self {
        case .performanceData, .usageStatistics:
            return true // Required for basic app functionality
        default:
            return false // Optional consents
        }
    }
}

/// User consent record
struct UserConsent: Codable {
    let consentType: ConsentType
    var isGranted: Bool
    var grantedDate: Date?
    var revokedDate: Date?
    var version: String // Version of consent text when granted

    init(type: ConsentType, isGranted: Bool = false, version: String = "1.0") {
        self.consentType = type
        self.isGranted = isGranted
        self.grantedDate = isGranted ? Date() : nil
        self.version = version
    }

    mutating func grant() {
        isGranted = true
        grantedDate = Date()
        revokedDate = nil
    }

    mutating func revoke() {
        isGranted = false
        revokedDate = Date()
    }
}

/// Manages all user consent preferences
class ConsentManager: ObservableObject {
    static let shared = ConsentManager()

    @Published var consents: [ConsentType: UserConsent] = [:]
    @Published var hasCompletedConsentFlow: Bool = false

    private let consentVersion = "1.0"
    private let storage = UserDefaults.standard

    private init() {
        loadConsents()
    }

    // MARK: - Public Methods

    /// Check if user has granted a specific consent
    func hasConsent(for type: ConsentType) -> Bool {
        return consents[type]?.isGranted ?? false
    }

    /// Grant consent for a specific type
    func grantConsent(for type: ConsentType) {
        var consent = consents[type] ?? UserConsent(type: type, version: consentVersion)
        consent.grant()
        consents[type] = consent
        saveConsents()

        print("✅ Consent granted: \(type.rawValue)")

        // Log consent event to Firebase if allowed
        if hasConsent(for: .usageStatistics) {
            Task {
                await logConsentEvent(type: type, granted: true)
            }
        }
    }

    /// Revoke consent for a specific type
    func revokeConsent(for type: ConsentType) {
        guard !type.isRequired else {
            print("⚠️ Cannot revoke required consent: \(type.rawValue)")
            return
        }

        var consent = consents[type] ?? UserConsent(type: type, version: consentVersion)
        consent.revoke()
        consents[type] = consent
        saveConsents()

        print("⚠️ Consent revoked: \(type.rawValue)")

        // Log revocation
        Task {
            await logConsentEvent(type: type, granted: false)
        }
    }

    /// Mark consent flow as completed
    func completeConsentFlow() {
        hasCompletedConsentFlow = true
        storage.set(true, forKey: "hasCompletedConsentFlow")
        storage.set(Date(), forKey: "consentFlowCompletedDate")

        print("✅ Consent flow completed")
    }

    /// Reset all consents (for testing or account deletion)
    func resetAllConsents() {
        consents.removeAll()
        hasCompletedConsentFlow = false
        storage.removeObject(forKey: "userConsents")
        storage.removeObject(forKey: "hasCompletedConsentFlow")
        storage.removeObject(forKey: "consentFlowCompletedDate")

        print("⚠️ All consents reset")
    }

    /// Get consent summary for display
    func getConsentSummary() -> String {
        let granted = consents.values.filter { $0.isGranted }.count
        let total = ConsentType.allCases.count
        return "\(granted)/\(total) consents granted"
    }

    /// Check if all required consents are granted
    func hasRequiredConsents() -> Bool {
        for type in ConsentType.allCases where type.isRequired {
            if !hasConsent(for: type) {
                return false
            }
        }
        return true
    }

    /// Export consent history (for data portability/GDPR)
    func exportConsentHistory() -> [String: Any] {
        var history: [String: Any] = [:]

        for (type, consent) in consents {
            history[type.rawValue] = [
                "isGranted": consent.isGranted,
                "grantedDate": consent.grantedDate?.ISO8601Format() ?? "N/A",
                "revokedDate": consent.revokedDate?.ISO8601Format() ?? "N/A",
                "version": consent.version
            ]
        }

        history["consentFlowCompleted"] = hasCompletedConsentFlow
        history["consentVersion"] = consentVersion

        return history
    }

    // MARK: - Private Methods

    private func loadConsents() {
        // Load consent flow completion status
        hasCompletedConsentFlow = storage.bool(forKey: "hasCompletedConsentFlow")

        // Load individual consents
        if let data = storage.data(forKey: "userConsents"),
           let decoded = try? JSONDecoder().decode([ConsentType: UserConsent].self, from: data) {
            consents = decoded
            print("✅ Loaded \(consents.count) consent preferences")
        } else {
            // Initialize with default consents
            for type in ConsentType.allCases {
                consents[type] = UserConsent(type: type, isGranted: type.isRequired, version: consentVersion)
            }
            print("ℹ️ Initialized default consent preferences")
        }
    }

    private func saveConsents() {
        if let encoded = try? JSONEncoder().encode(consents) {
            storage.set(encoded, forKey: "userConsents")
        }
    }

    private func logConsentEvent(type: ConsentType, granted: Bool) async {
        // Log to Firebase if user is signed in and has analytics consent
        guard let firebase = try? FirebaseManager.shared,
              firebase.isSignedIn else {
            return
        }

        // This would integrate with your analytics system
        print("📊 Logging consent event: \(type.rawValue) = \(granted)")
    }
}
