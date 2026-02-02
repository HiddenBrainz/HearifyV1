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

    init() {
        // Configure Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured for HearifyV1")
    }

    var body: some Scene {
        WindowGroup {
            if firebase.isSignedIn {
                ContentView()
                    .environmentObject(firebase)
            } else {
                PatientLoginView()
                    .environmentObject(firebase)
            }
        }
    }
}
