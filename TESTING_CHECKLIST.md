# 🧪 HearifyV1 Testing Checklist

## Testing Date: ___________
## Tester: ___________
## Device: ___________ (iOS Version: _______)

---

## ✅ Phase 1: Navigation & Hub

### Main App Launch
- [ ] App launches without crashes
- [ ] Main screen displays correctly
- [ ] No console errors on launch
- [ ] All UI elements visible and aligned

### Phase Selection Screen
- [ ] "Speaking Practice" button visible
- [ ] Clicking "Speaking Practice" opens hub
- [ ] Navigation animation smooth
- [ ] Can navigate back to main screen

### Speaking Practice Hub
- [ ] Hub displays correctly
- [ ] All 5 feature cards visible:
  - [ ] Standard Practice
  - [ ] Targeted Practice
  - [ ] Conversation Practice
  - [ ] Progress Dashboard
  - [ ] Recording History
- [ ] User stats display (points, level, streak)
- [ ] "What You'll Get" section shows features
- [ ] All buttons are tappable
- [ ] Navigation works for all features

**Issues Found:**
```
[Write any issues here]
```

---

## ✅ Phase 2: Speaking/Pronunciation Features

### 1. Standard Practice Mode

#### Setup & Permissions
- [ ] Microphone permission prompt appears
- [ ] Speech recognition permission prompt appears
- [ ] Permissions work correctly
- [ ] Error message if permissions denied

#### Exercise Flow
- [ ] Exercise displays correctly
- [ ] Current exercise shows (1 of 30)
- [ ] Progress bar updates
- [ ] Exercise text is readable
- [ ] Pronunciation tip displays
- [ ] Exercise type badge shows (Word/Sentence)

#### Recording
- [ ] Microphone button visible and large
- [ ] Tap starts recording (turns red)
- [ ] "Recording..." indicator shows
- [ ] Live transcription appears
- [ ] Recognizes speech correctly
- [ ] Tap again stops recording
- [ ] Results appear after stopping

#### Results Screen
- [ ] Overall score displays (0-100%)
- [ ] Score circle animates
- [ ] Feedback message shows
- [ ] Phonetic analysis appears (IPA notation)
- [ ] Word-by-word accuracy breakdown
- [ ] Character-by-character comparison
- [ ] Color coding (green/yellow/red)
- [ ] "Hear Correct" button plays audio
- [ ] "Hear Yours" button plays recording
- [ ] Speed control buttons work (0.25x, 0.5x, 0.75x, 1x)
- [ ] "Waveform Comparison" button visible
- [ ] Raw sounds detected section shows
- [ ] Alternative interpretations display

#### Waveform Comparison
- [ ] Button opens full-screen view
- [ ] Target waveform displays (green)
- [ ] User waveform displays (blue)
- [ ] Waveforms are visually different
- [ ] Insights section shows explanations
- [ ] Back button returns to results
- [ ] No crashes when opening/closing

#### Navigation
- [ ] "Try Again" resets the exercise
- [ ] "Next" advances to next exercise
- [ ] Can complete 5+ exercises in a row
- [ ] "Finish" button on last exercise
- [ ] Returns to hub when finished

**Issues Found:**
```
[Write any issues here]
```

---

### 2. Targeted Practice Mode

#### Category Selection
- [ ] 8 categories display:
  - [ ] TH Sounds
  - [ ] R Sounds
  - [ ] L Sounds
  - [ ] Vowel Sounds
  - [ ] Consonant Clusters
  - [ ] Silent Letters
  - [ ] Word Stress
  - [ ] Common Mistakes
- [ ] Category cards are tappable
- [ ] Category icons display
- [ ] Difficulty badges show

#### Category Exercise Flow
- [ ] Exercises load for selected category
- [ ] 7-10 exercises per category
- [ ] Can practice any category
- [ ] Exercises specific to category
- [ ] Tips are relevant
- [ ] Recording works same as Standard Practice
- [ ] Results display correctly
- [ ] Can switch between categories

**Test Each Category:**
- [ ] TH Sounds (three vs tree)
- [ ] R Sounds (run, rice, rain)
- [ ] L Sounds (light, left, hello)
- [ ] Vowel Sounds (ship vs sheep)
- [ ] Consonant Clusters (street, spring)
- [ ] Silent Letters (knight, write)
- [ ] Word Stress (REcord vs reCORD)
- [ ] Common Mistakes (hello vs hallow)

**Issues Found:**
```
[Write any issues here]
```

---

### 3. Progress Dashboard

