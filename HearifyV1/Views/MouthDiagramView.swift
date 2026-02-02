//
//  MouthDiagramView.swift
//  HearifyV1
//
//  Custom visualization of mouth position for phonemes
//  Phase 3: Computer Vision & Visual Graphics
//

import SwiftUI

struct MouthDiagramView: View {
    let phoneme: PhonemeVisual
    @State private var animatePulse = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.95, green: 0.95, blue: 0.98))

                // Main mouth diagram
                VStack(spacing: 8) {
                    Text("Mouth Position")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)

                    // The actual mouth diagram
                    MouthCrossSectionView(phoneme: phoneme, animatePulse: $animatePulse)
                        .frame(height: geometry.size.height * 0.7)
                        .padding(.horizontal, 20)

                    // Quick info
                    HStack(spacing: 12) {
                        InfoChip(icon: "mouth", text: phoneme.lipShape.rawValue, color: phoneme.lipShape.color)
                        InfoChip(icon: "arrow.up.and.down", text: phoneme.jawOpening.rawValue, color: .blue)
                    }
                    .font(.system(size: 11))
                }
                .padding()
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
        }
    }
}

// MARK: - Mouth Cross Section View
struct MouthCrossSectionView: View {
    let phoneme: PhonemeVisual
    @Binding var animatePulse: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Head outline (side profile)
                HeadOutlineShape()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)

                // Oral cavity
                OralCavityShape(jawOpening: phoneme.jawOpening)
                    .fill(Color(red: 1.0, green: 0.95, blue: 0.95))
                    .opacity(0.5)

                // Hard palate
                HardPalateShape()
                    .fill(Color(red: 1.0, green: 0.9, blue: 0.7))
                    .opacity(0.6)

                // Soft palate (velum)
                SoftPalateShape()
                    .fill(Color(red: 1.0, green: 0.8, blue: 0.6))
                    .opacity(0.6)

                // Alveolar ridge marker
                AlveolarRidgeMarker()
                    .fill(phoneme.articulationPoint == .alveolar ? AppTheme.primaryBlue : Color.gray)
                    .opacity(phoneme.articulationPoint == .alveolar ? 0.8 : 0.3)
                    .scaleEffect(phoneme.articulationPoint == .alveolar && animatePulse ? 1.2 : 1.0)

                // Tongue
                TongueShape(config: phoneme.tongueConfig, jawOpening: phoneme.jawOpening)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.6),
                                Color(red: 0.95, green: 0.5, blue: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)

                // Lips
                LipsShape(lipShape: phoneme.lipShape, jawOpening: phoneme.jawOpening)
                    .fill(phoneme.lipShape.color)
                    .shadow(color: .black.opacity(0.2), radius: 2)

                // Teeth
                TeethShape(jawOpening: phoneme.jawOpening)
                    .fill(Color(red: 0.95, green: 0.95, blue: 1.0))

                // Airflow visualization
                if phoneme.mannerOfArticulation == .fricative ||
                    phoneme.mannerOfArticulation == .affricate {
                    AirflowVisualization(
                        phoneme: phoneme,
                        animate: animatePulse
                    )
                }

                // Labels
                ArticulationLabels(phoneme: phoneme)
            }
        }
    }
}

// MARK: - Head Outline Shape
struct HeadOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Simple head profile
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.1))
        path.addCurve(
            to: CGPoint(x: width * 0.3, y: height * 0.9),
            control1: CGPoint(x: width * 0.05, y: height * 0.3),
            control2: CGPoint(x: width * 0.1, y: height * 0.7)
        )

        // Chin
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.95))

        // Front of face
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.5))
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.1),
            control1: CGPoint(x: width * 0.7, y: height * 0.3),
            control2: CGPoint(x: width * 0.6, y: height * 0.15)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Oral Cavity Shape
struct OralCavityShape: Shape {
    let jawOpening: JawOpening

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let opening = jawOpening.openingFactor

        // Mouth cavity
        path.move(to: CGPoint(x: width * 0.3, y: height * 0.4))
        path.addCurve(
            to: CGPoint(x: width * 0.3, y: height * (0.5 + opening * 0.2)),
            control1: CGPoint(x: width * 0.25, y: height * 0.45),
            control2: CGPoint(x: width * 0.25, y: height * (0.45 + opening * 0.1))
        )
        path.addLine(to: CGPoint(x: width * 0.55, y: height * (0.55 + opening * 0.2)))
        path.addLine(to: CGPoint(x: width * 0.55, y: height * 0.45))
        path.closeSubpath()

        return path
    }
}

// MARK: - Hard Palate Shape
struct HardPalateShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.4, y: height * 0.35))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.32, y: height * 0.42),
            control: CGPoint(x: width * 0.35, y: height * 0.32)
        )
        path.addLine(to: CGPoint(x: width * 0.32, y: height * 0.45))
        path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.38))
        path.closeSubpath()

        return path
    }
}

// MARK: - Soft Palate Shape
struct SoftPalateShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.32, y: height * 0.42))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.28, y: height * 0.48),
            control: CGPoint(x: width * 0.29, y: height * 0.43)
        )
        path.addLine(to: CGPoint(x: width * 0.28, y: height * 0.51))
        path.addLine(to: CGPoint(x: width * 0.32, y: height * 0.45))
        path.closeSubpath()

        return path
    }
}

