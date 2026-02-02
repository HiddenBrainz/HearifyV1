//
//  CommonModels.swift
//  HearifyV1
//
//  Common enums and data structures
//

import SwiftUI

// MARK: - Background Noise Type
enum BackgroundNoiseType: String, CaseIterable, Codable {
    case none = "None"
    case cafe = "Café"
    case traffic = "Traffic"
    case crowd = "Crowd"
    case office = "Office"
    case nature = "Nature"
}

// MARK: - Difficulty Level
enum DifficultyLevel: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var color: String {
        switch self {
        case .easy:
            return "success"
        case .medium:
            return "warning"
        case .hard:
            return "error"
        }
    }

    // Automatic playback speed based on difficulty
    var playbackSpeed: Float {
        switch self {
        case .easy:
            return 0.8      // Slower for easy
        case .medium:
            return 1.0      // Normal speed
        case .hard:
            return 1.3      // Faster for hard
        }
    }

    var displayDescription: String {
        switch self {
        case .easy:
            return "Slower speed (0.8x) - Best for beginners"
        case .medium:
            return "Normal speed (1.0x) - Standard practice"
        case .hard:
            return "Faster speed (1.3x) - Advanced challenge"
        }
    }
}

// MARK: - Analytics Chart Data
struct ChartDataPoint {
    let label: String
    let value: Double
    let color: Color
}

// MARK: - Daily Progress Data
struct DailyProgressData {
    let date: Date
    let accuracy: Double
    let attempts: Int
}

// MARK: - Device Type
enum DeviceType {
    case iPad
    case iPhoneLarge    // iPhone 14 Pro Max, etc.
    case iPhoneRegular  // iPhone 14, 13, etc.
    case iPhoneSmall    // iPhone SE, etc.
}

// MARK: - Responsive Layout Helper
struct ResponsiveLayoutHelper {
    let geometry: GeometryProxy

    var deviceType: DeviceType {
        if geometry.size.width >= 768 {
            return .iPad
        } else if geometry.size.width < 375 || geometry.size.height < 667 {
            return .iPhoneSmall
        } else if geometry.size.width >= 414 {
            return .iPhoneLarge
        } else {
            return .iPhoneRegular
        }
    }

    var isLandscape: Bool {
        geometry.size.width > geometry.size.height
    }

    var buttonWidth: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? geometry.size.width * 0.5 : geometry.size.width * 0.7
        case .iPhoneLarge:
            return geometry.size.width * 0.85
        case .iPhoneRegular:
            return geometry.size.width * 0.8
        case .iPhoneSmall:
            return geometry.size.width * 0.9
        }
    }

    var buttonHeight: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 80 : 100
        case .iPhoneLarge:
            return 75
        case .iPhoneRegular:
            return 65
        case .iPhoneSmall:
            return 50
        }
    }

    var titleFontSize: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 32 : 40
        case .iPhoneLarge:
            return 28
        case .iPhoneRegular:
            return 24
        case .iPhoneSmall:
            return 20
        }
    }

    var bodyFontSize: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 20 : 24
        case .iPhoneLarge:
            return 18
        case .iPhoneRegular:
            return 16
        case .iPhoneSmall:
            return 14
        }
    }

    var largeFontSize: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 80 : 100
        case .iPhoneLarge:
            return 70
        case .iPhoneRegular:
            return 60
        case .iPhoneSmall:
            return 50
        }
    }

    var imageSize: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 200 : 250
        case .iPhoneLarge:
            return 180
        case .iPhoneRegular:
            return 150
        case .iPhoneSmall:
            return 120
        }
    }

    var spacing: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 20 : 25
        case .iPhoneLarge:
            return 15
        case .iPhoneRegular:
            return 12
        case .iPhoneSmall:
            return 8
        }
    }

    var spacingXS: CGFloat {
        return spacing * 0.5
    }

    var spacingS: CGFloat {
        return spacing * 0.75
    }

    var spacingM: CGFloat {
        return spacing
    }

    var spacingL: CGFloat {
        return spacing * 1.5
    }

    var spacingXL: CGFloat {
        return spacing * 2
    }

    var padding: CGFloat {
        switch deviceType {
        case .iPad:
            return isLandscape ? 20 : 24
        case .iPhoneLarge:
            return 16
        case .iPhoneRegular:
            return 12
        case .iPhoneSmall:
            return 8
        }
    }

    var maxButtonTextWidth: CGFloat {
        // Leave padding for button styling
        return buttonWidth - (padding * 4)
    }
}