#### Display & Stats
- [ ] Dashboard loads without errors
- [ ] Period selector works (Week/Month/All Time)
- [ ] Average score displays correctly
- [ ] Total sessions count shows
- [ ] Current streak displays
- [ ] Score trend chart appears
- [ ] Chart has data points
- [ ] Chart line connects points
- [ ] Grid lines visible

#### Exercise Breakdown
- [ ] Exercise type breakdown shows
- [ ] Word/Sentence/Conversation stats
- [ ] Average scores per type
- [ ] Session counts per type
- [ ] Icons display correctly

#### Best Performances
- [ ] Top 5 exercises display
- [ ] Scores show (0-100%)
- [ ] Dates show correctly
- [ ] Sorted by highest score
- [ ] "No sessions yet" if empty

#### Most Practiced
- [ ] Shows most repeated exercises
- [ ] Repeat counts display
- [ ] Sorted by frequency
- [ ] "No sessions yet" if empty

**Issues Found:**
```
[Write any issues here]
```

---

### 4. Recording History

#### Grouping Options
- [ ] Group by Exercise works
- [ ] Group by Date works
- [ ] Group by Score works
- [ ] Grouping selector visible
- [ ] Toggle between options smooth

#### Exercise Group View
- [ ] Exercises group correctly
- [ ] Shows attempt count
- [ ] Shows average score
- [ ] Shows improvement rate (↑ or ↓)
- [ ] Cards expandable/collapsible
- [ ] Expansion animation smooth

#### Session Details
- [ ] Individual sessions show
- [ ] Score circles display
- [ ] Dates/times correct
- [ ] Recognized text shows
- [ ] Exercise type badges
- [ ] Color coding by score

#### Empty State
- [ ] Shows "No Recordings Yet" if empty
- [ ] Helpful message displays
- [ ] Icon shows

**Issues Found:**
```
[Write any issues here]
```

---

### 5. Waveform Comparison (Full View)

#### Visual Display
- [ ] Opens in full screen
- [ ] Header shows exercise text
- [ ] Target waveform (green) displays
- [ ] User waveform (blue) displays
- [ ] Waveforms have bars/amplitude
- [ ] Visual difference is clear
- [ ] Background colors distinct

#### Insights Section
- [ ] "What to Look For" section shows
- [ ] 4 insights display:
  - [ ] Wave height = volume
  - [ ] Wave pattern = rhythm
  - [ ] Wave length = duration
  - [ ] Peaks = emphasis
- [ ] Icons display
- [ ] Text is readable

#### Navigation
- [ ] Back button works
- [ ] Returns to results screen
- [ ] No crashes

**Issues Found:**
```
[Write any issues here]
```

---

## ✅ Phase 3: Conversation/Context Features

### Conversation Practice Hub

#### Scenario List
- [ ] Opens from Speaking Hub
- [ ] Info card displays
- [ ] Filter section shows
- [ ] Scenarios list displays
- [ ] 3 scenarios available:
  - [ ] Restaurant
  - [ ] Doctor's Office
  - [ ] Job Interview

#### Filters
- [ ] Category filter works
- [ ] All categories show
- [ ] Difficulty filter works
- [ ] Beginner/Intermediate/Advanced
- [ ] Clear filter button
- [ ] Filtered results update

#### Scenario Cards
- [ ] Title displays
- [ ] Description shows
- [ ] Category badge
- [ ] Difficulty badge (color coded)
- [ ] Turn count shows
- [ ] Key phrases count shows
- [ ] Cards are tappable

**Issues Found:**
```
[Write any issues here]
```

---

### Conversation Scenario Execution

#### Restaurant Scenario (Beginner)
- [ ] Scenario loads
- [ ] Context card shows
- [ ] Turn counter displays (Turn 1 of 6)
- [ ] Progress circle shows percentage

**Turn Flow:**
- [ ] Turn 1: Other person speaks
  - [ ] Text displays
  - [ ] "Hear Pronunciation" button works
  - [ ] Audio plays
  - [ ] "Continue" button advances
- [ ] Turn 2: User's turn
  - [ ] Suggested response shows
  - [ ] Pronunciation tip displays
  - [ ] Recording button visible
  - [ ] Can record response
  - [ ] Results show after recording
  - [ ] Score displays
  - [ ] "Next Turn" button advances
- [ ] Turns alternate correctly
- [ ] Conversation history shows past turns
- [ ] Can complete all 6 turns

**Completion:**
- [ ] "Scenario Complete!" shows
- [ ] Overall score displays
- [ ] Completion time shows
- [ ] "Practice Again" button works
- [ ] "Done" button returns to list

