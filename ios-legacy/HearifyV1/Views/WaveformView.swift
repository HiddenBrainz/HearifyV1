//
//  WaveformView.swift
//  HearifyV1
//
//  Visual waveform display for audio comparison
//

import SwiftUI
import AVFoundation

// MARK: - Waveform View
struct WaveformView: View {
    let audioLevels: [Float]
    let color: Color
    let showLabel: Bool

    init(audioLevels: [Float], color: Color = AppTheme.primaryBlue, showLabel: Bool = false) {
        self.audioLevels = audioLevels
        self.color = color
        self.showLabel = showLabel
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<min(audioLevels.count, 50), id: \.self) { index in
                    let level = audioLevels[index]
                    let normalizedHeight = CGFloat(level) * geometry.size.height * 0.8

                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: max(2, geometry.size.width / CGFloat(min(audioLevels.count, 50))), height: max(4, normalizedHeight))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

// MARK: - Waveform Comparison View
struct WaveformComparisonView: View {
    let userAudioLevels: [Float]
    let expectedText: String
    let recognizedText: String
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

                Text("Waveform Comparison")
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
                    // Info card
                    VStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.info)

                        Text("Visual Sound Comparison")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Compare the sound patterns of your pronunciation with the ideal pronunciation")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()

                    // Expected pronunciation waveform
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.success)
                            Text("Target: \(expectedText)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Text("Ideal pronunciation pattern")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)

                        // Simulated ideal waveform (since we can't get TTS waveform easily)
                        WaveformView(
                            audioLevels: generateIdealWaveform(for: expectedText),
                            color: AppTheme.success
                        )
                        .frame(height: 80)
                        .background(AppTheme.success.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4)

                    // User's pronunciation waveform
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(AppTheme.info)
                            Text("You said: \(recognizedText)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Text("Your pronunciation pattern")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)

                        if !userAudioLevels.isEmpty {
                            WaveformView(
                                audioLevels: userAudioLevels,
                                color: AppTheme.info
                            )
                            .frame(height: 80)
                            .background(AppTheme.info.opacity(0.05))
                            .cornerRadius(8)
                        } else {
                            Text("No audio data available")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4)

                    // Comparison insights
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(AppTheme.warning)
                            Text("What to Look For")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            InsightRow(
                                icon: "arrow.up.arrow.down",
                                text: "Wave height shows volume - taller waves = louder sounds"
                            )
                            InsightRow(
                                icon: "waveform.path",
                                text: "Wave pattern shows rhythm - match the overall shape"
                            )
                            InsightRow(
                                icon: "timer",
                                text: "Wave length shows duration - longer waves = slower speech"
                            )
                            InsightRow(
                                icon: "chart.bar.fill",
                                text: "Peaks show emphasis - match where the tall waves appear"
                            )
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4)
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
    }

    // Generate a simulated waveform for the expected text
    private func generateIdealWaveform(for text: String) -> [Float] {
        var levels: [Float] = []
        let syllables = text.split(separator: " ").count + text.count / 3

        for i in 0..<50 {
            let position = Float(i) / 50.0
            let syllablePhase = sin(Double(position) * Double(syllables) * .pi * 2) * 0.3
            let baseline = 0.2
            let variation = Float.random(in: -0.1...0.1)
            let level = Float(baseline + syllablePhase) + variation

            levels.append(max(0.05, min(1.0, level)))
        }

        return levels
    }
}

// MARK: - Insight Row
struct InsightRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.info)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Mini Waveform (for inline use)
struct MiniWaveformView: View {
    let audioLevels: [Float]
    let color: Color

    var body: some View {
        HStack(alignment: .center, spacing: 1) {
            ForEach(0..<min(audioLevels.count, 30), id: \.self) { index in
                let level = audioLevels[index]

                RoundedRectangle(cornerRadius: 1)
                    .fill(color)
                    .frame(width: 2, height: CGFloat(level) * 20)
            }
        }
        .frame(height: 24)
    }
}
