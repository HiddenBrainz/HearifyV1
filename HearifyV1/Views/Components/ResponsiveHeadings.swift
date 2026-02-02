//
//  ResponsiveHeadings.swift
//  HearifyV1
//
//  Responsive heading component with gradient styling
//

import SwiftUI

// MARK: - Responsive Headings
struct ResponsiveHeadings: View {
    var text: String
    var geometry: GeometryProxy?

    var body: some View {
        let layout = geometry.map { ResponsiveLayoutHelper(geometry: $0) }

        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content
            VStack(spacing: 2) {
                Text(text)
                    .font(.system(size: layout?.titleFontSize ?? 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                // Subtle underline accent
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.4), .clear, .cyan.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .frame(maxWidth: min(150, (layout?.buttonWidth ?? 300) * 0.5))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, layout?.padding ?? 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 65)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}
