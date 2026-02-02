# 🔨 Build & Test Instructions - Phase 3 Camera Features

## ⚠️ IMPORTANT: Must Use Real Device!

**The camera features require a physical iPhone/iPad.** The iOS Simulator does not have camera access, so you MUST test on a real device.

---

## 🚀 Quick Start (5 minutes)

### **Step 1: Open Project**
```bash
# Navigate to project
cd "/Users/Veer/Library/Mobile Documents/com~apple~CloudDocs/HearifyV1"

# Open in Xcode
open HearifyV1.xcodeproj
```

### **Step 2: Connect Device**
1. Plug in your iPhone/iPad via USB
2. Trust computer if prompted on device
3. In Xcode, select your device from the device menu (top bar)
4. Click the device name to open and select it

### **Step 3: Build**
1. Press **⌘B** (Command + B) to build
2. Wait for build to complete (~30 seconds)
3. Fix any errors if they appear (should be none!)

### **Step 4: Run**
1. Press **⌘R** (Command + R) to run on device
2. Wait for app to install and launch
3. If prompted, trust developer in Settings → General → VPN & Device Management

### **Step 5: Test Camera Feature**
1. In app, tap **"Speaking Practice"**
2. Select any exercise
3. Tap purple **"Practice with Camera"** button
4. Tap **"Allow"** when camera permission prompt appears
5. Position face in camera view
6. Watch match score update in real-time!

---

## 🧪 Detailed Testing Checklist

### **Phase 3: Camera & Computer Vision**

#### **1. Camera Access**
- [ ] Camera permission prompt appears on first use
- [ ] Tapping "Allow" grants permission
- [ ] Camera preview shows immediately
- [ ] Front camera is used (selfie view)
- [ ] Video is mirrored correctly
- [ ] No crashes when opening camera

#### **2. Face Detection**
- [ ] Face detected within 1-2 seconds
- [ ] Green banner shows: "Perfect! Ready to practice"
- [ ] Red banner if too close: "Move back from camera"
- [ ] Red banner if too far: "Move closer to camera"
- [ ] Red banner if off-center: "Center your face"
- [ ] Detection works in good lighting
- [ ] Detection works at different distances

#### **3. Mouth Analysis**
- [ ] Match score circle appears (0-100%)
- [ ] Score updates in real-time as mouth moves
- [ ] Circle color changes based on score:
  - [ ] Green (85%+)
  - [ ] Yellow (65-84%)
  - [ ] Red (<65%)
- [ ] Score is accurate (matches mouth position)

#### **4. Visual Feedback**
- [ ] Tips appear below score circle
- [ ] Tips are relevant to the phoneme
- [ ] Multiple tips can show at once
- [ ] "Perfect! Hold this position" when score high
- [ ] Examples of tips seen:
  - [ ] "Open your mouth more"
  - [ ] "Close your mouth slightly"
  - [ ] "Spread lips wider (like smiling)"
  - [ ] "Round lips fully (like blowing)"

#### **5. Integration**
- [ ] "Practice with Camera" button visible
- [ ] Button has purple gradient
- [ ] "OR" text separates camera from microphone
- [ ] Tapping button opens camera
- [ ] X button closes camera cleanly
- [ ] Can switch between exercises
- [ ] Camera works for different exercises

#### **6. Performance**
- [ ] UI is smooth (60 FPS)
- [ ] No lag or stuttering
- [ ] Face detection is responsive
- [ ] Score updates smoothly
- [ ] No overheating
- [ ] Battery drain acceptable

#### **7. Error Handling**
- [ ] If permission denied, shows helpful message
- [ ] "Open Settings" button works
- [ ] Can still use microphone mode
- [ ] No crashes if camera unavailable
- [ ] Graceful fallback if face not detected

---

## 🎯 Test Scenarios

### **Scenario 1: Vowel with Lip Spread (/iː/ - "sheep")**

**Expected mouth position:**
- Lips spread wide (like smiling)
- Jaw narrow (small opening)
- Opening ratio: 0.15-0.30

**Test:**
1. Find exercise with "sheep" or similar /iː/ sound
2. Open camera mode
3. Keep lips neutral → Score should be LOW (< 50%)
4. Spread lips wide → Score should INCREASE (85%+)
5. Should see tip: "Spread lips wider (like smiling)"
6. When lips spread correctly, should see "Perfect!"

**✅ Pass if:** Score increases when lips spread, shows green at 85%+

---

### **Scenario 2: Vowel with Lip Rounding (/uː/ - "food")**

**Expected mouth position:**
- Lips rounded (like blowing a kiss)
- Jaw narrow
- Opening ratio: 0.15-0.30

