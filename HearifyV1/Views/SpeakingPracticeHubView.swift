//
//  SpeakingPracticeHubView.swift
//  HearifyV1
//
//  Speaking Practice Hub - Main menu for all pronunciation features
//

import SwiftUI

struct SpeakingPracticeHubView: View {
    // Use shared instances to avoid creating duplicates (performance issue)
    @ObservedObject private var gamificationManager = GamificationManager.shared
    @ObservedObject private var progressTrackingManager = ProgressTrackingManager.shared
    @ObservedObject private var analyticsManager = AnalyticsManager.shared
    @State private var selectedFeature: SpeakingFeature?
    var onDismiss: () -> Void = {}

    enum SpeakingFeature {
        case standardPractice
        case targetedPractice
        case conversationPractice
        case visualPronunciation
        case progressDashboard
        case recordingHistory
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    if selectedFeature != nil {
                        selectedFeature = nil
                    } else {
                        onDismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(selectedFeature == nil ? "Speaking Practice" : featureTitle(selectedFeature!))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text(selectedFeature == nil ? "Level \(gamificationManager.currentLevel)" : "Speaking Module")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(gamificationManager.currentStreak)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(AppTheme.primaryGradient)

            // Content area - either feature list or selected feature view
            if let feature = selectedFeature {
                // Show selected feature inline
                Group {
                    switch feature {
                    case .standardPractice:
                        SpeakingPracticeView(onDismiss: {
                            selectedFeature = nil
                        })
                    case .targetedPractice:
                        TargetedPracticeView(onDismiss: {
                            selectedFeature = nil
                        })
                    case .conversationPractice:
                        ConversationPracticeView(onDismiss: {
                            selectedFeature = nil
                        })
                    case .visualPronunciation:
                        VisualPronunciationHubView(onDismiss: {
                            selectedFeature = nil
                        })
                    case .progressDashboard:
                        ProgressDashboardView(
                            progressManager: progressTrackingManager,
                            gamificationManager: gamificationManager,
                            analyticsManager: analyticsManager,
                            onDismiss: {
                                selectedFeature = nil
                            }
                        )
                    case .recordingHistory:
                        RecordingHistoryView(onDismiss: {
                            selectedFeature = nil
                        })
                    }
                }
            } else {
                // Show feature list
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome Card
                        welcomeCard

                        // Practice Features
                        VStack(spacing: 16) {
                            Text("Choose Practice Mode")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            // Standard Practice
                            featureCard(
                                title: "Standard Practice",
                                description: "Practice with guided exercises and instant feedback",
                                icon: "mic.circle.fill",
                                color: AppTheme.primaryBlue,
                                feature: .standardPractice
                            )

                            // Targeted Practice
                            featureCard(
                                title: "Targeted Practice",
                                description: "Focus on specific sounds like TH, R, L, and more",
                                icon: "target",
                                color: AppTheme.accentOrange,
                                feature: .targetedPractice
                            )

                            // Conversation Practice
                            featureCard(
                                title: "Conversation Practice",
                                description: "Real-world scenarios like restaurants, interviews, and more",
                                icon: "bubble.left.and.bubble.right.fill",
                                color: AppTheme.accentPurple,
                                feature: .conversationPractice
                            )

                            // Visual Pronunciation (Camera Vision Module)
                            featureCard(
                                title: "Visual Pronunciation",
                                description: "See how sounds are made with interactive mouth diagrams",
                                icon: "eye.fill",
                                color: Color(red: 0.6, green: 0.4, blue: 0.9),
                                feature: .visualPronunciation
                            )
                        }

                        // Progress & History
                        VStack(spacing: 16) {
                            Text("Track Your Progress")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            // Progress Dashboard
                            featureCard(
                                title: "Progress Dashboard",
                                description: "View your scores, trends, and improvements over time",
                                icon: "chart.line.uptrend.xyaxis",
                                color: AppTheme.success,
                                feature: .progressDashboard
                            )

                            // Recording History
                            featureCard(
                                title: "Recording History",
                                description: "Review all your past pronunciation attempts",
                                icon: "waveform.circle.fill",
                                color: AppTheme.info,
                                feature: .recordingHistory
                            )
                        }

                        // Features Overview
                        featuresOverview
                    }
                    .padding()
                }
                .background(AppTheme.backgroundPrimary)
            }
        }
    }

    // Helper function to get feature title
    private func featureTitle(_ feature: SpeakingFeature) -> String {
        switch feature {
        case .standardPractice: return "Standard Practice"
        case .targetedPractice: return "Targeted Practice"
        case .conversationPractice: return "Conversation Practice"
        case .visualPronunciation: return "Visual Pronunciation"
        case .progressDashboard: return "Progress Dashboard"
        case .recordingHistory: return "Recording History"
        }
    }

    // MARK: - Welcome Card
    private var welcomeCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.primaryBlue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Improve Your Pronunciation")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Practice speaking and get instant AI feedback")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            // Quick Stats
            HStack(spacing: 12) {
                quickStat(icon: "checkmark.circle.fill", value: "\(gamificationManager.totalPoints)", label: "Points", color: AppTheme.success)
                quickStat(icon: "star.fill", value: "Lvl \(gamificationManager.currentLevel)", label: "Level", color: AppTheme.warning)
                quickStat(icon: "flame.fill", value: "\(gamificationManager.currentStreak)", label: "Streak", color: AppTheme.accentOrange)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Feature Card
    private func featureCard(title: String, description: String, icon: String, color: Color, feature: SpeakingFeature) -> some View {
        Button(action: {
            selectedFeature = feature
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Features Overview
    private var featuresOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What You'll Get")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 8) {
                featureBullet(icon: "waveform.path.ecg", text: "Visual waveform comparison", color: AppTheme.accentPurple)
                featureBullet(icon: "speedometer", text: "Slow-motion playback (4 speeds)", color: AppTheme.accentOrange)
                featureBullet(icon: "textformat.abc", text: "Phonetic analysis (IPA notation)", color: AppTheme.info)
                featureBullet(icon: "chart.bar.fill", text: "Word-by-word accuracy breakdown", color: AppTheme.success)
                featureBullet(icon: "brain.head.profile", text: "AI-powered pronunciation scoring", color: AppTheme.primaryBlue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Helper Views
    private func quickStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }

    private func featureBullet(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)

            Spacer()
        }
    }
}
