//
//  RecordingHistoryView.swift
//  HearifyV1
//
//  View past pronunciation attempts and compare progress
//

import SwiftUI
import AVFoundation

struct RecordingHistoryView: View {
    // Use shared instance to avoid creating duplicates (performance issue)
    @ObservedObject private var progressManager = ProgressTrackingManager.shared
    @State private var selectedExercise: String?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var groupBy: GroupingOption = .exercise
    var onDismiss: () -> Void = {}

    enum GroupingOption {
        case exercise
        case date
        case score
    }

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

                Text("Recording History")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Menu {
                    Button(action: { groupBy = .exercise }) {
                        Label("By Exercise", systemImage: "text.alignleft")
                    }
                    Button(action: { groupBy = .date }) {
                        Label("By Date", systemImage: "calendar")
                    }
                    Button(action: { groupBy = .score }) {
                        Label("By Score", systemImage: "star.fill")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(AppTheme.primaryGradient)

            if progressManager.allSessions.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        switch groupBy {
                        case .exercise:
                            exerciseGroupedView
                        case .date:
                            dateGroupedView
                        case .score:
                            scoreGroupedView
                        }
                    }
                    .padding()
                }
                .background(AppTheme.backgroundPrimary)
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "waveform.circle")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.textTertiary)

            Text("No Recordings Yet")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text("Complete some pronunciation exercises to see your recording history here")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundPrimary)
    }

    // MARK: - Exercise Grouped View
    private var exerciseGroupedView: some View {
        let grouped = Dictionary(grouping: progressManager.allSessions) { $0.exerciseText }
        let sorted = grouped.sorted { $0.value.count > $1.value.count }

        return ForEach(sorted, id: \.key) { exercise, sessions in
            ExerciseGroupCard(
                exerciseText: exercise,
                sessions: sessions.sorted { $0.date > $1.date },
                selectedExercise: $selectedExercise
            )
        }
    }

    // MARK: - Date Grouped View
    private var dateGroupedView: some View {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: progressManager.allSessions) { session in
            calendar.startOfDay(for: session.date)
        }
        let sorted = grouped.sorted { $0.key > $1.key }

        return ForEach(sorted, id: \.key) { date, sessions in
            VStack(alignment: .leading, spacing: 12) {
                Text(formatDate(date))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal)

                ForEach(sessions.sorted { $0.date > $1.date }) { session in
                    SessionCard(session: session)
                }
            }
        }
    }

    // MARK: - Score Grouped View
    private var scoreGroupedView: some View {
        let sorted = progressManager.allSessions.sorted { $0.score > $1.score }

        return ForEach(sorted) { session in
            SessionCard(session: session)
        }
    }

    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Exercise Group Card
struct ExerciseGroupCard: View {
    let exerciseText: String
    let sessions: [PracticeSession]
    @Binding var selectedExercise: String?

    @State private var isExpanded = false

    private var averageScore: Double {
        sessions.isEmpty ? 0 : sessions.reduce(0.0) { $0 + $1.score } / Double(sessions.count)
    }

    private var improvementRate: Double {
        guard sessions.count >= 2 else { return 0 }
        let firstScore = sessions.last?.score ?? 0
        let lastScore = sessions.first?.score ?? 0
        return lastScore - firstScore
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header - Tap to expand/collapse
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exerciseText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        HStack(spacing: 12) {
                            Label("\(sessions.count) attempts", systemImage: "repeat")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)

                            Label("\(Int(averageScore * 100))% avg", systemImage: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)

                            if improvementRate != 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: improvementRate > 0 ? "arrow.up" : "arrow.down")
                                    Text("\(abs(Int(improvementRate * 100)))%")
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(improvementRate > 0 ? AppTheme.success : AppTheme.error)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppTheme.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }
            }

            // Expanded - Show all attempts
            if isExpanded {
                Divider()

                ForEach(sessions) { session in
                    SessionCard(session: session, compact: true)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }
}

// MARK: - Session Card
struct SessionCard: View {
    let session: PracticeSession
    var compact: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false

    var body: some View {
        HStack {
            // Score circle
            ZStack {
                Circle()
                    .stroke(AppTheme.backgroundSecondary, lineWidth: 4)
                    .frame(width: compact ? 40 : 50, height: compact ? 40 : 50)

                Circle()
                    .trim(from: 0, to: session.score)
                    .stroke(scoreColor(session.score), lineWidth: 4)
                    .frame(width: compact ? 40 : 50, height: compact ? 40 : 50)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(session.score * 100))%")
                    .font(.system(size: compact ? 10 : 12, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                if !compact {
                    Text(session.exerciseText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                }

                Text(formatDateTime(session.date))
                    .font(.system(size: compact ? 11 : 12))
                    .foregroundColor(AppTheme.textSecondary)

                if !compact {
                    Text("Recognized: \(session.recognizedText)")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Type badge
            Image(systemName: iconForType(session.exerciseType))
                .font(.system(size: compact ? 14 : 16))
                .foregroundColor(colorForType(session.exerciseType))
        }
        .padding(compact ? 8 : 12)
        .background(compact ? AppTheme.backgroundSecondary : Color.white)
        .cornerRadius(8)
        .if(!compact) { view in
            view.shadow(color: .black.opacity(0.1), radius: 4)
        }
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.9 { return AppTheme.success }
        else if score >= 0.7 { return AppTheme.warning }
        else { return AppTheme.error }
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
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
