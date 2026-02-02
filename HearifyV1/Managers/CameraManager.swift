//
//  CameraManager.swift
//  HearifyV1
//
//  Camera access and video capture for pronunciation analysis
//  Phase 3: Camera & Computer Vision
//

import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isCameraActive = false
    @Published var error: CameraError?

    private let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput?
    private let sessionQueue = DispatchQueue(label: "com.hearify.camera")
    private var isSetupComplete = false

    @Published var previewLayer: AVCaptureVideoPreviewLayer?

    // Callback for video frames
    var onFrameCaptured: ((CMSampleBuffer) -> Void)?

    override init() {
        super.init()
    }

    // MARK: - Permission
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            isAuthorized = false
            error = .permissionDenied
        @unknown default:
            isAuthorized = false
        }
    }

    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if !granted {
                    self?.error = .permissionDenied
                }
            }
        }
    }

    // MARK: - Setup Camera
    func setupCamera() {
        print("🎬 setupCamera() called")

        guard isAuthorized else {
            print("❌ Not authorized")
            DispatchQueue.main.async {
                self.error = .permissionDenied
            }
            return
        }

        guard !isSetupComplete else {
            print("⚠️ Already set up")
            return
        }

        print("✅ Starting camera setup on background queue...")
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            // Wrap entire setup in error handling
            do {
                try self.performCameraSetup()
                print("✅ Camera setup completed successfully!")
            } catch {
                print("❌ Camera setup failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.error = .setupFailed
                }
            }
        }
    }

    private func performCameraSetup() throws {
        print("🔧 performCameraSetup() starting...")
        captureSession.beginConfiguration()
        defer {
            print("📋 Committing configuration...")
            captureSession.commitConfiguration()
            self.isSetupComplete = true
            print("✓ isSetupComplete = true")
            // NOTE: Preview layer will be created AFTER session starts running
        }

        // Set session preset - use medium for better aspect ratio match
        if captureSession.canSetSessionPreset(.medium) {
            captureSession.sessionPreset = .medium
            print("✓ Set preset to Medium")
        } else if captureSession.canSetSessionPreset(.hd1280x720) {
            captureSession.sessionPreset = .hd1280x720
            print("✓ Set preset to HD 720p")
        }

        // Get front camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("❌ No front camera found!")
            throw NSError(domain: "CameraManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Front camera not available"])
        }
        print("✓ Found front camera: \(frontCamera.localizedName)")

        // Add camera input
        let input = try AVCaptureDeviceInput(device: frontCamera)
        guard captureSession.canAddInput(input) else {
            print("❌ Cannot add camera input to session")
            throw NSError(domain: "CameraManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Cannot add camera input"])
        }
        captureSession.addInput(input)
        print("✓ Added camera input")

        // Add video output
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.hearify.videoOutput"))
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        guard captureSession.canAddOutput(output) else {
            print("❌ Cannot add video output to session")
            throw NSError(domain: "CameraManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "Cannot add video output"])
        }
        captureSession.addOutput(output)
        self.videoOutput = output
        print("✓ Added video output")

        // Configure video orientation
        if let connection = output.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            // MUST disable automatic mirroring before setting manual mirroring
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
            print("✓ Configured video orientation (portrait, mirrored)")
        }
    }

    private func createPreviewLayer() {
        // MUST be called on main thread since it updates @Published property
        print("📹 createPreviewLayer() - Session running: \(self.captureSession.isRunning)")

        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspect  // Match the preview view setting
        preview.frame = .zero // Will be updated by UIViewRepresentable

        // Configure preview connection
        if let connection = preview.connection {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            // MUST disable automatic mirroring before setting manual mirroring
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
            print("✓ Preview layer connection configured")
            print("   Connection exists: YES")
            print("   Connection active: \(connection.isActive)")
            print("   Connection enabled: \(connection.isEnabled)")
            print("   Video orientation: \(connection.videoOrientation.rawValue)")
            print("   Video mirrored: \(connection.isVideoMirrored)")
        } else {
            print("❌ Preview layer has NO connection!")
        }

        self.previewLayer = preview
        print("✅ Preview layer ASSIGNED to @Published property!")
        print("   This should trigger SwiftUI to render CameraPreviewView")
    }

    // MARK: - Start/Stop
    func startCamera() {
        print("▶️ startCamera() called")

        guard isAuthorized else {
            print("❌ Not authorized, checking permission...")
            checkPermission()
            return
        }

        guard isSetupComplete else {
            print("⚠️ Setup not complete yet, skipping start")
            return
        }

        print("✅ Starting camera session on background queue...")
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard !self.captureSession.isRunning else {
                print("⚠️ Session already running")
                return
            }

            print("🎬 Calling captureSession.startRunning()...")
            self.captureSession.startRunning()
            print("✅ Camera session started!")

            // Small delay to ensure session is fully running
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isCameraActive = true
                print("✓ isCameraActive = true")

                // NOW create preview layer (session is configured AND running)
                if self.previewLayer == nil {
                    print("📹 Creating preview layer NOW (session configured + running)...")
                    self.createPreviewLayer()
                } else {
                    print("⚠️ Preview layer already exists")
                    if let layer = self.previewLayer {
                        print("   Session running: \(layer.session?.isRunning ?? false)")
                        print("   Connection active: \(layer.connection?.isActive ?? false)")
                    }
                }
            }
        }
    }

    func stopCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                DispatchQueue.main.async {
                    self.isCameraActive = false
                }
            }
        }
    }

    // MARK: - Cleanup
    func cleanup() {
        print("🧹 Cleaning up camera resources...")
        stopCamera()
        previewLayer = nil
        isSetupComplete = false
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    private static var frameCount = 0

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Log first frame and then every 30th frame
        CameraManager.frameCount += 1

        if CameraManager.frameCount == 1 {
            print("🎉 FIRST CAMERA FRAME CAPTURED!")
            print("   - Frame has image buffer: \(CMSampleBufferGetImageBuffer(sampleBuffer) != nil)")
            print("   - Connection video orientation: \(connection.videoOrientation.rawValue)")
            print("   - Connection is mirrored: \(connection.isVideoMirrored)")
        } else if CameraManager.frameCount % 30 == 0 {
            print("📹 Captured frame #\(CameraManager.frameCount) - camera is working!")
        }

        // Forward frame to callback
        onFrameCaptured?(sampleBuffer)
    }
}

// MARK: - Camera Error
enum CameraError: LocalizedError {
    case permissionDenied
    case cameraNotAvailable
    case setupFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission denied. Please enable in Settings."
        case .cameraNotAvailable:
            return "Camera not available on this device."
        case .setupFailed:
            return "Failed to setup camera."
        }
    }
}
