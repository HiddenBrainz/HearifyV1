//
//  CloudKitDebugView.swift
//  HearifyV1
//
//  Debug view to diagnose CloudKit sync issues
//

import SwiftUI
import CloudKit

struct CloudKitDebugView: View {
    @StateObject private var cloudKit = CloudKitManager.shared
    @StateObject private var analytics = AnalyticsManager.shared
    @State private var statusMessage = "Checking..."
    @State private var showDetails = false

    var body: some View {
        NavigationView {
            List {
                Section("iCloud Status") {
                    HStack {
                        Text("Signed In")
                        Spacer()
                        Image(systemName: cloudKit.isSignedInToiCloud ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(cloudKit.isSignedInToiCloud ? .green : .red)
                    }

                    if let userID = cloudKit.currentUserRecordID {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("User Record ID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(userID.recordName)
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }

                    if let lastSync = cloudKit.lastSyncDate {
                        HStack {
                            Text("Last Sync")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Never synced")
                            .foregroundColor(.orange)
                    }

                    HStack {
                        Text("Syncing")
                        Spacer()
                        if cloudKit.isSyncing {
                            ProgressView()
                        } else {
                            Text("Idle")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("Session Data") {
                    HStack {
                        Text("Total Sessions")
                        Spacer()
                        Text("\(analytics.sessions.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Cloud Sync Enabled")
                        Spacer()
                        Image(systemName: analytics.cloudSyncEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(analytics.cloudSyncEnabled ? .green : .red)
                    }
                }

                Section("Actions") {
                    Button(action: {
                        cloudKit.checkiCloudStatus()
                    }) {
                        Label("Refresh iCloud Status", systemImage: "arrow.clockwise")
                    }

                    Button(action: {
                        Task {
                            await testCloudKitConnection()
                        }
                    }) {
                        Label("Test CloudKit Connection", systemImage: "network")
                    }

                    Button(action: {
                        Task {
                            await syncAllSessions()
                        }
                    }) {
                        Label("Manual Sync All Sessions", systemImage: "icloud.and.arrow.up")
                    }
                    .disabled(analytics.sessions.isEmpty || !cloudKit.isSignedInToiCloud)
                }

                Section("Status Messages") {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Recent Sessions") {
                    ForEach(analytics.sessions.prefix(5)) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.exerciseType)
                                .font(.headline)
                            Text("Accuracy: \(Int(session.accuracy * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(session.sessionDate, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("CloudKit Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func testCloudKitConnection() async {
        statusMessage = "Testing CloudKit connection..."

        do {
            // Try to fetch container info
            let container = CKContainer(identifier: "iCloud.VeerChopra.HearifyV1")
            let status = try await container.accountStatus()

            switch status {
            case .available:
                statusMessage = "✅ CloudKit available and ready"
            case .noAccount:
                statusMessage = "❌ No iCloud account signed in"
            case .restricted:
                statusMessage = "⚠️ iCloud account is restricted"
            case .couldNotDetermine:
                statusMessage = "⚠️ Could not determine iCloud status"
            case .temporarilyUnavailable:
                statusMessage = "⚠️ iCloud temporarily unavailable"
            @unknown default:
                statusMessage = "⚠️ Unknown iCloud status"
            }

            // Try to get user record ID
            if status == .available {
                let userRecordID = try await container.userRecordID()
                statusMessage += "\n\nUser ID: \(userRecordID.recordName)"
            }

        } catch {
            statusMessage = "❌ Error: \(error.localizedDescription)"
        }
    }

    private func syncAllSessions() async {
        statusMessage = "Syncing \(analytics.sessions.count) sessions..."

        do {
            try await cloudKit.syncAllSessions(analytics.sessions)
            statusMessage = "✅ Successfully synced \(analytics.sessions.count) sessions at \(Date().formatted(date: .omitted, time: .shortened))"
        } catch {
            statusMessage = "❌ Sync failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    CloudKitDebugView()
}