// MARK: - Alveolar Ridge Marker
struct AlveolarRidgeMarker: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Small circle for alveolar ridge
        let center = CGPoint(x: width * 0.53, y: height * 0.42)
        let radius: CGFloat = 8

        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        return path
    }
}

// MARK: - Tongue Shape
struct TongueShape: Shape {
    let config: TongueConfiguration
    let jawOpening: JawOpening

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Base position
        let baseX = width * 0.35
        let baseY = height * (0.65 + jawOpening.openingFactor * 0.15)

        // Tongue position based on config
        let tipX = baseX + (width * config.displayPosition.x * 0.3)
        let tipY = height * (0.4 + (1.0 - config.displayPosition.y) * 0.25)

        // Draw tongue
        path.move(to: CGPoint(x: baseX - width * 0.05, y: baseY))

        // Tongue body
        path.addQuadCurve(
            to: CGPoint(x: tipX, y: tipY),
            control: CGPoint(x: baseX + width * 0.05, y: baseY - height * 0.1)
        )

        // Tongue tip
        switch config.tip {
        case .interdental:
            // Extend forward between teeth
            path.addLine(to: CGPoint(x: tipX + width * 0.08, y: tipY))
        case .alveolar:
            // Touch alveolar ridge
            path.addLine(to: CGPoint(x: tipX + width * 0.03, y: tipY - height * 0.02))
        case .retroflex:
            // Curl back
            path.addQuadCurve(
                to: CGPoint(x: tipX, y: tipY - height * 0.03),
                control: CGPoint(x: tipX - width * 0.02, y: tipY - height * 0.04)
            )
        default:
            // Normal tip
            path.addLine(to: CGPoint(x: tipX + width * 0.02, y: tipY))
        }

        // Back down
        path.addQuadCurve(
            to: CGPoint(x: baseX + width * 0.05, y: baseY),
            control: CGPoint(x: tipX, y: baseY - height * 0.05)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Lips Shape
struct LipsShape: Shape {
    let lipShape: LipShape
    let jawOpening: JawOpening

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let opening = jawOpening.openingFactor
        let lipWidth = lipShape.width

        // Upper lip
        let upperY = height * 0.45
        path.move(to: CGPoint(x: width * 0.50, y: upperY))
        path.addQuadCurve(
            to: CGPoint(x: width * (0.50 + 0.08 * lipWidth), y: upperY + height * 0.02),
            control: CGPoint(x: width * (0.50 + 0.04 * lipWidth), y: upperY - height * 0.01)
        )

        // Lower lip
        let lowerY = height * (0.55 + opening * 0.15)
        path.addLine(to: CGPoint(x: width * (0.50 + 0.08 * lipWidth), y: lowerY))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.50, y: lowerY + height * 0.02),
            control: CGPoint(x: width * (0.50 + 0.04 * lipWidth), y: lowerY + height * 0.03)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Teeth Shape
struct TeethShape: Shape {
    let jawOpening: JawOpening

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let opening = jawOpening.openingFactor

        // Upper teeth
        let upperTeeth = CGRect(
            x: width * 0.52,
            y: height * 0.43,
            width: width * 0.06,
            height: height * 0.04
        )
        path.addRect(upperTeeth)

        // Lower teeth
        let lowerTeeth = CGRect(
            x: width * 0.52,
            y: height * (0.55 + opening * 0.15),
            width: width * 0.06,
            height: height * 0.04
        )
        path.addRect(lowerTeeth)

        return path
    }
}

// MARK: - Airflow Visualization
struct AirflowVisualization: View {
    let phoneme: PhonemeVisual
    let animate: Bool

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "arrow.forward")
                    .font(.system(size: 12))
                    .foregroundColor(phoneme.airflowType.color)
                    .offset(
                        x: geometry.size.width * (0.55 + CGFloat(index) * 0.05),
                        y: geometry.size.height * getAirflowY(for: phoneme)
                    )
                    .opacity(animate ? 0.8 : 0.3)
                    .animation(
                        Animation
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: animate
                    )
            }
        }
    }

    private func getAirflowY(for phoneme: PhonemeVisual) -> CGFloat {
        switch phoneme.airflowType {
        case .nasal: return 0.3 // Upper
        case .oral: return 0.5 // Middle
        case .oralNasal: return 0.4 // Both
        }
    }
}

// MARK: - Articulation Labels
struct ArticulationLabels: View {
    let phoneme: PhonemeVisual

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    if phoneme.articulationPoint == .alveolar {
                        Label("Alveolar Ridge", systemImage: "arrow.down")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.primaryBlue)
                            .padding(4)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(4)
                            .offset(x: -geometry.size.width * 0.15, y: geometry.size.height * 0.35)
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Info Chip
struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 10))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.8))
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct MouthDiagramView_Previews: PreviewProvider {
    static var previews: some View {
        if let phoneme = PhonemeDatabase.shared.phoneme(symbol: "θ") {
            MouthDiagramView(phoneme: phoneme)
                .frame(width: 300, height: 300)
                .padding()
        }
    }
}
