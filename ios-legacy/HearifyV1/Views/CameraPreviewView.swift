//
//  CameraPreviewView.swift
//  HearifyV1
//
//  SwiftUI wrapper for camera preview layer
//  Phase 3: Camera & Computer Vision
//

import SwiftUI
import AVFoundation

// Custom UIView that auto-updates preview layer frame
class PreviewContainerView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func layoutSubviews() {
        super.layoutSubviews()

        if let layer = previewLayer {
            if layer.frame != bounds {
                print("📐 PreviewContainerView layoutSubviews - updating frame to: \(bounds)")
                layer.frame = bounds
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> PreviewContainerView {
        let view = PreviewContainerView(frame: .zero)
        view.backgroundColor = .clear
        view.previewLayer = previewLayer

        // Configure preview layer
        previewLayer.videoGravity = .resizeAspect  // Changed from Fill to preserve coordinates
        previewLayer.backgroundColor = UIColor.black.cgColor

        // Add preview layer to view
        view.layer.insertSublayer(previewLayer, at: 0)

        print("📹 CameraPreviewView makeUIView() called!")
        print("   - Session running: \(previewLayer.session?.isRunning ?? false)")
        print("   - Connection exists: \(previewLayer.connection != nil)")
        print("   - Connection active: \(previewLayer.connection?.isActive ?? false)")
        print("   - Preview layer frame: \(previewLayer.frame)")
        print("   - UIView frame: \(view.frame)")

        // Add a debug label
        let debugLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 300, height: 40))
        debugLabel.text = "📹 PREVIEW VIEW"
        debugLabel.textColor = .cyan
        debugLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        debugLabel.font = UIFont.boldSystemFont(ofSize: 16)
        debugLabel.tag = 999
        view.addSubview(debugLabel)

        return view
    }

    func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        print("🔄 CameraPreviewView updateUIView() called!")
        print("   - UIView bounds: \(uiView.bounds)")
        print("   - Preview layer frame: \(previewLayer.frame)")

        // Update debug label
        if let debugLabel = uiView.viewWithTag(999) as? UILabel {
            debugLabel.text = "📹 \(Int(uiView.bounds.width))x\(Int(uiView.bounds.height))"
        }

        // Ensure preview layer is in hierarchy
        if previewLayer.superlayer == nil {
            print("⚠️ Preview layer lost! Re-adding...")
            uiView.layer.insertSublayer(previewLayer, at: 0)
        }

        // layoutSubviews will handle frame updates automatically
        uiView.setNeedsLayout()
    }
}
