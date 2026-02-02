# 🎥 Phase 3: Camera & Computer Vision - ACTUAL Implementation Plan

## Overview
Phase 3 uses the device camera and Apple's Vision framework to analyze the user's mouth position in real-time while practicing pronunciation. The system provides visual feedback on whether their mouth/lip position matches the correct articulation.

---

## 🎯 Core Features

### **1. Camera Integration**
- Access front-facing camera
- Real-time video preview
- Permission handling
- Portrait orientation lock

### **2. Face & Mouth Detection**
- Use Vision framework's face detection
- Detect facial landmarks (lips, mouth, jaw)
- Track mouth position and shape
- Calculate mouth opening ratio
- Detect lip rounding

### **3. Real-time Analysis**
- Compare user's mouth to target phoneme
- Calculate similarity score
- Detect mouth opening (wide vs narrow)
- Detect lip shape (spread vs rounded)
- Jaw position tracking

### **4. Visual Feedback Overlay**
- Green outline when correct
- Yellow when close
- Red when incorrect
- Target mouth shape guide
- Confidence percentage
- Realtime tips

### **5. Integration with Practice**
- Camera mode in pronunciation practice
- Before recording: Show target, user adjusts mouth
- During recording: Real-time feedback
- After recording: Compare actual mouth positions throughout

---

## 🛠️ Technical Stack

### **Frameworks:**
- `AVFoundation` - Camera access and capture
- `Vision` - Face and landmark detection
- `CoreML` - (Optional) Custom mouth shape model
- `SwiftUI` - UI and overlays

### **Key Classes:**
- `VNDetectFaceLandmarksRequest` - Detect facial features
- `VNFaceObservation` - Face detection results
- `AVCaptureSession` - Camera session management
- `AVCaptureVideoPreviewLayer` - Camera preview

---

## 📋 Implementation Steps

### **Step 1: Camera Manager**
- Camera permission handling
- AVCaptureSession setup
- Video preview layer
- Front camera selection

### **Step 2: Face Detection**
- Vision request setup
- Face landmark detection
- Lip points extraction
- Continuous analysis loop

### **Step 3: Mouth Analysis**
- Calculate mouth opening ratio (height/width)
- Calculate lip spread (horizontal distance)
- Detect lip rounding (shape analysis)
- Jaw opening estimation

### **Step 4: Comparison Logic**
- Target mouth metrics for each phoneme
- Similarity calculation algorithm
- Threshold-based feedback
- Color-coded visual indicators

### **Step 5: Camera Practice View**
- Live camera preview
- Overlay with face detection
- Target shape guide
- Real-time score display
- Record button with camera active

### **Step 6: Integration**
- Add "Camera Mode" toggle to practice
- Show camera view before/during recording
- Save camera analysis with results
- Compare mouth positions in results

---

## 📁 Files to Create

### **Managers:**
- `CameraManager.swift` - Camera access and session
- `FaceDetectionManager.swift` - Vision framework face detection
- `MouthAnalyzer.swift` - Mouth shape analysis
- `MouthComparisonEngine.swift` - Compare user vs target

### **Models:**
- `MouthMetrics.swift` - Mouth measurement data
- `MouthTarget.swift` - Target mouth positions for phonemes
- `FaceLandmarks.swift` - Face landmark data

### **Views:**
- `CameraPreviewView.swift` - Camera preview with UIViewRepresentable
- `CameraPracticeView.swift` - Main camera practice interface
- `MouthOverlayView.swift` - Visual feedback overlay
- `CameraModeToggle.swift` - Toggle for camera mode

---

## 🎨 Visual Feedback Design

### **Overlay Elements:**

1. **Face Detection Box**
   - Green border when face detected
   - Red when no face or too far/close

2. **Mouth Region Highlight**
   - Outline around detected mouth
   - Color-coded: Green (correct), Yellow (close), Red (wrong)

3. **Target Shape Guide**
   - Semi-transparent target mouth shape
   - Position guide for alignment
   - Reference image for phoneme

4. **Metrics Display**
   - Mouth opening: 45% (Target: 40-50%)
   - Lip spread: Wide ✓
   - Match score: 85%

5. **Tips Overlay**
   - "Open wider"
   - "Round your lips more"
   - "Perfect! Hold this position"

---

## 🧮 Mouth Analysis Algorithm

### **Metrics to Calculate:**

1. **Mouth Height**
   ```swift
   let upperLip = landmarks.outerLips.pointsInImage(imageSize: size)[13]
   let lowerLip = landmarks.outerLips.pointsInImage(imageSize: size)[19]
   let height = abs(upperLip.y - lowerLip.y)
   ```

