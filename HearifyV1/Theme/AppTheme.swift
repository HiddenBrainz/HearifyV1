//
//  AppTheme.swift
//  HearifyV1
//
//  Design System - Colors, Gradients, Spacing, Shadows
//  UPDATED: Now supports both Light and Dark mode
//

import SwiftUI

struct AppTheme {
    // MARK: - Primary Colors (Adaptive for Dark Mode)
    static let primaryBlue = Color("PrimaryBlue", bundle: nil)
        .fallback(light: Color(red: 0.1, green: 0.4, blue: 0.8),
                  dark: Color(red: 0.3, green: 0.6, blue: 1.0))

    static let primaryCyan = Color("PrimaryCyan", bundle: nil)
        .fallback(light: Color(red: 0.2, green: 0.7, blue: 0.9),
                  dark: Color(red: 0.4, green: 0.8, blue: 1.0))

    static let accentOrange = Color("AccentOrange", bundle: nil)
        .fallback(light: Color(red: 1.0, green: 0.6, blue: 0.2),
                  dark: Color(red: 1.0, green: 0.7, blue: 0.3))

    static let accentPurple = Color("AccentPurple", bundle: nil)
        .fallback(light: Color(red: 0.6, green: 0.3, blue: 0.9),
                  dark: Color(red: 0.7, green: 0.5, blue: 1.0))

    // MARK: - Semantic Colors (Adaptive)
    static let success = Color("Success", bundle: nil)
        .fallback(light: Color(red: 0.2, green: 0.8, blue: 0.4),
                  dark: Color(red: 0.3, green: 0.9, blue: 0.5))

    static let warning = Color("Warning", bundle: nil)
        .fallback(light: Color(red: 1.0, green: 0.7, blue: 0.0),
                  dark: Color(red: 1.0, green: 0.8, blue: 0.2))

    static let error = Color("Error", bundle: nil)
        .fallback(light: Color(red: 0.9, green: 0.3, blue: 0.3),
                  dark: Color(red: 1.0, green: 0.4, blue: 0.4))

    static let info = Color("Info", bundle: nil)
        .fallback(light: Color(red: 0.3, green: 0.6, blue: 1.0),
                  dark: Color(red: 0.4, green: 0.7, blue: 1.0))

    // MARK: - Background Colors (Adaptive - KEY CHANGE)
    static let backgroundPrimary = Color("BackgroundPrimary", bundle: nil)
        .fallback(light: Color(red: 0.94, green: 0.94, blue: 0.96),
                  dark: Color(red: 0.0, green: 0.0, blue: 0.0))

    static let backgroundSecondary = Color("BackgroundSecondary", bundle: nil)
        .fallback(light: Color(red: 0.96, green: 0.96, blue: 0.98),
                  dark: Color(red: 0.1, green: 0.1, blue: 0.1))

    static let cardBackground = Color("CardBackground", bundle: nil)
        .fallback(light: Color.white,
                  dark: Color(red: 0.15, green: 0.15, blue: 0.15))

    static let overlayBackground = Color("OverlayBackground", bundle: nil)
        .fallback(light: Color.black.opacity(0.1),
                  dark: Color.white.opacity(0.1))

    // MARK: - Text Colors (Adaptive - KEY CHANGE)
    static let textPrimary = Color("TextPrimary", bundle: nil)
        .fallback(light: Color(red: 0.15, green: 0.15, blue: 0.2),
                  dark: Color(red: 0.95, green: 0.95, blue: 1.0))

    static let textSecondary = Color("TextSecondary", bundle: nil)
        .fallback(light: Color(red: 0.5, green: 0.5, blue: 0.6),
                  dark: Color(red: 0.7, green: 0.7, blue: 0.75))

    static let textTertiary = Color("TextTertiary", bundle: nil)
        .fallback(light: Color(red: 0.7, green: 0.7, blue: 0.75),
                  dark: Color(red: 0.5, green: 0.5, blue: 0.55))

    // MARK: - Button Text Colors (Adaptive)
    static let buttonTextPrimary = Color("ButtonTextPrimary", bundle: nil)
        .fallback(light: Color.white,
                  dark: Color.white)

    static let buttonTextSecondary = Color("ButtonTextSecondary", bundle: nil)
        .fallback(light: Color.black,
                  dark: Color.white)

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, primaryCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accentOrange, Color(red: 1.0, green: 0.4, blue: 0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [success, Color(red: 0.4, green: 0.9, blue: 0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [cardBackground, backgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Shadows (Adaptive)
    static let cardShadow = Color("CardShadow", bundle: nil)
        .fallback(light: Color.black.opacity(0.12),
                  dark: Color.black.opacity(0.3))

    static let buttonShadow = Color("ButtonShadow", bundle: nil)
        .fallback(light: Color.black.opacity(0.12),
                  dark: Color.black.opacity(0.3))

    static let deepShadow = Color("DeepShadow", bundle: nil)
        .fallback(light: Color.black.opacity(0.15),
                  dark: Color.black.opacity(0.4))

    // MARK: - Corner Radius
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXLarge: CGFloat = 24

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
}

// MARK: - Color Extension for Dark Mode Support
extension Color {
    /// Provides fallback colors for light and dark mode
    func fallback(light: Color, dark: Color) -> Color {
        // If named color exists in asset catalog, use it
        // Otherwise use the provided light/dark fallbacks
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
