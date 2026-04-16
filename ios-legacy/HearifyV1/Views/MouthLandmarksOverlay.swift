//
//  MouthLandmarksOverlay.swift
//  HearifyV1
//
//  Visual overlay showing detected mouth landmarks
//  Phase 3: Camera & Computer Vision - Visual Feedback
//

import SwiftUI
import Vision

struct MouthLandmarksOverlay: View {
    let landmarks: MouthLandmarks
    let viewSize: CGSize

    var body: some View {
        Canvas { context, size in
            // Draw outer lips
            drawLandmarkPoints(
                context: context,
                points: landmarks.outerPoints,
                color: .green,
                size: size,
                boundingBox: landmarks.boundingBox,
                isClosed: true
            )

            // Draw inner lips
            drawLandmarkPoints(
                context: context,
                points: landmarks.innerPoints,
                color: .cyan,
                size: size,
                boundingBox: landmarks.boundingBox,
                isClosed: true
            )

            // Draw key points (corners and center)
            if landmarks.outerPoints.count >= 20 {
                // Left corner
                drawKeyPoint(context: context, point: landmarks.outerPoints[0],
                           label: "L", color: .yellow, size: size, boundingBox: landmarks.boundingBox)

                // Right corner
                drawKeyPoint(context: context, point: landmarks.outerPoints[6],
                           label: "R", color: .yellow, size: size, boundingBox: landmarks.boundingBox)

                // Top center
                drawKeyPoint(context: context, point: landmarks.outerPoints[13],
                           label: "T", color: .blue, size: size, boundingBox: landmarks.boundingBox)

                // Bottom center
                drawKeyPoint(context: context, point: landmarks.outerPoints[19],
                           label: "B", color: .blue, size: size, boundingBox: landmarks.boundingBox)
            }
        }
        .frame(width: viewSize.width, height: viewSize.height)
    }

    private func drawLandmarkPoints(context: GraphicsContext, points: [CGPoint], color: Color, size: CGSize, boundingBox: CGRect, isClosed: Bool) {
        guard !points.isEmpty else { return }

        // Convert normalized points to screen coordinates
        let screenPoints = points.map { point -> CGPoint in
            convertNormalizedPoint(point, boundingBox: boundingBox, viewSize: size)
        }

        // Draw lines connecting points
        var path = Path()
        path.move(to: screenPoints[0])
        for i in 1..<screenPoints.count {
            path.addLine(to: screenPoints[i])
        }
        if isClosed {
            path.closeSubpath()
        }

        context.stroke(path, with: .color(color), lineWidth: 2)

        // Draw small circles at each point
        for point in screenPoints {
            var pointPath = Path()
            pointPath.addEllipse(in: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6))
            context.fill(pointPath, with: .color(color))
        }
    }

    private func drawKeyPoint(context: GraphicsContext, point: CGPoint, label: String, color: Color, size: CGSize, boundingBox: CGRect) {
        let screenPoint = convertNormalizedPoint(point, boundingBox: boundingBox, viewSize: size)

        // Draw larger circle for key point
        var circlePath = Path()
        circlePath.addEllipse(in: CGRect(x: screenPoint.x - 6, y: screenPoint.y - 6, width: 12, height: 12))
        context.fill(circlePath, with: .color(color))
        context.stroke(circlePath, with: .color(.white), lineWidth: 2)

        // Draw label
        let text = Text(label)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
        context.draw(text, at: CGPoint(x: screenPoint.x, y: screenPoint.y - 15))
    }

    private func convertNormalizedPoint(_ point: CGPoint, boundingBox: CGRect, viewSize: CGSize) -> CGPoint {
        // Vision framework coordinates are normalized (0-1) with bottom-left origin
        // Points are relative to the face bounding box

        // Convert from face-relative to full-image coordinates
        let imageX = boundingBox.origin.x + point.x * boundingBox.width
        let imageY = boundingBox.origin.y + point.y * boundingBox.height

        // Flip Y axis (Vision uses bottom-left, UIKit uses top-left)
        let flippedY = 1 - imageY

        // Scale to screen size
        // Note: This assumes the video fills the entire view (resizeAspectFill)
        // For HD 720p (1280x720 = 1.78:1) on iPhone (typically 2.17:1),
        // the video is cropped on left/right sides
        let screenX = imageX * viewSize.width
        let screenY = flippedY * viewSize.height

        return CGPoint(x: screenX, y: screenY)
    }
}

// Preview helper
struct MouthLandmarksOverlay_Previews: PreviewProvider {
    static var previews: some View {
        // Mock data for preview
        let mockOuterPoints = [
            CGPoint(x: 0, y: 0.5),
            CGPoint(x: 0.1, y: 0.4),
            CGPoint(x: 0.2, y: 0.35),
            CGPoint(x: 0.3, y: 0.3),
            CGPoint(x: 0.4, y: 0.28),
            CGPoint(x: 0.5, y: 0.3),
            CGPoint(x: 1.0, y: 0.5),
            CGPoint(x: 0.9, y: 0.4),
            CGPoint(x: 0.8, y: 0.35),
            CGPoint(x: 0.7, y: 0.3),
            CGPoint(x: 0.6, y: 0.28),
            CGPoint(x: 0.5, y: 0.3),
            CGPoint(x: 0.4, y: 0.2),
            CGPoint(x: 0.5, y: 0.1),
            CGPoint(x: 0.6, y: 0.2),
            CGPoint(x: 0.7, y: 0.7),
            CGPoint(x: 0.6, y: 0.72),
            CGPoint(x: 0.5, y: 0.7),
            CGPoint(x: 0.4, y: 0.72),
            CGPoint(x: 0.5, y: 0.9),
        ]

        let mockInnerPoints = [
            CGPoint(x: 0.3, y: 0.4),
            CGPoint(x: 0.5, y: 0.35),
            CGPoint(x: 0.7, y: 0.4),
            CGPoint(x: 0.7, y: 0.6),
            CGPoint(x: 0.5, y: 0.65),
            CGPoint(x: 0.3, y: 0.6),
        ]

        let mockLandmarks = MouthLandmarks(
            outerPoints: mockOuterPoints,
            innerPoints: mockInnerPoints,
            boundingBox: CGRect(x: 0.25, y: 0.3, width: 0.5, height: 0.4),
            metrics: MouthMetrics(width: 0.3, height: 0.15, openingRatio: 0.5, lipSpread: 0.2, lipRounding: 0.4)
        )

        ZStack {
            Color.black
            MouthLandmarksOverlay(landmarks: mockLandmarks, viewSize: CGSize(width: 400, height: 800))
        }
    }
}