2. **Mouth Width**
   ```swift
   let leftCorner = landmarks.outerLips.pointsInImage(imageSize: size)[0]
   let rightCorner = landmarks.outerLips.pointsInImage(imageSize: size)[6]
   let width = abs(rightCorner.x - leftCorner.x)
   ```

3. **Opening Ratio**
   ```swift
   let ratio = height / width
   // Close vowels: < 0.3
   // Mid vowels: 0.3 - 0.6
   // Open vowels: > 0.6
   ```

4. **Lip Rounding**
   ```swift
   // Calculate circularity of lip shape
   let perimeter = calculatePerimeter(landmarks.outerLips)
   let area = calculateArea(landmarks.outerLips)
   let circularity = (4 * .pi * area) / (perimeter * perimeter)
   // More circular = more rounded
   ```

---

## 📊 Target Metrics for Phonemes

### Example Targets:

```swift
// /iː/ (sheep) - Close front vowel
MouthTarget(
    phoneme: "iː",
    openingRatio: 0.2...0.3,  // Narrow
    lipSpread: .wide,
    lipRounding: .none,
    jawOpening: .narrow
)

// /ɑː/ (father) - Open back vowel
MouthTarget(
    phoneme: "ɑː",
    openingRatio: 0.7...0.9,  // Wide
    lipSpread: .neutral,
    lipRounding: .none,
    jawOpening: .veryWide
)

// /uː/ (food) - Close back rounded vowel
MouthTarget(
    phoneme: "uː",
    openingRatio: 0.2...0.3,  // Narrow
    lipSpread: .narrow,
    lipRounding: .full,
    jawOpening: .narrow
)
```

---

## 🚀 Implementation Priority

### **Phase 3A: Camera Basics** (Day 1)
1. ✅ Camera permission and setup
2. ✅ Camera preview view
3. ✅ Face detection integration
4. ✅ Basic landmark visualization

### **Phase 3B: Mouth Analysis** (Day 2)
1. ✅ Extract mouth points
2. ✅ Calculate metrics
3. ✅ Create target database
4. ✅ Comparison algorithm

### **Phase 3C: Visual Feedback** (Day 3)
1. ✅ Overlay system
2. ✅ Color-coded feedback
3. ✅ Real-time tips
4. ✅ Score display

### **Phase 3D: Integration** (Day 4)
1. ✅ Add to pronunciation practice
2. ✅ Camera mode toggle
3. ✅ Record with camera
4. ✅ Results with camera analysis

---

## 🔒 Privacy & Permissions

### **Info.plist Entries:**
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is used to analyze your mouth position and provide pronunciation feedback</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Save practice session recordings with visual feedback</string>
```

### **Permission Handling:**
- Request on first camera mode use
- Graceful fallback if denied
- Settings redirect option
- Privacy-first approach (no recording saved unless user wants)

---

## 📱 User Flow

### **Using Camera Mode:**

1. **Enable Camera Mode**
   - Toggle in practice settings
   - Permission prompt appears
   - Camera preview shows

2. **Position Face**
   - Center face in frame
   - Adjust distance (guidance shown)
   - Face detection confirms ready

3. **Select Exercise**
   - Choose phoneme/word to practice
   - Target mouth shape shows
   - Tips display

4. **Practice**
   - Adjust mouth to match target
   - Real-time feedback (colors)
   - Score updates continuously
   - Tips guide adjustments

5. **Record**
   - Hold correct position
   - Tap record
   - Camera analysis + audio recording
   - Dual feedback (visual + audio)

6. **Review**
   - See mouth position timeline
   - Audio waveform + mouth opening graph
   - Identify where mouth was wrong
   - Specific improvement tips

---

## 🎯 Success Metrics

### **Technical:**
- Face detection: >30 FPS
- Landmark detection: <50ms latency
- Comparison calculation: <10ms
- UI updates: 60 FPS smooth

### **User Experience:**
- Clear visual feedback
- Accurate mouth analysis (>85%)
- Helpful realtime tips
- Easy to understand

---

## 🔮 Future Enhancements

### **Short-term:**
1. Side-view camera option
2. Tongue visibility detection (for TH)
3. Smile detection (for lip spread)
4. Screenshot best position

### **Long-term:**
1. AR overlays with ARKit
2. 3D face mesh analysis
3. Custom CoreML model for mouth shapes
4. Multi-person practice (compare with friend)
5. Slow-motion replay of mouth movement

---

## 🚀 Let's Build!

Starting with camera integration and face detection...
