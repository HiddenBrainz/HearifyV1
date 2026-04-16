//
//  FaceDetectionManager.swift
//  HearifyV1
//
//  Face and mouth landmark detection using Vision framework
//  Phase 3: Camera & Computer Vision
//

import Vision
import AVFoundation
import CoreImage
import UIKit
import SwiftUI

class FaceDetectionManager: ObservableObject {
    @Published var faceDetected = false
    @Published var mouthLandmarks: MouthLandmarks?
    @Published var faceQuality: FaceQuality = .none

    private var lastProcessedTime: TimeInterval = 0
    private let processingInterval: TimeInterval = 0.1 // Process every 100ms (10 FPS)
    private var frameCount = 0
    private var detectionCount = 0

    // Callback for when new landmarks are detected
    var onLandmarksDetected: ((MouthLandmarks) -> Void)?

    // MARK: - Process Frame
    func processFrame(_ sampleBuffer: CMSampleBuffer) {
        frameCount += 1

        let currentTime = CACurrentMediaTime()
        guard currentTime - lastProcessedTime >= processingInterval else { return }
        lastProcessedTime = currentTime

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            if frameCount % 30 == 0 {
                print("⚠️ Failed to get pixel buffer from sample")
            }
            return
        }

        // Log every 30 processed frames
        if frameCount % 30 == 0 {
            print("👁️ Processing frame #\(frameCount) for face detection...")
        }

        // Create Vision request
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            self?.handleFaceDetection(request: request, error: error)
        }

        // Set to detect all landmarks
        request.revision = VNDetectFaceLandmarksRequestRevision3

        // Perform request
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])

        do {
            try handler.perform([request])
        } catch {
            print("❌ Face detection error: \(error)")
        }
    }

    // MARK: - Handle Detection Results
    private func handleFaceDetection(request: VNRequest, error: Error?) {
        if let error = error {
            print("❌ Face detection error: \(error)")
            DispatchQueue.main.async {
                self.faceDetected = false
                self.faceQuality = .none
                self.mouthLandmarks = nil
            }
            return
        }

        guard let results = request.results as? [VNFaceObservation],
              let face = results.first else {
            // No face detected - only log occasionally
            if frameCount % 60 == 0 {
                print("👤 No face detected in frame")
            }
            DispatchQueue.main.async {
                self.faceDetected = false
                self.faceQuality = .none
                self.mouthLandmarks = nil
            }
            return
        }

        // Face detected
        detectionCount += 1
        if detectionCount % 30 == 0 {
            print("😀 Face detected (#\(detectionCount)) with confidence: \(String(format: "%.2f", face.confidence))")
        }

        DispatchQueue.main.async {
            self.faceDetected = true
            self.analyzeFaceQuality(face)
            self.extractMouthLandmarks(from: face)
        }
    }

    // MARK: - Analyze Face Quality
    private func analyzeFaceQuality(_ face: VNFaceObservation) {
        let boundingBox = face.boundingBox

        // Check face size (should be 20-60% of frame)
        let faceArea = boundingBox.width * boundingBox.height
        let isTooSmall = faceArea < 0.15
        let isTooLarge = faceArea > 0.7

        // Check face position (should be centered)
        let centerX = boundingBox.midX
        let centerY = boundingBox.midY
        let isOffCenter = abs(centerX - 0.5) > 0.2 || abs(centerY - 0.5) > 0.2

        // Check face quality metrics
        let hasGoodQuality = face.confidence > 0.7

        if isTooSmall {
            faceQuality = .tooFar
        } else if isTooLarge {
            faceQuality = .tooClose
        } else if isOffCenter {
            faceQuality = .offCenter
        } else if !hasGoodQuality {
            faceQuality = .poor
        } else {
            faceQuality = .good
        }
    }

    // MARK: - Extract Mouth Landmarks
    private func extractMouthLandmarks(from face: VNFaceObservation) {
        guard let landmarks = face.landmarks,
              let outerLips = landmarks.outerLips,
              let innerLips = landmarks.innerLips else {
            if detectionCount % 30 == 0 {
                print("⚠️ Face detected but no mouth landmarks available")
            }
            return
        }

        // Convert normalized points to actual points
        let boundingBox = face.boundingBox

        // Get key mouth points
        let outerPoints = outerLips.normalizedPoints
        let innerPoints = innerLips.normalizedPoints

        if detectionCount % 30 == 0 {
            print("👄 Mouth landmarks extracted: \(outerPoints.count) outer points, \(innerPoints.count) inner points")
        }

        // Calculate mouth metrics
        let metrics = calculateMouthMetrics(
            outerPoints: outerPoints,
            innerPoints: innerPoints,
            boundingBox: boundingBox
        )

        if detectionCount % 30 == 0 {
            print("📏 Mouth metrics: width=\(String(format: "%.3f", metrics.width)), height=\(String(format: "%.3f", metrics.height)), ratio=\(String(format: "%.3f", metrics.openingRatio))")
        }

        let mouthData = MouthLandmarks(
            outerPoints: outerPoints,
            innerPoints: innerPoints,
            boundingBox: boundingBox,
            metrics: metrics
        )

        mouthLandmarks = mouthData

        // Notify callback with new landmarks
        onLandmarksDetected?(mouthData)
    }

    // MARK: - Calculate Mouth Metrics
    private func calculateMouthMetrics(outerPoints: [CGPoint], innerPoints: [CGPoint], boundingBox: CGRect) -> MouthMetrics {
        guard outerPoints.count >= 4 else {
            print("⚠️ Not enough outer points: \(outerPoints.count)")
            return MouthMetrics(width: 0, height: 0, openingRatio: 0, lipSpread: 0, lipRounding: 0)
        }

        // Find extreme points (works with any number of points)
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.leastNormalMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = CGFloat.leastNormalMagnitude

        for point in outerPoints {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }

        // Calculate width and height from extremes
        let width = maxX - minX
        let height = maxY - minY

        // Opening ratio (height / width)
        let openingRatio = width > 0 ? height / width : 0

        // Lip spread (horizontal extent)
        let lipSpread = width

        // Lip rounding (circularity)
        let lipRounding = calculateCircularity(points: outerPoints)

        if detectionCount % 30 == 0 {
            print("🔢 Calculated from \(outerPoints.count) points: width=\(String(format: "%.3f", width)), height=\(String(format: "%.3f", height))")
        }

        return MouthMetrics(
            width: width,
            height: height,
            openingRatio: openingRatio,
            lipSpread: lipSpread,
            lipRounding: lipRounding
        )
    }

    // MARK: - Calculate Circularity
    private func calculateCircularity(points: [CGPoint]) -> CGFloat {
        guard points.count > 2 else { return 0 }

        // Approximate area using shoelace formula
        var area: CGFloat = 0
        for i in 0..<points.count {
            let j = (i + 1) % points.count
            area += points[i].x * points[j].y
            area -= points[j].x * points[i].y
        }
        area = abs(area) / 2.0

        // Calculate perimeter
        var perimeter: CGFloat = 0
        for i in 0..<points.count {
            let j = (i + 1) % points.count
            let dx = points[j].x - points[i].x
            let dy = points[j].y - points[i].y
            perimeter += sqrt(dx * dx + dy * dy)
        }

        // Circularity = 4π * area / perimeter²
        // Perfect circle = 1.0, less circular = lower value
        guard perimeter > 0 else { return 0 }
        let circularity = (4 * .pi * area) / (perimeter * perimeter)

        return circularity
    }
}

