//
//  AboutScreenView.swift
//  Hearify
//
//  Copyright © 2025-2026 Hearify, Inc. All rights reserved.
//
//  This file is part of Hearify, a proprietary auditory rehabilitation application.
//  Unauthorized use, copying, modification, or distribution is strictly prohibited.
//
//  Created on January 28, 2026.
//

import SwiftUI

/// Professional About screen with comprehensive legal notices and copyright information
struct AboutScreenView: View {
    @Environment(\.dismiss) var dismiss

    // App version from Bundle
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private var fullVersion: String {
        "Version \(appVersion) (Build \(buildNumber))"
    }

    private var copyrightYear: String {
        let startYear = 2025
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear > startYear ? "\(startYear)-\(currentYear)" : "\(startYear)"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - App Icon and Title
                    appHeaderSection

                    // MARK: - Version Information
                    versionSection

                    Divider()
                        .padding(.horizontal)

                    // MARK: - Copyright Notice
                    copyrightSection

                    Divider()
                        .padding(.horizontal)

                    // MARK: - Trademark Notice
                    trademarkSection

                    Divider()
                        .padding(.horizontal)

                    // MARK: - Patent Notice
                    patentSection

                    Divider()
                        .padding(.horizontal)

                    // MARK: - Description
                    descriptionSection

                    Divider()
                        .padding(.horizontal)

                    // MARK: - Legal Links
                    legalLinksSection

                    Divider()
                        .padding(.horizontal)

                    // MARK: - Contact Information
                    contactSection

                    Divider()
                        .padding(.horizontal)

                    // MARK: - Developer Credits
                    creditsSection

                    Divider()
                        .padding(.horizontal)

                    // MARK: - Third-Party Acknowledgments
                    acknowledgementsSection

                    // MARK: - Bottom Spacing
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 24)
            }
            .background(AppTheme.backgroundPrimary)
            .navigationTitle("About Hearify")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryBlue)
                }
            }
        }
    }

    // MARK: - App Header Section
    private var appHeaderSection: some View {
        VStack(spacing: 16) {
            // App Icon
            if let appIcon = Bundle.main.icon {
                Image(uiImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                // Fallback icon if app icon not available
                Image(systemName: "ear.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primaryBlue)
                    .frame(width: 100, height: 100)
                    .background(AppTheme.primaryBlue.opacity(0.1))
                    .cornerRadius(20)
            }

            // App Name
            Text("Hearify™")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            // Tagline
            Text("Auditory Rehabilitation Made Simple")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Version Section
    private var versionSection: some View {
        VStack(spacing: 8) {
            Text(fullVersion)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            Text("Built for iOS 17.0+")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)
        }
    }

    // MARK: - Copyright Section
    private var copyrightSection: some View {
        VStack(spacing: 12) {
            Label("Copyright", systemImage: "c.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.primaryBlue)

            VStack(spacing: 4) {
                Text("Copyright © \(copyrightYear) Hearify, Inc.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text("All Rights Reserved")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text("This software and associated documentation files are the proprietary and confidential information of Hearify, Inc. Unauthorized copying, distribution, or use is strictly prohibited.")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Trademark Section
    private var trademarkSection: some View {
        VStack(spacing: 12) {
            Label("Trademarks", systemImage: "trademark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.primaryBlue)

            VStack(spacing: 8) {
                Text("Hearify™, HearifyV1™, and HearifyPro™")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text("are trademarks of Hearify, Inc.")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text("All other trademarks are the property of their respective owners.")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Patent Section
    private var patentSection: some View {
        VStack(spacing: 12) {
            Label("Patents", systemImage: "doc.text.magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.primaryBlue)

            // Update this once patent is filed
            Text("Patent Pending")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.accentOrange)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(AppTheme.accentOrange.opacity(0.1))
                .cornerRadius(8)

            Text("Protected by U.S. and international patent laws. This application contains proprietary technology and innovative features.")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(spacing: 12) {
            Label("About This App", systemImage: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.primaryBlue)

            Text("Hearify is a comprehensive auditory rehabilitation platform designed to help individuals with hearing challenges improve their listening and speaking abilities through evidence-based exercises, real-time feedback, and engaging gamification.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .lineSpacing(4)

            // Medical Disclaimer
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.warning)
                    Text("Medical Disclaimer")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Text("Hearify is not a medical device and is not intended to diagnose, treat, cure, or prevent any disease. It is designed as a supplementary tool for auditory training and should not replace professional medical care or advice from your audiologist or physician.")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineSpacing(3)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Legal Links Section
    private var legalLinksSection: some View {
        VStack(spacing: 12) {
            Label("Legal", systemImage: "doc.text")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.primaryBlue)

            VStack(spacing: 8) {
                // Terms of Service Button
                NavigationLink(destination: TermsOfServiceView()) {
                    HStack {
                        Text("Terms of Service")
                            .font(.system(size: 14))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.primaryBlue)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }
                .padding(.horizontal, 24)

                // Privacy Policy Button
                NavigationLink(destination: PrivacyPolicyView()) {
                    HStack {
                        Text("Privacy Policy")
                            .font(.system(size: 14))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.primaryBlue)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }
                .padding(.horizontal, 24)

                // License Agreement Button
                Button(action: {
                    // Show license information
                }) {
                    HStack {
                        Text("License Agreement")
                            .font(.system(size: 14))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.primaryBlue)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(spacing: 12) {
            Label("Contact", systemImage: "envelope")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.primaryBlue)

            VStack(spacing: 8) {
                ContactRow(icon: "envelope.fill", label: "Contact Us", value: "contact@hearifyapp.com")
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Credits Section
    private var creditsSection: some View {
        VStack(spacing: 12) {
            Label("Credits", systemImage: "person.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.primaryBlue)

            VStack(spacing: 8) {
                Text("Developed by")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)

                Text("Hearify, Inc.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Founded by Veer Chopra")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)

                Text("With support from audiologists and speech-language pathologists dedicated to improving auditory rehabilitation outcomes.")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Acknowledgements Section
    private var acknowledgementsSection: some View {
        VStack(spacing: 12) {
            Label("Acknowledgments", systemImage: "heart.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.primaryBlue)

            VStack(spacing: 8) {
                AcknowledgementRow(name: "Firebase", purpose: "Cloud infrastructure and authentication")
                AcknowledgementRow(name: "Apple CloudKit", purpose: "iCloud synchronization")
                AcknowledgementRow(name: "Apple Speech Recognition", purpose: "Real-time speech processing")
                AcknowledgementRow(name: "SwiftUI", purpose: "User interface framework")
            }
            .padding(.horizontal, 24)

            Text("Special thanks to the open-source community and all contributors who make apps like Hearify possible.")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)
        }
    }
}

// MARK: - Supporting Views

struct ContactRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        Button(action: {
            if let url = URL(string: "mailto:\(value)") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.primaryBlue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(value)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.primaryBlue)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4)
        }
    }
}

struct AcknowledgementRow: View {
    let name: String
    let purpose: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.success)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                Text(purpose)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 8)

                Text("Last Updated: January 28, 2026")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Divider()

                Group {
                    SectionHeader(title: "1. Acceptance of Terms")
                    BodyText(text: "By accessing or using Hearify™ (\"the App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.")

                    SectionHeader(title: "2. Medical Disclaimer")
                    BodyText(text: "Hearify is NOT a medical device and is NOT intended to diagnose, treat, cure, or prevent any disease or medical condition. The App is designed as a supplementary auditory training tool and should not replace professional medical advice, diagnosis, or treatment from qualified healthcare providers.")

                    SectionHeader(title: "3. License Grant")
                    BodyText(text: "Subject to your compliance with these Terms, Hearify, Inc. grants you a limited, non-exclusive, non-transferable, revocable license to use the App for your personal, non-commercial use.")

                    SectionHeader(title: "4. Intellectual Property")
                    BodyText(text: "All content, features, and functionality of the App are owned by Hearify, Inc. and are protected by copyright, trademark, patent, and other intellectual property laws. Unauthorized use, copying, or distribution is strictly prohibited.")

                    SectionHeader(title: "5. User Data and Privacy")
                    BodyText(text: "Your use of the App is subject to our Privacy Policy. We collect and process health-related data in compliance with HIPAA regulations. By using the App, you consent to our data collection practices as described in the Privacy Policy.")

                    SectionHeader(title: "6. Patient-Clinician Linking")
                    BodyText(text: "If you choose to link your account with a clinician, you authorize the sharing of your practice data, progress reports, and analytics with that clinician. You may revoke this authorization at any time through the App settings.")

                    SectionHeader(title: "7. Prohibited Activities")
                    BodyText(text: "You agree not to: (a) reverse engineer or decompile the App; (b) use the App for any illegal purpose; (c) share your account credentials; (d) attempt to gain unauthorized access to our systems; or (e) interfere with the App's operation.")

                    SectionHeader(title: "8. Limitation of Liability")
                    BodyText(text: "TO THE MAXIMUM EXTENT PERMITTED BY LAW, HEARIFY, INC. SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING FROM YOUR USE OF THE APP.")
                }

                Group {
                    SectionHeader(title: "9. Disclaimer of Warranties")
                    BodyText(text: "THE APP IS PROVIDED \"AS IS\" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.")

                    SectionHeader(title: "10. Subscription and Fees")
                    BodyText(text: "HearifyPro™ features may require a paid subscription. All fees are non-refundable except as required by law. Subscriptions automatically renew unless cancelled.")

                    SectionHeader(title: "11. Termination")
                    BodyText(text: "We reserve the right to suspend or terminate your access to the App at any time for violation of these Terms or for any other reason.")

                    SectionHeader(title: "12. Changes to Terms")
                    BodyText(text: "We may modify these Terms at any time. Continued use of the App after changes constitutes acceptance of the modified Terms.")

                    SectionHeader(title: "13. Governing Law")
                    BodyText(text: "These Terms are governed by the laws of the United States and the State of Delaware, without regard to conflict of law principles.")

                    SectionHeader(title: "14. Contact Information")
                    BodyText(text: "For questions about these Terms, contact us at: contact@hearifyapp.com")
                }

                Text("© 2025-2026 Hearify, Inc. All rights reserved.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 8)

                Text("Last Updated: January 28, 2026")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Divider()

                Group {
                    SectionHeader(title: "1. Information We Collect")
                    BodyText(text: "We collect information you provide directly (name, email, health data), automatically (usage data, device information), and from clinicians (if you authorize linking).")

                    SectionHeader(title: "2. How We Use Your Information")
                    BodyText(text: "We use your information to: provide and improve the App, track your progress, generate analytics, enable clinician collaboration, and ensure HIPAA compliance.")

                    SectionHeader(title: "3. HIPAA Compliance")
                    BodyText(text: "Hearify processes Protected Health Information (PHI) in compliance with HIPAA regulations. We implement appropriate safeguards to protect your health data, including encryption, access controls, and audit logs.")

                    SectionHeader(title: "4. Data Sharing and Disclosure")
                    BodyText(text: "We do NOT sell your personal information. We may share data with: (a) authorized clinicians you've linked with, (b) service providers bound by confidentiality agreements (Firebase, CloudKit), and (c) legal authorities when required by law.")

                    SectionHeader(title: "5. Your Rights")
                    BodyText(text: "You have the right to: access your data, request corrections, delete your account, revoke clinician authorization, opt-out of analytics, and receive a copy of your health records.")

                    SectionHeader(title: "6. Data Security")
                    BodyText(text: "We implement industry-standard security measures including: end-to-end encryption, secure cloud storage, regular security audits, and multi-factor authentication options.")

                    SectionHeader(title: "7. Data Retention")
                    BodyText(text: "We retain your data for as long as your account is active. You may request deletion at any time. After deletion, we retain anonymized analytics data for up to 7 years as required by HIPAA.")
                }

                Group {
                    SectionHeader(title: "8. Children's Privacy")
                    BodyText(text: "Hearify is not intended for children under 13. If we discover we've collected data from a child under 13, we will delete it immediately.")

                    SectionHeader(title: "9. International Users")
                    BodyText(text: "Your data may be transferred to and processed in the United States. By using the App, you consent to this transfer and processing.")

                    SectionHeader(title: "10. California Privacy Rights (CCPA)")
                    BodyText(text: "California residents have additional rights including: right to know what data is collected, right to delete personal information, and right to opt-out of data sales (though we do not sell data).")

                    SectionHeader(title: "11. European Users (GDPR)")
                    BodyText(text: "European users have rights under GDPR including: data portability, right to erasure, right to object to processing, and right to lodge complaints with supervisory authorities.")

                    SectionHeader(title: "12. Cookies and Tracking")
                    BodyText(text: "We use essential cookies for authentication and functionality. We do not use advertising or tracking cookies.")

                    SectionHeader(title: "13. Changes to Privacy Policy")
                    BodyText(text: "We may update this Privacy Policy. We will notify you of material changes via email or in-app notification.")

                    SectionHeader(title: "14. Contact Us")
                    BodyText(text: "For privacy questions or to exercise your rights, contact us at: contact@hearifyapp.com")
                }

                Text("© 2025-2026 Hearify, Inc. All rights reserved.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views for Legal Documents
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.top, 8)
    }
}

struct BodyText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(AppTheme.textSecondary)
            .lineSpacing(4)
    }
}

// MARK: - Bundle Extension for App Icon
extension Bundle {
    var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}

// MARK: - Preview
struct AboutScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AboutScreenView()

        AboutScreenView()
            .preferredColorScheme(.dark)
    }
}
