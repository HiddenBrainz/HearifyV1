//
//  TargetedPracticeView.swift
//  HearifyV1
//
//  Practice specific sound categories to target problem areas
//

import SwiftUI

// MARK: - Sound Category
enum SoundCategory: String, CaseIterable, Identifiable {
    case thSounds = "TH Sounds"
    case rSounds = "R Sounds"
    case lSounds = "L Sounds"
    case vowelSounds = "Vowel Sounds"
    case consonantClusters = "Consonant Clusters"
    case silentLetters = "Silent Letters"
    case stressPatterns = "Word Stress"
    case commonMistakes = "Common Mistakes"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .thSounds: return "t.square.fill"
        case .rSounds: return "r.square.fill"
        case .lSounds: return "l.square.fill"
        case .vowelSounds: return "a.square.fill"
        case .consonantClusters: return "textformat.size.larger"
        case .silentLetters: return "eye.slash.fill"
        case .stressPatterns: return "waveform"
        case .commonMistakes: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .thSounds: return AppTheme.primaryBlue
        case .rSounds: return AppTheme.success
        case .lSounds: return AppTheme.accentOrange
        case .vowelSounds: return AppTheme.accentPurple
        case .consonantClusters: return AppTheme.info
        case .silentLetters: return AppTheme.warning
        case .stressPatterns: return Color(red: 0.5, green: 0.2, blue: 0.8)
        case .commonMistakes: return AppTheme.error
        }
    }

    var description: String {
        switch self {
        case .thSounds:
            return "Practice the TH sound (θ). Common problem: saying 'T' or 'D' instead."
        case .rSounds:
            return "Practice American R sounds. Focus on tongue position."
        case .lSounds:
            return "Practice L sounds at different positions in words."
        case .vowelSounds:
            return "Master tricky vowel distinctions like 'i' vs 'ee'."
        case .consonantClusters:
            return "Practice words with multiple consonants together (str, spr, thr)."
        case .silentLetters:
            return "Learn words with silent letters (knight, psychology, Wednesday)."
        case .stressPatterns:
            return "Practice correct syllable stress in multi-syllable words."
        case .commonMistakes:
            return "Practice word pairs people often confuse (hello/hallow, three/tree)."
        }
    }

    var exercises: [SpeakingPracticeItem] {
        switch self {
        case .thSounds:
            return [
                SpeakingPracticeItem(text: "think", type: .word, tip: "Tongue between teeth, blow air: THINK"),
                SpeakingPracticeItem(text: "three", type: .word, tip: "TH + REE, not TREE"),
                SpeakingPracticeItem(text: "thirty", type: .word, tip: "THIR-ty, not DIR-ty"),
                SpeakingPracticeItem(text: "through", type: .word, tip: "TH-ROOOUGH (long OO sound)"),
                SpeakingPracticeItem(text: "thunder", type: .word, tip: "THUN-der, strong TH at start"),
                SpeakingPracticeItem(text: "method", type: .word, tip: "METH-od, TH in the middle"),
                SpeakingPracticeItem(text: "birthday", type: .word, tip: "BIRTH-day, TH + D together"),
                SpeakingPracticeItem(text: "thank you", type: .sentence, tip: "THANK yoo, clear TH sound"),
                SpeakingPracticeItem(text: "I think so", type: .sentence, tip: "Two TH sounds in a row"),
                SpeakingPracticeItem(text: "the weather", type: .sentence, tip: "Two different TH sounds"),
            ]
        case .rSounds:
            return [
                SpeakingPracticeItem(text: "red", type: .word, tip: "Curl tongue back, don't touch roof"),
                SpeakingPracticeItem(text: "right", type: .word, tip: "R at start: RRRIGHT"),
                SpeakingPracticeItem(text: "very", type: .word, tip: "VEH-ry, R in middle"),
                SpeakingPracticeItem(text: "car", type: .word, tip: "American R at end: CARRR"),
                SpeakingPracticeItem(text: "Paris", type: .word, tip: "PAH-ris (silent R in French, but say it in English)"),
                SpeakingPracticeItem(text: "library", type: .word, tip: "LY-brer-y, two R sounds"),
                SpeakingPracticeItem(text: "February", type: .word, tip: "FEB-roo-er-y, don't skip first R"),
                SpeakingPracticeItem(text: "really great", type: .sentence, tip: "Two R sounds close together"),
                SpeakingPracticeItem(text: "are you ready", type: .sentence, tip: "Three R sounds"),
            ]
        case .lSounds:
            return [
                SpeakingPracticeItem(text: "love", type: .word, tip: "Tongue touches roof: LUUV"),
                SpeakingPracticeItem(text: "light", type: .word, tip: "L at start: LLLITE"),
                SpeakingPracticeItem(text: "yellow", type: .word, tip: "YEL-low, L in middle"),
                SpeakingPracticeItem(text: "little", type: .word, tip: "LIT-tle, two L sounds"),
                SpeakingPracticeItem(text: "slowly", type: .word, tip: "SLOW-ly, L at end"),
                SpeakingPracticeItem(text: "paralysis", type: .word, tip: "Three L sounds"),
                SpeakingPracticeItem(text: "I like it", type: .sentence, tip: "Two L sounds"),
                SpeakingPracticeItem(text: "literally lovely", type: .sentence, tip: "Four L sounds"),
            ]
        case .vowelSounds:
            return [
                SpeakingPracticeItem(text: "sheep", type: .word, tip: "Long EE sound: SHEEEP"),
                SpeakingPracticeItem(text: "ship", type: .word, tip: "Short I sound: SHIP (not SHEEP)"),
                SpeakingPracticeItem(text: "beat", type: .word, tip: "Long EE: BEET"),
                SpeakingPracticeItem(text: "bit", type: .word, tip: "Short I: BIT"),
                SpeakingPracticeItem(text: "fool", type: .word, tip: "Long OO: FOOOL"),
                SpeakingPracticeItem(text: "full", type: .word, tip: "Short OO: FULL"),
                SpeakingPracticeItem(text: "caught", type: .word, tip: "CAWT (AW sound)"),
                SpeakingPracticeItem(text: "cot", type: .word, tip: "CAHT (AH sound)"),
                SpeakingPracticeItem(text: "hello", type: .word, tip: "hə-LO (schwa sound at start)"),
                SpeakingPracticeItem(text: "hallow", type: .word, tip: "HAL-oh (different vowel!)"),
            ]
        case .consonantClusters:
            return [
                SpeakingPracticeItem(text: "street", type: .word, tip: "STR together: STREET"),
                SpeakingPracticeItem(text: "spring", type: .word, tip: "SPR together: SPRING"),
                SpeakingPracticeItem(text: "strong", type: .word, tip: "STR + ONG"),
                SpeakingPracticeItem(text: "scratched", type: .word, tip: "SCR + ATCH + T"),
                SpeakingPracticeItem(text: "twelfth", type: .word, tip: "Four consonants at end!"),
                SpeakingPracticeItem(text: "strengths", type: .word, tip: "One of the hardest words!"),
                SpeakingPracticeItem(text: "split screen", type: .sentence, tip: "SPL + SCR clusters"),
            ]
        case .silentLetters:
            return [
                SpeakingPracticeItem(text: "knight", type: .word, tip: "Silent K: NITE"),
                SpeakingPracticeItem(text: "knife", type: .word, tip: "Silent K: NIFE"),
                SpeakingPracticeItem(text: "psychology", type: .word, tip: "Silent P: sy-KOL-ogy"),
                SpeakingPracticeItem(text: "Wednesday", type: .word, tip: "Silent D: WENZ-day"),
                SpeakingPracticeItem(text: "receipt", type: .word, tip: "Silent P: rih-SEET"),
                SpeakingPracticeItem(text: "listen", type: .word, tip: "Silent T: LIS-sen"),
                SpeakingPracticeItem(text: "answer", type: .word, tip: "Silent W: AN-ser"),
                SpeakingPracticeItem(text: "island", type: .word, tip: "Silent S: EYE-land"),
            ]
        case .stressPatterns:
            return [
                SpeakingPracticeItem(text: "present", type: .word, tip: "PREZ-ent (noun) vs pre-ZENT (verb)"),
                SpeakingPracticeItem(text: "record", type: .word, tip: "REK-ord (noun) vs re-KORD (verb)"),
                SpeakingPracticeItem(text: "photograph", type: .word, tip: "FO-to-graf (stress first)"),
                SpeakingPracticeItem(text: "photography", type: .word, tip: "fo-TOG-ra-fee (stress second)"),
                SpeakingPracticeItem(text: "comfortable", type: .word, tip: "KUMF-ter-bul (3 syllables, NOT 4)"),
                SpeakingPracticeItem(text: "definitely", type: .word, tip: "DEF-in-it-lee (stress first)"),
                SpeakingPracticeItem(text: "ということ", type: .word, tip: "Massachusetts (stress third syllable)"),
            ]
        case .commonMistakes:
            return [
                SpeakingPracticeItem(text: "hello", type: .word, tip: "hə-LO (NOT hal-oh)"),
                SpeakingPracticeItem(text: "three", type: .word, tip: "THREE (NOT tree)"),
                SpeakingPracticeItem(text: "sheet", type: .word, tip: "SHEET (NOT a bad word!)"),
                SpeakingPracticeItem(text: "beach", type: .word, tip: "BEACH (NOT another bad word!)"),
                SpeakingPracticeItem(text: "focus", type: .word, tip: "FO-cus (NOT a bad word!)"),
                SpeakingPracticeItem(text: "comfortable", type: .word, tip: "KUMF-ter-bul (NOT com-for-ta-bul)"),
                SpeakingPracticeItem(text: "library", type: .word, tip: "LY-brer-y (NOT lie-berry)"),
                SpeakingPracticeItem(text: "ask", type: .word, tip: "ASK (NOT aks)"),
                SpeakingPracticeItem(text: "espresso", type: .word, tip: "es-PRESS-o (NOT ex-press-o)"),
                SpeakingPracticeItem(text: "nuclear", type: .word, tip: "NOO-klee-er (NOT noo-kyu-lar)"),
            ]
        }
    }
}

