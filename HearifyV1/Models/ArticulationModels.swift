//
//  ArticulationModels.swift
//  HearifyV1
//
//  Articulatory phonetics models for visual pronunciation
//  Phase 3: Computer Vision & Visual Graphics
//

import SwiftUI

// MARK: - Tongue Position
enum TonguePosition: String, Codable {
    // Horizontal (front/back)
    case front = "Front"
    case centralFront = "Central-Front"
    case central = "Central"
    case centralBack = "Central-Back"
    case back = "Back"

    // Vertical (height)
    case high = "High"
    case nearHigh = "Near-High"
    case highMid = "High-Mid"
    case mid = "Mid"
    case lowMid = "Low-Mid"
    case nearLow = "Near-Low"
    case low = "Low"

    var visualOffset: CGPoint {
        switch self {
        case .front: return CGPoint(x: 0.2, y: 0.5)
        case .centralFront: return CGPoint(x: 0.35, y: 0.5)
        case .central: return CGPoint(x: 0.5, y: 0.5)
        case .centralBack: return CGPoint(x: 0.65, y: 0.5)
        case .back: return CGPoint(x: 0.8, y: 0.5)
        case .high: return CGPoint(x: 0.5, y: 0.2)
        case .nearHigh: return CGPoint(x: 0.5, y: 0.3)
        case .highMid: return CGPoint(x: 0.5, y: 0.4)
        case .mid: return CGPoint(x: 0.5, y: 0.5)
        case .lowMid: return CGPoint(x: 0.5, y: 0.6)
        case .nearLow: return CGPoint(x: 0.5, y: 0.7)
        case .low: return CGPoint(x: 0.5, y: 0.8)
        }
    }
}

// Combined tongue position
struct TongueConfiguration: Codable {
    let horizontal: TongueHorizontal
    let vertical: TongueVertical
    let tip: TongueTip
    let tension: TongueTension

    var displayPosition: CGPoint {
        // Convert to 2D position for visualization
        let x = horizontal.xPosition
        let y = vertical.yPosition
        return CGPoint(x: x, y: y)
    }
}

enum TongueHorizontal: String, Codable, CaseIterable {
    case front = "Front"
    case nearFront = "Near-Front"
    case central = "Central"
    case nearBack = "Near-Back"
    case back = "Back"

    var xPosition: CGFloat {
        switch self {
        case .front: return 0.25
        case .nearFront: return 0.375
        case .central: return 0.5
        case .nearBack: return 0.625
        case .back: return 0.75
        }
    }
}

enum TongueVertical: String, Codable, CaseIterable {
    case high = "High"
    case nearHigh = "Near-High"
    case highMid = "High-Mid"
    case mid = "Mid"
    case lowMid = "Low-Mid"
    case nearLow = "Near-Low"
    case low = "Low"

    var yPosition: CGFloat {
        switch self {
        case .high: return 0.2
        case .nearHigh: return 0.3
        case .highMid: return 0.4
        case .mid: return 0.5
        case .lowMid: return 0.6
        case .nearLow: return 0.7
        case .low: return 0.8
        }
    }
}

enum TongueTip: String, Codable {
    case down = "Down"
    case alveolar = "Alveolar Ridge"
    case dental = "Teeth"
    case interdental = "Between Teeth"
    case postalveolar = "Behind Alveolar Ridge"
    case palatal = "Hard Palate"
    case velar = "Soft Palate"
    case retroflex = "Curled Back"
}

enum TongueTension: String, Codable {
    case tense = "Tense"
    case lax = "Lax"
    case neutral = "Neutral"
}

// MARK: - Lip Shape
enum LipShape: String, Codable, CaseIterable {
    case spread = "Spread"
    case neutral = "Neutral"
    case rounded = "Rounded"
    case compressed = "Compressed"
    case protruded = "Protruded"

    var icon: String {
        switch self {
        case .spread: return "⬌"
        case .neutral: return "○"
        case .rounded: return "◯"
        case .compressed: return "—"
        case .protruded: return "⊙"
        }
    }

    var width: CGFloat {
        switch self {
        case .spread: return 1.3
        case .neutral: return 1.0
        case .rounded: return 0.8
        case .compressed: return 0.7
        case .protruded: return 0.65
        }
    }

    var color: Color {
        return Color(red: 0.95, green: 0.7, blue: 0.7)
    }
}

// MARK: - Jaw Opening
enum JawOpening: String, Codable, CaseIterable {
    case closed = "Closed"
    case narrow = "Narrow"
    case mid = "Mid"
    case wide = "Wide"
    case veryWide = "Very Wide"

    var openingFactor: CGFloat {
        switch self {
        case .closed: return 0.1
        case .narrow: return 0.3
        case .mid: return 0.5
        case .wide: return 0.7
        case .veryWide: return 0.9
        }
    }
}

// MARK: - Voicing
enum Voicing: String, Codable {
    case voiced = "Voiced"
    case voiceless = "Voiceless"

    var color: Color {
        switch self {
        case .voiced: return .blue
        case .voiceless: return .gray
        }
    }

