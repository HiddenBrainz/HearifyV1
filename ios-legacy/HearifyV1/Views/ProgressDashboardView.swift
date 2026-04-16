//
//  ProgressDashboardView.swift
//  HearifyV1
//
//  Progress tracking dashboard with charts and statistics
//

import SwiftUI

struct ProgressDashboardView: View {
    @ObservedObject var progressManager: ProgressTrackingManager
    @ObservedObject var gamificationManager: GamificationManager
    @ObservedObject var analyticsManager: AnalyticsManager
    @State private var selectedPeriod: TimePeriod = .week
    @State private var showingClearDataAlert = false
    var onDismiss: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { onDismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Your Progress")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 12) {
                    // Direct Clear Data Button
                    Button(action: {
                        showingClearDataAlert = true
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.red.opacity(0.3)))
                    }
                }
            }
            .padding()
            .background(AppTheme.primaryGradient)

            ScrollView {
                VStack(spacing: 16) {
                    // Period Selector
                    periodSelector

                    // Stats Cards
                    statsCards

                    // Score Trend Chart
                    scoreTrendChart

                    // Exercise Type Breakdown
                    exerciseTypeBreakdown

                    // Best Performances
                    bestPerformances

                    // Most Practiced
                    mostPracticed
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
        .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All Data", role: .destructive) {
                // Clear all data sources
                progressManager.clearAllSessions()
                analyticsManager.clearAllData()
                ProgressManager.shared.resetProgress()
                print("🗑️ All stats and clinical data cleared")
            }
        } message: {
            Text("This will permanently delete all your practice sessions, stats, and clinical data. This action cannot be undone.")
        }
        .onAppear {
            // Refresh daily stats when dashboard appears (for performance, we don't calculate on every session)
            progressManager.dailyStats = progressManager.getScoreTrend(for: .month)
            print("📊 Dashboard loaded - refreshing stats")
        }
    }

    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 8) {
            ForEach([TimePeriod.week, .month, .allTime], id: \.self) { period in
                Button(action: {
                    selectedPeriod = period
                }) {
                    Text(periodLabel(period))
                        .font(.system(size: 14, weight: selectedPeriod == period ? .bold : .regular))
                        .foregroundColor(selectedPeriod == period ? .white : AppTheme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedPeriod == period ?
                            AppTheme.primaryGradient :
                            LinearGradient(colors: [AppTheme.backgroundSecondary], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(20)
                }
            }
        }
    }

    // MARK: - Stats Cards
    private var statsCards: some View {
        HStack(spacing: 12) {
            // Average Score
            StatCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Avg Score",
                value: "\(Int(progressManager.getAverageScore(for: selectedPeriod) * 100))%",
                color: AppTheme.success
            )

            // Total Sessions
            StatCard(
                icon: "flame.fill",
                title: "Sessions",
                value: "\(progressManager.getSessionsForPeriod(selectedPeriod).count)",
                color: AppTheme.accentOrange
            )

            // Current Streak
            StatCard(
                icon: "calendar",
                title: "Streak",
                value: "\(gamificationManager.currentStreak)",
                color: AppTheme.info
            )
        }
    }

    // MARK: - Score Trend Chart
    private var scoreTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .foregroundColor(AppTheme.primaryBlue)
                Text("Score Trend")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            let trend = progressManager.getScoreTrend(for: selectedPeriod)

            if trend.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.textTertiary)
                    Text("No data yet")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                    Text("Complete some exercises to see your progress!")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Simple line chart
                SimpleLineChart(dataPoints: trend.map { $0.averageScore })
                    .frame(height: 150)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Exercise Type Breakdown
    private var exerciseTypeBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(AppTheme.accentOrange)
                Text("By Exercise Type")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            let stats = progressManager.getStatsByType()

            ForEach(stats, id: \.type) { stat in
                HStack {
                    Image(systemName: iconForType(stat.type))
                        .foregroundColor(colorForType(stat.type))
                        .frame(width: 24)

                    Text(stat.type.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(stat.avgScore * 100))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(colorForType(stat.type))
                        Text("\(stat.count) sessions")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Best Performances
    private var bestPerformances: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(AppTheme.warning)
                Text("Best Performances")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            let best = progressManager.getBestExercises(limit: 5)

            if best.isEmpty {
                Text("No sessions yet")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(best) { session in
                    VStack(spacing: 6) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.exerciseText)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text(formatDate(session.date))
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.textSecondary)
                            }

                            Spacer(minLength: 12)

                            Text("\(Int(session.score * 100))%")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.success)
                                .fixedSize()
                        }
                        
                        if session != best.last {
                            Divider()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Most Practiced
    private var mostPracticed: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "repeat")
                    .foregroundColor(AppTheme.info)
                Text("Most Practiced")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            let most = progressManager.getMostPracticedExercises(limit: 5)

            if most.isEmpty {
                Text("No sessions yet")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(most, id: \.text) { item in
                    VStack(spacing: 6) {
                        HStack(alignment: .center) {
                            Text(item.text)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: 12)

                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                    .font(.system(size: 12))
                                Text("\(item.count)×")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(AppTheme.info)
                            .fixedSize()
                        }
                        
                        if item.text != most.last?.text {
                            Divider()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Helper Methods
    private func periodLabel(_ period: TimePeriod) -> String {
        switch period {
        case .today: return "Today"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        case .allTime: return "All Time"
        }
    }

    private func iconForType(_ type: ExerciseType) -> String {
        switch type {
        case .word: return "textformat.size"
        case .sentence: return "quote.bubble.fill"
        case .conversation: return "bubble.left.and.bubble.right.fill"
        }
    }

    private func colorForType(_ type: ExerciseType) -> Color {
        switch type {
        case .word: return AppTheme.accentOrange
        case .sentence: return AppTheme.info
        case .conversation: return AppTheme.accentPurple
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }
}

// MARK: - Simple Line Chart
struct SimpleLineChart: View {
    let dataPoints: [Double]

    var body: some View {
        GeometryReader { geometry in
            let maxValue = dataPoints.max() ?? 1.0
            let minValue = dataPoints.min() ?? 0.0
            let range = maxValue - minValue
            let normalizedRange = range == 0 ? 1.0 : range

            ZStack {
                // Grid lines
                ForEach(0..<5) { i in
                    let y = CGFloat(i) * geometry.size.height / 4
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(AppTheme.backgroundSecondary, lineWidth: 1)
                }

                // Line chart
                Path { path in
                    guard !dataPoints.isEmpty else { return }

                    let stepX = geometry.size.width / CGFloat(max(dataPoints.count - 1, 1))

                    for (index, value) in dataPoints.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedValue = (value - minValue) / normalizedRange
                        let y = geometry.size.height - (CGFloat(normalizedValue) * geometry.size.height)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(AppTheme.primaryBlue, lineWidth: 3)

                // Data points
                ForEach(0..<dataPoints.count, id: \.self) { index in
                    let value = dataPoints[index]
                    let x = CGFloat(index) * (geometry.size.width / CGFloat(max(dataPoints.count - 1, 1)))
                    let normalizedValue = (value - minValue) / normalizedRange
                    let y = geometry.size.height - (CGFloat(normalizedValue) * geometry.size.height)

                    Circle()
                        .fill(AppTheme.primaryBlue)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
    }
}
