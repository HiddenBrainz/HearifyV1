//
//  ModernHeader.swift
//  HearifyV1
//
//  Modern header component with gradient background
//

import SwiftUI

// MARK: - Modern Header Component
struct ModernHeader: View {
    let text: String
    let layout: ResponsiveLayoutHelper

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with gradient
                AppTheme.primaryGradient
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Content
                VStack(spacing: 4) {
                    Text(text)
                        .font(.system(size: layout.titleFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)

                    // Subtle accent line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, .white.opacity(0.4), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .frame(maxWidth: layout.buttonWidth * 0.5)
                }
                .padding(.top, geometry.safeAreaInsets.top + 50)
                .padding(.bottom, 12)
                .padding(.horizontal, 12)
            }
            .frame(maxWidth: .infinity)
            .shadow(color: AppTheme.deepShadow, radius: 8, x: 0, y: 4)
        }
        .frame(height: layout.deviceType == .iPad ? 135 : 115)
    }
}