// MARK: - Targeted Practice View
struct TargetedPracticeView: View {
    @State private var selectedCategory: SoundCategory?
    @State private var showPractice = false
    var onDismiss: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { onDismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Targeted Practice")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .opacity(0)  // Hidden spacer
                }
            }
            .padding()
            .background(AppTheme.primaryGradient)

            ScrollView {
                VStack(spacing: 16) {
                    // Header Info
                    VStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.primaryBlue)

                        Text("Focus on Your Weak Areas")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Select a sound category to practice specific pronunciation challenges")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // Categories
                    ForEach(SoundCategory.allCases) { category in
                        CategoryCard(category: category) {
                            selectedCategory = category
                            showPractice = true
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
        .sheet(isPresented: $showPractice) {
            if let category = selectedCategory {
                CategoryPracticeView(category: category) {
                    showPractice = false
                }
            }
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: SoundCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundColor(category.color)
                    .frame(width: 60, height: 60)
                    .background(category.color.opacity(0.1))
                    .cornerRadius(12)

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(category.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 10))
                        Text("\(category.exercises.count) exercises")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(category.color)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4)
        }
    }
}

// MARK: - Category Practice View
struct CategoryPracticeView: View {
    let category: SoundCategory
    var onDismiss: () -> Void

    var body: some View {
        // Reuse SpeakingPracticeView but with category-specific exercises
        CategoryPracticeWrapper(category: category, onDismiss: onDismiss)
    }
}

