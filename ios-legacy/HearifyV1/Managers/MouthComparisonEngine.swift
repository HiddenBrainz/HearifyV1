//
//  MouthComparisonEngine.swift
//  HearifyV1
//
//  Compare user's mouth position to target phoneme articulation
//  Phase 3: Camera & Computer Vision
//

import Foundation
import SwiftUI

class MouthComparisonEngine: ObservableObject {
    @Published var matchScore: Double = 0.0
    @Published var feedback: MouthFeedback?
    @Published var matchColor: Color = .gray

    // Current target
    private var currentTarget: MouthTarget?

    // MARK: - Set Target
    func setTarget(phoneme: String) {
        currentTarget = MouthTargetDatabase.shared.getTarget(for: phoneme)
        if let target = currentTarget {
            print("🎯 Target loaded: \(phoneme) - Opening: \(target.openingRatioRange), Spread: \(target.lipSpread), Rounding: \(target.lipRounding)")
        } else {
            print("⚠️ No target found for phoneme: \(phoneme)")
        }
    }

    private var lastLogTime: Date?
    private var comparisonCount = 0
    private var lastScore: Double = 0

    // MARK: - Compare
    func compare(metrics: MouthMetrics) {
        guard let target = currentTarget else {
            matchScore = 0
            feedback = nil
            if comparisonCount == 0 {
                print("⚠️ No target set for comparison")
            }
            comparisonCount += 1
            return
        }

        // Calculate match for each aspect
        let openingMatch = calculateOpeningMatch(metrics: metrics, target: target)
        let spreadMatch = calculateSpreadMatch(metrics: metrics, target: target)
        let roundingMatch = calculateRoundingMatch(metrics: metrics, target: target)

        // Weighted average
        let totalScore = (openingMatch * 0.5) + (spreadMatch * 0.25) + (roundingMatch * 0.25)

        // Update published property
        matchScore = totalScore

        // Log if score changed significantly (more than 5%)
        if abs(totalScore - lastScore) > 0.05 {
            print("🔄 Score updated: \(Int(lastScore * 100))% → \(Int(totalScore * 100))%")
            lastScore = totalScore
        }

        // Update color
        if totalScore >= 0.85 {
            matchColor = .green
        } else if totalScore >= 0.65 {
            matchColor = .yellow
        } else {
            matchColor = .red
        }

        // Log every second
        comparisonCount += 1
        let now = Date()
        if lastLogTime == nil || now.timeIntervalSince(lastLogTime!) >= 1.0 {
            print("📊 Match Score: \(Int(totalScore * 100))% (Opening: \(Int(openingMatch * 100))%, Spread: \(Int(spreadMatch * 100))%, Round: \(Int(roundingMatch * 100))%) | Metrics: width=\(String(format: "%.3f", metrics.width)), height=\(String(format: "%.3f", metrics.height)), ratio=\(String(format: "%.3f", metrics.openingRatio))")
            lastLogTime = now
        }

        // Generate feedback
        feedback = generateFeedback(metrics: metrics, target: target, score: totalScore)
    }

    // MARK: - Calculate Opening Match
    private func calculateOpeningMatch(metrics: MouthMetrics, target: MouthTarget) -> Double {
        let ratio = metrics.openingRatio
        let targetRange = target.openingRatioRange

        if targetRange.contains(ratio) {
            // Perfect match
            return 1.0
        } else {
            // Calculate distance from range
            let distance = min(
                abs(ratio - targetRange.lowerBound),
                abs(ratio - targetRange.upperBound)
            )

            // Convert distance to score (0-1)
            let maxDeviation: CGFloat = 0.3
            let score = max(0, 1.0 - Double(distance / maxDeviation))
            return score
        }
    }

    // MARK: - Calculate Spread Match
    private func calculateSpreadMatch(metrics: MouthMetrics, target: MouthTarget) -> Double {
        let actualSpread: LipSpreadLevel
        if metrics.lipSpread < 0.10 {
            actualSpread = .narrow
        } else if metrics.lipSpread < 0.15 {
            actualSpread = .neutral
        } else {
            actualSpread = .wide
        }

        return actualSpread == target.lipSpread ? 1.0 : 0.5
    }

