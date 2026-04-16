//
//  EnhancedProgressDashboardView.swift
//  HearifyV1
//
//  Comprehensive progress dashboard with charts and statistics
//  High Priority Feature: Progress Tracking System
//

import SwiftUI
import Charts

struct EnhancedProgressDashboardView: View {
    @ObservedObject var progressManager = ProgressManager.shared
    var onDismiss: () -> Void

    @State private var selectedTab = 0
    @State private var showExportSheet = false
    @State private var exportedText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            // Tab Selector
            tabSelector

            // Content based on selected tab
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedTab {
                    case 0:
                        overviewTab
                    case 1:
                        scoresTab
                    case 2:
                        achievementsTab
                    case 3:
                        phonemesTab
                    default:
                        overviewTab
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
        .sheet(isPresented: $showExportSheet) {
            exportSheet
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: { onDismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            Text("Progress Dashboard")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Button(action: { exportProgress() }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(AppTheme.primaryGradient)
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Overview", index: 0)
            tabButton(title: "Scores", index: 1)
            tabButton(title: "Achievements", index: 2)
            tabButton(title: "Phonemes", index: 3)
        }
        .background(Color.white)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            Text(title)
                .font(.system(size: 14, weight: selectedTab == index ? .bold : .regular))
                .foregroundColor(selectedTab == index ? AppTheme.primaryBlue : AppTheme.textSecondary)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(selectedTab == index ? AppTheme.primaryBlue.opacity(0.1) : Color.clear)
                .overlay(
                    Rectangle()
                        .fill(AppTheme.primaryBlue)
                        .frame(height: 3),
                    alignment: .bottom
                )
                .opacity(selectedTab == index ? 1.0 : 0.0)
        }
    }

    // MARK: - Overview Tab
    private var overviewTab: some View {
        VStack(spacing: 16) {
            // Streak Card
            streakCard

            // Quick Stats
            quickStatsGrid

            // Recent Sessions
            recentSessionsCard
        }
    }

    private var streakCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(progressManager.getCurrentStreak()) Days")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Current Streak")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            HStack {
                statPill(label: "Longest", value: "\(progressManager.getLongestStreak())", color: .purple)
                statPill(label: "Total Days", value: "\(progressManager.userProgress.streak.totalPracticeDays)", color: .blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    private var quickStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(
                title: "Total Exercises",
                value: "\(progressManager.getTotalExercises())",
                icon: "checkmark.circle.fill",
                color: AppTheme.success
            )

            statCard(
                title: "Average Score",
                value: "\(Int(progressManager.getAverageScore() * 100))%",
                icon: "chart.bar.fill",
                color: AppTheme.info
            )

            statCard(
                title: "Practice Time",
                value: "\(Int(progressManager.userProgress.totalDuration / 60))m",
                icon: "clock.fill",
                color: AppTheme.accentOrange
            )

            statCard(
                title: "Achievements",
                value: "\(progressManager.getUnlockedAchievements().count)",
                icon: "star.fill",
                color: AppTheme.warning
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }

    private var recentSessionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(progressManager.getRecentSessions(limit: 5)) { session in
                recentSessionRow(session: session)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    private func recentSessionRow(session: UserPracticeSession) -> some View {
        HStack {
            // Phase icon
            Circle()
                .fill(phaseColor(session.phase))
                .frame(width: 40, height: 40)
                .overlay(
                    Text("P\(session.phase)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(session.exerciseType)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                if let phoneme = session.phoneme {
                    Text(phoneme)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Spacer()

            Text("\(Int(session.score * 100))%")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(scoreColor(session.score))
        }
        .padding(.vertical, 8)
    }

    // MARK: - Scores Tab
    private var scoresTab: some View {
        VStack(spacing: 16) {
            // Score over time chart
            scoreChartCard

            // Score distribution
            scoreDistributionCard
        }
    }

    private var scoreChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score History (Last 30 Days)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(progressManager.getScoreHistory(days: 30), id: \.0) { date, score in
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Score", score * 100)
                        )
                        .foregroundStyle(AppTheme.primaryBlue)

                        PointMark(
                            x: .value("Date", date),
                            y: .value("Score", score * 100)
                        )
                        .foregroundStyle(AppTheme.primaryBlue)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel() {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)%")
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS 15
                Text("Chart requires iOS 16+")
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    private var scoreDistributionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Distribution")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            let sessions = progressManager.userProgress.sessions
            let excellent = sessions.filter { $0.score >= 0.85 }.count
            let good = sessions.filter { $0.score >= 0.65 && $0.score < 0.85 }.count
            let needsWork = sessions.filter { $0.score < 0.65 }.count
            let total = max(sessions.count, 1)

            distributionBar(label: "Excellent (85%+)", count: excellent, total: total, color: .green)
            distributionBar(label: "Good (65-84%)", count: good, total: total, color: .yellow)
            distributionBar(label: "Needs Work (<65%)", count: needsWork, total: total, color: .red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    private func distributionBar(label: String, count: Int, total: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)

                Spacer()

                Text("\(count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .frame(width: geometry.size.width, height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(count) / CGFloat(total), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Achievements Tab
    private var achievementsTab: some View {
        VStack(spacing: 16) {
            // Unlocked achievements
            if !progressManager.getUnlockedAchievements().isEmpty {
                achievementSection(title: "Unlocked", achievements: progressManager.getUnlockedAchievements(), isUnlocked: true)
            }

            // Locked achievements
            achievementSection(title: "In Progress", achievements: progressManager.getLockedAchievements(), isUnlocked: false)
        }
    }

    private func achievementSection(title: String, achievements: [Achievement], isUnlocked: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(achievements, id: \.id) { achievement in
                achievementCard(achievement: achievement, isUnlocked: isUnlocked)
            }
        }
    }

    private func achievementCard(achievement: Achievement, isUnlocked: Bool) -> some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppTheme.warning : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? .white : .gray)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(achievement.description)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)

                if !isUnlocked {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                                .cornerRadius(3)

                            Rectangle()
                                .fill(AppTheme.primaryBlue)
                                .frame(width: geometry.size.width * CGFloat(achievement.progressPercentage), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)

                    Text("\(achievement.progress)/\(achievement.requirement)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }

    // MARK: - Phonemes Tab
    private var phonemesTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Phoneme Statistics")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(progressManager.getPhonemeStats(), id: \.phoneme) { stat in
                phonemeStatCard(stat: stat)
            }
        }
    }

    private func phonemeStatCard(stat: PhonemeStats) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stat.phoneme)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.primaryBlue)

                Spacer()

                Text("\(Int(stat.averageScore * 100))%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(scoreColor(stat.averageScore))
            }

            HStack(spacing: 16) {
                statPill(label: "Attempts", value: "\(stat.attemptCount)", color: .blue)
                statPill(label: "Best", value: "\(Int(stat.bestScore * 100))%", color: .green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }

    // MARK: - Export Sheet
    private var exportSheet: some View {
        NavigationView {
            ScrollView {
                Text(exportedText)
                    .font(.system(size: 12, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Progress Report")
            .navigationBarItems(
                leading: Button("Done") { showExportSheet = false },
                trailing: Button(action: { shareText(exportedText) }) {
                    Image(systemName: "square.and.arrow.up")
                }
            )
        }
    }

    // MARK: - Helpers
    private func exportProgress() {
        exportedText = progressManager.exportProgressReport()
        showExportSheet = true
    }

    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    private func statPill(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textSecondary)
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }

    private func phaseColor(_ phase: Int) -> Color {
        switch phase {
        case 1: return AppTheme.primaryBlue
        case 2: return AppTheme.accentOrange
        case 3: return Color(red: 0.2, green: 0.8, blue: 0.6)
        default: return .gray
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.85 {
            return .green
        } else if score >= 0.65 {
            return .orange
        } else {
            return .red
        }
    }
}
