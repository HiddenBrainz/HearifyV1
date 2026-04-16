//
//  DataConsentView.swift
//  HearifyV1
//
//  Data collection consent screen with granular opt-ins
//

import SwiftUI

struct DataConsentView: View {
    @EnvironmentObject private var firebase: FirebaseManager
    @StateObject private var consentManager = ConsentManager.shared
    @Binding var hasCompletedConsent: Bool

    @State private var selectedConsents: Set<ConsentType> = []
    @State private var showingDetailFor: ConsentType? = nil
    @State private var canProceed = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [AppTheme.primaryBlue.opacity(0.05), AppTheme.backgroundPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)

                    // Header
                    headerSection

                    // Important Notice
                    importantNotice

                    // Consent Options
                    consentOptionsSection

                    // Privacy Info
                    privacyInfoSection

                    // Action Buttons
                    actionButtons

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(item: $showingDetailFor) { consentType in
            ConsentDetailSheet(consentType: consentType)
        }
        .onAppear {
            initializeSelectedConsents()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.primaryBlue.opacity(0.2), AppTheme.success.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "shield.checkmark.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.success],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("Data Privacy & Consent")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Your privacy and control over your data is our priority. Please review and choose which data you'd like to share.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Important Notice
    private var importantNotice: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Important Information")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Your data is always encrypted and stored securely")
                bulletPoint("You can change these preferences anytime in Settings")
                bulletPoint("Required permissions are needed for basic app functionality")
                bulletPoint("Optional permissions help improve research and personalization")
            }
        }
        .padding(20)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Consent Options Section
    private var consentOptionsSection: some View {
        VStack(spacing: 16) {
            Text("Choose What to Share")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(ConsentType.allCases, id: \.self) { consentType in
                ConsentOptionCard(
                    consentType: consentType,
                    isSelected: selectedConsents.contains(consentType),
                    onToggle: {
                        toggleConsent(consentType)
                    },
                    onLearnMore: {
                        showingDetailFor = consentType
                    }
                )
            }
        }
    }

    // MARK: - Privacy Info Section
    private var privacyInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(AppTheme.primaryBlue)
                Text("HIPAA Compliant")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            Text("All data collection practices comply with HIPAA regulations. Your Protected Health Information (PHI) is encrypted and only shared according to your explicit consent.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)

            Button(action: {
                // Open privacy policy
                if let url = URL(string: "https://hearifyapp.com/privacy") {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #endif
                }
            }) {
                Text("Read Full Privacy Policy →")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.primaryBlue)
            }
        }
        .padding(16)
        .background(AppTheme.primaryBlue.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Continue Button
            Button(action: {
                saveConsentsAndProceed()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text(canProceed ? "Continue to App" : "Accept Required Permissions")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: canProceed ? [AppTheme.primaryBlue, AppTheme.success] : [Color.gray, Color.gray.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: canProceed ? AppTheme.primaryBlue.opacity(0.3) : Color.clear, radius: 8, y: 4)
            }
            .disabled(!canProceed)

            // Skip Optional Button
            if !allOptionalSelected {
                Button(action: {
                    saveConsentsAndProceed()
                }) {
                    Text("Skip Optional Permissions")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            // Consent Summary
            Text(consentSummaryText)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }

    // MARK: - Helper Views
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
        }
    }

    // MARK: - Computed Properties
    private var allOptionalSelected: Bool {
        let optionalTypes = ConsentType.allCases.filter { !$0.isRequired }
        return optionalTypes.allSatisfy { selectedConsents.contains($0) }
    }

    private var consentSummaryText: String {
        let granted = selectedConsents.count
        let total = ConsentType.allCases.count
        return "\(granted) of \(total) permissions granted"
    }

    // MARK: - Actions
    private func initializeSelectedConsents() {
        // Pre-select required consents
        for type in ConsentType.allCases where type.isRequired {
            selectedConsents.insert(type)
        }

        // Load previously saved consents
        for type in ConsentType.allCases {
            if consentManager.hasConsent(for: type) {
                selectedConsents.insert(type)
            }
        }

        updateCanProceed()
    }

    private func toggleConsent(_ type: ConsentType) {
        if type.isRequired {
            // Cannot toggle required consents
            return
        }

        if selectedConsents.contains(type) {
            selectedConsents.remove(type)
        } else {
            selectedConsents.insert(type)
        }

        updateCanProceed()
    }

    private func updateCanProceed() {
        // Check if all required consents are selected
        let requiredTypes = ConsentType.allCases.filter { $0.isRequired }
        canProceed = requiredTypes.allSatisfy { selectedConsents.contains($0) }
    }

    private func saveConsentsAndProceed() {
        // Save all consents
        for type in ConsentType.allCases {
            if selectedConsents.contains(type) {
                consentManager.grantConsent(for: type)
            } else if !type.isRequired {
                consentManager.revokeConsent(for: type)
            }
        }

        // Mark consent flow as completed
        consentManager.completeConsentFlow()

        // Trigger completion
        withAnimation {
            hasCompletedConsent = true
        }

        print("✅ User consents saved and consent flow completed")
    }
}

