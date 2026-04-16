//
//  HearifyV1App.swift
//  HearifyV1
//
//  Created by Veer Chopra on 9/30/25.
//

import SwiftUI
import FirebaseCore

@main
struct HearifyV1App: App {
    @StateObject private var firebase = FirebaseManager.shared
    @StateObject private var consentManager = ConsentManager.shared
    @State private var hasAgreedToLegalTerms = UserDefaults.standard.bool(forKey: "hasAgreedToLegalTerms")

    init() {
        // Configure Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured for HearifyV1")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !firebase.isSignedIn {
                    // Step 1: Login/Signup
                    PatientLoginView()
                        .environmentObject(firebase)
                } else if !hasAgreedToLegalTerms {
                    // Step 2: Legal Agreement (Terms & Privacy)
                    LegalAgreementView(hasAgreedToTerms: $hasAgreedToLegalTerms)
                } else if !consentManager.hasCompletedConsentFlow {
                    // Step 3: Data Collection Consent
                    DataConsentView(hasCompletedConsent: $consentManager.hasCompletedConsentFlow)
                        .environmentObject(firebase)
                } else {
                    // Step 4: Main App
                    ContentView()
                        .environmentObject(firebase)
                }
            }
        }
    }
}