    // MARK: - Calculate Rounding Match
    private func calculateRoundingMatch(metrics: MouthMetrics, target: MouthTarget) -> Double {
        let actualRounding: LipRoundingLevel
        if metrics.lipRounding < 0.4 {
            actualRounding = .none
        } else if metrics.lipRounding < 0.6 {
            actualRounding = .partial
        } else {
            actualRounding = .full
        }

        return actualRounding == target.lipRounding ? 1.0 : 0.5
    }

    // MARK: - Generate Feedback
    private func generateFeedback(metrics: MouthMetrics, target: MouthTarget, score: Double) -> MouthFeedback {
        var tips: [String] = []

        // Check opening
        let ratio = metrics.openingRatio
        let targetRange = target.openingRatioRange

        if ratio < targetRange.lowerBound - 0.1 {
            tips.append("Open your mouth more")
        } else if ratio > targetRange.upperBound + 0.1 {
            tips.append("Close your mouth slightly")
        }

        // Check lip spread
        let actualSpread: LipSpreadLevel
        if metrics.lipSpread < 0.10 {
            actualSpread = .narrow
        } else if metrics.lipSpread < 0.15 {
            actualSpread = .neutral
        } else {
            actualSpread = .wide
        }

        if actualSpread != target.lipSpread {
            switch target.lipSpread {
            case .narrow:
                tips.append("Bring lips closer together")
            case .wide:
                tips.append("Spread lips wider (like smiling)")
            case .neutral:
                tips.append("Relax lips to neutral position")
            }
        }

        // Check rounding
        let actualRounding: LipRoundingLevel
        if metrics.lipRounding < 0.4 {
            actualRounding = .none
        } else if metrics.lipRounding < 0.6 {
            actualRounding = .partial
        } else {
            actualRounding = .full
        }

        if actualRounding != target.lipRounding {
            switch target.lipRounding {
            case .none:
                tips.append("Don't round your lips")
            case .partial:
                tips.append("Round lips slightly")
            case .full:
                tips.append("Round lips fully (like blowing)")
            }
        }

        // Overall message
        let message: String
        if score >= 0.85 {
            message = "Perfect! Hold this position"
        } else if score >= 0.65 {
            message = "Almost there! Small adjustments needed"
        } else {
            message = "Keep adjusting your mouth position"
        }

        return MouthFeedback(
            message: message,
            tips: tips,
            score: score
        )
    }
}

// MARK: - Mouth Feedback
struct MouthFeedback {
    let message: String
    let tips: [String]
    let score: Double
}

// MARK: - Mouth Target
struct MouthTarget {
    let phoneme: String
    let openingRatioRange: ClosedRange<CGFloat>
    let lipSpread: LipSpreadLevel
    let lipRounding: LipRoundingLevel
    let jawOpening: JawOpening
}

enum LipSpreadLevel {
    case narrow
    case neutral
    case wide
}

enum LipRoundingLevel {
    case none
    case partial
    case full
}

// MARK: - Mouth Target Database
class MouthTargetDatabase {
    static let shared = MouthTargetDatabase()

    private var targets: [String: MouthTarget] = [:]

    private init() {
        createTargets()
    }

    func getTarget(for phoneme: String) -> MouthTarget? {
        return targets[phoneme]
    }

