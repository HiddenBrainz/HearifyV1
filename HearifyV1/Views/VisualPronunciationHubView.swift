//
//  VisualPronunciationHubView.swift
//  HearifyV1
//
//  Main hub for visual pronunciation learning
//  Phase 3: Computer Vision & Visual Graphics
//

import SwiftUI

struct VisualPronunciationHubView: View {
    var onDismiss: () -> Void
    @State private var selectedPhoneme: PhonemeVisual?
    @State private var selectedCategory: PhonemeCategory?
    @State private var searchText = ""
    @State private var showComparisons = false

    private var filteredPhonemes: [PhonemeVisual] {
        var phonemes = PhonemeDatabase.shared.allPhonemes

        // Filter by category
        if let category = selectedCategory {
            phonemes = phonemes.filter { $0.category == category }
        }

        // Filter by search
        if !searchText.isEmpty {
            phonemes = phonemes.filter {
                $0.symbol.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.examples.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        return phonemes
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            ScrollView {
                VStack(spacing: 20) {
                    // Info Card
                    infoCard

                    // Search Bar
                    searchBar

                    // Category Filter
                    categoryFilter

                    // Quick Access Cards
                    quickAccessSection

                    // Phonemes Grid
                    phonemesSection
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
        .fullScreenCover(item: $selectedPhoneme) { phoneme in
            PhonemeVisualizationView(
                phoneme: phoneme,
                onDismiss: { selectedPhoneme = nil }
            )
        }
        .sheet(isPresented: $showComparisons) {
            PhonemeComparisonsListView(
                onDismiss: { showComparisons = false }
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

            Text("Visual Pronunciation")
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
                Image(systemName: "eye.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.accentPurple)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Visual Learning")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("See how sounds are produced with interactive diagrams")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            VStack(spacing: 8) {
                featureRow(icon: "mouth.fill", text: "Mouth position diagrams")
                featureRow(icon: "waveform", text: "Articulation animations")
                featureRow(icon: "arrow.left.arrow.right", text: "Sound comparisons")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)

            TextField("Search phonemes or examples...", text: $searchText)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textPrimary)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        icon: nil,
                        count: PhonemeDatabase.shared.allPhonemes.count,
                        isSelected: selectedCategory == nil,
                        color: AppTheme.primaryBlue,
                        action: { selectedCategory = nil }
                    )

                    ForEach(PhonemeCategory.allCases, id: \.self) { category in
                        let count = PhonemeDatabase.shared.phonemes(category: category).count
                        if count > 0 {
                            FilterChip(
                                title: category.rawValue,
                                icon: category.icon,
                                count: count,
                                isSelected: selectedCategory == category,
                                color: category.color,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Quick Access Section
    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            HStack(spacing: 12) {
                QuickAccessCard(
                    title: "Difficult Sounds",
                    icon: "exclamationmark.triangle.fill",
                    color: AppTheme.warning,
                    count: PhonemeDatabase.shared.phonemes(difficulty: .hard).count,
                    action: {
                        selectedCategory = nil
                        // Filter to advanced difficulty
                    }
                )

                QuickAccessCard(
                    title: "Comparisons",
                    icon: "arrow.left.arrow.right",
                    color: AppTheme.info,
                    count: PhonemeDatabase.shared.getComparisonPairs().count,
                    action: {
                        showComparisons = true
                    }
                )
            }
        }
    }

    // MARK: - Phonemes Section
    private var phonemesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(filteredPhonemes.count) Sounds")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if selectedCategory != nil || !searchText.isEmpty {
                    Button(action: {
                        selectedCategory = nil
                        searchText = ""
                    }) {
                        Text("Clear")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.primaryBlue)
                    }
                }
            }

            if filteredPhonemes.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(filteredPhonemes) { phoneme in
                        PhonemeGridItem(phoneme: phoneme) {
                            selectedPhoneme = phoneme
                        }
                    }
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

            Text("No sounds found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            Text("Try a different search or category")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
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
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String?
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                Text("(\(count))")
                    .font(.system(size: 11))
                    .opacity(0.7)
            }
            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : AppTheme.backgroundSecondary)
            .cornerRadius(16)
        }
    }
}

// MARK: - Quick Access Card
struct QuickAccessCard: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)

                    Spacer()

                    Text("\(count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Phoneme Grid Item
struct PhonemeGridItem: View {
    let phoneme: PhonemeVisual
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // IPA Symbol
                Text("/\(phoneme.symbol)/")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(phoneme.category.color)

                // Example word
                Text(phoneme.examples.first ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)

                // Difficulty indicator
                if phoneme.difficultyLevel == .hard {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.warning)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Phoneme Comparisons List View
struct PhonemeComparisonsListView: View {
    var onDismiss: () -> Void
    @State private var selectedPair: PhonemeComparisonPair?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(PhonemeDatabase.shared.getComparisonPairs()) { pair in
                        ComparisonPairCard(pair: pair) {
                            selectedPair = pair
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Sound Comparisons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedPair) { pair in
            PhonemeComparisonDetailView(
                pair: pair,
                onDismiss: { selectedPair = nil }
            )
        }
    }
}

// MARK: - Comparison Pair Card
struct ComparisonPairCard: View {
    let pair: PhonemeComparisonPair
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Title
                Text(pair.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                // Phonemes
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("/\(pair.phoneme1.symbol)/")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(pair.phoneme1.category.color)

                        Text(pair.phoneme1.examples.first ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Text("vs")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)

                    VStack(spacing: 4) {
                        Text("/\(pair.phoneme2.symbol)/")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(pair.phoneme2.category.color)

                        Text(pair.phoneme2.examples.first ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                // Example pair
                if let example = pair.practiceExamples.first {
                    HStack {
                        Text(example.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(pair.phoneme1.category.color)

                        Text("↔")
                            .foregroundColor(AppTheme.textTertiary)

                        Text(example.1)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(pair.phoneme2.category.color)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(AppTheme.backgroundSecondary)
                    .cornerRadius(8)
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textTertiary)
                    .font(.system(size: 12))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Phoneme Comparison Detail View (Placeholder)
struct PhonemeComparisonDetailView: View {
    let pair: PhonemeComparisonPair
    var onDismiss: () -> Void

    var body: some View {
        VStack {
            Text("Comparison Detail View")
            Text("Coming Soon: Side-by-side comparison of \(pair.phoneme1.symbol) and \(pair.phoneme2.symbol)")
            Button("Close") {
                onDismiss()
            }
        }
    }
}
