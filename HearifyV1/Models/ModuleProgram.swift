//
//  ModuleProgram.swift
//  HearifyV1
//
//  Module program structure and manual definitions
//

import Foundation

// MARK: - Module Program Structure
struct ModuleProgram: Identifiable {
    var id: Int { moduleNumber } // Use moduleNumber as stable ID
    let moduleNumber: Int
    let moduleName: String
    let icon: String
    let description: String
    let objectives: [String]
    let structure: [ProgramPhase]
    let tips: [String]
    let estimatedDuration: String
}

struct ProgramPhase: Identifiable {
    let id = UUID()
    let phaseNumber: Int
    let title: String
    let description: String
    let exercises: [String]
    let duration: String
    let successCriteria: String
}

// MARK: - Module Programs
extension ModuleProgram {
    // Module 1: Hearing Training
    static let module1 = ModuleProgram(
        moduleNumber: 1,
        moduleName: "Hearing Training",
        icon: "ear.fill",
        description: "A comprehensive program to improve your ability to recognize words, distinguish similar sounds, comprehend sentences, and understand speech in challenging listening environments. Track your progress and get AI-powered insights.",
        objectives: [
            "Improve word recognition accuracy to 85%+",
            "Master discrimination of similar-sounding word pairs",
            "Develop sentence comprehension skills in quiet and noise",
            "Build confidence in noisy environments (restaurants, crowds)",
            "Identify specific frequency and phoneme challenges",
            "Track progress over time with detailed analytics"
        ],
        structure: [
            ProgramPhase(
                phaseNumber: 1,
                title: "Foundation - Phoneme Discrimination",
                description: "Start with minimal pair discrimination to train your ear for subtle differences",
                exercises: [
                    "Matched Pairs - Phonetics: Distinguish minimal pairs (ship/sheep, bit/beat)",
                    "Matched Pairs - Syllables: Practice syllable discrimination",
                    "Matched Pairs - Consonants: Focus on consonant differences (bad/dad)",
                    "Matched Pairs - Final Consonants: Train final position discrimination",
                    "Matched Pairs - Vowels: Master vowel contrasts (bit/bet)",
                    "Custom Practice: Create your own word pairs for targeted training"
                ],
                duration: "1-2 weeks, 15-20 minutes daily",
                successCriteria: "Achieve 80% accuracy on matched pairs"
            ),
            ProgramPhase(
                phaseNumber: 2,
                title: "Word & Sentence Recognition - Quiet",
                description: "Progress to recognizing individual words and understanding complete sentences",
                exercises: [
                    "Word Recognition: Identify spoken words and repeat them back",
                    "Sentence Comprehension: Listen and transcribe full sentences",
                    "My Practice List: Build custom word/sentence lists for your needs",
                    "Diagnostic Test: Assess baseline performance (words + sentences)"
                ],
                duration: "2-3 weeks, 20-25 minutes daily",
                successCriteria: "Maintain 85%+ accuracy in quiet conditions"
            ),
            ProgramPhase(
                phaseNumber: 3,
                title: "Listening in Noise - Real-World Training",
                description: "Gradually introduce background noise (cafe, traffic) to simulate real environments",
                exercises: [
                    "Sentences in Noise: Start with light noise (+20 dB SNR)",
                    "Sentences in Noise: Progress to moderate noise (+10 dB SNR)",
                    "Sentences in Noise: Challenge yourself with restaurant-level noise (+5 dB SNR)",
                    "Sentences in Noise: Master street-level noise (0 dB SNR)",
                    "Diagnostic Test (with noise): Track progress in challenging conditions"
                ],
                duration: "3-4 weeks, 20-30 minutes daily",
                successCriteria: "Achieve 70%+ accuracy in moderate noise (10 dB SNR)"
            ),
            ProgramPhase(
                phaseNumber: 4,
                title: "Analysis, Insights & Optimization",
                description: "Use advanced analytics and AI insights to identify weak areas and optimize training",
                exercises: [
                    "Stats & Analytics: Review detailed performance metrics by category",
                    "Practice History: View correct and missed words/sentences",
                    "AI Analysis: Get personalized recommendations from AI audiologist",
                    "Clinical Dashboard: Export progress reports for your audiologist",
                    "Targeted Practice: Focus on problematic phonemes and word pairs",
                    "Custom Word Pair Selection: Practice specific challenging pairs"
                ],
                duration: "Review weekly, adjust practice accordingly",
                successCriteria: "Show measurable improvement in identified weak areas"
            )
        ],
        tips: [
            "Start with Matched Pairs to train phoneme discrimination",
            "Practice in a quiet room initially, then gradually add background noise",
            "Use headphones or hearing aids for best results",
            "Take breaks if you feel fatigued - auditory training can be demanding",
            "Check your Stats regularly to track progress and identify patterns",
            "Use the Diagnostic Test weekly to measure improvement",
            "Create a Practice List for words/sentences you encounter daily",
            "Enable background noise settings for Sentences in Noise exercises",
            "Review your Practice History to learn from mistakes",
            "Share Clinical Dashboard reports with your audiologist or speech therapist",
            "Try the Unlimited Practice mode for extra challenge"
        ],
        estimatedDuration: "6-10 weeks for complete program, ongoing practice recommended for maintenance"
    )

