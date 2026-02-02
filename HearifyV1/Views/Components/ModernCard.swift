//
//  ModernCard.swift
//  HearifyV1
//
//  Modern card component with customizable styling
//

import SwiftUI

// MARK: - Modern Card Component
struct ModernCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let backgroundColor: Color

    init(
        padding: CGFloat = AppTheme.spacingM,
        cornerRadius: CGFloat = AppTheme.radiusMedium,
        shadowRadius: CGFloat = 8,
        backgroundColor: Color = AppTheme.cardBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: AppTheme.cardShadow, radius: shadowRadius, x: 0, y: 4)
    }
}