**Issues Found:**
```
[Write any issues here]
```

---

#### Doctor Scenario (Intermediate)
- [ ] Scenario loads
- [ ] 4 turns complete correctly
- [ ] Medical terminology recognized
- [ ] Context is clear
- [ ] Cultural notes show
- [ ] Can complete successfully

**Issues Found:**
```
[Write any issues here]
```

---

#### Job Interview Scenario (Advanced)
- [ ] Scenario loads
- [ ] 4 turns complete correctly
- [ ] Professional language recognized
- [ ] Context is appropriate
- [ ] Can complete successfully

**Issues Found:**
```
[Write any issues here]
```

---

### Conversation Features

#### Context & Tips
- [ ] Scenario context displays
- [ ] Turn context updates
- [ ] Tips are helpful
- [ ] Cultural notes show (if available)
- [ ] Key phrases highlighted

#### Conversation History
- [ ] Past turns show in bubbles
- [ ] User bubbles (right, blue)
- [ ] Other bubbles (left, gray)
- [ ] Scores show on user bubbles
- [ ] Scrollable if many turns

**Issues Found:**
```
[Write any issues here]
```

---

## ✅ Phase 1 Enhancements: Advanced Listening

### Advanced Listening Hub

#### Display
- [ ] Opens from main menu
- [ ] Info card shows
- [ ] Adaptive mode toggle visible
- [ ] Exercise filters work
- [ ] Exercise list displays

#### Adaptive Mode
- [ ] Toggle works
- [ ] Current level shows
- [ ] Recent performance shows
- [ ] Difficulty adjusts automatically (test by completing exercises)

#### Exercise Types
- [ ] Sound Discrimination
- [ ] Sentence Comprehension
- [ ] Contextual Listening
- [ ] Multiple Choice
- [ ] Fill in the Blank
- [ ] Sequencing
- [ ] Dictation

**Issues Found:**
```
[Write any issues here]
```

---

### Advanced Listening Exercises

#### Exercise Execution (Placeholder)
- [ ] Exercise opens
- [ ] Title displays
- [ ] Instructions show
- [ ] Demo "Complete Exercise" button works
- [ ] Returns to list
- [ ] Adaptive difficulty updates

**Note:** Full implementation pending

**Issues Found:**
```
[Write any issues here]
```

---

## 🐛 Critical Bugs (Must Fix)

Priority bugs that prevent app use:

1. **Bug:**
   - **Severity:** Critical/High/Medium/Low
   - **Steps to Reproduce:**
   - **Expected:**
   - **Actual:**
   - **Screenshot/Video:**

2. **Bug:**
   - **Severity:**
   - **Steps to Reproduce:**
   - **Expected:**
   - **Actual:**

3. **Bug:**
   - **Severity:**
   - **Steps to Reproduce:**
   - **Expected:**
   - **Actual:**

---

## 💡 Improvements & Polish Needed

Non-critical improvements:

1. **UI/UX Issue:**
   - **Where:**
   - **What's Wrong:**
   - **Suggestion:**

2. **Performance Issue:**
   - **Where:**
   - **What's Slow:**
   - **Suggestion:**

3. **Missing Feature:**
   - **What:**
   - **Why Needed:**
   - **Priority:**

---

## 📱 Device-Specific Issues

### iPhone 15 (or current device)
- [ ] No issues
- [ ] Issues found: ___________

### iPad (if available)
- [ ] No issues
- [ ] Issues found: ___________

### Real Device vs Simulator
- [ ] Speech recognition better on real device
- [ ] Microphone works on real device
- [ ] Simulator limitations noted

---

## ⚡ Performance Notes

- [ ] App launches quickly (< 3 seconds)
- [ ] Navigation is smooth (60fps)
- [ ] No memory warnings
- [ ] No excessive battery drain
- [ ] Audio playback smooth
- [ ] Recording responsive
- [ ] No UI freezing

**Performance Issues:**
```
[Write any performance issues here]
```

---

## ✅ Overall Test Results

### Pass/Fail Summary
- **Total Tests:** _____ / _____
- **Passed:** _____
- **Failed:** _____
- **Pass Rate:** _____%

### Recommendation
- [ ] ✅ Ready for next phase
- [ ] ⚠️ Minor fixes needed
- [ ] ❌ Major fixes required before proceeding

### Next Steps
1. ___________________________
2. ___________________________
3. ___________________________

---

## 📝 Additional Notes

```
[Any other observations, suggestions, or comments]
```

---

**Testing Completed By:** _______________
**Date:** _______________
**Signature:** _______________