// MARK: - Consent Option Card
struct ConsentOptionCard: View {
    let consentType: ConsentType
    let isSelected: Bool
    let onToggle: () -> Void
    let onLearnMore: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            HStack(alignment: .top, spacing: 16) {
                // Checkbox/Required badge
                if consentType.isRequired {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(AppTheme.warning.opacity(0.2))
                                .frame(width: 28, height: 28)

                            Image(systemName: "exclamationmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.warning)
                        }
                    }
                } else {
                    Button(action: onToggle) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 28))
                            .foregroundColor(isSelected ? AppTheme.success : AppTheme.textTertiary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(consentType.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        if consentType.isRequired {
                            Text("REQUIRED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppTheme.warning)
                                .cornerRadius(4)
                        }

                        Spacer()
                    }

                    Text(consentType.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: onLearnMore) {
                        Text("Learn More →")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.primaryBlue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)
        }
        .background(isSelected ? AppTheme.success.opacity(0.05) : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppTheme.success : AppTheme.textTertiary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

// MARK: - Consent Detail Sheet
struct ConsentDetailSheet: View {
    let consentType: ConsentType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Icon and title
                    HStack {
                        Image(systemName: iconForType)
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.primaryBlue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(consentType.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            if consentType.isRequired {
                                Text("Required for app functionality")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.warning)
                            } else {
                                Text("Optional")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.success)
                            }
                        }
                    }
                    .padding(.bottom, 8)

                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What This Means")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text(consentType.description)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(6)
                    }

                    Divider()

                    // What we collect
                    detailSection(
                        title: "What We Collect",
                        items: whatWeCollect
                    )

                    // How we use it
                    detailSection(
                        title: "How We Use This Data",
                        items: howWeUseIt
                    )

                    // Your rights
                    detailSection(
                        title: "Your Rights",
                        items: yourRights
                    )

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var iconForType: String {
        switch consentType {
        case .clinicalResearch: return "flask.fill"
        case .anonymizedAnalytics: return "chart.bar.fill"
        case .progressSharing: return "arrow.up.doc.fill"
        case .performanceData: return "chart.line.uptrend.xyaxis"
        case .usageStatistics: return "clock.fill"
        }
    }

    private var whatWeCollect: [String] {
        switch consentType {
        case .clinicalResearch:
            return [
                "De-identified practice session data",
                "Accuracy and performance metrics",
                "Progress over time",
                "Device type and app version"
            ]
        case .anonymizedAnalytics:
            return [
                "App feature usage patterns",
                "Session duration and frequency",
                "Technical performance data",
                "Anonymized demographic information"
            ]
        case .progressSharing:
            return [
                "Individual session results",
                "Progress reports",
                "Performance trends",
                "Areas of difficulty"
            ]
        case .performanceData:
            return [
                "Response times",
                "Accuracy per exercise type",
                "Improvement patterns",
                "Phonetic error patterns"
            ]
        case .usageStatistics:
            return [
                "Time spent in app",
                "Features accessed",
                "Settings preferences",
                "Device information"
            ]
        }
    }

    private var howWeUseIt: [String] {
        switch consentType {
        case .clinicalResearch:
            return [
                "Develop better rehabilitation methods",
                "Publish research studies (anonymized)",
                "Improve clinical guidelines",
                "Validate treatment effectiveness"
            ]
        case .anonymizedAnalytics:
            return [
                "Improve app performance",
                "Identify popular features",
                "Fix bugs and crashes",
                "Optimize user experience"
            ]
        case .progressSharing:
            return [
                "Share with your healthcare provider",
                "Enable remote monitoring",
                "Support clinical decision-making",
                "Track therapy outcomes"
            ]
        case .performanceData:
            return [
                "Personalize your exercises",
                "Provide adaptive difficulty",
                "Track your improvement",
                "Generate progress reports"
            ]
        case .usageStatistics:
            return [
                "Prioritize feature development",
                "Optimize app performance",
                "Identify usage patterns",
                "Improve overall experience"
            ]
        }
    }

    private var yourRights: [String] {
        return [
            "You can revoke this consent at any time in Settings",
            "You can request a copy of your data",
            "You can request deletion of your data",
            "Your consent choices are always respected",
            "All data handling complies with HIPAA regulations"
        ]
    }

    private func detailSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.success)
                            .padding(.top, 2)

                        Text(item)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
    }
}

// Make ConsentType Identifiable for sheet presentation
extension ConsentType: Identifiable {
    var id: String { rawValue }
}

// MARK: - Preview
struct DataConsentView_Previews: PreviewProvider {
    static var previews: some View {
        DataConsentView(hasCompletedConsent: .constant(false))
            .environmentObject(FirebaseManager.shared)
    }
}
