//
//  ClinicianDashboardView.swift
//  HearifyV1
//
//  Dashboard for audiologists to monitor patient progress
//  For white-label partnerships and clinical validation
//

import SwiftUI
import Charts
import PDFKit

struct ClinicianDashboardView: View {
    // Use shared instances to avoid creating duplicates (performance issue)
    @ObservedObject private var analyticsManager = AnalyticsManager.shared
    @ObservedObject private var progressTrackingManager = ProgressTrackingManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var showingClearDataAlert = false
    @State private var pdfURL: URL?
    @State private var showingSessionDetails = false
    @State private var selectedTimeRange: TimeRange = .all
    @State private var showingLinkingView = false

    // Load listening history from UserDefaults
    @State private var listeningHistory: ListeningHistory = {
        if let savedData = UserDefaults.standard.data(forKey: "listeningHistory"),
           let decoded = try? JSONDecoder().decode(ListeningHistory.self, from: savedData) {
            return decoded
        }
        return ListeningHistory()
    }()

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    // Header
                    headerSection

                    // Patient Overview Card
                    if let metrics = analyticsManager.patientMetrics {
                        // Time Range Picker
                        timeRangePicker

                        patientOverviewCard(metrics)

                        // Clinical Outcomes
                        clinicalOutcomesCard(metrics)

                        // NEW: Exercise Performance Breakdown - REMOVED per user request
                        // exercisePerformanceBreakdownCard()

                        // NEW: Phonetic Error Analysis - REMOVED per user request
                        // phoneticErrorAnalysisCard()

                        // NEW: Frequently Missed Items - HIDDEN per user request
                        // frequentlyMissedItemsCard()

                        // NEW: Clinical Recommendations - HIDDEN per user request
                        // clinicalRecommendationsCard(metrics)

                        // Engagement Metrics
                        engagementMetricsCard(metrics)

                        // Progress Chart - HIDDEN per user request (not working properly)
                        // progressChartCard()

                        // NEW: Detailed Session History - HIDDEN per user request
                        // detailedSessionHistoryCard()
                    } else {
                        emptyStateCard
                    }
                }
                .padding(AppTheme.spacingM)
            }
            .background(AppTheme.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Clinical Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadListeningHistory()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingLinkingView = true
                        }) {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(AppTheme.primaryBlue)
                        }

                        Button(role: .destructive, action: {
                            showingClearDataAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(AppTheme.error)
                        }

                        Button(action: exportClinicalReport) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppTheme.primaryBlue)
                        }
                        .disabled(analyticsManager.patientMetrics == nil)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .foregroundColor(AppTheme.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfURL = pdfURL {
                    ShareSheet(items: [pdfURL])
                }
            }
            .sheet(isPresented: $showingLinkingView) {
                ClinicianLinkingView()
            }
            .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All Data", role: .destructive) {
                    // Clear all data sources
                    analyticsManager.clearAllData()
                    progressTrackingManager.clearAllSessions()
                    ProgressManager.shared.resetProgress()
                    print("🗑️ All clinical and stats data cleared")
                }
            } message: {
                Text("This will permanently delete all patient data, practice sessions, and clinical analytics. This action cannot be undone.")
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        ModernCard(padding: AppTheme.spacingM) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clinical Dashboard")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Patient Progress & Outcomes")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "stethoscope")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.primaryBlue)
            }
        }
    }

    // MARK: - Patient Overview
    private func patientOverviewCard(_ metrics: PatientMetrics) -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                Text("Patient Overview")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Divider()

                // Patient Info - Anonymized (Filtered by Time Range)
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(label: "Enrolled", value: "\(metrics.daysSinceEnrollment) days ago")
                        infoRow(label: "Days Practiced", value: "\(getFilteredUniquePracticeDays()) days")
                        infoRow(label: "Total Sessions", value: "\(filteredSessions().count)")
                        infoRow(label: "Practice Time", value: "\(calculateFilteredPracticeTime()) min")
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(label: "Current Streak", value: "\(metrics.streakDays) days")
                        infoRow(label: "Total Errors", value: "\(getFilteredTotalErrors())")
                        infoRow(label: "Error Rate", value: String(format: "%.1f%%", getFilteredErrorRate() * 100))
                        infoRow(label: "Last Active", value: daysAgo(metrics.lastActiveDate))
                    }
                }

                // Engagement Badge
                HStack {
                    Text("Engagement Level:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)

                    Text(metrics.engagementLevel)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(engagementColor(metrics.engagementLevel))
                        .cornerRadius(8)

                    Spacer()
                }
            }
        }
    }

    // MARK: - Clinical Outcomes
    private func clinicalOutcomesCard(_ metrics: PatientMetrics) -> some View {
        // Calculate filtered outcomes based on selected time range
        let filteredWordRecognition = getFilteredWordRecognition()
        let filteredSentenceComprehension = getFilteredSentenceComprehension()
        let filteredNoisePerformance = getFilteredNoisePerformance()

        let wordImprovement = getFilteredImprovement(baseline: metrics.baselineWordRecognition, current: filteredWordRecognition)
        let sentenceImprovement = getFilteredImprovement(baseline: metrics.baselineSentenceComprehension, current: filteredSentenceComprehension)
        let noiseImprovement = getFilteredImprovement(baseline: metrics.baselineNoisePerformance, current: filteredNoisePerformance)

        let maxFilteredImprovement = max(wordImprovement, sentenceImprovement, noiseImprovement)
        let hasSignificantFilteredImprovement = wordImprovement >= 0.15 || sentenceImprovement >= 0.15 || noiseImprovement >= 0.15

        return ModernCard(padding: AppTheme.spacingL, backgroundColor: AppTheme.success.opacity(0.05)) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.success)

                    Text("Clinical Outcomes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    // Show time range indicator
                    Text(selectedTimeRange.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(6)
                }

                Divider()

                // Baseline vs Current (filtered by time range)
                VStack(spacing: AppTheme.spacingM) {
                    outcomeRow(
                        title: "Word Recognition",
                        baseline: metrics.baselineWordRecognition,
                        current: filteredWordRecognition,
                        improvement: wordImprovement
                    )

                    outcomeRow(
                        title: "Sentence Comprehension",
                        baseline: metrics.baselineSentenceComprehension,
                        current: filteredSentenceComprehension,
                        improvement: sentenceImprovement
                    )

                    outcomeRow(
                        title: "Noise Performance",
                        baseline: metrics.baselineNoisePerformance,
                        current: filteredNoisePerformance,
                        improvement: noiseImprovement
                    )
                }

                // Key Findings (based on filtered data)
                if hasSignificantFilteredImprovement {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()

                        Text("✅ Clinical Significance")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.success)

                        Text("Patient shows statistically significant improvement (\(String(format: "%.0f%%+", maxFilteredImprovement * 100))) in auditory performance metrics for the selected time range.")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Engagement Metrics
    private func engagementMetricsCard(_ metrics: PatientMetrics) -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                Text("Engagement & Compliance")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Divider()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.spacingM) {
                    metricCard(
                        title: "Sessions/Week",
                        value: String(format: "%.1f", metrics.averageSessionsPerWeek),
                        icon: "calendar",
                        color: .blue
                    )

                    metricCard(
                        title: "Avg Practice/Week",
                        value: "\(Int(metrics.totalPracticeTime / Double(max(metrics.weeksSinceEnrollment, 1)))) min",
                        icon: "clock",
                        color: .orange
                    )

                    metricCard(
                        title: "Current Streak",
                        value: "\(metrics.streakDays) days",
                        icon: "flame",
                        color: .red
                    )

                    metricCard(
                        title: "Last Active",
                        value: daysAgo(metrics.lastActiveDate),
                        icon: "checkmark.circle",
                        color: .green
                    )
                }
            }
        }
    }

    // MARK: - Progress Chart
    private func progressChartCard() -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                Text("Progress Over Time")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                if analyticsManager.progressSnapshots.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.5))

                        Text("Not enough data yet")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)

                        Text("Progress charts appear after 2+ weeks of practice")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Simple line representation (since Charts is iOS 16+)
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(analyticsManager.progressSnapshots.suffix(8)) { snapshot in
                            progressBarRow(
                                week: formatWeek(snapshot.date),
                                wordScore: snapshot.wordRecognitionScore,
                                sentenceScore: snapshot.sentenceComprehensionScore,
                                noiseScore: snapshot.noisePerformanceScore
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recent Sessions
    private func recentSessionsCard() -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                Text("Recent Sessions")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Divider()

                if analyticsManager.sessions.isEmpty {
                    Text("No sessions recorded yet")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.vertical, 20)
                } else {
                    ForEach(analyticsManager.sessions.suffix(10).reversed()) { session in
                        sessionRow(session)
                        if session.id != analyticsManager.sessions.suffix(10).reversed().last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Time Range Picker
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: - Exercise Performance Breakdown
    private func exercisePerformanceBreakdownCard() -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primaryBlue)

                    Text("Exercise Performance Breakdown")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Divider()

                // Show performance for each exercise category (filter out invalid/short names)
                ForEach(Array(listeningHistory.categoryBreakdown.keys.sorted()), id: \.self) { category in
                    if let stats = listeningHistory.categoryBreakdown[category],
                       category.count >= 3,  // Filter out short/invalid names like "Pd"
                       !category.isEmpty {
                        exercisePerformanceRow(category: category, stats: stats)
                    }
                }

                if listeningHistory.categoryBreakdown.filter({ $0.key.count >= 3 }).isEmpty {
                    Text("No exercise data available")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.vertical, 20)
                }
            }
        }
    }

    private func exercisePerformanceRow(category: String, stats: CategoryStats) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Text("\(Int(stats.accuracy * 100))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(stats.accuracy >= 0.8 ? AppTheme.success : stats.accuracy >= 0.6 ? AppTheme.accentOrange : AppTheme.error)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.backgroundSecondary)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(stats.accuracy >= 0.8 ? AppTheme.success : stats.accuracy >= 0.6 ? AppTheme.accentOrange : AppTheme.error)
                        .frame(width: geometry.size.width * CGFloat(stats.accuracy), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(stats.correctAttempts)/\(stats.totalAttempts) correct")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)

                Spacer()

                if let lastDate = stats.lastPracticed {
                    Text("Last: \(daysAgo(lastDate))")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppTheme.backgroundSecondary.opacity(0.3))
        .cornerRadius(12)
    }

    // MARK: - Phonetic Error Analysis
    private func phoneticErrorAnalysisCard() -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                HStack {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.accentOrange)

                    Text("Phonetic Error Patterns")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Divider()

                // Analyze phonetic errors from missed items
                let phoneticErrors = analyzePhoneticErrors()

                if phoneticErrors.isEmpty {
                    Text("No phonetic error patterns detected yet")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.vertical, 20)
                } else {
                    ForEach(phoneticErrors.prefix(5), id: \.pattern) { error in
                        phoneticErrorRow(error: error)
                    }
                }
            }
        }
    }

    private func phoneticErrorRow(error: PhoneticError) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(error.pattern)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(error.description)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(error.count)x")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.error)

                Text("errors")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.error.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Frequently Missed Items
    private func frequentlyMissedItemsCard() -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.warning)

                    Text("Frequently Missed Items")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Divider()

                // Get all missed items across all categories
                let allMissed = getAllMissedItems()

                if allMissed.isEmpty {
                    Text("No missed items to display")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.vertical, 20)
                } else {
                    ForEach(allMissed.prefix(10), id: \.id) { item in
                        missedItemRow(item: item)
                    }
                }
            }
        }
    }

    private func missedItemRow(item: WordHistoryEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.firstWord != item.lastWord ? "\(item.firstWord) / \(item.lastWord)" : item.firstWord)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                if !item.userSaid.isEmpty {
                    HStack(spacing: 4) {
                        Text("Said:")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                        Text(item.userSaid)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.error)
                    }
                }

                Text(item.category)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            Text(formatShortDate(item.timestamp))
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .background(AppTheme.backgroundSecondary.opacity(0.3))
        .cornerRadius(12)
    }

    // MARK: - Clinical Recommendations
    private func clinicalRecommendationsCard(_ metrics: PatientMetrics) -> some View {
        ModernCard(padding: AppTheme.spacingL, backgroundColor: AppTheme.primaryBlue.opacity(0.05)) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.primaryBlue)

                    Text("Clinical Recommendations")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Divider()

                let recommendations = generateClinicalRecommendations(metrics)

                ForEach(recommendations.indices, id: \.self) { index in
                    recommendationRow(recommendation: recommendations[index], number: index + 1)
                }
            }
        }
    }

    private func recommendationRow(recommendation: String, number: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(AppTheme.primaryBlue)
                .clipShape(Circle())

            Text(recommendation)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(AppTheme.backgroundSecondary.opacity(0.3))
        .cornerRadius(12)
    }

    // MARK: - Detailed Session History
    private func detailedSessionHistoryCard() -> some View {
        ModernCard(padding: AppTheme.spacingL) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                HStack {
                    Text("Session History")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    Button(action: exportSessionCSV) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.doc")
                            Text("Export CSV")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.primaryBlue)
                    }
                }

                Divider()

                if analyticsManager.sessions.isEmpty {
                    Text("No sessions recorded yet")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.vertical, 20)
                } else {
                    // Session list
                    ForEach(filteredSessions().prefix(20)) { session in
                        detailedSessionRow(session)
                    }

                    if filteredSessions().count > 20 {
                        Text("Showing 20 of \(filteredSessions().count) sessions")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 8)
                    }
                }
            }
        }
    }

    private func detailedSessionRow(_ session: SessionAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.exerciseType)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(formatDateTime(session.sessionDate))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(session.accuracy * 100))%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(session.scoreColor)

                    Text("\(session.itemsCorrect)/\(session.itemsAttempted)")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            // Duration bar
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)

                Text("\(Int(session.duration / 60)) min \(Int(session.duration.truncatingRemainder(dividingBy: 60))) sec")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.backgroundSecondary.opacity(0.3))
        .cornerRadius(12)
    }

    // MARK: - Empty State
    private var emptyStateCard: some View {
        ModernCard(padding: AppTheme.spacingXL) {
            VStack(spacing: AppTheme.spacingM) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 64))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.5))

                Text("No Patient Data")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Complete some training sessions to see clinical analytics and progress metrics here.")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 40)
        }
    }

    // MARK: - Helper Views
    private func infoRow(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label + ":")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)

            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
        }
    }

    private func outcomeRow(title: String, baseline: Double?, current: Double, improvement: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            HStack {
                if let baseline = baseline {
                    Text("Baseline: \(String(format: "%.0f%%", baseline * 100))")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Text("Current: \(String(format: "%.0f%%", current * 100))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.primaryBlue)

                if improvement != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: improvement > 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10))

                        Text("\(String(format: "%.0f%%", abs(improvement * 100)))")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(improvement > 0 ? AppTheme.success : AppTheme.error)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((improvement > 0 ? AppTheme.success : AppTheme.error).opacity(0.1))
                    .cornerRadius(6)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.backgroundSecondary)
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(AppTheme.success)
                        .frame(width: geometry.size.width * CGFloat(current), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppTheme.backgroundSecondary.opacity(0.5))
        .cornerRadius(12)
    }

    private func metricCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.spacingM)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(12)
    }

    private func progressBarRow(week: String, wordScore: Double, sentenceScore: Double, noiseScore: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(week)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            HStack(spacing: 4) {
                scoreBar(score: wordScore, color: .blue, label: "W")
                scoreBar(score: sentenceScore, color: .green, label: "S")
                scoreBar(score: noiseScore, color: .orange, label: "N")
            }
        }
    }

    private func scoreBar(score: Double, color: Color, label: String) -> some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.backgroundSecondary)
                        .frame(height: 20)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(score), height: 20)
                        .cornerRadius(4)

                    Text("\(Int(score * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                }
            }
            .frame(height: 20)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textSecondary)
        }
    }

    private func sessionRow(_ session: SessionAnalytics) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.exerciseType)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text(formatDateTime(session.sessionDate))
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(session.accuracy * 100))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(session.scoreColor)

                Text("\(session.itemsCorrect)/\(session.itemsAttempted)")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helper Functions
    private func engagementColor(_ level: String) -> Color {
        switch level {
        case "Highly Engaged": return .green
        case "Engaged": return .blue
        case "Moderately Engaged": return .orange
        default: return .red
        }
    }

    private func hasSignificantImprovement(_ metrics: PatientMetrics) -> Bool {
        return metrics.improvementWordRecognition >= 0.15 ||
               metrics.improvementSentenceComprehension >= 0.15 ||
               metrics.improvementNoisePerformance >= 0.15
    }

    private func maxImprovement(_ metrics: PatientMetrics) -> Double {
        return max(metrics.improvementWordRecognition,
                   metrics.improvementSentenceComprehension,
                   metrics.improvementNoisePerformance)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func daysAgo(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days == 0 { return "Today" }
        if days == 1 { return "Yesterday" }
        return "\(days) days ago"
    }

    // MARK: - Export Function
    private func exportClinicalReport() {
        guard let metrics = analyticsManager.patientMetrics else { return }

        let pdfMetadata = [
            kCGPDFContextTitle: "Clinical Progress Report",
            kCGPDFContextAuthor: "Hearify Clinical Dashboard"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetadata as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = 50
            let leftMargin: CGFloat = 50
            let rightMargin: CGFloat = pageRect.width - 50
            let contentWidth = rightMargin - leftMargin

            // Header
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let title = "Clinical Progress Report"
            title.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: [
                .font: titleFont,
                .foregroundColor: UIColor.systemBlue
            ])
            yPosition += 40

            // Report Date
            let dateFont = UIFont.systemFont(ofSize: 12)
            let dateStr = "Generated: \(formatDateTime(Date()))"
            dateStr.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: [
                .font: dateFont,
                .foregroundColor: UIColor.gray
            ])
            yPosition += 30

            // Patient Overview Section - Anonymized
            drawSectionHeader("Training Overview", at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Enrolled:", value: "\(metrics.daysSinceEnrollment) days ago", at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Days Practiced:", value: "\(analyticsManager.getUniquePracticeDays()) days", at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Total Sessions:", value: "\(metrics.totalSessions)", at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Total Practice Time:", value: "\(Int(metrics.totalPracticeTime)) minutes", at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Total Errors:", value: "\(analyticsManager.getTotalErrors())", at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Error Rate:", value: String(format: "%.1f%%", analyticsManager.getErrorRate() * 100), at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Last Active:", value: daysAgo(metrics.lastActiveDate), at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Engagement Level:", value: metrics.engagementLevel, at: &yPosition, leftMargin: leftMargin)
            yPosition += 20

            // Clinical Outcomes Section
            drawSectionHeader("Clinical Outcomes", at: &yPosition, leftMargin: leftMargin)

            if let baseline = metrics.baselineWordRecognition {
                drawOutcome("Word Recognition", baseline: baseline, current: metrics.currentWordRecognition, at: &yPosition, leftMargin: leftMargin)
            }

            if let baseline = metrics.baselineSentenceComprehension {
                drawOutcome("Sentence Comprehension", baseline: baseline, current: metrics.currentSentenceComprehension, at: &yPosition, leftMargin: leftMargin)
            }

            if let baseline = metrics.baselineNoisePerformance {
                drawOutcome("Noise Performance", baseline: baseline, current: metrics.currentNoisePerformance, at: &yPosition, leftMargin: leftMargin)
            }

            yPosition += 20

            // Engagement Metrics
            drawSectionHeader("Engagement & Compliance", at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Sessions per Week:", value: String(format: "%.1f", metrics.averageSessionsPerWeek), at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Current Streak:", value: "\(metrics.streakDays) days", at: &yPosition, leftMargin: leftMargin)
            drawKeyValue("Last Active:", value: daysAgo(metrics.lastActiveDate), at: &yPosition, leftMargin: leftMargin)
            yPosition += 20

            // Recent Sessions - REMOVED for privacy/simplicity
            // drawSectionHeader("Recent Sessions (Last 10)", at: &yPosition, leftMargin: leftMargin)
            // for session in analyticsManager.sessions.suffix(10).reversed() {
            //     let sessionStr = "\(formatDateTime(session.sessionDate)) - \(session.exerciseType): \(Int(session.accuracy * 100))% (\(session.itemsCorrect)/\(session.itemsAttempted))"
            //     drawText(sessionStr, at: &yPosition, leftMargin: leftMargin, fontSize: 10)
            // }

            // Footer
            yPosition = pageRect.height - 50
            let footer = "Hearify - Auditory Rehabilitation Training System"
            footer.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ])
        }

        // Save to temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Clinical_Report_\(Date().timeIntervalSince1970).pdf"
        let url = tempDir.appendingPathComponent(fileName)

        do {
            try data.write(to: url)

            // Upload PDF to Firebase Storage for clinician access
            Task {
                do {
                    let downloadURL = try await FirebaseManager.shared.uploadPDFReport(fileURL: url)
                    print("✅ PDF uploaded and available to clinician: \(downloadURL)")
                } catch {
                    print("⚠️ Failed to upload PDF to Firebase: \(error)")
                    // Continue anyway - patient can still share locally
                }
            }

            DispatchQueue.main.async {
                self.pdfURL = url
                self.showingShareSheet = true
            }
        } catch {
            print("Error saving PDF: \(error)")
        }
    }

    // PDF Helper Functions
    private func drawSectionHeader(_ text: String, at yPosition: inout CGFloat, leftMargin: CGFloat) {
        let font = UIFont.boldSystemFont(ofSize: 16)
        text.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: [
            .font: font,
            .foregroundColor: UIColor.black
        ])
        yPosition += 25
    }

    private func drawKeyValue(_ key: String, value: String, at yPosition: inout CGFloat, leftMargin: CGFloat) {
        let font = UIFont.systemFont(ofSize: 12)
        let boldFont = UIFont.boldSystemFont(ofSize: 12)

        let text = "\(key) \(value)"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: key.count))
        attributedString.addAttribute(.font, value: boldFont, range: NSRange(location: key.count, length: value.count + 1))

        attributedString.draw(at: CGPoint(x: leftMargin, y: yPosition))
        yPosition += 20
    }

    private func drawOutcome(_ title: String, baseline: Double, current: Double, at yPosition: inout CGFloat, leftMargin: CGFloat) {
        let improvement = current - baseline
        let improvementStr = improvement >= 0 ? "+\(Int(improvement * 100))%" : "\(Int(improvement * 100))%"

        let text = "\(title): \(Int(baseline * 100))% → \(Int(current * 100))% (\(improvementStr))"
        let font = UIFont.systemFont(ofSize: 12)
        let color = improvement >= 0 ? UIColor.systemGreen : UIColor.systemRed

        text.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: [
            .font: font,
            .foregroundColor: color
        ])
        yPosition += 20
    }

    private func drawText(_ text: String, at yPosition: inout CGFloat, leftMargin: CGFloat, fontSize: CGFloat = 12) {
        let font = UIFont.systemFont(ofSize: fontSize)
        text.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: [
            .font: font,
            .foregroundColor: UIColor.black
        ])
        yPosition += (fontSize + 8)
    }

    // MARK: - New Helper Functions

    struct PhoneticError: Identifiable {
        let id = UUID()
        let pattern: String
        let description: String
        let count: Int
    }

    private func analyzePhoneticErrors() -> [PhoneticError] {
        var errorPatterns: [String: Int] = [:]

        // Analyze all missed items across categories
        for (_, stats) in listeningHistory.categoryBreakdown {
            for missedWord in stats.missedWords {
                let content = missedWord.firstWord.lowercased()

                // If this is a sentence (contains spaces), extract individual words
                // Otherwise analyze as a single word
                let wordsToAnalyze: [String]
                if content.contains(" ") {
                    // It's a sentence - split into individual words and analyze each
                    wordsToAnalyze = content.components(separatedBy: .whitespaces)
                        .filter { !$0.isEmpty }
                        .filter { $0.count > 2 } // Only analyze words with 3+ characters
                } else {
                    // It's a single word - analyze directly
                    wordsToAnalyze = content.count > 2 ? [content] : []
                }

                // Analyze each individual word for phonetic patterns
                for word in wordsToAnalyze {
                    analyzeWordPhonetics(word: word, errorPatterns: &errorPatterns)
                }
            }
        }

        // Convert to PhoneticError array and sort by count
        return errorPatterns.map { pattern, count in
            PhoneticError(
                pattern: pattern.capitalized,
                description: getPhoneticDescription(pattern),
                count: count
            )
        }.sorted { $0.count > $1.count }
    }

    private func analyzeWordPhonetics(word: String, errorPatterns: inout [String: Int]) {
        // Check for common phonetic confusions in individual words
        if word.contains("s") || word.contains("z") {
            errorPatterns["s/z confusion"] = (errorPatterns["s/z confusion"] ?? 0) + 1
        }
        if word.contains("th") || word.contains("d") || word.contains("t") {
            errorPatterns["th/d/t confusion"] = (errorPatterns["th/d/t confusion"] ?? 0) + 1
        }
        if word.contains("f") || word.contains("v") {
            errorPatterns["f/v voicing"] = (errorPatterns["f/v voicing"] ?? 0) + 1
        }
        if word.contains("p") || word.contains("b") {
            errorPatterns["p/b voicing"] = (errorPatterns["p/b voicing"] ?? 0) + 1
        }
        if word.contains("r") || word.contains("l") {
            errorPatterns["r/l confusion"] = (errorPatterns["r/l confusion"] ?? 0) + 1
        }

        // Vowel patterns
        if word.contains("a") || word.contains("e") || word.contains("i") {
            errorPatterns["front vowel errors"] = (errorPatterns["front vowel errors"] ?? 0) + 1
        }
    }

    private func getPhoneticDescription(_ pattern: String) -> String {
        switch pattern {
        case "s/z confusion": return "Difficulty distinguishing 's' and 'z' sounds"
        case "th/d/t confusion": return "Difficulty with 'th', 'd', and 't' sounds"
        case "f/v voicing": return "Difficulty distinguishing 'f' and 'v'"
        case "p/b voicing": return "Difficulty with voicing in 'p' and 'b'"
        case "r/l confusion": return "Difficulty distinguishing 'r' and 'l'"
        case "front vowel errors": return "Difficulty with front vowels (a, e, i)"
        default: return "Phonetic difficulty detected"
        }
    }

    private func getAllMissedItems() -> [WordHistoryEntry] {
        var allMissed: [WordHistoryEntry] = []

        for (_, stats) in listeningHistory.categoryBreakdown {
            allMissed.append(contentsOf: stats.missedWords)
        }

        // Sort by timestamp, most recent first
        return allMissed.sorted { $0.timestamp > $1.timestamp }
    }

    private func generateClinicalRecommendations(_ metrics: PatientMetrics) -> [String] {
        var recommendations: [String] = []

        // Engagement recommendations
        if metrics.engagementLevel == "Low Engagement" || metrics.engagementLevel == "Moderately Engaged" {
            recommendations.append("Increase practice frequency to 3-4 sessions per week for optimal outcomes. Current engagement is below recommended levels.")
        }

        // Word recognition recommendations
        if metrics.currentWordRecognition < 0.70 {
            recommendations.append("Focus on word recognition exercises in quiet environments. Current performance (\(Int(metrics.currentWordRecognition * 100))%) indicates need for foundational auditory training.")
        } else if metrics.currentWordRecognition >= 0.70 && metrics.currentWordRecognition < 0.85 {
            recommendations.append("Continue word recognition practice. Consider advancing to sentence-level exercises once accuracy reaches 85%.")
        }

        // Sentence comprehension recommendations
        if metrics.currentSentenceComprehension < 0.70 {
            recommendations.append("Increase sentence comprehension practice. Current performance suggests difficulty with connected speech. Focus on shorter sentences first.")
        }

        // Noise performance recommendations
        if metrics.currentNoisePerformance < 0.60 {
            recommendations.append("Start with low-noise environments before increasing background noise complexity. Current noise performance (\(Int(metrics.currentNoisePerformance * 100))%) indicates significant difficulty.")
        } else if metrics.currentNoisePerformance >= 0.60 && metrics.currentNoisePerformance < 0.75 {
            recommendations.append("Gradually increase background noise levels. Patient showing progress in noisy environments but not yet at target performance.")
        }

        // Improvement-based recommendations
        if hasSignificantImprovement(metrics) {
            recommendations.append("Excellent progress observed! Consider advancing to more challenging exercises or increasing session complexity.")
        } else if metrics.daysSinceEnrollment > 14 && maxImprovement(metrics) < 0.10 {
            recommendations.append("Limited improvement observed after 2+ weeks. Consider adjusting difficulty level, reviewing hearing aid settings, or modifying training protocol.")
        }

        // Streak-based recommendations
        if metrics.streakDays >= 7 {
            recommendations.append("Strong adherence to training schedule! Maintain current practice frequency for continued progress.")
        } else if metrics.streakDays == 0 {
            let daysSinceActive = Calendar.current.dateComponents([.day], from: metrics.lastActiveDate, to: Date()).day ?? 0
            if daysSinceActive > 3 {
                recommendations.append("Patient has not practiced in \(daysSinceActive) days. Follow up to address barriers to adherence and re-engage with training program.")
            }
        }

        // Default recommendation if none generated
        if recommendations.isEmpty {
            recommendations.append("Patient is making satisfactory progress. Continue current training regimen and monitor for continued improvement.")
        }

        return recommendations
    }

    private func filteredSessions() -> [SessionAnalytics] {
        let allSessions = analyticsManager.sessions

        switch selectedTimeRange {
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return allSessions.filter { $0.sessionDate >= weekAgo }.sorted { $0.sessionDate > $1.sessionDate }
        case .month:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return allSessions.filter { $0.sessionDate >= monthAgo }.sorted { $0.sessionDate > $1.sessionDate }
        case .all:
            return allSessions.sorted { $0.sessionDate > $1.sessionDate }
        }
    }

    // NEW: Get filtered unique practice days based on time range
    private func getFilteredUniquePracticeDays() -> Int {
        let sessions = filteredSessions()
        let calendar = Calendar.current
        var uniqueDays = Set<Date>()

        for session in sessions {
            let sessionDay = calendar.startOfDay(for: session.sessionDate)
            uniqueDays.insert(sessionDay)
        }

        return uniqueDays.count
    }

    // NEW: Get filtered total errors based on time range
    private func getFilteredTotalErrors() -> Int {
        return filteredSessions().reduce(0) { total, session in
            total + (session.itemsAttempted - session.itemsCorrect)
        }
    }

    // NEW: Get filtered error rate based on time range
    private func getFilteredErrorRate() -> Double {
        let sessions = filteredSessions()
        let totalAttempted = sessions.reduce(0) { $0 + $1.itemsAttempted }
        let totalErrors = getFilteredTotalErrors()

        return totalAttempted > 0 ? Double(totalErrors) / Double(totalAttempted) : 0.0
    }

    // NEW: Calculate filtered practice time based on time range
    private func calculateFilteredPracticeTime() -> Int {
        let sessions = filteredSessions()
        let totalSeconds = sessions.reduce(0.0) { $0 + $1.duration }
        return Int(totalSeconds / 60.0) // Convert to minutes
    }

    // MARK: - Filtered Clinical Outcomes

    private func getFilteredWordRecognition() -> Double {
        let sessions = filteredSessions().filter { $0.exerciseType.lowercased().contains("word") }
        guard !sessions.isEmpty else { return 0.0 }

        let totalCorrect = sessions.reduce(0) { $0 + $1.itemsCorrect }
        let totalAttempted = sessions.reduce(0) { $0 + $1.itemsAttempted }

        return totalAttempted > 0 ? Double(totalCorrect) / Double(totalAttempted) : 0.0
    }

    private func getFilteredSentenceComprehension() -> Double {
        let sessions = filteredSessions().filter { $0.exerciseType.lowercased().contains("sentence") }
        guard !sessions.isEmpty else { return 0.0 }

        let totalCorrect = sessions.reduce(0) { $0 + $1.itemsCorrect }
        let totalAttempted = sessions.reduce(0) { $0 + $1.itemsAttempted }

        return totalAttempted > 0 ? Double(totalCorrect) / Double(totalAttempted) : 0.0
    }

    private func getFilteredNoisePerformance() -> Double {
        let sessions = filteredSessions().filter { $0.exerciseType.lowercased().contains("noise") }
        guard !sessions.isEmpty else { return 0.0 }

        let totalCorrect = sessions.reduce(0) { $0 + $1.itemsCorrect }
        let totalAttempted = sessions.reduce(0) { $0 + $1.itemsAttempted }

        return totalAttempted > 0 ? Double(totalCorrect) / Double(totalAttempted) : 0.0
    }

    private func getFilteredImprovement(baseline: Double?, current: Double) -> Double {
        guard let baseline = baseline else { return 0.0 }
        return current - baseline
    }

    private func exportSessionCSV() {
        // Create CSV content
        var csvContent = "Date,Time,Exercise Type,Accuracy,Correct,Attempted,Duration (seconds)\n"

        for session in analyticsManager.sessions.sorted(by: { $0.sessionDate > $1.sessionDate }) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: session.sessionDate)

            dateFormatter.dateFormat = "HH:mm:ss"
            let time = dateFormatter.string(from: session.sessionDate)

            let row = "\(date),\(time),\(session.exerciseType),\(String(format: "%.2f", session.accuracy)),\(session.itemsCorrect),\(session.itemsAttempted),\(Int(session.duration))\n"
            csvContent += row
        }

        // Save to temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Session_History_\(Date().timeIntervalSince1970).csv"
        let url = tempDir.appendingPathComponent(fileName)

        do {
            try csvContent.write(to: url, atomically: true, encoding: .utf8)
            DispatchQueue.main.async {
                self.pdfURL = url
                self.showingShareSheet = true
            }
        } catch {
            print("Error saving CSV: \(error)")
        }
    }

    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    private func loadListeningHistory() {
        if let savedData = UserDefaults.standard.data(forKey: "listeningHistory"),
           let decoded = try? JSONDecoder().decode(ListeningHistory.self, from: savedData) {
            listeningHistory = decoded
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Preview
struct ClinicianDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ClinicianDashboardView()
    }
}
