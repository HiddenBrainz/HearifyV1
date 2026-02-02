//
//  TargetMouthShape.swift
//  HearifyV1
//
//  Animated target mouth shape showing ideal pronunciation
//  Phase 3: Camera & Computer Vision - Visual Feedback
//

import SwiftUI

struct TargetMouthShapeView: View {
    let phoneme: String
    let matchScore: Double
    @State private var animationPhase: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            Text("TARGET")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.7))

            ZStack {
                // Background circle
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 100, height: 100)

                // Animated mouth shape
                mouthShape
                    .foregroundColor(matchScore >= 0.85 ? .green : .cyan)
                    .scaleEffect(1.0 + animationPhase * 0.05)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: animationPhase
                    )

                // Phoneme label
                Text(phoneme)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: 35)
            }

            Text(getMouthDescription(for: phoneme))
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
        .onAppear {
            animationPhase = 1.0
        }
    }

    private var mouthShape: some View {
        Group {
            let target = MouthTargetDatabase.shared.getTarget(for: phoneme)

            if let target = target {
                switch (target.lipSpread, target.lipRounding) {
                // Wide spread (smile)
                case (.wide, _):
                    wideSpreadShape(jawOpening: target.jawOpening)

                // Rounded lips
                case (_, .full), (_, .partial):
                    roundedShape(jawOpening: target.jawOpening, rounding: target.lipRounding)

                // Neutral
                default:
                    neutralShape(jawOpening: target.jawOpening)
                }
            } else {
                // Default shape
                neutralShape(jawOpening: .mid)
            }
        }
    }

    // MARK: - Mouth Shapes

    private func wideSpreadShape(jawOpening: JawOpening) -> some View {
        let height = getHeight(for: jawOpening)

        return Capsule()
            .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
            .frame(width: 60, height: height)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }

    private func roundedShape(jawOpening: JawOpening, rounding: LipRoundingLevel) -> some View {
        let size = getRoundedSize(for: jawOpening, rounding: rounding)

        return Circle()
            .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
    }

    private func neutralShape(jawOpening: JawOpening) -> some View {
        let height = getHeight(for: jawOpening)

        return Capsule()
            .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
            .frame(width: 45, height: height)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }

    // MARK: - Helpers

    private func getHeight(for jawOpening: JawOpening) -> CGFloat {
        switch jawOpening {
        case .closed: return 8
        case .narrow: return 15
        case .mid: return 25
        case .wide: return 35
        case .veryWide: return 45
        }
    }

    private func getRoundedSize(for jawOpening: JawOpening, rounding: LipRoundingLevel) -> CGFloat {
        switch jawOpening {
        case .closed: return 25
        case .narrow: return 30
        case .mid: return 35
        case .wide: return 40
        case .veryWide: return 45
        }
    }

    private func getMouthDescription(for phoneme: String) -> String {
        guard let target = MouthTargetDatabase.shared.getTarget(for: phoneme) else {
            return ""
        }

        var parts: [String] = []

        // Lip spread
        switch target.lipSpread {
        case .wide: parts.append("Wide")
        case .narrow: parts.append("Narrow")
        case .neutral: parts.append("Neutral")
        }

        // Lip rounding
        switch target.lipRounding {
        case .full: parts.append("Rounded")
        case .partial: parts.append("Slight Round")
        case .none: parts.append("Unrounded")
        }

        return parts.joined(separator: "\n")
    }
}

// Preview
struct TargetMouthShapeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            HStack(spacing: 30) {
                TargetMouthShapeView(phoneme: "iː", matchScore: 0.9)
                TargetMouthShapeView(phoneme: "uː", matchScore: 0.7)
                TargetMouthShapeView(phoneme: "æ", matchScore: 0.5)
            }
        }
    }
}