// MARK: - Category Practice Wrapper
struct CategoryPracticeWrapper: View {
    let category: SoundCategory
    var onDismiss: () -> Void

    @StateObject private var speechManager = SpeechRecognitionManagerAdvanced()
    // Use shared instances to avoid creating duplicates (performance issue)
    @ObservedObject private var gamificationManager = GamificationManager.shared
    @ObservedObject private var progressManager = ProgressTrackingManager.shared
    @State private var currentExerciseIndex = 0
    @State private var showResults = false
    @State private var exerciseStartTime: Date?

    var exercises: [SpeakingPracticeItem] {
        category.exercises
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { onDismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(category.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text("Exercise \(currentExerciseIndex + 1) of \(exercises.count)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .opacity(0)  // Hidden spacer
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [category.color, category.color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Content (simplified version of SpeakingPracticeView)
            ScrollView {
                VStack(spacing: 16) {
                    // Exercise card
                    if !showResults {
                        VStack(spacing: 20) {
                            Text(exercises[currentExerciseIndex].text)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(AppTheme.warning)
                                Text(exercises[currentExerciseIndex].tip)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding()
                            .background(AppTheme.warning.opacity(0.1))
                            .cornerRadius(8)

                            // Hear Pronunciation Button
                            Button(action: {
                                speechManager.playCorrectPronunciation(text: exercises[currentExerciseIndex].text)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 18))
                                    Text("Hear Pronunciation")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(category.color)
                                .cornerRadius(10)
                            }

                            // Simple mic button
                            Button(action: {
                                if speechManager.isRecording {
                                    speechManager.stopRecording()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showResults = true
                                    }
                                } else {
                                    exerciseStartTime = Date()
                                    speechManager.startRecording(expectedText: exercises[currentExerciseIndex].text)
                                }
                            }) {
                                Circle()
                                    .fill(speechManager.isRecording ? AppTheme.error : category.color)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4)
                    }

                    // Results (simple version)
                    if showResults, let result = speechManager.pronunciationResult {
                        VStack(spacing: 12) {
                            Text("\(Int(result.overallScore * 100))%")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(category.color)

                            HStack(spacing: 12) {
                                Button("Try Again") {
                                    showResults = false
                                    speechManager.pronunciationResult = nil
                                }
                                .buttonStyle(.bordered)

                                Button(currentExerciseIndex < exercises.count - 1 ? "Next" : "Finish") {
                                    if currentExerciseIndex < exercises.count - 1 {
                                        currentExerciseIndex += 1
                                        showResults = false
                                        speechManager.pronunciationResult = nil
                                    } else {
                                        onDismiss()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundPrimary)
        }
        .onAppear {
            speechManager.requestAuthorization()
        }
    }
}
