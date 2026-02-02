//
//  ConversationScenarioView.swift
//  HearifyV1
//
//  Interactive conversation scenario execution
//  Phase 3: Conversation/Context Module
//

import SwiftUI

struct ConversationScenarioView: View {
    let scenario: ConversationScenario
    var onDismiss: () -> Void

    @StateObject private var speechManager = SpeechRecognitionManagerAdvanced()
    // Use shared instance to avoid creating duplicates (performance issue)
    @ObservedObject private var gamificationManager = GamificationManager.shared
    @State private var currentTurnIndex = 0
    @State private var conversationHistory: [ConversationHistoryItem] = []
    @State private var showResults = false
    @State private var isRecording = false
    @State private var showPermissionAlert = false
    @State private var turnResults: [TurnResult] = []
    @State private var scenarioStartTime: Date?

    private var currentTurn: ConversationTurn? {
        currentTurnIndex < scenario.turns.count ? scenario.turns[currentTurnIndex] : nil
    }

    private var isComplete: Bool {
        currentTurnIndex >= scenario.turns.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            if isComplete {
                // Results View
                resultsView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Context Card
                        contextCard

                        // Conversation History
                        conversationHistoryView

                        // Current Turn
                        if let turn = currentTurn {
                            currentTurnView(turn)
                        }

                        // Recording Controls (for user turns)
                        if currentTurn?.speaker == .user {
                            recordingControls
                        }
                    }
                    .padding()
                }
                .background(AppTheme.backgroundPrimary)
            }
        }
        .onAppear {
            scenarioStartTime = Date()
        }
        .alert("Microphone Permission Required", isPresented: $showPermissionAlert) {
            Button("OK") {
                showPermissionAlert = false
            }
        } message: {
            Text("Please grant microphone and speech recognition permissions in Settings.")
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

            VStack(spacing: 2) {
                Text(scenario.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text("Turn \(currentTurnIndex + 1) of \(scenario.turns.count)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // Progress indicator
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                    .frame(width: 36, height: 36)

                Circle()
                    .trim(from: 0, to: CGFloat(currentTurnIndex) / CGFloat(scenario.turns.count))
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(Double(currentTurnIndex) / Double(scenario.turns.count) * 100))%")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(AppTheme.primaryGradient)
    }

    // MARK: - Context Card
    private var contextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppTheme.info)
                Text("Scenario Context")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            Text(scenario.context)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)

            if let turn = currentTurn, !turn.context.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Right Now:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(turn.context)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Conversation History
    private var conversationHistoryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !conversationHistory.isEmpty {
                Text("Conversation")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                ForEach(conversationHistory) { item in
                    conversationBubble(item)
                }
            }
        }
    }

    // MARK: - Current Turn View
    private func currentTurnView(_ turn: ConversationTurn) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: turn.speaker == .user ? "person.circle.fill" : "person.circle")
                    .foregroundColor(turn.speaker == .user ? AppTheme.primaryBlue : AppTheme.accentPurple)
                Text(turn.speaker == .user ? "Your Turn" : "Other Person")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            if turn.speaker == .other {
                // Show what the other person says
                Text(turn.text)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding()
                    .background(AppTheme.accentPurple.opacity(0.1))
                    .cornerRadius(12)

                // Play audio button
                Button(action: {
                    speechManager.playCorrectPronunciation(text: turn.text)
                }) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Hear Pronunciation")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.accentPurple)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppTheme.accentPurple, lineWidth: 2)
                    )
                }

                // Continue button
                Button(action: {
                    advanceToNextTurn(userResponse: nil, score: 1.0)
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(10)
                }
            } else {
                // Show what user should say
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested Response:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)

                    Text(turn.text)
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.info.opacity(0.1))
                        .cornerRadius(8)

                    if !turn.tip.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(AppTheme.warning)
                            Text(turn.tip)
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(8)
                        .background(AppTheme.warning.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }

            // Show results if just recorded
            if showResults, let result = speechManager.pronunciationResult {
                resultCard(result)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Recording Controls
    private var recordingControls: some View {
        VStack(spacing: 12) {
            Button(action: {
                if speechManager.isRecording {
                    speechManager.stopRecording()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showResults = true
                    }
                } else {
                    if !speechManager.isAuthorized {
                        showPermissionAlert = true
                        speechManager.requestAuthorization()
                    } else {
                        guard let turn = currentTurn else { return }
                        speechManager.startRecording(expectedText: turn.text)
                    }
                }
            }) {
                Circle()
                    .fill(speechManager.isRecording ? AppTheme.error : AppTheme.success)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .shadow(radius: 8)
            }

            Text(speechManager.isRecording ? "Recording..." : "Tap to Record")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            if speechManager.isRecording {
                Text(speechManager.recognizedText.isEmpty ? "Listening..." : speechManager.recognizedText)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.backgroundSecondary)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    // MARK: - Result Card
    private func resultCard(_ result: PronunciationResult) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Response")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)

                    Text(result.recognizedText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                // Score
                VStack(spacing: 2) {
                    Text("\(Int(result.overallScore * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(scoreColor(result.overallScore))

                    Text("Score")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Button(action: {
                advanceToNextTurn(userResponse: result.recognizedText, score: result.overallScore)
            }) {
                Text("Next Turn")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.success)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(scoreColor(result.overallScore).opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Results View
    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Completion Badge
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.success)

                    Text("Scenario Complete!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Great job completing the conversation!")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                // Overall Score
                let avgScore = turnResults.isEmpty ? 0 : turnResults.reduce(0.0) { $0 + $1.score } / Double(turnResults.count)

                VStack(spacing: 12) {
                    Text("Overall Score")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)

                    ZStack {
                        Circle()
                            .stroke(AppTheme.backgroundSecondary, lineWidth: 12)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: avgScore)
                            .stroke(scoreColor(avgScore), lineWidth: 12)
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(avgScore * 100))%")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4)

                // Completion Time
                if let startTime = scenarioStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(AppTheme.info)
                        Text("Completed in \(formatDuration(duration))")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Restart
                        currentTurnIndex = 0
                        conversationHistory = []
                        turnResults = []
                        showResults = false
                        scenarioStartTime = Date()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Practice Again")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.primaryBlue, lineWidth: 2)
                        )
                    }

                    Button(action: {
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Done")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryGradient)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.backgroundPrimary)
    }

    // MARK: - Conversation Bubble
    private func conversationBubble(_ item: ConversationHistoryItem) -> some View {
        HStack {
            if item.isUser {
                Spacer()
            }

            VStack(alignment: item.isUser ? .trailing : .leading, spacing: 4) {
                Text(item.text)
                    .font(.system(size: 14))
                    .foregroundColor(item.isUser ? .white : AppTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(item.isUser ? AppTheme.primaryBlue : AppTheme.backgroundSecondary)
                    .cornerRadius(16)

                if let score = item.score {
                    Text("\(Int(score * 100))% match")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }

            if !item.isUser {
                Spacer()
            }
        }
    }

    // MARK: - Helper Functions
    private func advanceToNextTurn(userResponse: String?, score: Double) {
        // Add to history
        if let turn = currentTurn {
            let historyItem = ConversationHistoryItem(
                id: UUID(),
                text: userResponse ?? turn.text,
                isUser: turn.speaker == .user,
                score: turn.speaker == .user ? score : nil
            )
            conversationHistory.append(historyItem)

            // Record turn result
            if turn.speaker == .user, let response = userResponse {
                let turnResult = TurnResult(
                    turnIndex: currentTurnIndex,
                    userResponse: response,
                    expectedResponse: turn.text,
                    score: score,
                    pronunciationScore: score,
                    grammarScore: score,
                    contextScore: score,
                    feedback: "Good job!"
                )
                turnResults.append(turnResult)
            }
        }

        // Advance
        currentTurnIndex += 1
        showResults = false
        speechManager.pronunciationResult = nil
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.9 { return AppTheme.success }
        else if score >= 0.7 { return AppTheme.warning }
        else { return AppTheme.error }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Conversation History Item
struct ConversationHistoryItem: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let score: Double?
}
