//
//  AppTutorialView.swift
//  HearifyV1
//
//  Comprehensive tutorial covering all app features
//  Updated: January 20, 2026
//

import SwiftUI

// MARK: - Tutorial Page Model
struct TutorialPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    let detailedSteps: [String]
}

// MARK: - App Tutorial View
struct AppTutorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var showingDetailedView = false
    
    let pages: [TutorialPage] = [
        // Welcome Page
        TutorialPage(
            title: "Welcome to Hearify",
            description: "Your comprehensive auditory rehabilitation app with speech recognition, pronunciation practice, and visual feedback.",
            icon: "waveform.circle.fill",
            iconColor: AppTheme.primaryBlue,
            detailedSteps: [
                "Hearify helps you improve speech perception and pronunciation",
                "Practice with words, sentences, and conversations",
                "Get real-time feedback with advanced speech recognition",
                "Track your progress with detailed analytics"
            ]
        ),
        
        // Phase 1: Listening & Recognition
        TutorialPage(
            title: "Phase 1: Listening Practice",
            description: "Build your auditory skills with word and sentence recognition exercises.",
            icon: "ear.fill",
            iconColor: AppTheme.primaryCyan,
            detailedSteps: [
                "Listen to words or sentences spoken by the app",
                "Choose the correct answer from multiple choices",
                "Practice in quiet or with background noise",
                "Adjust volume and playback speed to your preference",
                "Track accuracy and progress over time"
            ]
        ),
        
        // Phase 2: Speaking & Pronunciation
        TutorialPage(
            title: "Phase 2: Speaking Practice",
            description: "Improve pronunciation with real-time speech recognition and feedback.",
            icon: "mic.fill",
            iconColor: AppTheme.accentOrange,
            detailedSteps: [
                "Hear the target word or sentence",
                "Speak it clearly into your device",
                "Get instant feedback on your pronunciation",
                "See detailed analysis of what you said vs. expected",
                "Compare phonetic breakdowns and waveforms",
                "Practice minimal pairs (cat vs. bat, sheep vs. ship)"
            ]
        ),
        
        // Phase 3: Visual Pronunciation
        TutorialPage(
            title: "Phase 3: Visual Feedback",
            description: "Use your camera to see how your mouth shapes match target phonemes.",
            icon: "video.fill",
            iconColor: AppTheme.accentPurple,
            detailedSteps: [
                "Position your face in the camera view",
                "See target mouth shape for each phoneme",
                "Practice forming the correct mouth position",
                "Get real-time feedback on mouth shape accuracy",
                "Visual guides help you see exactly how to position your mouth"
            ]
        ),
        
        // Voice Settings
        TutorialPage(
            title: "Voice Settings",
            description: "Customize the voice used throughout the app.",
            icon: "speaker.wave.3.fill",
            iconColor: AppTheme.info,
            detailedSteps: [
                "Choose between Male Voice or Female Voice",
                "High-quality natural-sounding speech synthesis",
                "Consistent voice across all exercises",
                "Settings persist across app sessions"
            ]
        ),
        
        // Audio Controls
        TutorialPage(
            title: "Audio Controls",
            description: "Adjust volume and playback speed for optimal learning.",
            icon: "slider.horizontal.3",
            iconColor: AppTheme.success,
            detailedSteps: [
                "Volume Control: Adjust from 0% to 100%",
                "Speed Control: Range from 0.5x (slow) to 2.0x (fast)",
                "Start slower to understand, speed up as you improve",
                "Replay any audio as many times as needed"
            ]
        ),
        
        // Background Noise
        TutorialPage(
            title: "Background Noise Training",
            description: "Practice listening in challenging environments.",
            icon: "waveform.badge.exclamationmark",
            iconColor: AppTheme.warning,
            detailedSteps: [
                "Choose from various noise types: Cafe, Traffic, Party",
                "Adjust noise level from 10% to 100%",
                "Builds real-world listening skills",
                "Gradually increase difficulty as you improve",
                "Simulates challenging listening environments"
            ]
        ),
        
        // Progress Tracking
        TutorialPage(
            title: "Progress Dashboard",
            description: "Track your improvement with comprehensive analytics.",
            icon: "chart.line.uptrend.xyaxis",
            iconColor: AppTheme.primaryBlue,
            detailedSteps: [
                "View your overall statistics and accuracy",
                "Track your practice streak (consecutive days)",
                "See which exercises you've mastered",
                "Review matched pairs performance (e.g., cat vs bat)",
                "Export detailed progress reports to share with clinicians",
                "Unlock achievements for milestones"
            ]
        ),
        
        // Speech Recognition Features
        TutorialPage(
            title: "Advanced Speech Analysis",
            description: "Detailed feedback on your pronunciation.",
            icon: "waveform.path.ecg",
            iconColor: AppTheme.accentOrange,
            detailedSteps: [
                "Character-by-character comparison of what you said",
                "Confidence scores for each word detected",
                "Phonetic analysis with IPA notation",
                "Audio waveform visualization",
                "Multiple pronunciation alternatives shown",
                "Raw transcription segments for transparency"
            ]
        ),
        
        // Conversation Practice
        TutorialPage(
            title: "Conversation Scenarios",
            description: "Practice real-world communication situations.",
            icon: "person.2.fill",
            iconColor: Color(red: 0.2, green: 0.8, blue: 0.6),
            detailedSteps: [
                "Choose from various scenarios (ordering food, asking directions)",
                "Interactive multi-turn conversations",
                "Practice both listening and speaking",
                "Get context-aware feedback",
                "Build practical communication skills"
            ]
        ),
        
        // Permissions
        TutorialPage(
            title: "Required Permissions",
            description: "Hearify needs access to work properly.",
            icon: "lock.shield.fill",
            iconColor: AppTheme.error,
            detailedSteps: [
                "Microphone: Required for speech recognition",
                "Speech Recognition: Analyzes what you say",
                "Camera (Phase 3 only): For visual mouth shape feedback",
                "All processing happens on your device",
                "Your privacy is protected - no data is sent to servers"
            ]
        ),
        
        // Tips for Success
        TutorialPage(
            title: "Tips for Best Results",
            description: "Get the most out of your practice sessions.",
            icon: "star.fill",
            iconColor: AppTheme.accentOrange,
            detailedSteps: [
                "Practice in a quiet environment for best recognition",
                "Speak clearly and at a normal volume",
                "Use headphones for better audio quality",
                "Position your device 6-12 inches from your mouth",
                "Practice regularly - consistency is key!",
                "Start with easier exercises and progress gradually",
                "Review your progress weekly to stay motivated"
            ]
        ),
        
        // Getting Started
        TutorialPage(
            title: "Ready to Begin!",
            description: "You're all set to start your auditory rehabilitation journey.",
            icon: "checkmark.circle.fill",
            iconColor: AppTheme.success,
            detailedSteps: [
                "Choose Phase 1, 2, or 3 from the main menu",
                "Start with Phase 1 if you're new",
                "Grant microphone permission when prompted",
                "Practice for 10-15 minutes daily for best results",
                "Check your progress dashboard regularly",
                "Have fun and celebrate your improvements!"
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("Tutorial")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Skip button
                Button(action: { dismiss() }) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .background(AppTheme.primaryGradient)
            
            // Page Indicator
            HStack(spacing: 4) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? AppTheme.primaryBlue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 12)
            .background(Color.white)
            
            // Content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    tutorialPageView(page: page, pageNumber: index + 1)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Navigation Buttons
            HStack(spacing: 16) {
                if currentPage > 0 {
                    Button(action: { withAnimation { currentPage -= 1 } }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryBlue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                if currentPage < pages.count - 1 {
                    Button(action: { withAnimation { currentPage += 1 } }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Get Started")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.successGradient)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
            .background(Color.white)
        }
        .background(AppTheme.backgroundPrimary)
    }
    
    // MARK: - Tutorial Page View
    private func tutorialPageView(page: TutorialPage, pageNumber: Int) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundColor(page.iconColor)
                    .padding(.top, 20)
                
                // Title
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Detailed Steps
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(page.detailedSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "\(index + 1).circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(page.iconColor)
                            
                            Text(step)
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8)
                .padding(.horizontal)
                
                // Page number indicator
                Text("Page \(pageNumber) of \(pages.count)")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Quick Tips View (for in-app help)
struct QuickTipsView: View {
    @Environment(\.dismiss) var dismiss
    
    let tips: [(icon: String, title: String, description: String, color: Color)] = [
        ("mic.fill", "Clear Speech", "Speak clearly and at a normal volume for best recognition", AppTheme.accentOrange),
        ("speaker.wave.3.fill", "Replay Anytime", "Tap the speaker button to hear the word or sentence again", AppTheme.info),
        ("slider.horizontal.3", "Adjust Speed", "Slow down audio to 0.5x if you need more time to process", AppTheme.success),
        ("waveform", "Background Noise", "Start with quiet mode, then add noise as you improve", AppTheme.warning),
        ("chart.line.uptrend.xyaxis", "Track Progress", "Check your dashboard to see improvements over time", AppTheme.primaryBlue),
        ("flame.fill", "Daily Streak", "Practice every day to build your streak and stay motivated", .orange)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(tips, id: \.title) { tip in
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: tip.icon)
                                .font(.system(size: 28))
                                .foregroundColor(tip.color)
                                .frame(width: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(tip.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text(tip.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4)
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
            .navigationTitle("Quick Tips")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

// MARK: - Preview
struct AppTutorialView_Previews: PreviewProvider {
    static var previews: some View {
        AppTutorialView()
    }
}
