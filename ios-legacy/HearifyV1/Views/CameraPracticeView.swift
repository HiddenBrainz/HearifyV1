//
//  CameraPracticeView.swift
//  HearifyV1
//
//  Camera-based pronunciation practice with visual feedback
//  Phase 3: Camera & Computer Vision
//

import SwiftUI

struct CameraPracticeView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var faceDetection = FaceDetectionManager()
    @StateObject private var comparisonEngine = MouthComparisonEngine()

    var exerciseText: String
    var phoneme: String
    var onDismiss: () -> Void

    @State private var showPermissionAlert = false
    @State private var isSetup = false
    @State private var showSuccessAnimation = false
    @State private var lastSuccessTime: Date?
    @State private var sessionStartTime: Date?
    @State private var bestScoreThisSession: Double = 0

    var body: some View {
        ZStack {
            // Always show black background
            Color.black.edgesIgnoringSafeArea(.all)

            // Show loading while setting up
            if !isSetup {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))

                    Text("Initializing Camera...")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }

            if isSetup {
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        // Camera Preview - full screen background
                        if let previewLayer = cameraManager.previewLayer {
                            CameraPreviewView(previewLayer: previewLayer)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea(.all)
                        } else {
                            // Show black while camera initializes with debug text
                            ZStack {
                                Color.black
                                    .ignoresSafeArea(.all)

                                VStack {
                                    Text("⚠️ Preview Layer: NIL")
                                        .foregroundColor(.red)
                                        .font(.system(size: 20, weight: .bold))
                                    Text("Session: \(cameraManager.isCameraActive ? "RUNNING" : "STOPPED")")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16))
                                }
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                            }
                        }

                // Mouth landmarks overlay (visual feedback)
                if faceDetection.faceDetected, let landmarks = faceDetection.mouthLandmarks {
                    MouthLandmarksOverlay(landmarks: landmarks, viewSize: geometry.size)
                        .allowsHitTesting(false)
                        .ignoresSafeArea(.all)
                }

                // UI Overlay
                VStack(spacing: 0) {
                    // Header
                    header

                    Spacer()

                    // Face quality indicator
                    if faceDetection.faceDetected {
                        faceQualityBanner
                    }

                    Spacer()

                    // Mouth feedback
                    if faceDetection.faceDetected, let _ = faceDetection.mouthLandmarks {
                        mouthFeedbackPanel
                    }
                }

                // Target mouth shape (top right corner)
                VStack {
                    HStack {
                        Spacer()
                        TargetMouthShapeView(
                            phoneme: phoneme,
                            matchScore: comparisonEngine.matchScore
                        )
                        .padding(.trailing, 20)
                        .padding(.top, 100)
                    }
                    Spacer()
                }
                .allowsHitTesting(false)

                // Success animation overlay
                if showSuccessAnimation {
                    SuccessAnimationView(score: comparisonEngine.matchScore)
                        .onAppear {
                            // Hide after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                showSuccessAnimation = false
                            }
                        }
                }

                    // Permission denied overlay
                    if !cameraManager.isAuthorized && !cameraManager.isCameraActive {
                        permissionDeniedView
                    }
                    }
                }
            }

            // Show permission denied even if not setup
            if !cameraManager.isAuthorized && isSetup {
                permissionDeniedView
            }
        }
        .ignoresSafeArea(.all, edges: .all)
        .onAppear {
            if !isSetup {
                isSetup = true
                sessionStartTime = Date()

                // Delay setup slightly to ensure view is fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.setupCamera()
                }
            }
        }
        .onDisappear {
            print("📱 CameraPracticeView disappearing - cleaning up")
            // Record session before cleanup
            recordSession()
            // Clean up camera resources
            cameraManager.cleanup()
            // Reset state
            isSetup = false
            showSuccessAnimation = false
            lastSuccessTime = nil
            sessionStartTime = nil
            bestScoreThisSession = 0
        }
        .onChange(of: comparisonEngine.matchScore) { newScore in
            checkForSuccess(score: newScore)
            // Track best score
            if newScore > bestScoreThisSession {
                bestScoreThisSession = newScore
            }
        }
    }

    // MARK: - Record Session
    private func recordSession() {
        guard let startTime = sessionStartTime else { return }
        guard bestScoreThisSession > 0 else { return } // Only record if user actually practiced

        let duration = Date().timeIntervalSince(startTime)

        // Record to progress manager
        ProgressManager.shared.recordSession(
            phase: 3,
            exerciseType: "Camera Vision",
            phoneme: phoneme,
            score: bestScoreThisSession,
            duration: duration
        )

        print("✅ Recorded Phase 3 session: \(phoneme), best score: \(Int(bestScoreThisSession * 100))%, duration: \(Int(duration))s")
    }

    // MARK: - Success Detection
    private func checkForSuccess(score: Double) {
        // Trigger success animation if score >= 85% and hasn't shown recently
        guard score >= 0.85 else { return }
        guard !showSuccessAnimation else { return }

        // Check if enough time has passed since last success (cooldown: 5 seconds)
        if let lastTime = lastSuccessTime, Date().timeIntervalSince(lastTime) < 5.0 {
            return
        }

        lastSuccessTime = Date()
        showSuccessAnimation = true
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            // Back button
            Button(action: {
                onDismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Spacer()

            // Exercise info
            VStack(spacing: 4) {
                Text("Camera Mode")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text(exerciseText)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.5))
            .cornerRadius(20)

            Spacer()

            // Spacer for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 50) // Extra padding to avoid notch/Dynamic Island
        .padding(.bottom, 10)
    }

    // MARK: - Face Quality Banner
    private var faceQualityBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: faceDetection.faceQuality == .good ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(faceDetection.faceQuality.color)

            Text(faceDetection.faceQuality.message)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.7))
        .cornerRadius(25)
        .padding(.top, 20)
    }

    // MARK: - Mouth Feedback Panel
    private var mouthFeedbackPanel: some View {
        VStack(spacing: 16) {
            // Match score circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: CGFloat(comparisonEngine.matchScore))
                    .stroke(comparisonEngine.matchColor, lineWidth: 8)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: comparisonEngine.matchScore)

                VStack(spacing: 4) {
                    Text("\(Int(comparisonEngine.matchScore * 100))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Match")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            // Feedback message
            if let feedback = comparisonEngine.feedback {
                VStack(spacing: 8) {
                    Text(feedback.message)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    if !feedback.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(feedback.tips, id: \.self) { tip in
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12))
                                    Text(tip)
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.7))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }

    // MARK: - Permission Denied View
    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.7))

            Text("Camera Access Required")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text("Please enable camera access in Settings to use this feature")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(AppTheme.primaryBlue)
                    .cornerRadius(25)
            }

            Button(action: { onDismiss() }) {
                Text("Go Back")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }

    // MARK: - Setup
    private func setupCamera() {
        print("🎬 CameraPracticeView.setupCamera() called")

        // Set target phoneme first
        comparisonEngine.setTarget(phoneme: phoneme)
        print("🎯 Target phoneme set: \(phoneme)")

        // Handle landmark detection - compare as soon as new landmarks are available
        faceDetection.onLandmarksDetected = { [comparisonEngine] landmarks in
            // This is already on main thread from FaceDetectionManager
            DispatchQueue.main.async {
                comparisonEngine.compare(metrics: landmarks.metrics)
            }
        }

        // Handle video frames
        cameraManager.onFrameCaptured = { [faceDetection] sampleBuffer in
            // Process with face detection
            faceDetection.processFrame(sampleBuffer)
        }

        // Check permission
        print("🔐 Checking camera permission...")
        cameraManager.checkPermission()

        // Wait for permission check, then setup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("⏱️ Permission check delay complete")
            if self.cameraManager.isAuthorized {
                print("✅ Authorized! Setting up camera...")
                self.cameraManager.setupCamera()

                // Wait for setup to complete before starting
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    print("⏱️ Setup delay complete, starting camera...")
                    self.cameraManager.startCamera()
                }
            } else {
                print("❌ Not authorized after permission check")
            }
        }
    }
}
