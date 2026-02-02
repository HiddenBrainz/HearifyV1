# 🔄 Rollback Instructions - Restore Pre-recorded Audio System

## ⚠️ IMPORTANT: Read This First

This document explains how to restore the original pre-recorded MP3 audio system if you need to roll back from the AVSpeechSynthesizer implementation.

**Date of Change**: January 9, 2026
**Changed System**: Audio playback from pre-recorded MP3 files to AVSpeechSynthesizer (TTS)

---

## 📋 What Was Changed

### Files Modified:
1. **AudioManager.swift** - Completely replaced with AVSpeech implementation
2. **VoiceSettings.swift** - Updated to map voices to AVSpeech instead of MP3 files

### Files Created (Backups):
1. **AudioManager_BACKUP_PreRecorded.swift** - Original AudioManager
2. **VoiceSettings_BACKUP.swift** - Original VoiceSettings
3. **AVSPEECH_TEST_GUIDE.md** - Testing documentation
4. **AVSpeechTestView.swift** - Test laboratory view
5. **ROLLBACK_INSTRUCTIONS.md** - This file

### Files NOT Changed:
- ContentView.swift (interface remained the same)
- All other view files
- All MP3 audio files (still in Audio/ folder)

---

## 🔙 Complete Rollback Steps

### Method 1: Quick Restore (Recommended)

**Time Required**: ~5 minutes

1. **Delete the new AudioManager.swift**:
   ```bash
   # In Terminal, navigate to project directory:
   cd "/Users/Veer/Library/Mobile Documents/com~apple~CloudDocs/HearifyV1/HearifyV1/Managers"

   # Remove new version:
   rm AudioManager.swift
   ```

2. **Restore the backup AudioManager**:
   ```bash
   # Copy backup to main file:
   cp AudioManager_BACKUP_PreRecorded.swift AudioManager.swift
   ```

3. **Delete the new VoiceSettings.swift**:
   ```bash
   cd "../Models"
   rm VoiceSettings.swift
   ```

4. **Restore the backup VoiceSettings**:
   ```bash
   cp VoiceSettings_BACKUP.swift VoiceSettings.swift
   ```

5. **Open project in Xcode and clean build**:
   - In Xcode: Product → Clean Build Folder (⇧⌘K)
   - Build project (⌘B)

6. **Run and test**:
   - Run on simulator/device
   - Test audio playback with pre-recorded files
   - Verify voice selection works

---

### Method 2: Manual Code Restoration

If you prefer to manually restore the code:

#### Step 1: Restore AudioManager.swift

Open `AudioManager.swift` and replace the entire contents with the code from `AudioManager_BACKUP_PreRecorded.swift`, specifically:

```swift
//
//  AudioManager.swift
//  HearifyV1
//
//  Audio playback management with voice selection support
//

import Foundation
import AVFoundation
import SwiftUI

// MARK: - Audio Manager
class AudioManager: ObservableObject {
    @Published private var audioPlayer = GenerateAudio(audio: "")
    private var voiceSettings: VoiceSettings?

    func setVoiceSettings(_ settings: VoiceSettings) {
        self.voiceSettings = settings
    }

    func playAudio(_ audioName: String, completion: ((Bool) -> Void)? = nil) {
        let finalAudioName: String

        // Special handling for button press and other system sounds
        if audioName == "buttonpress" {
            finalAudioName = "buttonpressMale1"
        } else if let voiceSettings = voiceSettings {
            finalAudioName = voiceSettings.getAudioFileName(for: audioName)
        } else {
            finalAudioName = "\(audioName)Male1"
        }

        audioPlayer.playAudio(audio1: finalAudioName, completion: completion)
    }

    func setVolume(_ volume: Float) {
        audioPlayer.setVolume(volume)
    }

    func setPlaybackSpeed(_ speed: Float) {
        audioPlayer.setPlaybackSpeed(speed)
    }

    func stopAudio() {
        audioPlayer.stopAudio()
    }
}

// ... (rest of GenerateAudio class from backup file)
```

**Full code available in**: `AudioManager_BACKUP_PreRecorded.swift`

#### Step 2: Restore VoiceSettings.swift

Open `VoiceSettings.swift` and replace with contents from `VoiceSettings_BACKUP.swift`.

**Key changes to restore**:
- Remove `import AVFoundation`
- Remove `avSpeechIdentifier` property
- Remove `getVoice()` method
- Remove `getAVSpeechVoice()` method
- Restore `isAvailable` to only return `true` for `.male1`

