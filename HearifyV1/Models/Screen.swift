//
//  Screen.swift
//  HearifyV1
//
//  Navigation screen enum
//

import Foundation

enum Screen {
    case screen1, screen2, screen3, screen5, screen8, homescreen, beginscreen, creditsscreen, settingscreen, onboardingscreen, statsscreen, dailychallengescreen
    // Main selection screen (Auditory Training / Tutorial choice)
    case mainSelectionScreen, tutorialScreen
    // New category screens
    case wordRecognitionScreen, sentenceComprehensionScreen, sentencesInNoiseScreen, diagnosticTestScreen, matchedPairsScreen, aiAnalysisScreen, practiceListSessionScreen, customPracticeScreen
    // Phase selection screens
    case phaseSelectionScreen, speakingPracticeScreen, cameraVisionScreen
    // CloudKit / Clinician screens
    case clinicianLinkingScreen
    // Test/Developer screens
    case avSpeechTestScreen
}

// Practice List Sub-Screen State
enum PracticeListSubScreen {
    case question      // Showing question/choices
    case success       // Showing success feedback
    case incorrect     // Showing incorrect feedback
}
