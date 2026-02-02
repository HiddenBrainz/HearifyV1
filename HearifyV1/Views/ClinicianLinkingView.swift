//
//  ClinicianLinkingView.swift
//  HearifyV1
//
//  Patient view to link with audiologist via CloudKit
//

import SwiftUI
import CloudKit

struct ClinicianLinkingView: View {
    @StateObject private var firebase = FirebaseManager.shared
    @State private var linkingCode: String = ""
    @State private var isGeneratingCode = false
    @State private var showCode = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Connect with Your Audiologist")
                        .font(.title2.bold())

                    Text("Share a code with your audiologist to sync your progress and receive personalized guidance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)

                // Firebase Status
                if !firebase.isSignedIn {
                    firebaseNotSignedInView
                } else if showCode {
                    // Display linking code
                    linkingCodeView
                } else {
                    // Generate code button
                    generateCodeButton
                }

                // Features
                featuresView

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Link Audiologist")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text("Successfully linked with your audiologist. Your progress will now sync automatically.")
        }
    }

    // MARK: - Subviews

    private var firebaseNotSignedInView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Not Signed In")
                .font(.headline)

            Text("Connecting to Firebase...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            ProgressView()
                .padding()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }

    private var linkingCodeView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Your Linking Code")
                    .font(.headline)

                Text("Share this code with your audiologist")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Code display
            Text(linkingCode)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .tracking(8)
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.blue.opacity(0.3))
                )

            // Expiry warning
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("Code expires in 24 hours")
                    .font(.caption.bold())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(20)

            // Actions
            HStack(spacing: 12) {
                Button {
                    UIPasteboard.general.string = linkingCode
                } label: {
                    Label("Copy Code", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    shareCode()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
            }

            Button("Generate New Code") {
                generateCode()
            }
            .font(.subheadline)
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var generateCodeButton: some View {
        Button(action: generateCode) {
            HStack(spacing: 12) {
                if isGeneratingCode {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "qrcode")
                        .font(.title3)
                    Text("Generate Linking Code")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isGeneratingCode)
    }

    private var featuresView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Benefits of Linking")
                .font(.headline)

            FeatureRow(
                icon: "arrow.triangle.2.circlepath",
                title: "Auto-Sync Progress",
                description: "Your practice sessions automatically sync to your audiologist's dashboard"
            )

            FeatureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Professional Analytics",
                description: "Get detailed insights and progress reports from your clinician"
            )

            FeatureRow(
                icon: "person.fill.checkmark",
                title: "Personalized Plans",
                description: "Receive custom treatment plans based on your performance"
            )

            FeatureRow(
                icon: "lock.shield.fill",
                title: "Secure & Private",
                description: "Secure cloud sync with Firebase, HIPAA-ready"
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    // MARK: - Actions

    private func generateCode() {
        isGeneratingCode = true
        errorMessage = nil

        Task {
            do {
                linkingCode = try await firebase.generateLinkingCode()
                showCode = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isGeneratingCode = false
        }
    }

    private func shareCode() {
        let message = "Join my Hearify therapy! Use this code to link: \(linkingCode)"
        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ClinicianLinkingView()
    }
}