**Full code available in**: `VoiceSettings_BACKUP.swift`

---

## 🧪 Verification Checklist

After rollback, verify these work correctly:

### Audio Playback:
- [ ] Words play with pre-recorded audio
- [ ] Sentences play correctly
- [ ] Volume control works
- [ ] Speed control works (0.5x - 2.0x)
- [ ] Audio stops when needed

### Voice Selection:
- [ ] Only "Male Voice 1" shows as available
- [ ] Other voices show as "Coming Soon"
- [ ] Voice selection persists across app restarts

### No Errors:
- [ ] No build errors
- [ ] No runtime errors
- [ ] No missing audio file warnings in console

---

## 🗂️ File Locations Reference

```
HearifyV1/
├── HearifyV1/
│   ├── Managers/
│   │   ├── AudioManager.swift                          ← Current (AVSpeech version)
│   │   └── AudioManager_BACKUP_PreRecorded.swift      ← Backup (Original)
│   │
│   ├── Models/
│   │   ├── VoiceSettings.swift                        ← Current (AVSpeech version)
│   │   └── VoiceSettings_BACKUP.swift                 ← Backup (Original)
│   │
│   ├── Views/
│   │   └── AVSpeechTestView.swift                     ← New test view (can be deleted)
│   │
│   └── Audio/
│       ├── TreeMale1.mp3                              ← Still exists!
│       ├── BushMale1.mp3
│       └── ...all other MP3 files
│
├── AVSPEECH_TEST_GUIDE.md                             ← New documentation
├── ROLLBACK_INSTRUCTIONS.md                           ← This file
└── (other project files...)
```

---

## 🐛 Troubleshooting

### Problem: "Cannot find 'AudioManager' in scope"

**Solution**:
- Make sure you completely replaced AudioManager.swift
- Clean build folder (⇧⌘K)
- Rebuild project (⌘B)

### Problem: "Value of type 'VoiceSettings' has no member 'getAVSpeechVoice'"

**Solution**:
- You forgot to restore VoiceSettings.swift
- Replace with backup version
- Clean and rebuild

### Problem: "Audio files not found"

**Solution**:
- Check that MP3 files still exist in Audio/ folder
- Verify they're included in build target
- In Xcode: Select audio file → File Inspector → Target Membership → Check "HearifyV1"

### Problem: All voices show as available but shouldn't

**Solution**:
- You haven't fully restored VoiceSettings.swift
- The `isAvailable` property should return `false` for all except `.male1`

---

## 📊 Comparison: Before vs. After

| Feature | Pre-recorded (Original) | AVSpeech (New) | After Rollback |
|---------|------------------------|----------------|----------------|
| Audio Source | MP3 files | Text-to-Speech | MP3 files |
| Storage Size | ~50-100 MB | ~1 MB | ~50-100 MB |
| Vocabulary | Limited to recordings | Unlimited | Limited to recordings |
| Voice Quality | High (recorded) | Good (synthetic) | High (recorded) |
| Offline | ✅ Yes | ✅ Yes | ✅ Yes |
| Available Voices | 1 (Male1) | 12+ | 1 (Male1) |
| Speed Control | ✅ 0.5x-2.0x | ✅ 0.5x-2.0x | ✅ 0.5x-2.0x |

---

## 💾 Keep or Delete?

After successful rollback, you can **optionally** delete these files (but keep backups just in case):

### Safe to Delete:
- `AVSpeechTestView.swift` (test interface)
- `AVSPEECH_TEST_GUIDE.md` (testing documentation)

### KEEP THESE (Important backups):
- `AudioManager_BACKUP_PreRecorded.swift`
- `VoiceSettings_BACKUP.swift`
- `ROLLBACK_INSTRUCTIONS.md` (this file)

---

## ❓ Need Help?

If rollback doesn't work:

1. **Check Git history** (if using version control):
   ```bash
   git log --oneline
   git checkout <commit-before-changes>
   ```

2. **Compare files**: Use a diff tool to compare current vs. backup files

3. **Nuclear option**: If all else fails, restore from your last known good backup of the entire project

---

## 📝 Notes for Future

If you decide to try AVSpeech again in the future:

1. All backup files are preserved
2. The AVSpeech implementation is fully commented in current files
3. AVSpeechTestView.swift provides a testing environment
4. Consider a hybrid approach (AVSpeech for sentences, MP3 for phonemes)

---

**Last Updated**: January 9, 2026
**Created By**: Claude Code
**Tested**: ⚠️ Awaiting user verification