    private func createTargets() {
        // VOWELS

        // /iː/ (sheep) - Close front unrounded
        targets["iː"] = MouthTarget(
            phoneme: "iː",
            openingRatioRange: 0.15...0.30,
            lipSpread: .wide,
            lipRounding: .none,
            jawOpening: .narrow
        )

        // /ɪ/ (ship) - Near-close front unrounded
        targets["ɪ"] = MouthTarget(
            phoneme: "ɪ",
            openingRatioRange: 0.20...0.35,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .narrow
        )

        // /uː/ (food) - Close back rounded
        targets["uː"] = MouthTarget(
            phoneme: "uː",
            openingRatioRange: 0.15...0.30,
            lipSpread: .narrow,
            lipRounding: .full,
            jawOpening: .narrow
        )

        // /ʊ/ (book) - Near-close back rounded
        targets["ʊ"] = MouthTarget(
            phoneme: "ʊ",
            openingRatioRange: 0.20...0.35,
            lipSpread: .narrow,
            lipRounding: .partial,
            jawOpening: .narrow
        )

        // /ɛ/ (bed) - Open-mid front unrounded
        targets["ɛ"] = MouthTarget(
            phoneme: "ɛ",
            openingRatioRange: 0.40...0.60,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .mid
        )

        // /ə/ (about) - Mid central
        targets["ə"] = MouthTarget(
            phoneme: "ə",
            openingRatioRange: 0.35...0.50,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .mid
        )

        // /ʌ/ (cup) - Open-mid back unrounded
        targets["ʌ"] = MouthTarget(
            phoneme: "ʌ",
            openingRatioRange: 0.40...0.60,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .mid
        )

        // /æ/ (cat) - Near-open front unrounded
        targets["æ"] = MouthTarget(
            phoneme: "æ",
            openingRatioRange: 0.60...0.80,
            lipSpread: .wide,
            lipRounding: .none,
            jawOpening: .wide
        )

        // /ɑː/ (father) - Open back unrounded
        targets["ɑː"] = MouthTarget(
            phoneme: "ɑː",
            openingRatioRange: 0.70...0.90,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .veryWide
        )

        // /ɔː/ (thought) - Open-mid back rounded
        targets["ɔː"] = MouthTarget(
            phoneme: "ɔː",
            openingRatioRange: 0.50...0.70,
            lipSpread: .narrow,
            lipRounding: .partial,
            jawOpening: .wide
        )

        // DIPHTHONGS

        // /eɪ/ (day) - Start position
        targets["eɪ"] = MouthTarget(
            phoneme: "eɪ",
            openingRatioRange: 0.35...0.50,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .mid
        )

        // /aɪ/ (my) - Start position
        targets["aɪ"] = MouthTarget(
            phoneme: "aɪ",
            openingRatioRange: 0.70...0.90,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .wide
        )

        // /ɔɪ/ (boy) - Start position
        targets["ɔɪ"] = MouthTarget(
            phoneme: "ɔɪ",
            openingRatioRange: 0.45...0.65,
            lipSpread: .narrow,
            lipRounding: .partial,
            jawOpening: .mid
        )

        // /aʊ/ (now) - Start position
        targets["aʊ"] = MouthTarget(
            phoneme: "aʊ",
            openingRatioRange: 0.65...0.85,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .wide
        )

        // /oʊ/ (go) - Start position
        targets["oʊ"] = MouthTarget(
            phoneme: "oʊ",
            openingRatioRange: 0.30...0.45,
            lipSpread: .narrow,
            lipRounding: .partial,
            jawOpening: .narrow
        )

        // CONSONANTS (selected ones with visible mouth positions)

        // /θ/ (think) - Interdental
        targets["θ"] = MouthTarget(
            phoneme: "θ",
            openingRatioRange: 0.20...0.35,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .narrow
        )

        // /f/ (fish) - Labiodental
        targets["f"] = MouthTarget(
            phoneme: "f",
            openingRatioRange: 0.15...0.30,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .narrow
        )

        // /w/ (we) - Labio-velar
        targets["w"] = MouthTarget(
            phoneme: "w",
            openingRatioRange: 0.20...0.35,
            lipSpread: .narrow,
            lipRounding: .full,
            jawOpening: .narrow
        )

        // /m/ (man) - Bilabial nasal
        targets["m"] = MouthTarget(
            phoneme: "m",
            openingRatioRange: 0.0...0.10,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .closed
        )

        // /p/ (pen) - Bilabial stop
        targets["p"] = MouthTarget(
            phoneme: "p",
            openingRatioRange: 0.0...0.10,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .closed
        )

        // /b/ (bat) - Bilabial stop
        targets["b"] = MouthTarget(
            phoneme: "b",
            openingRatioRange: 0.0...0.10,
            lipSpread: .neutral,
            lipRounding: .none,
            jawOpening: .closed
        )
    }
}