    var icon: String {
        switch self {
        case .voiced: return "waveform"
        case .voiceless: return "waveform.path"
        }
    }

    var description: String {
        switch self {
        case .voiced: return "Vocal cords vibrate"
        case .voiceless: return "Vocal cords don't vibrate"
        }
    }
}

// MARK: - Airflow Type
enum AirflowType: String, Codable {
    case oral = "Oral"
    case nasal = "Nasal"
    case oralNasal = "Oral & Nasal"

    var color: Color {
        switch self {
        case .oral: return Color(red: 0.5, green: 0.8, blue: 1.0)
        case .nasal: return Color(red: 0.6, green: 1.0, blue: 0.6)
        case .oralNasal: return Color(red: 0.8, green: 0.9, blue: 0.7)
        }
    }

    var icon: String {
        switch self {
        case .oral: return "mouth"
        case .nasal: return "nose"
        case .oralNasal: return "mouth.fill"
        }
    }
}

// MARK: - Articulation Point
enum ArticulationPoint: String, Codable, CaseIterable {
    case bilabial = "Bilabial"
    case labiodental = "Labiodental"
    case dental = "Dental"
    case alveolar = "Alveolar"
    case postalveolar = "Post-alveolar"
    case retroflex = "Retroflex"
    case palatal = "Palatal"
    case velar = "Velar"
    case uvular = "Uvular"
    case pharyngeal = "Pharyngeal"
    case glottal = "Glottal"

    var description: String {
        switch self {
        case .bilabial: return "Both lips"
        case .labiodental: return "Lower lip + upper teeth"
        case .dental: return "Tongue + teeth"
        case .alveolar: return "Tongue + alveolar ridge"
        case .postalveolar: return "Tongue + behind alveolar ridge"
        case .retroflex: return "Curled tongue + palate"
        case .palatal: return "Tongue + hard palate"
        case .velar: return "Tongue + soft palate"
        case .uvular: return "Tongue + uvula"
        case .pharyngeal: return "Root of tongue + pharynx"
        case .glottal: return "Glottis (vocal cords)"
        }
    }

    var color: Color {
        switch self {
        case .bilabial: return Color(red: 1.0, green: 0.7, blue: 0.7)
        case .labiodental: return Color(red: 1.0, green: 0.8, blue: 0.6)
        case .dental: return Color(red: 0.9, green: 0.9, blue: 0.9)
        case .alveolar: return Color(red: 1.0, green: 0.95, blue: 0.7)
        case .postalveolar: return Color(red: 0.95, green: 0.9, blue: 0.6)
        case .retroflex: return Color(red: 0.9, green: 0.6, blue: 0.5)
        case .palatal: return Color(red: 1.0, green: 0.9, blue: 0.5)
        case .velar: return Color(red: 1.0, green: 0.7, blue: 0.5)
        case .uvular: return Color(red: 0.9, green: 0.6, blue: 0.4)
        case .pharyngeal: return Color(red: 0.8, green: 0.5, blue: 0.5)
        case .glottal: return Color(red: 0.7, green: 0.4, blue: 0.4)
        }
    }
}

// MARK: - Manner of Articulation
enum MannerOfArticulation: String, Codable, CaseIterable {
    case stop = "Stop/Plosive"
    case nasal = "Nasal"
    case trill = "Trill"
    case tapFlap = "Tap/Flap"
    case fricative = "Fricative"
    case lateralFricative = "Lateral Fricative"
    case approximant = "Approximant"
    case lateralApproximant = "Lateral Approximant"
    case affricate = "Affricate"
    case vowel = "Vowel"

    var description: String {
        switch self {
        case .stop: return "Complete blockage then release"
        case .nasal: return "Air through nose"
        case .trill: return "Rapid vibration"
        case .tapFlap: return "Quick tap"
        case .fricative: return "Turbulent airflow"
        case .lateralFricative: return "Air flows around sides"
        case .approximant: return "Articulators approach but don't touch"
        case .lateralApproximant: return "Air flows around sides smoothly"
        case .affricate: return "Stop followed by fricative"
        case .vowel: return "Open vocal tract"
        }
    }

    var icon: String {
        switch self {
        case .stop: return "stop.circle"
        case .nasal: return "nose"
        case .trill: return "waveform.path.ecg"
        case .tapFlap: return "hand.tap"
        case .fricative: return "wind"
        case .lateralFricative: return "wind.snow"
        case .approximant: return "arrow.up.left.and.arrow.down.right"
        case .lateralApproximant: return "arrow.left.and.right"
        case .affricate: return "stop.circle.fill"
        case .vowel: return "circle"
        }
    }
}

// MARK: - Visual Hint
struct VisualHint: Codable {
    let text: String
    let highlightArea: HighlightArea
    let animationType: AnimationType
}

enum HighlightArea: String, Codable {
    case tongue
    case lips
    case teeth
    case jaw
    case velum
    case alveolarRidge
    case hardPalate
    case softPalate
    case throat
}

enum AnimationType: String, Codable {
    case pulse
    case arrow
    case circle
    case highlight
}
