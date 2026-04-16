//
//  ResponsiveButton.swift
//  HearifyV1
//
//  Enhanced responsive button with multiple styles
//

import SwiftUI

// MARK: - Button Style Enum
enum ButtonStyle {
    case primary, secondary, accent, success, warning, danger, ghost

    var backgroundColor: Color {
        switch self {
        case .primary: return AppTheme.primaryBlue
        case .secondary: return AppTheme.backgroundSecondary
        case .accent: return AppTheme.accentOrange
        case .success: return AppTheme.success
        case .warning: return AppTheme.warning
        case .danger: return AppTheme.error
        case .ghost: return Color.clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary, .accent, .success, .warning, .danger: return .white
        case .secondary, .ghost: return AppTheme.textPrimary
        }
    }

    var gradient: LinearGradient? {
        switch self {
        case .primary: return AppTheme.primaryGradient
        case .accent: return AppTheme.accentGradient
        case .success: return AppTheme.successGradient
        default: return nil
        }
    }
}

// MARK: - Responsive Button
struct ResponsiveButton: View {
    let text: String
    let action: () -> Void
    let layout: ResponsiveLayoutHelper
    let style: ButtonStyle
    let icon: String?
    let width: CGFloat?
    let height: CGFloat?
    let isLoading: Bool

    // Legacy support for existing code
    let backgroundColor: Color?
    let foregroundColor: Color?

    @State private var isPressed = false

    init(
        text: String,
        action: @escaping () -> Void,
        layout: ResponsiveLayoutHelper,
        style: ButtonStyle = .primary,
        icon: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        isLoading: Bool = false,
        // Legacy parameters for backward compatibility
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil
    ) {
        self.text = text
        self.action = action
        self.layout = layout
        self.style = style
        self.icon = icon
        self.width = width
        self.height = height
        self.isLoading = isLoading
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    private var resolvedStyle: ButtonStyle {
        // Use legacy colors if provided for backward compatibility
        if backgroundColor != nil || foregroundColor != nil {
            return .secondary
        }
        return style
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacingS) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(foregroundColor ?? resolvedStyle.foregroundColor)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: layout.bodyFontSize, weight: .medium))
                }

                Text(text)
                    .font(.system(size: layout.titleFontSize, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
            }
            .foregroundColor(foregroundColor ?? resolvedStyle.foregroundColor)
            .padding(.vertical, AppTheme.spacingM)
            .padding(.horizontal, AppTheme.spacingL)
            .frame(
                width: width ?? layout.buttonWidth,
                height: height ?? layout.buttonHeight
            )
            .background(
                Group {
                    if let legacyColor = backgroundColor {
                        legacyColor
                    } else if let gradient = resolvedStyle.gradient {
                        gradient
                    } else {
                        resolvedStyle.backgroundColor
                    }
                }
            )
            .cornerRadius(AppTheme.radiusMedium)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .shadow(
                color: AppTheme.buttonShadow,
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .disabled(isLoading)
    }
}
