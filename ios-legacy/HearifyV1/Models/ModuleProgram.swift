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
    // Get customized Module 1 based on hearing type
    static func module1(for hearingType: TrainingModuleType) -> ModuleProgram {
        switch hearingType {
        case .hearingLoss:
            return module1HearingLoss
        case .hearingAids:
            return module1HearingAids
        case .cochlearImplants:
            return module1CochlearImplants
        }
    }

    // Module 1 for Hearing Loss users
    private static let module1HearingLoss = ModuleProgram(
        moduleNumber: 1,
        moduleName: "Hearing Training - Understanding Your Hearing",
        icon: "ear.fill",
        description: "Comprehensive program to improve listening skills while learning about hearing loss, its causes, and management strategies. Build your understanding alongside practical training.",
        objectives: [
            "Understand different types of hearing loss and their impacts",
            "Improve word recognition accuracy to 85%+",
            "Master discrimination of similar-sounding word pairs",
            "Develop sentence comprehension skills in quiet and noise",
            "Learn about hearing protection and management",
            "Track progress and identify specific challenges"
        ],
        structure: [
            ProgramPhase(
                phaseNumber: 1,
                title: "Understanding Hearing Loss + Foundation Training",
                description: "Learn about hearing loss basics while starting phoneme discrimination training",
                exercises: [
                    "Educational: Types of hearing loss and their causes",
                    "Educational: How hearing loss affects communication",
                    "Matched Pairs - Phonetics: Distinguish minimal pairs",
                    "Matched Pairs - Vowels: Master vowel contrasts",
                    "Educational Quiz: Test your hearing loss knowledge"
                ],
                duration: "1-2 weeks, 20 minutes daily",
                successCriteria: "Complete educational modules and achieve 80% accuracy on matched pairs"
            ),
            ProgramPhase(
                phaseNumber: 2,
                title: "Communication Strategies + Word Recognition",
                description: "Learn effective communication strategies while practicing word and sentence recognition",
                exercises: [
                    "Educational: Communication strategies for hearing loss",
                    "Educational: Working with audiologists",
                    "Word Recognition: Identify spoken words",
                    "Sentence Comprehension: Practice full sentences",
                    "My Practice List: Build custom practice materials"
                ],
                duration: "2-3 weeks, 25 minutes daily",
                successCriteria: "Understand key strategies and maintain 85%+ accuracy"
            ),
            ProgramPhase(
                phaseNumber: 3,
                title: "Real-World Listening + Environmental Awareness",
                description: "Practice listening in noise while learning about challenging listening environments",
                exercises: [
                    "Educational: Managing difficult listening situations",
                    "Educational: Hearing protection and preservation",
                    "Sentences in Noise: Progressive noise training",
                    "Diagnostic Test: Track your progress",
                    "Educational Quiz: Environmental awareness"
                ],
                duration: "3-4 weeks, 30 minutes daily",
                successCriteria: "Achieve 70%+ accuracy in noise and complete educational content"
            )
        ],
        tips: [
            "Review educational content before each training session",
            "Practice in quiet initially, gradually add background noise",
            "Apply communication strategies you learn in daily life",
            "Share your progress with your audiologist",
            "Use Practice List for words you encounter in daily conversations",
            "Take breaks if you feel auditory fatigue",
            "Review educational quizzes to reinforce learning"
        ],
        estimatedDuration: "6-8 weeks for complete program"
    )

    // Module 1 for Hearing Aid users
    private static let module1HearingAids = ModuleProgram(
        moduleNumber: 1,
        moduleName: "Hearing Training - Optimizing Your Hearing Aids",
        icon: "ear.badge.waveform",
        description: "Comprehensive training program combined with hearing aid education. Learn to maximize your hearing aid benefits while improving listening skills.",
        objectives: [
            "Master hearing aid use, maintenance, and optimization",
            "Adapt to amplified sound and improve word recognition",
            "Learn troubleshooting and care techniques",
            "Develop listening skills in various environments",
            "Understand hearing aid features and settings",
            "Build confidence with your devices"
        ],
        structure: [
            ProgramPhase(
                phaseNumber: 1,
                title: "Hearing Aid Basics + Initial Training",
                description: "Learn hearing aid fundamentals while beginning auditory training",
                exercises: [
                    "Educational: Getting started with hearing aids",
                    "Educational: Daily maintenance and care",
                    "Matched Pairs: Adapt to amplified sounds",
                    "Word Recognition: Practice with your hearing aids",
                    "Educational Quiz: Hearing aid knowledge check"
                ],
                duration: "1-2 weeks, 20 minutes daily",
                successCriteria: "Complete care training and achieve 80% accuracy"
            ),
            ProgramPhase(
                phaseNumber: 2,
                title: "Advanced Features + Comprehension",
                description: "Master hearing aid features while improving sentence comprehension",
                exercises: [
                    "Educational: Understanding hearing aid programs and settings",
                    "Educational: Using telecoil and wireless features",
                    "Sentence Comprehension: Practice with different programs",
                    "Diagnostic Test: Assess performance with aids",
                    "Educational: Troubleshooting common issues"
                ],
                duration: "2-3 weeks, 25 minutes daily",
                successCriteria: "Use advanced features confidently and maintain 85%+ accuracy"
            ),
            ProgramPhase(
                phaseNumber: 3,
                title: "Real-World Optimization + Noise Training",
                description: "Optimize settings for different environments while training in noise",
                exercises: [
                    "Educational: Adjusting for different environments",
                    "Educational: Working with your audiologist for adjustments",
                    "Sentences in Noise: Test different programs and settings",
                    "Custom Practice: Focus on challenging listening situations",
                    "Educational: Long-term care and maintenance"
                ],
                duration: "3-4 weeks, 30 minutes daily",
                successCriteria: "Optimize aids for various settings and achieve 70%+ accuracy in noise"
            )
        ],
        tips: [
            "Wear your hearing aids during all training sessions",
            "Start with your everyday program, then try other settings",
            "Practice cleaning and maintenance daily",
            "Keep spare batteries or charge regularly",
            "Note which settings work best in different situations",
            "Discuss training results with your audiologist",
            "Review troubleshooting guides when needed"
        ],
        estimatedDuration: "6-8 weeks for complete program"
    )

    // Module 1 for Cochlear Implant users
    private static let module1CochlearImplants = ModuleProgram(
        moduleNumber: 1,
        moduleName: "Hearing Training - Cochlear Implant Rehabilitation",
        icon: "cpu",
        description: "Specialized auditory rehabilitation program for cochlear implant users. Develop listening skills with your implant while learning about device function and care.",
        objectives: [
            "Understand cochlear implant function and components",
            "Adapt to electrical hearing and sound processing",
            "Master device care and troubleshooting",
            "Develop word and sentence recognition skills",
            "Learn about mapping and programming",
            "Build confidence in various listening environments"
        ],
        structure: [
            ProgramPhase(
                phaseNumber: 1,
                title: "CI Fundamentals + Sound Awareness",
                description: "Learn implant basics while beginning sound awareness training",
                exercises: [
                    "Educational: How your cochlear implant works",
                    "Educational: Daily care and equipment management",
                    "Sound Awareness: Adapt to electrical hearing",
                    "Matched Pairs: Environmental sound discrimination",
                    "Educational Quiz: CI knowledge assessment"
                ],
                duration: "2-3 weeks, 25 minutes daily",
                successCriteria: "Complete care training and show sound awareness progress"
            ),
            ProgramPhase(
                phaseNumber: 2,
                title: "Speech Understanding + Device Optimization",
                description: "Develop speech recognition while learning about programming and mapping",
                exercises: [
                    "Educational: Understanding mapping and programming",
                    "Educational: Troubleshooting and accessories",
                    "Word Recognition: Build speech understanding",
                    "Sentence Comprehension: Progress to full sentences",
                    "Educational: Working with your CI audiologist"
                ],
                duration: "3-4 weeks, 30 minutes daily",
                successCriteria: "Achieve consistent word recognition and understand mapping process"
            ),
            ProgramPhase(
                phaseNumber: 3,
                title: "Complex Listening + Advanced Strategies",
                description: "Master challenging listening situations and advanced device features",
                exercises: [
                    "Educational: Advanced features and wireless connectivity",
                    "Educational: Strategies for difficult listening environments",
                    "Sentences in Noise: Progressive noise training",
                    "Diagnostic Test: Track rehabilitation progress",
                    "Educational: Long-term care and upgrades"
                ],
                duration: "4-6 weeks, 30-35 minutes daily",
                successCriteria: "Show improvement in noise and master device features"
            ),
            ProgramPhase(
                phaseNumber: 4,
                title: "Maintenance + Ongoing Rehabilitation",
                description: "Continue skill development and learn ongoing care strategies",
                exercises: [
                    "Educational: Lifelong device management",
                    "Advanced Sentence Training: Complex materials",
                    "Practice in Various Environments: Real-world testing",
                    "Educational: Music appreciation with CI",
                    "Continuous Progress Tracking"
                ],
                duration: "Ongoing practice recommended",
                successCriteria: "Demonstrate consistent performance and independence"
            )
        ],
        tips: [
            "Wear your processor during all training sessions",
            "Start with shorter sessions and gradually increase duration",
            "Keep equipment clean and check connections daily",
            "Maintain backup equipment and batteries",
            "Note any sound quality changes to discuss at mappings",
            "Practice in various environments beyond training",
            "Be patient - CI rehabilitation is a journey",
            "Attend all mapping appointments",
            "Review educational content regularly"
        ],
        estimatedDuration: "12-16 weeks for initial program, ongoing practice for continued improvement"
    )

    // Original Module 1 (default/fallback)
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
