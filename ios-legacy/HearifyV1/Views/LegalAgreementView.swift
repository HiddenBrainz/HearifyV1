//
//  LegalAgreementView.swift
//  Hearify
//
//  Copyright © 2025-2026 Hearify, Inc. All rights reserved.
//
//  This file is part of Hearify, a proprietary auditory rehabilitation application.
//  Unauthorized use, copying, modification, or distribution is strictly prohibited.
//
//  Created on January 29, 2026.
//

import SwiftUI

/// Legal agreement screen shown on first app launch
struct LegalAgreementView: View {
    @Binding var hasAgreedToTerms: Bool
    @State private var hasScrolledToBottom = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showTerms = true // true = Terms, false = Privacy

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [AppTheme.primaryBlue.opacity(0.05), AppTheme.backgroundPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Segmented control for Terms/Privacy
                segmentedControl
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Content
                if showTerms {
                    termsContent
                } else {
                    privacyContent
                }

                // Agreement footer
                agreementFooter
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 40)

            Text("Legal Agreement")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text("Please read and accept our Terms of Service and Privacy Policy to continue")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
        }
    }

    // MARK: - Segmented Control
    private var segmentedControl: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    showTerms = true
                    hasScrolledToBottom = false
                }
            }) {
                Text("Terms of Service")
                    .font(.system(size: 14, weight: showTerms ? .semibold : .regular))
                    .foregroundColor(showTerms ? .white : AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        showTerms ? AppTheme.primaryBlue : Color.clear
                    )
                    .cornerRadius(8)
            }

            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    showTerms = false
                    hasScrolledToBottom = false
                }
            }) {
                Text("Privacy Policy")
                    .font(.system(size: 14, weight: !showTerms ? .semibold : .regular))
                    .foregroundColor(!showTerms ? .white : AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        !showTerms ? AppTheme.primaryBlue : Color.clear
                    )
                    .cornerRadius(8)
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    // MARK: - Terms Content
    private var termsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    LegalSectionHeader(title: "1. Acceptance of Terms")
                    LegalBodyText(text: "By accessing or using Hearify™ (\"the App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.")

                    LegalSectionHeader(title: "2. Medical Disclaimer")
                    LegalBodyText(text: "Hearify is NOT a medical device and is NOT intended to diagnose, treat, cure, or prevent any disease or medical condition. The App is designed as a supplementary auditory training tool and should not replace professional medical advice, diagnosis, or treatment from qualified healthcare providers.")

                    LegalSectionHeader(title: "3. License Grant")
                    LegalBodyText(text: "Subject to your compliance with these Terms, Hearify, Inc. grants you a limited, non-exclusive, non-transferable, revocable license to use the App for your personal, non-commercial use.")

                    LegalSectionHeader(title: "4. Intellectual Property")
                    LegalBodyText(text: "All content, features, and functionality of the App are owned by Hearify, Inc. and are protected by copyright, trademark, patent, and other intellectual property laws. Unauthorized use, copying, or distribution is strictly prohibited.")

                    LegalSectionHeader(title: "5. User Data and Privacy")
                    LegalBodyText(text: "Your use of the App is subject to our Privacy Policy. We collect and process health-related data in compliance with HIPAA regulations. By using the App, you consent to our data collection practices as described in the Privacy Policy.")
                }

                Group {
                    LegalSectionHeader(title: "6. Patient-Clinician Linking")
                    LegalBodyText(text: "If you choose to link your account with a clinician, you authorize the sharing of your practice data, progress reports, and analytics with that clinician. You may revoke this authorization at any time through the App settings.")

                    LegalSectionHeader(title: "7. Prohibited Activities")
                    LegalBodyText(text: "You agree not to: (a) reverse engineer or decompile the App; (b) use the App for any illegal purpose; (c) share your account credentials; (d) attempt to gain unauthorized access to our systems; or (e) interfere with the App's operation.")

                    LegalSectionHeader(title: "8. Limitation of Liability")
                    LegalBodyText(text: "TO THE MAXIMUM EXTENT PERMITTED BY LAW, HEARIFY, INC. SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING FROM YOUR USE OF THE APP.")

                    LegalSectionHeader(title: "9. Disclaimer of Warranties")
                    LegalBodyText(text: "THE APP IS PROVIDED \"AS IS\" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.")

                    LegalSectionHeader(title: "10. Governing Law")
                    LegalBodyText(text: "These Terms are governed by the laws of the United States and the State of Delaware, without regard to conflict of law principles.")
                }

                Text("Last Updated: January 29, 2026")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)

                Text("© 2025-2026 Hearify, Inc. All rights reserved.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8)
        .padding(.horizontal, 20)
    }

    // MARK: - Privacy Content
    private var privacyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    LegalSectionHeader(title: "1. Information We Collect")
                    LegalBodyText(text: "We collect information you provide directly (name, email, health data), automatically (usage data, device information), and from clinicians (if you authorize linking).")

                    LegalSectionHeader(title: "2. How We Use Your Information")
                    LegalBodyText(text: "We use your information to: provide and improve the App, track your progress, generate analytics, enable clinician collaboration, and ensure HIPAA compliance.")

                    LegalSectionHeader(title: "3. HIPAA Compliance")
                    LegalBodyText(text: "Hearify processes Protected Health Information (PHI) in compliance with HIPAA regulations. We implement appropriate safeguards to protect your health data, including encryption, access controls, and audit logs.")

                    LegalSectionHeader(title: "4. Data Sharing and Disclosure")
                    LegalBodyText(text: "We do NOT sell your personal information. We may share data with: (a) authorized clinicians you've linked with, (b) service providers bound by confidentiality agreements (Firebase, CloudKit), and (c) legal authorities when required by law.")

                    LegalSectionHeader(title: "5. Your Rights")
                    LegalBodyText(text: "You have the right to: access your data, request corrections, delete your account, revoke clinician authorization, opt-out of analytics, and receive a copy of your health records.")
                }

                Group {
                    LegalSectionHeader(title: "6. Data Security")
                    LegalBodyText(text: "We implement industry-standard security measures including: end-to-end encryption, secure cloud storage, regular security audits, and multi-factor authentication options.")

                    LegalSectionHeader(title: "7. Data Retention")
                    LegalBodyText(text: "We retain your data for as long as your account is active. You may request deletion at any time. After deletion, we retain anonymized analytics data for up to 7 years as required by HIPAA.")

                    LegalSectionHeader(title: "8. Children's Privacy")
                    LegalBodyText(text: "Hearify is not intended for children under 13. If we discover we've collected data from a child under 13, we will delete it immediately.")

                    LegalSectionHeader(title: "9. California & GDPR Rights")
                    LegalBodyText(text: "California residents and European users have additional rights including data portability, right to erasure, and right to object to processing.")

                    LegalSectionHeader(title: "10. Contact Us")
                    LegalBodyText(text: "For privacy questions or to exercise your rights, contact us at: contact@hearifyapp.com")
                }

                Text("Last Updated: January 29, 2026")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)

                Text("© 2025-2026 Hearify, Inc. All rights reserved.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8)
        .padding(.horizontal, 20)
    }

    // MARK: - Agreement Footer
    private var agreementFooter: some View {
        VStack(spacing: 16) {
            Divider()

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primaryBlue)

                    Text("By tapping 'I Agree', you acknowledge that you have read and agree to both the Terms of Service and Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 20)

                Button(action: {
                    withAnimation(.spring(response: 0.4)) {
                        hasAgreedToTerms = true
                        UserDefaults.standard.set(true, forKey: "hasAgreedToLegalTerms")
                        UserDefaults.standard.set(Date(), forKey: "legalTermsAgreementDate")
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        Text("I Agree to Terms and Privacy Policy")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: AppTheme.primaryBlue.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 20)

                Button(action: {
                    // Exit app
                    exit(0)
                }) {
                    Text("Decline and Exit")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color.white)
    }
}

// MARK: - Supporting Views

struct LegalSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.top, 8)
    }
}

struct LegalBodyText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(AppTheme.textSecondary)
            .lineSpacing(4)
    }
}

// MARK: - Preview
struct LegalAgreementView_Previews: PreviewProvider {
    static var previews: some View {
        LegalAgreementView(hasAgreedToTerms: .constant(false))
    }
}
