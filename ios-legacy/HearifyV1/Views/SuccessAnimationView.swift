//
//  SuccessAnimationView.swift
//  HearifyV1
//
//  Celebration animation when user achieves high score
//  Phase 3: Camera & Computer Vision - Visual Feedback
//

import SwiftUI

struct SuccessAnimationView: View {
    let score: Double
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var particlesVisible = false

    var body: some View {
        ZStack {
            // Particle burst
            if particlesVisible {
                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(particleColor(for: index))
                        .frame(width: 10, height: 10)
                        .offset(particleOffset(for: index))
                        .opacity(opacity)
                        .animation(
                            Animation.easeOut(duration: 0.8)
                                .delay(Double(index) * 0.03),
                            value: particlesVisible
                        )
                }
            }

            // Success icon
            ZStack {
                // Glow background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [successColor.opacity(0.6), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(scale * 1.5)

                // Main circle
                Circle()
                    .fill(successColor)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))

                // Icon
                Image(systemName: successIcon)
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
            }

            // Score text
            VStack(spacing: 4) {
                Text(successMessage)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("\(Int(score * 100))%")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(successColor)
            }
            .offset(y: -120)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            playAnimation()
        }
    }

    // MARK: - Animation
    private func playAnimation() {
        // Impact feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Main animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }

        withAnimation(.linear(duration: 0.5)) {
            rotation = 360
        }

        // Particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                particlesVisible = true
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 0
                scale = 0.8
            }
        }
    }

    // MARK: - Helpers
    private var successColor: Color {
        if score >= 0.95 {
            return .green
        } else if score >= 0.85 {
            return .cyan
        } else {
            return .blue
        }
    }

    private var successIcon: String {
        if score >= 0.95 {
            return "star.fill"
        } else if score >= 0.85 {
            return "checkmark.circle.fill"
        } else {
            return "hand.thumbsup.fill"
        }
    }

    private var successMessage: String {
        if score >= 0.95 {
            return "PERFECT!"
        } else if score >= 0.90 {
            return "EXCELLENT!"
        } else {
            return "GREAT JOB!"
        }
    }

    private func particleColor(for index: Int) -> Color {
        let colors: [Color] = [.green, .cyan, .blue, .yellow, .pink, .purple]
        return colors[index % colors.count]
    }

    private func particleOffset(for index: Int) -> CGSize {
        let angle = CGFloat(index) * (360.0 / 12.0) * .pi / 180.0
        let radius: CGFloat = particlesVisible ? 100 : 0
        return CGSize(
            width: CGFloat(cos(angle)) * radius,
            height: CGFloat(sin(angle)) * radius
        )
    }
}

// Preview
struct SuccessAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SuccessAnimationView(score: 0.95)
        }
    }
}