// MARK: - Mouth Landmarks
struct MouthLandmarks {
    let outerPoints: [CGPoint]
    let innerPoints: [CGPoint]
    let boundingBox: CGRect
    let metrics: MouthMetrics
}

// MARK: - Mouth Metrics
struct MouthMetrics {
    let width: CGFloat
    let height: CGFloat
    let openingRatio: CGFloat
    let lipSpread: CGFloat
    let lipRounding: CGFloat

    var jawOpening: JawOpening {
        if openingRatio < 0.2 {
            return .closed
        } else if openingRatio < 0.35 {
            return .narrow
        } else if openingRatio < 0.55 {
            return .mid
        } else if openingRatio < 0.75 {
            return .wide
        } else {
            return .veryWide
        }
    }

    var lipShape: LipShapeType {
        if lipRounding > 0.7 {
            return .rounded
        } else if lipSpread > 0.15 {
            return .spread
        } else {
            return .neutral
        }
    }
}

enum LipShapeType {
    case spread
    case neutral
    case rounded
}

// MARK: - Face Quality
enum FaceQuality {
    case none
    case tooFar
    case tooClose
    case offCenter
    case poor
    case good

    var message: String {
        switch self {
        case .none:
            return "No face detected"
        case .tooFar:
            return "Move closer to camera"
        case .tooClose:
            return "Move back from camera"
        case .offCenter:
            return "Center your face"
        case .poor:
            return "Improve lighting"
        case .good:
            return "Perfect! Ready to practice"
        }
    }

    var color: Color {
        switch self {
        case .none, .tooFar, .tooClose, .offCenter, .poor:
            return .red
        case .good:
            return .green
        }
    }
}