    // Module 2: Speaking & Pronunciation
    static let module2 = ModuleProgram(
        moduleNumber: 2,
        moduleName: "Speaking & Pronunciation",
        icon: "mic.fill",
        description: "Develop clear pronunciation and speech patterns through structured practice with real-time feedback.",
        objectives: [
            "Improve pronunciation clarity",
            "Master difficult phonemes and sounds",
            "Build confidence in conversational speech",
            "Develop natural speech rhythm",
            "Practice real-world scenarios"
        ],
        structure: [
            ProgramPhase(
                phaseNumber: 1,
                title: "Phoneme Foundation",
                description: "Master individual sounds and basic phoneme production",
                exercises: [
                    "Visual Pronunciation: Learn mouth positions for each sound",
                    "Phoneme Visualization: Practice vowels and consonants",
                    "Targeted Practice: Focus on challenging sounds"
                ],
                duration: "2-3 weeks, 15 minutes daily",
                successCriteria: "Consistent recognition of practiced phonemes"
            ),
            ProgramPhase(
                phaseNumber: 2,
                title: "Word & Syllable Practice",
                description: "Combine phonemes into words and practice syllable stress",
                exercises: [
                    "Standard Practice: Common words and phrases",
                    "Syllable exercises: Practice word stress patterns",
                    "Minimal pairs: Distinguish similar words"
                ],
                duration: "3-4 weeks, 20 minutes daily",
                successCriteria: "Speech-to-text accuracy of 85%+"
            ),
            ProgramPhase(
                phaseNumber: 3,
                title: "Conversational Practice",
                description: "Apply skills in realistic conversation scenarios",
                exercises: [
                    "Conversation Practice: Simulated dialogues",
                    "Real-world scenarios: Restaurant, phone calls, etc.",
                    "Recording & playback: Review your progress"
                ],
                duration: "3-4 weeks, 20-25 minutes daily",
                successCriteria: "Natural conversation flow, 90%+ clarity"
            ),
            ProgramPhase(
                phaseNumber: 4,
                title: "Advanced Articulation",
                description: "Refine pronunciation and tackle complex speech patterns",
                exercises: [
                    "Advanced articulation exercises",
                    "Speed variations: Practice at different tempos",
                    "Custom sentence practice"
                ],
                duration: "Ongoing maintenance, 3-4x weekly",
                successCriteria: "Maintain clarity at various speeds"
            )
        ],
        tips: [
            "Practice in front of a mirror to observe mouth positions",
            "Record yourself to track improvement over time",
            "Start slowly and focus on accuracy before speed",
            "Use the visual feedback to perfect mouth shapes",
            "Practice difficult sounds multiple times throughout the day"
        ],
        estimatedDuration: "8-12 weeks for complete program, ongoing refinement"
    )

    // Module 3: Camera Vision Analysis
    static let module3 = ModuleProgram(
        moduleNumber: 3,
        moduleName: "Camera Vision Analysis",
        icon: "camera.fill",
        description: "Use real-time camera feedback to perfect your mouth position and articulation for each sound.",
        objectives: [
            "Master correct mouth positioning for all phonemes",
            "Develop muscle memory for articulation",
            "Improve lip rounding and spreading control",
            "Perfect jaw opening positions",
            "Build visual awareness of speech production"
        ],
        structure: [
            ProgramPhase(
                phaseNumber: 1,
                title: "Basic Mouth Positions",
                description: "Learn fundamental mouth shapes for vowels",
                exercises: [
                    "Lip Spread Practice: Wide smile sounds (ee, i)",
                    "Lip Rounding Practice: Rounded sounds (oo, u)",
                    "Jaw Opening Practice: Open vowels (ah, a)"
                ],
                duration: "1-2 weeks, 10-15 minutes daily",
                successCriteria: "Match score of 85%+ for basic vowels"
            ),
            ProgramPhase(
                phaseNumber: 2,
                title: "Consonant Articulation",
                description: "Master mouth positions for consonant sounds",
                exercises: [
                    "Plosives: p, b, t, d, k, g positions",
                    "Fricatives: f, v, s, z, sh positions",
                    "Nasals and other consonants"
                ],
                duration: "2-3 weeks, 15 minutes daily",
                successCriteria: "Match score of 80%+ for consonants"
            ),
            ProgramPhase(
                phaseNumber: 3,
                title: "Combined Positions",
                description: "Practice transitioning between mouth positions",
                exercises: [
                    "Diphthongs: Combined vowel sounds",
                    "Consonant clusters: bl, tr, st, etc.",
                    "Rapid transitions between positions"
                ],
                duration: "2-3 weeks, 15-20 minutes daily",
                successCriteria: "Smooth transitions, 75%+ match score"
            ),
            ProgramPhase(
                phaseNumber: 4,
                title: "Real-time Integration",
                description: "Apply visual feedback during actual speech",
                exercises: [
                    "Practice with Module 2 exercises using camera",
                    "Self-correction using visual feedback",
                    "Integrate into daily practice routine"
                ],
                duration: "Ongoing, use as needed for difficult sounds",
                successCriteria: "Automatic correct positioning"
            )
        ],
        tips: [
            "Ensure good lighting for camera detection",
            "Position camera at eye level for best results",
            "Focus on the target shape, not perfection",
            "Practice exaggerated movements initially",
            "Combine with Module 2 for best results",
            "Use green feedback to confirm correct position"
        ],
        estimatedDuration: "6-8 weeks for mastery, use as supplemental tool ongoing"
    )

    static let allModules: [ModuleProgram] = [module1, module2, module3]
}
