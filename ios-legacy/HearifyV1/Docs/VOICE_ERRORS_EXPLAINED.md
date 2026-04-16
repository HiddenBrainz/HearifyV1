# Voice Asset Query Errors - Explanation & Solutions

## What Are These Errors?

When you run the app, you're seeing errors like:
```
Query for com.apple.MobileAsset.VoiceServicesVocalizerVoice failed: 2
Query for com.apple.MobileAsset.VoiceServices.GryphonVoice failed: 2
Unable to list voice folder
```

## Why They Happen

### 1. **iOS Simulator Limitations**
- The iOS Simulator doesn't have all the voice assets that real devices have
- Enhanced voices like **Alex** and **Samantha** are often missing in the simulator
- These voices need to be downloaded from Apple's servers (not available in simulator)

### 2. **Voice Asset System**
- iOS uses a system called **MobileAsset** to download and manage voices
- When the app tries to enumerate voices, iOS attempts to query for available assets
- In the simulator, these queries fail because the assets aren't present

### 3. **Sandbox Restrictions**
- Simulator has different sandbox permissions than real devices
- Some voice folders aren't accessible in the simulator environment

## Are These Errors Critical?

**NO!** These are **harmless warnings** that don't affect app functionality:

✅ The app will still work perfectly
✅ Voices will still play (using fallback)
✅ Speech recognition will still work
✅ No crashes or functional issues

## What Happens When Voices Aren't Available?

The app has a **robust fallback system** in `VoiceSettings.swift`:

1. **First**: Try to get the requested voice (Alex or Samantha)
2. **Fallback 1**: Use any Premium quality en-US voice
3. **Fallback 2**: Use any Enhanced quality en-US voice
4. **Fallback 3**: Use any en-US voice
5. **Fallback 4**: Use system default voice

You'll see logs like:
```
⚠️ Requested voice 'com.apple.voice.enhanced.en-US.Alex' not available - using fallback
📊 Found 8 US English voices available
✅ Using enhanced fallback: Samantha
```

## How to Test Voices

### In the App:

1. Go to **Settings**
2. Scroll down and tap **"Test Alex & Samantha Voices"**
3. Check the **Xcode console** for output:

```
🎤 ===== VOICE AVAILABILITY TEST =====

📊 Total voices available: 73
📊 US English voices: 8

🔍 Checking for Alex (Male) voice...
✅ Alex voice found!
   Name: Alex
   Language: en-US
   Quality: Enhanced
   Identifier: com.apple.voice.enhanced.en-US.Alex

🔍 Checking for Samantha (Female) voice...
✅ Samantha voice found!
   Name: Samantha
   Language: en-US
   Quality: Enhanced
   Identifier: com.apple.voice.enhanced.en-US.Samantha
```

## Solutions

### Option 1: Ignore the Warnings (Recommended)
- These are iOS system warnings, not your app's errors
- The fallback system ensures voices always work
- No action needed!

### Option 2: Test on Real Device
- Run the app on a real iPhone/iPad
- Real devices have full voice assets
- Enhanced voices (Alex, Samantha) are usually pre-installed or downloadable

### Option 3: Download Voices in Simulator (Sometimes Works)
On your Mac:
1. Open **System Settings** → **Accessibility** → **Spoken Content**
2. Click **System Voice** → **Manage Voices**
3. Download "Alex" and "Samantha" (Enhanced)
4. Restart the simulator

**Note**: This may or may not work depending on macOS version.

### Option 4: Suppress Console Warnings (For Cleaner Logs)
The warnings come from iOS system, not your code. To see only your app's logs:

**In Xcode Console:**
1. Click the filter icon
2. Add filter: `-com.apple.MobileAsset`
3. This hides MobileAsset warnings

Or filter for your app only:
- Filter: `Hearify` (shows only logs with "Hearify")

## Voice Availability by Platform

| Platform | Alex | Samantha | Fallback Voices |
|----------|------|----------|-----------------|
| **Real iOS Device** | ✅ Usually Available | ✅ Usually Available | ✅ Many options |
| **iOS Simulator** | ⚠️ Sometimes Missing | ⚠️ Sometimes Missing | ✅ Basic voices |
| **macOS (for simulator)** | ✅ If downloaded | ✅ If downloaded | ✅ System voices |

## Testing Checklist

- [ ] Test voice playback in the app
- [ ] Check Xcode console for voice logs
- [ ] Verify fallback voices work
- [ ] Test on real device (if possible)
- [ ] Confirm speech recognition works
- [ ] Test voice switching (Male ↔ Female)

## Expected Behavior

### ✅ Good Logs (Voice Available):
```
✅ Found requested voice: Alex (com.apple.voice.enhanced.en-US.Alex)
🔊 Playing audio with voice: Alex
```

### ⚠️ Acceptable Logs (Using Fallback):
```
⚠️ Requested voice 'com.apple.voice.enhanced.en-US.Alex' not available - using fallback
📊 Found 8 US English voices available
✅ Using enhanced fallback: Samantha
🔊 Playing audio with fallback voice: Samantha
```

### ❌ Error (Would Need Investigation):
```
❌ No voices available at all
❌ Audio playback failed
```

## Summary

**These voice query errors are completely normal and expected in the iOS Simulator.**

The app is designed to handle missing voices gracefully with a fallback system. Your users on real devices will likely have Alex and Samantha voices available, or the app will seamlessly use the best available alternative.

**No action required** - the app is working as designed! 🎉

---

**Last Updated**: 2026-01-19
**Related Files**:
- `VoiceSettings.swift` - Voice fallback logic
- `VoiceTest.swift` - Voice diagnostic tool
- `AudioManager.swift` - Audio playback
