//
//  AdvancedListeningView.swift
//  HearifyV1
//
//  Advanced listening practice with adaptive difficulty
//  Phase 1 Enhancements: Advanced Listening Module
//

import SwiftUI
import AVFoundation

struct AdvancedListeningView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var adaptiveManager = AdaptiveDifficultyManager()
    @State private var selectedExercise: AdvancedListeningExercise?
    @State private var selectedType: AdvancedExerciseType?
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var showAdaptiveMode = true
    var onDismiss: () -> Void = {}

    private var filteredExercises: [AdvancedListeningExercise] {
        AdvancedListeningExercise.allExercises.filter { exercise in
            (selectedType == nil || exercise.type == selectedType) &&
            (selectedDifficulty == nil || exercise.difficulty == selectedDifficulty)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            ScrollView {
                VStack(spacing: 20) {
                    // Info Card
                    infoCard

                    // Adaptive Mode Toggle
                    adaptiveModeCard

                    // Filters
                    filtersSection

                    // Exercises
                    exercisesSection
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
        .fullScreenCover(item: $selectedExercise) { exercise in
            AdvancedListeningExerciseView(
                exercise: exercise,
                adaptiveManager: adaptiveManager,
                onComplete: { result in
                    if showAdaptiveMode {
                        adaptiveManager.updateDifficulty(score: result.score)
                    }
                    selectedExercise = nil
                },
                onDismiss: {
                    selectedExercise = nil
                }
            )
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

            Text("Advanced Listening")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .opacity(0)
            }
        }
        .padding()
        .background(AppTheme.primaryGradient)
    }

    // MARK: - Info Card
    private var infoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "ear.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.info)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Advanced Training")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Master listening with adaptive difficulty and realistic scenarios")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            // Features
            VStack(spacing: 8) {
                featureRow(icon: "brain.head.profile", text: "Adaptive difficulty")
                featureRow(icon: "waveform.path.ecg", text: "Sound discrimination")
                featureRow(icon: "speaker.wave.3.fill", text: "Background noise training")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Adaptive Mode Card
    private var adaptiveModeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Adaptive Mode")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Difficulty adjusts based on your performance")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Toggle("", isOn: $showAdaptiveMode)
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryBlue))
            }

            if showAdaptiveMode {
                Divider()

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Level")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(difficultyColor(adaptiveManager.currentDifficulty))
                                .frame(width: 8, height: 8)

                            Text(adaptiveManager.currentDifficulty.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Recent Performance")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)

                        let average = adaptiveManager.performanceHistory.isEmpty ? 0 :
                            adaptiveManager.performanceHistory.reduce(0, +) / Double(adaptiveManager.performanceHistory.count)

                        Text("\(Int(average * 100))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(scoreColor(average))
                    }
                }
            }
        }
        .padding()
        .background(showAdaptiveMode ? AppTheme.primaryBlue.opacity(0.05) : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(showAdaptiveMode ? AppTheme.primaryBlue : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Filters Section
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercise Type")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(
                        title: "All",
                        isSelected: selectedType == nil,
                        action: { selectedType = nil }
                    )

                    ForEach(AdvancedExerciseType.allCases, id: \.self) { type in
                        filterChip(
                            title: type.rawValue,
                            icon: type.icon,
                            isSelected: selectedType == type,
                            action: { selectedType = type }
                        )
                    }
                }
            }

            if !showAdaptiveMode {
                Text("Difficulty")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top, 8)

                HStack(spacing: 8) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        filterChip(
                            title: difficulty.rawValue,
                            isSelected: selectedDifficulty == difficulty,
                            color: difficultyColor(difficulty),
                            action: { selectedDifficulty = difficulty }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Exercises Section
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(filteredExercises.count) Exercises")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            if filteredExercises.isEmpty {
                emptyStateView
            } else {
                ForEach(filteredExercises) { exercise in
                    exerciseCard(exercise)
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textTertiary)

            Text("No exercises found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Exercise Card
    private func exerciseCard(_ exercise: AdvancedListeningExercise) -> some View {
        Button(action: {
            selectedExercise = exercise
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: exercise.type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.info)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.info.opacity(0.1))
                        .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text(exercise.type.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Spacer()

                    difficultyBadge(exercise.difficulty)
                }

                Text(exercise.instructions)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)

                // Stats
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 12))
                        Text("\(exercise.questions.count) questions")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.textSecondary)

                    HStack(spacing: 4) {
                        Image(systemName: exercise.backgroundNoiseLevel.icon)
                            .font(.system(size: 12))
                        Text(exercise.backgroundNoiseLevel.rawValue)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.textSecondary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helper Views
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.info)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)

            Spacer()
        }
    }

    private func filterChip(title: String, icon: String? = nil, isSelected: Bool, color: Color = AppTheme.primaryBlue, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : AppTheme.backgroundSecondary)
            .cornerRadius(16)
        }
    }

    private func difficultyBadge(_ difficulty: DifficultyLevel) -> some View {
        Text(difficulty.rawValue)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor(difficulty))
            .cornerRadius(6)
    }

    private func difficultyColor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy, .easy: return AppTheme.success
        case .medium, .medium: return AppTheme.warning
        case .hard, .hard, .hard: return AppTheme.error
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.9 { return AppTheme.success }
        else if score >= 0.7 { return AppTheme.warning }
        else { return AppTheme.error }
    }
}

// MARK: - Placeholder for Exercise Execution View
struct AdvancedListeningExerciseView: View {
    let exercise: AdvancedListeningExercise
    let adaptiveManager: AdaptiveDifficultyManager
    var onComplete: (AdvancedExerciseResult) -> Void
    var onDismiss: () -> Void

    @State private var currentQuestionIndex = 0
    @State private var userAnswers: [String] = []
    @State private var showResults = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { onDismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text(exercise.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "xmark")
                        .opacity(0)
                }
            }
            .padding()
            .background(AppTheme.primaryGradient)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Exercise View - Coming Soon")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("This view will display the exercise with audio playback, questions, and interactive elements.")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: {
                        // Simulate completion
                        let result = AdvancedExerciseResult(
                            exerciseId: exercise.id,
                            score: 0.85,
                            completionTime: 60,
                            answers: [],
                            backgroundNoiseLevel: exercise.backgroundNoiseLevel,
                            difficulty: exercise.difficulty,
                            date: Date()
                        )
                        onComplete(result)
                    }) {
                        Text("Complete Exercise (Demo)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
    }
}
