# Privacy Permissions Setup for Hearify

Since you're using a modern iOS project, add these permissions directly in Xcode (not via Info.plist file).

## How to Add Permissions in Xcode:

### Method 1: Using Info Tab (Recommended)

1. **Open your project in Xcode**
2. **Select the HearifyV1 target** (blue project icon in left sidebar)
3. **Click the "Info" tab**
4. **Find "Custom iOS Target Properties"**
5. **Hover over any row and click the "+" button**
6. **Add each permission below:**

### Required Permissions:

#### For Phase 2 (Speaking/Pronunciation):

**Permission 1:**
- **Key:** `Privacy - Speech Recognition Usage Description`
- **Type:** String
- **Value:** `Hearify needs access to speech recognition to analyze your pronunciation and provide feedback on your speaking skills.`

**Permission 2:**
- **Key:** `Privacy - Microphone Usage Description`
- **Type:** String
- **Value:** `Hearify needs microphone access to record your speech for pronunciation analysis and speaking practice exercises.`

#### For Phase 3 (Facial Expression/Presentation):

**Permission 3:**
- **Key:** `Privacy - Camera Usage Description`
- **Type:** String
- **Value:** `Hearify needs camera access to record your presentation practice and analyze facial expressions for engagement feedback.`

**Permission 4:**
- **Key:** `Privacy - Photo Library Additions Usage Description`
- **Type:** String
- **Value:** `Hearify needs permission to save your practice videos to your photo library.`

**Permission 5 (Optional - if you want to read from library):**
- **Key:** `Privacy - Photo Library Usage Description`
- **Type:** String
- **Value:** `Hearify needs photo library access to save your practice recordings for later review.`

---

## Alternative Method 2: Edit Info.plist in Source Code

If your project has an Info.plist file embedded in the project settings:

1. **In Xcode, find Info.plist in the Project Navigator**
2. **Right-click → Open As → Source Code**
3. **Add these entries inside the `<dict>` tag:**

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Hearify needs access to speech recognition to analyze your pronunciation and provide feedback on your speaking skills.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Hearify needs microphone access to record your speech for pronunciation analysis and speaking practice exercises.</string>

<key>NSCameraUsageDescription</key>
<string>Hearify needs camera access to record your presentation practice and analyze facial expressions for engagement feedback.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Hearify needs permission to save your practice videos to your photo library.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Hearify needs photo library access to save your practice recordings for later review.</string>
```

---

## Testing Permissions

After adding permissions:

1. **Clean build folder:** `Cmd + Shift + K`
2. **Build the project:** `Cmd + B`
3. **Run on device** (permissions won't appear in simulator for camera/mic)
4. **First time opening Phase 2/3:** You'll see permission prompts
5. **Grant permissions** to test features

---

## Troubleshooting

**If permissions don't show up:**
- Make sure you're testing on a **physical device** (not simulator)
- Clean build folder and rebuild
- Delete app from device and reinstall

**If app crashes when accessing camera/mic:**
- Check that permissions are properly added in Info tab
- Restart Xcode
- Check Console for permission-related errors

**Already denied permissions?**
- Go to **Settings → Privacy & Security**
- Find **Microphone / Camera / Speech Recognition**
- Enable for Hearify

---

## Quick Reference: Permission Keys

| Feature | Raw Key | Display Name in Xcode |
|---------|---------|----------------------|
| Speech Recognition | `NSSpeechRecognitionUsageDescription` | Privacy - Speech Recognition Usage Description |
| Microphone | `NSMicrophoneUsageDescription` | Privacy - Microphone Usage Description |
| Camera | `NSCameraUsageDescription` | Privacy - Camera Usage Description |
| Photo Library (Add) | `NSPhotoLibraryAddUsageDescription` | Privacy - Photo Library Additions Usage Description |
| Photo Library (Read) | `NSPhotoLibraryUsageDescription` | Privacy - Photo Library Usage Description |