**Test:**
1. Find exercise with "food" or similar /uː/ sound
2. Open camera mode
3. Keep lips spread → Score LOW
4. Round lips fully → Score INCREASES
5. Should see tip: "Round lips fully (like blowing)"
6. When rounded correctly → "Perfect!"

**✅ Pass if:** Score increases with lip rounding, reaches green

---

### **Scenario 3: Open Vowel (/æ/ - "cat")**

**Expected mouth position:**
- Mouth wide open
- Lips slightly spread
- Opening ratio: 0.60-0.80

**Test:**
1. Find exercise with "cat" or similar /æ/ sound
2. Open camera mode
3. Keep mouth nearly closed → Score LOW
4. Open mouth wide → Score INCREASES
5. Should see tip: "Open your mouth more"
6. When open correctly → "Perfect!"

**✅ Pass if:** Score increases with mouth opening

---

### **Scenario 4: Face Quality Checks**

**Test:**
1. Open camera mode
2. Move very close to camera → Should say "Move back"
3. Move far away → Should say "Move closer"
4. Position face to the left → Should say "Center your face"
5. Position face to the right → Should say "Center your face"
6. Center face at good distance → Should say "Perfect! Ready to practice"

**✅ Pass if:** All warnings appear correctly

---

### **Scenario 5: Permission Handling**

**Test:**
1. Delete app from device (to reset permissions)
2. Reinstall and run
3. Go to camera mode
4. Tap "Don't Allow" when prompted
5. Should see permission denied screen
6. Tap "Open Settings" → Should open iOS Settings
7. Enable camera permission
8. Return to app
9. Try camera mode again → Should work

**✅ Pass if:** Permission flow works smoothly

---

## 🐛 Common Issues & Fixes

### **Issue: "Camera not showing / black screen"**

**Possible Causes:**
- Running on simulator instead of real device
- Camera permission denied
- Camera in use by another app

**Fix:**
1. Make sure you're on a REAL device (not simulator)
2. Check Settings → HearifyV1 → Camera is ON
3. Close other camera apps (FaceTime, Instagram, etc.)
4. Restart app
5. Restart device if needed

---

### **Issue: "Face not detected"**

**Possible Causes:**
- Lighting too dark
- Face too close/far
- Camera lens dirty or covered

**Fix:**
1. Improve lighting (turn on lights, go near window)
2. Adjust distance from camera (arm's length)
3. Clean camera lens
4. Remove anything blocking face (mask, hand, hair)
5. Make sure face is centered

---

### **Issue: "Score stuck at 0% or very low"**

**Possible Causes:**
- Face not centered properly
- Mouth not detected clearly
- Lighting issues
- Exercising wrong phoneme

**Fix:**
1. Ensure face quality shows "Perfect!"
2. Exaggerate mouth movements
3. Hold position for 2-3 seconds
4. Try better lighting
5. Check you're doing the right mouth shape for that word

---

### **Issue: "App crashes when opening camera"**

**Possible Causes:**
- Build errors
- Missing import statements
- Device compatibility

**Fix:**
1. Check Xcode console for error message
2. Clean build folder (Shift + ⌘ + K)
3. Rebuild project
4. Make sure device is iOS 14+
5. Check all new files are added to target

---

## 📊 Build Error Reference

### **If you see build errors:**

**"Cannot find type 'Color'"**
- ✅ FIXED - Added `import SwiftUI` to FaceDetectionManager.swift

**"Cannot find 'CameraPracticeView'"**
- Make sure CameraPracticeView.swift is added to project target
- Check file is in navigator

**"Cannot find 'CameraManager'"**
- Make sure all Manager files are in project
- Check they're added to target

**"Missing import"**
- Each file needs proper imports
- Check all imports are present

---

## ✅ Success Checklist

After testing, verify:

- [ ] All 7 camera features work (access, detection, analysis, feedback, integration, performance, errors)
- [ ] At least 3 test scenarios pass
- [ ] No crashes or freezes
- [ ] Smooth performance on device
- [ ] Permission handling works
- [ ] Can use both camera and microphone modes
- [ ] Face quality checks are accurate
- [ ] Match score is responsive and accurate

---

## 📝 Report Issues

If you find bugs, note:
1. **What happened:** Describe the issue
2. **Expected:** What should have happened
3. **Steps to reproduce:** How to make it happen again
4. **Device:** iPhone model and iOS version
5. **Screenshot/video:** If possible

---

## 🎉 When Testing is Complete

Phase 3 is **COMPLETE** when:
- ✅ Camera opens successfully
- ✅ Face detection works
- ✅ Match score updates in real-time
- ✅ Feedback tips appear
- ✅ No major crashes
- ✅ Performance is acceptable

---

**You're ready to test!** Connect your iPhone and let's see the camera magic in action! 📹✨
