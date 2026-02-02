//
//  PhonemeVisualizationView.swift
//  HearifyV1
//
//  Detailed phoneme visualization with mouth diagram and learning aids
//  Phase 3: Computer Vision & Visual Graphics
//

import SwiftUI
import AVFoundation

struct PhonemeVisualizationView: View {
    let phoneme: PhonemeVisual
    var onDismiss: () -> Void
    @State private var selectedTab = 0
    @StateObject private var speechSynthesizer = PhonemeAudioManager()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            ScrollView {
                VStack(spacing: 20) {
                    // Phoneme Symbol Card
                    phonemeSymbolCard

                    // Tab Picker
                    tabPicker

                    // Content based on selected tab
                    if selectedTab == 0 {
                        visualizationTab
                    } else if selectedTab == 1 {
                        detailsTab
                    } else {
                        practiceTab
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
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

            Text("Phoneme Guide")
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

    // MARK: - Phoneme Symbol Card
    private var phonemeSymbolCard: some View {
        VStack(spacing: 12) {
            // Large IPA Symbol
            Text("/\(phoneme.symbol)/")
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(phoneme.category.color)

            Text(phoneme.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            // Play button
            Button(action: {
                speechSynthesizer.speak(examples: phoneme.examples)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: speechSynthesizer.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 16))
                    Text(speechSynthesizer.isSpeaking ? "Playing..." : "Hear Examples")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(phoneme.category.color)
                .cornerRadius(12)
            }
            .disabled(speechSynthesizer.isSpeaking)

            // Category badge
            HStack(spacing: 8) {
                Image(systemName: phoneme.category.icon)
                Text(phoneme.category.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(phoneme.category.color)
            .cornerRadius(16)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Tab Picker
    private var tabPicker: some View {
        HStack(spacing: 0) {
            TabButton(title: "Visual", icon: "eye.fill", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "Details", icon: "info.circle.fill", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "Practice", icon: "textbook.fill", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(12)
    }

    // MARK: - Visualization Tab
    private var visualizationTab: some View {
        VStack(spacing: 20) {
            // Mouth Diagram
            VStack(alignment: .leading, spacing: 12) {
                Text("Mouth Position")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                MouthDiagramView(phoneme: phoneme)
                    .frame(height: 300)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4)
            }

            // Articulation Summary
            articulationSummary

            // Visual Hints
            visualHintsSection
        }
    }

    // MARK: - Details Tab
    private var detailsTab: some View {
        VStack(spacing: 20) {
            // Examples
            examplesSection

            // Description
            descriptionSection

            // Articulation Details
            articulationDetailsSection

            // Common Mistakes
            commonMistakesSection

            // Tips
            tipsSection
        }
    }

    // MARK: - Practice Tab
    private var practiceTab: some View {
        VStack(spacing: 20) {
            // Minimal pairs (if available)
            if !phoneme.confusedWith.isEmpty {
                confusedWithSection
            }

            // Practice exercises suggestion
            practiceExercisesSection
        }
    }

    // MARK: - Articulation Summary
    private var articulationSummary: some View {
        VStack(spacing: 12) {
            Text("Articulation Summary")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                SummaryRow(
                    icon: phoneme.voicing.icon,
                    label: "Voicing",
                    value: phoneme.voicing.rawValue,
                    color: phoneme.voicing.color
                )
                SummaryRow(
                    icon: "location.fill",
                    label: "Place",
                    value: phoneme.articulationPoint.rawValue,
                    color: phoneme.articulationPoint.color
                )
                SummaryRow(
                    icon: phoneme.mannerOfArticulation.icon,
                    label: "Manner",
                    value: phoneme.mannerOfArticulation.rawValue,
                    color: AppTheme.info
                )
                SummaryRow(
                    icon: phoneme.airflowType.icon,
                    label: "Airflow",
                    value: phoneme.airflowType.rawValue,
                    color: phoneme.airflowType.color
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Visual Hints Section
    private var visualHintsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Points")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(phoneme.visualHints, id: \.text) { hint in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.success)

                    Text(hint.text)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()
                }
            }
        }
        .padding()
        .background(AppTheme.success.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Examples Section
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Example Words")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(Array(zip(phoneme.examples, phoneme.exampleIPA)), id: \.0) { example, ipa in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(example)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("/\(ipa)/")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: {
                        speechSynthesizer.speak(word: example)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(phoneme.category.color)
                            .padding(8)
                            .background(phoneme.category.color.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to Produce")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Text(phoneme.description)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Articulation Details Section
    private var articulationDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Articulation Details")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            DetailRow(label: "Tongue Position", value: "\(phoneme.tongueConfig.horizontal.rawValue), \(phoneme.tongueConfig.vertical.rawValue)")
            DetailRow(label: "Tongue Tip", value: phoneme.tongueConfig.tip.rawValue)
            DetailRow(label: "Lip Shape", value: phoneme.lipShape.rawValue)
            DetailRow(label: "Jaw Opening", value: phoneme.jawOpening.rawValue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Common Mistakes Section
    private var commonMistakesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppTheme.warning)
                Text("Common Mistakes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            ForEach(phoneme.commonMistakes, id: \.self) { mistake in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(AppTheme.warning)
                    Text(mistake)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(AppTheme.warning.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppTheme.info)
                Text("Tips")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            ForEach(phoneme.tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Text("💡")
                    Text(tip)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(AppTheme.info.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Confused With Section
    private var confusedWithSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Often Confused With")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(phoneme.confusedWith, id: \.self) { confusedSymbol in
                if let confusedPhoneme = PhonemeDatabase.shared.phoneme(symbol: confusedSymbol) {
                    HStack {
                        Text("/\(confusedPhoneme.symbol)/")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(confusedPhoneme.category.color)
                            .frame(width: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(confusedPhoneme.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)

                            Text(confusedPhoneme.examplesString)
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Practice Exercises Section
    private var practiceExercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice This Sound")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Text("Go to Targeted Practice → \(getCategoryName(for: phoneme)) to practice this sound in exercises")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)

            Button(action: {
                // Will implement navigation
            }) {
                HStack {
                    Text("Start Practice")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(phoneme.category.color)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Helper Functions
    private func getCategoryName(for phoneme: PhonemeVisual) -> String {
        // Map phoneme to practice category
        if phoneme.symbol == "θ" || phoneme.symbol == "ð" {
            return "TH Sounds"
        } else if phoneme.symbol == "ɹ" {
            return "R Sounds"
        } else if phoneme.symbol == "l" {
            return "L Sounds"
        } else if phoneme.mannerOfArticulation == .vowel {
            return "Vowel Sounds"
        } else {
            return "Common Mistakes"
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? AppTheme.primaryBlue : Color.clear)
            .cornerRadius(12)
        }
    }
}

// MARK: - Summary Row
struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 80, alignment: .leading)

            Text(value)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textPrimary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textPrimary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Phoneme Audio Manager
class PhonemeAudioManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = 0.4
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
        isSpeaking = true
    }

    func speak(examples: [String]) {
        for (index, example) in examples.enumerated() {
            let utterance = AVSpeechUtterance(string: example)
            utterance.rate = 0.4
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

            if index < examples.count - 1 {
                utterance.postUtteranceDelay = 0.5
            }

            synthesizer.speak(utterance)
        }
        isSpeaking = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if synthesizer.isSpeaking == false {
            isSpeaking = false
        }
    }
}
