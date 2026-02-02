//
//  ConversationPracticeView.swift
//  HearifyV1
//
//  Interactive conversation practice with real-world scenarios
//  Phase 3: Conversation/Context Module
//

import SwiftUI

struct ConversationPracticeView: View {
    @StateObject private var speechManager = SpeechRecognitionManagerAdvanced()
    // Use shared instance to avoid creating duplicates (performance issue)
    @ObservedObject private var gamificationManager = GamificationManager.shared
    @State private var selectedScenario: ConversationScenario?
    @State private var showScenarioDetail = false
    @State private var selectedCategory: ScenarioCategory?
    @State private var selectedDifficulty: DifficultyLevel?
    var onDismiss: () -> Void = {}

    // Filter scenarios
    private var filteredScenarios: [ConversationScenario] {
        ConversationScenario.allScenarios.filter { scenario in
            (selectedCategory == nil || scenario.category == selectedCategory) &&
            (selectedDifficulty == nil || scenario.difficulty == selectedDifficulty)
        }
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

                Text("Conversation Practice")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .opacity(0)  // Hidden spacer
                }
            }
            .padding()
            .background(AppTheme.primaryGradient)

            ScrollView {
                VStack(spacing: 20) {
                    // Info Card
                    infoCard

                    // Filters
                    filtersSection

                    // Scenarios List
                    scenariosSection
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
        .fullScreenCover(item: $selectedScenario) { scenario in
            ConversationScenarioView(
                scenario: scenario,
                onDismiss: {
                    selectedScenario = nil
                }
            )
        }
    }

    // MARK: - Info Card
    private var infoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.accentPurple)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Real-World Conversations")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Practice multi-turn conversations in real-life situations")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            // Features
            VStack(spacing: 8) {
                featureRow(icon: "person.2.fill", text: "Role-play scenarios")
                featureRow(icon: "globe", text: "Cultural context & tips")
                featureRow(icon: "waveform.path.ecg", text: "Real-time feedback")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Filters Section
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )

                    ForEach(ScenarioCategory.allCases, id: \.self) { category in
                        filterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
            }

            // Difficulty Filter
            HStack(spacing: 8) {
                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    filterChip(
                        title: difficulty.rawValue,
                        isSelected: selectedDifficulty == difficulty,
                        color: colorForDifficulty(difficulty),
                        action: { selectedDifficulty = difficulty }
                    )
                }

                if selectedDifficulty != nil {
                    Button(action: { selectedDifficulty = nil }) {
                        Text("Clear")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }

    // MARK: - Scenarios Section
    private var scenariosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(filteredScenarios.count) Scenarios")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            if filteredScenarios.isEmpty {
                emptyStateView
            } else {
                ForEach(filteredScenarios) { scenario in
                    scenarioCard(scenario)
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

            Text("No scenarios found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            Text("Try adjusting your filters")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Scenario Card
    private func scenarioCard(_ scenario: ConversationScenario) -> some View {
        Button(action: {
            selectedScenario = scenario
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: scenario.category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.accentPurple)
                        .frame(width: 40, height: 40)
                        .background(AppTheme.accentPurple.opacity(0.1))
                        .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(scenario.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text(scenario.category.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Spacer()

                    difficultyBadge(scenario.difficulty)
                }

                Text(scenario.description)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)

                // Stats
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 12))
                        Text("\(scenario.turns.count) turns")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.textSecondary)

                    if !scenario.keyPhrases.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 12))
                            Text("\(scenario.keyPhrases.count) key phrases")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }

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
            .background(colorForDifficulty(difficulty))
            .cornerRadius(6)
    }

    private func colorForDifficulty(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy, .easy: return AppTheme.success
        case .medium, .medium: return AppTheme.warning
        case .hard, .hard, .hard: return AppTheme.error
        }
    }
}
