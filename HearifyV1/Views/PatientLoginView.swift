//
//  PatientLoginView.swift
//  HearifyV1
//
//  Patient login/signup view for email/password authentication
//

import SwiftUI

struct PatientLoginView: View {
    @EnvironmentObject private var firebase: FirebaseManager
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isAuthenticating = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 60)

                    // Logo/Header
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)

                            Image(systemName: "ear.badge.waveform")
                                .font(.system(size: 70))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 8) {
                            Text("HearifyV1")
                                .font(.largeTitle.bold())

                            Text("Auditory Rehabilitation")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Form Card
                    VStack(spacing: 24) {
                        // Toggle between Sign In / Sign Up
                        Picker("Mode", selection: $isSignUp) {
                            Text("Sign In").tag(false)
                            Text("Sign Up").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 8)

                        // Form Fields
                        VStack(spacing: 16) {
                            if isSignUp {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Full Name")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.secondary)

                                    TextField("John Smith", text: $name)
                                        .textFieldStyle(.plain)
                                        .textContentType(.name)
                                        .autocapitalization(.words)
                                        .padding()
                                        #if os(iOS)
                                        .background(Color(.systemGray6))
                                        #else
                                        .background(Color(NSColor.controlBackgroundColor))
                                        #endif
                                        .cornerRadius(12)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.secondary)

                                TextField("email@example.com", text: $email)
                                    .textFieldStyle(.plain)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .padding()
                                    #if os(iOS)
                                    .background(Color(.systemGray6))
                                    #else
                                    .background(Color(NSColor.controlBackgroundColor))
                                    #endif
                                    .cornerRadius(12)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.secondary)

                                SecureField("••••••••", text: $password)
                                    .textFieldStyle(.plain)
                                    .textContentType(isSignUp ? .newPassword : .password)
                                    .padding()
                                    #if os(iOS)
                                    .background(Color(.systemGray6))
                                    #else
                                    .background(Color(NSColor.controlBackgroundColor))
                                    #endif
                                    .cornerRadius(12)

                                if isSignUp {
                                    Text("Minimum 6 characters")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Auth Button
                        Button {
                            Task {
                                await authenticate()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if isAuthenticating {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: isSignUp ? "person.badge.plus" : "lock.open")
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                        }
                        .disabled(isAuthenticating || !isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)

                        // Toggle Mode
                        Button {
                            withAnimation {
                                isSignUp.toggle()
                            }
                        } label: {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(32)
                    .frame(maxWidth: 500)
                    #if os(iOS)
                    .background(Color(.systemBackground))
                    #else
                    .background(Color(NSColor.windowBackgroundColor))
                    #endif
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 60)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && password.count >= 6 && !name.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }

    // MARK: - Actions

    private func authenticate() async {
        isAuthenticating = true

        do {
            if isSignUp {
                try await firebase.signUp(email: email, password: password, name: name)
            } else {
                try await firebase.signIn(email: email, password: password)
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isAuthenticating = false
            }
            return
        }

        await MainActor.run {
            isAuthenticating = false
        }
    }
}

#Preview {
    PatientLoginView()
        .environmentObject(FirebaseManager.shared)
}
