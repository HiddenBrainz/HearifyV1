//
//  AIAnalysisService.swift
//  HearifyV1
//
//  AI Analysis Service - ChatGPT-powered practice insights
//  Pipeline: Data Collection → Preprocessing → Feature Extraction → LLM Analysis → Audiologist Review
//

import Foundation
import SwiftUI

// MARK: - AI Analysis Service
@MainActor
class AIAnalysisService: ObservableObject {
    static let shared = AIAnalysisService()

    @Published var isAnalyzing = false
    @Published var currentReport: AIAnalysisReport?
    @Published var analysisError: String?

    // ChatGPT API Configuration
    private let apiKey: String
    private let apiEndpoint = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4" // or "gpt-3.5-turbo" for faster/cheaper

    init() {
        // Load API key from UserDefaults or Config
        self.apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        print("✅ AIAnalysisService initialized")
    }

    // MARK: - Main Analysis Pipeline
    func generateAnalysis(forUserId userId: String = "default") async throws -> AIAnalysisReport {
        isAnalyzing = true
        analysisError = nil

        defer {
            Task { @MainActor in
                isAnalyzing = false
            }
        }

        print("🤖 Starting AI analysis pipeline...")

        // STEP 1: DATA COLLECTION
        print("📊 Step 1: Collecting practice session data...")
        let rawData = collectPracticeData()

        // STEP 2: PREPROCESSING
        print("🔧 Step 2: Preprocessing data...")
        let preprocessedData = preprocessData(rawData)

        // STEP 3: FEATURE EXTRACTION
        print("🔍 Step 3: Extracting features...")
        let features = extractFeatures(from: preprocessedData)

        // STEP 4: AI LAYER (ChatGPT API)
        print("🧠 Step 4: Running LLM analysis...")
        let aiInsights = try await performLLMAnalysis(features: features)

        // STEP 5: BUILD REPORT
        print("📋 Step 5: Building analysis report...")
        let report = buildReport(features: features, aiInsights: aiInsights)

        await MainActor.run {
            currentReport = report
        }

        print("✅ AI analysis complete!")
        return report
    }

    // MARK: - STEP 1: Data Collection
    private func collectPracticeData() -> RawPracticeData {
        let progressManager = ProgressTrackingManager.shared

        // Collect all sessions (limit to last 100 for performance)
        let recentSessions = Array(progressManager.allSessions.prefix(100))

        print("   → Collected \(recentSessions.count) practice sessions")

        return RawPracticeData(
            sessions: recentSessions,
            collectionDate: Date()
        )
    }

    // MARK: - STEP 2: Preprocessing
    private func preprocessData(_ rawData: RawPracticeData) -> PreprocessedData {
        var normalizedTranscripts: [NormalizedTranscript] = []

        for session in rawData.sessions {
            // Normalize text
            let normalizedExpected = normalizeText(session.exerciseText)
            let normalizedRecognized = normalizeText(session.recognizedText)

            // Segment into words
            let expectedWords = segmentIntoWords(normalizedExpected)
            let recognizedWords = segmentIntoWords(normalizedRecognized)

            // Segment into phonemes (simplified - group by similar sounds)
            let expectedPhonemes = segmentIntoPhonemes(normalizedExpected)
            let recognizedPhonemes = segmentIntoPhonemes(normalizedRecognized)

            let transcript = NormalizedTranscript(
                sessionId: session.id,
                date: session.date,
                exerciseType: session.exerciseType,
                expectedText: normalizedExpected,
                recognizedText: normalizedRecognized,
                expectedWords: expectedWords,
                recognizedWords: recognizedWords,
                expectedPhonemes: expectedPhonemes,
                recognizedPhonemes: recognizedPhonemes,
                score: session.score,
                duration: session.duration
            )

            normalizedTranscripts.append(transcript)
        }

        print("   → Normalized \(normalizedTranscripts.count) transcripts")
        print("   → Segmented into words and phonemes")

        return PreprocessedData(transcripts: normalizedTranscripts)
    }

    // Helper: Normalize text
    private func normalizeText(_ text: String) -> String {
        return text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
    }

    // Helper: Segment into words
    private func segmentIntoWords(_ text: String) -> [String] {
        return text
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
    }

    // Helper: Segment into phonemes (simplified - group by phonetic categories)
    private func segmentIntoPhonemes(_ text: String) -> [PhonemeSegment] {
        // Simplified phoneme detection - in real app, use proper phonetic library
        let words = segmentIntoWords(text)
        var phonemes: [PhonemeSegment] = []

        for word in words {
            // Detect phonetic patterns
            let category = detectPhoneticCategory(word)
            phonemes.append(PhonemeSegment(
                text: word,
                category: category,
                position: phonemes.count
            ))
        }

        return phonemes
    }

    // Helper: Detect phonetic category
    private func detectPhoneticCategory(_ word: String) -> PhoneticCategory {
        let lower = word.lowercased()

        // Nasals (m, n, ng)
        if lower.contains("m") || lower.contains("n") || lower.contains("ng") {
            return .nasals
        }

        // Liquids (l, r)
        if lower.contains("l") || lower.contains("r") {
            return .liquids
        }

        // Fricatives (f, v, s, z, th, sh)
        if lower.contains("f") || lower.contains("v") || lower.contains("s") || lower.contains("z") ||
           lower.contains("th") || lower.contains("sh") {
            return .fricatives
        }

        // Plosives (p, b, t, d, k, g)
        if lower.contains("p") || lower.contains("b") || lower.contains("t") || lower.contains("d") ||
           lower.contains("k") || lower.contains("g") {
            return .plosives
        }

        // Vowels
        if lower.contains("a") || lower.contains("e") || lower.contains("i") ||
           lower.contains("o") || lower.contains("u") {
            return .vowels
        }

        return .consonants
    }

    // MARK: - STEP 3: Feature Extraction
    private func extractFeatures(from data: PreprocessedData) -> ExtractedFeatures {
        var missedWords: [MissedWord] = []
        var phoneticConfusions: [PhoneticConfusion] = []
        var repeatedPatterns: [RepeatedPattern] = []

        // Track word occurrences for pattern detection
        var wordErrorCounts: [String: Int] = [:]
        var phoneticErrorCounts: [String: Int] = [:]

        // Analyze each transcript
        for transcript in data.transcripts {
            // Find missed words
            for expectedWord in transcript.expectedWords {
                if !transcript.recognizedWords.contains(expectedWord) {
                    missedWords.append(MissedWord(
                        word: expectedWord,
                        context: transcript.expectedText,
                        date: transcript.date,
                        exerciseType: transcript.exerciseType
                    ))

                    // Track for patterns
                    wordErrorCounts[expectedWord, default: 0] += 1
                }
            }

            // Find phonetic confusions
            for (index, expectedPhoneme) in transcript.expectedPhonemes.enumerated() {
                if index < transcript.recognizedPhonemes.count {
                    let recognizedPhoneme = transcript.recognizedPhonemes[index]

                    if expectedPhoneme.text != recognizedPhoneme.text &&
                       expectedPhoneme.category == recognizedPhoneme.category {
                        // Same category but different word = confusion
                        let confusionKey = "\(expectedPhoneme.category.rawValue): \(expectedPhoneme.text) → \(recognizedPhoneme.text)"
                        phoneticErrorCounts[confusionKey, default: 0] += 1

                        phoneticConfusions.append(PhoneticConfusion(
                            expectedSound: expectedPhoneme.text,
                            heardSound: recognizedPhoneme.text,
                            category: expectedPhoneme.category,
                            date: transcript.date
                        ))
                    }
                }
            }
        }

        // Identify repeated patterns (errors that occur 3+ times)
        for (word, count) in wordErrorCounts where count >= 3 {
            repeatedPatterns.append(RepeatedPattern(
                pattern: "Repeatedly missed: \(word)",
                occurrences: count,
                category: "Missed Words",
                severity: count >= 5 ? "High" : "Medium"
            ))
        }

        for (confusion, count) in phoneticErrorCounts where count >= 3 {
            repeatedPatterns.append(RepeatedPattern(
                pattern: "Phonetic confusion: \(confusion)",
                occurrences: count,
                category: "Phonetic Errors",
                severity: count >= 5 ? "High" : "Medium"
            ))
        }

        // Calculate overall stats
        let totalAttempts = data.transcripts.count
        let totalErrors = missedWords.count
        let accuracy = totalAttempts > 0 ? Double(totalAttempts - totalErrors) / Double(totalAttempts) : 0.0

        print("   → Found \(missedWords.count) missed words")
        print("   → Found \(phoneticConfusions.count) phonetic confusions")
        print("   → Identified \(repeatedPatterns.count) repeated patterns")

        return ExtractedFeatures(
            missedWords: missedWords,
            phoneticConfusions: phoneticConfusions,
            repeatedPatterns: repeatedPatterns,
            totalSessions: totalAttempts,
            totalErrors: totalErrors,
            overallAccuracy: accuracy
        )
    }

    // MARK: - STEP 4: AI Layer (ChatGPT API)
    private func performLLMAnalysis(features: ExtractedFeatures) async throws -> AIInsights {
        guard !apiKey.isEmpty else {
            throw AIAnalysisError.missingAPIKey
        }

        // Build prompt for ChatGPT
        let prompt = buildAnalysisPrompt(features: features)

        // Call ChatGPT API
        let response = try await callChatGPTAPI(prompt: prompt)

        // Parse response
        let insights = parseAIResponse(response)

        print("   → LLM identified \(insights.identifiedTrends.count) trends")
        print("   → LLM suggested \(insights.hypotheses.count) hypotheses")

        return insights
    }

    // Build analysis prompt
    private func buildAnalysisPrompt(features: ExtractedFeatures) -> String {
        var prompt = """
        You are an AI assistant helping audiologists analyze speech therapy practice data.
        Your role is to identify trends and suggest hypotheses, NOT to make prescriptions or decisions.

        **IMPORTANT**: Frame all suggestions as "possible areas to adjust" for the audiologist to review.

        ## Practice Data Summary

        Total Sessions: \(features.totalSessions)
        Total Errors: \(features.totalErrors)
        Overall Accuracy: \(String(format: "%.1f%%", features.overallAccuracy * 100))

        ## Missed Words (\(features.missedWords.count) instances)
        """

        // Add top missed words
        let missedWordGroups = Dictionary(grouping: features.missedWords) { $0.word }
        let topMissed = missedWordGroups
            .map { (word: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(10)

        for item in topMissed {
            prompt += "\n- '\(item.word)' missed \(item.count) times"
        }

        prompt += "\n\n## Phonetic Confusions (\(features.phoneticConfusions.count) instances)\n"

        // Add phonetic confusions
        let confusionGroups = Dictionary(grouping: features.phoneticConfusions) {
            "\($0.expectedSound) → \($0.heardSound) (\($0.category.rawValue))"
        }
        let topConfusions = confusionGroups
            .map { (confusion: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(5)

        for item in topConfusions {
            prompt += "\n- \(item.confusion): \(item.count) times"
        }

        prompt += "\n\n## Repeated Patterns (\(features.repeatedPatterns.count) identified)\n"

        for pattern in features.repeatedPatterns.prefix(5) {
            prompt += "\n- [\(pattern.severity)] \(pattern.pattern) (\(pattern.occurrences) occurrences)"
        }

        prompt += """


        ## Your Task

        1. **Identify Trends**: What patterns do you observe across the data?
        2. **Suggest Hypotheses**: What might explain these patterns? (Frame as possibilities, not certainties)
        3. **Possible Adjustments**: What areas could the audiologist consider exploring?

        **Remember**: Use language like "may indicate", "could suggest", "might benefit from", NOT "must do" or "should do".

        Format your response as JSON:
        {
          "identifiedTrends": ["trend 1", "trend 2", ...],
          "hypotheses": ["hypothesis 1", "hypothesis 2", ...],
          "possibleAdjustments": ["adjustment 1", "adjustment 2", ...],
          "summary": "brief summary for audiologist"
        }
        """

        return prompt
    }

    // Call ChatGPT API
    private func callChatGPTAPI(prompt: String) async throws -> String {
        guard let url = URL(string: apiEndpoint) else {
            throw AIAnalysisError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are an AI assistant for audiologists analyzing speech therapy data. Provide insights in JSON format."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIAnalysisError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw AIAnalysisError.apiError(statusCode: httpResponse.statusCode)
        }

        // Parse ChatGPT response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIAnalysisError.invalidResponse
        }

        return content
    }

    // Parse AI response
    private func parseAIResponse(_ response: String) -> AIInsights {
        // Try to parse JSON response
        guard let jsonData = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            // Fallback if not valid JSON
            return AIInsights(
                identifiedTrends: ["Unable to parse AI response"],
                hypotheses: [],
                possibleAdjustments: [],
                summary: response
            )
        }

        let trends = json["identifiedTrends"] as? [String] ?? []
        let hypotheses = json["hypotheses"] as? [String] ?? []
        let adjustments = json["possibleAdjustments"] as? [String] ?? []
        let summary = json["summary"] as? String ?? "AI analysis complete"

        return AIInsights(
            identifiedTrends: trends,
            hypotheses: hypotheses,
            possibleAdjustments: adjustments,
            summary: summary
        )
    }

    // MARK: - STEP 5: Build Report
    private func buildReport(features: ExtractedFeatures, aiInsights: AIInsights) -> AIAnalysisReport {
        // Convert features to report format
        let recommendations = aiInsights.possibleAdjustments.map { adjustment in
            AudiologistRecommendation(
                title: "Possible Area to Explore",
                description: adjustment,
                priority: .medium,
                category: .focusedTraining
            )
        }

        // Build frequency analysis (simplified)
        let frequencyAnalysis: [FrequencyRange: Double] = [
            .lowFrequency: 0.8,
            .midFrequency: 0.85,
            .highFrequency: 0.75,
            .veryHighFrequency: 0.7
        ]

        // Build phonetic analysis
        var phoneticAnalysis: [PhoneticCategory: Double] = [:]
        let totalPhonetic = Double(features.phoneticConfusions.count)

        // Manually iterate through phonetic categories (no allCases)
        let categories: [PhoneticCategory] = [.vowels, .consonants, .fricatives, .plosives, .nasals, .liquids]
        for category in categories {
            let count = features.phoneticConfusions.filter { $0.category == category }.count
            phoneticAnalysis[category] = totalPhonetic > 0 ? Double(count) / totalPhonetic : 0.0
        }

        // Build top problematic words
        let wordGroups = Dictionary(grouping: features.missedWords) { $0.word }
        let topProblematic = wordGroups
            .map { (word: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(10)
            .map { ProblematicWord(word: $0.word, errorCount: $0.count, contexts: []) }

        // Build phonetic errors with proper difference analysis
        let phoneticErrors = features.phoneticConfusions.prefix(20).map { confusion in
            let analysis = analyzeWordDifference(word1: confusion.expectedSound, word2: confusion.heardSound)

            let difference = PhoneticDifference(
                word1: confusion.expectedSound,
                word2: confusion.heardSound,
                differenceType: analysis.type,
                differingPhoneme1: analysis.phoneme1,
                differingPhoneme2: analysis.phoneme2,
                position: analysis.position
            )

            return PhoneticError(
                difference: difference,
                missCount: 1,
                lastMissed: confusion.date
            )
        }

        // Helper function to analyze actual difference between two words
        func analyzeWordDifference(word1: String, word2: String) -> (type: PhoneticDifferenceType, phoneme1: String, phoneme2: String, position: String) {
            let w1 = word1.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let w2 = word2.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

            // Safety check: handle empty strings
            guard !w1.isEmpty && !w2.isEmpty else {
                return (.consonantCluster, w1.isEmpty ? "" : String(w1.prefix(1)), w2.isEmpty ? "" : String(w2.prefix(1)), "unknown")
            }

            // Find where they differ
            var diffIndex = -1
            let minLen = min(w1.count, w2.count)

            // Check from start
            for i in 0..<minLen {
                let idx1 = w1.index(w1.startIndex, offsetBy: i)
                let idx2 = w2.index(w2.startIndex, offsetBy: i)
                if w1[idx1] != w2[idx2] {
                    diffIndex = i
                    break
                }
            }

            // If no difference found in common part, difference is in length
            if diffIndex == -1 {
                if w1.count != w2.count {
                    // Length difference
                    let longerWord = w1.count > w2.count ? w1 : w2
                    let shorterWord = w1.count > w2.count ? w2 : w1
                    let extraPart = String(longerWord.suffix(longerWord.count - shorterWord.count))
                    return (.finalConsonant, extraPart, "", "final")
                } else {
                    // Identical words - shouldn't happen but handle gracefully
                    return (.consonantCluster, String(w1.prefix(1)), String(w2.prefix(1)), "identical")
                }
            }

            // Determine position - safe division
            let position: String
            let relativePos = w1.count > 0 ? Double(diffIndex) / Double(w1.count) : 0.0
            if diffIndex == 0 {
                position = "initial"
            } else if relativePos < 0.33 {
                position = "initial"
            } else if relativePos > 0.66 {
                position = "final"
            } else {
                position = "medial"
            }

            // Extract differing phonemes - SAFE indexing
            let char1: String
            let char2: String

            if diffIndex < w1.count {
                let idx1 = w1.index(w1.startIndex, offsetBy: diffIndex)
                char1 = String(w1[idx1])
            } else {
                char1 = ""
            }

            if diffIndex < w2.count {
                let idx2 = w2.index(w2.startIndex, offsetBy: diffIndex)
                char2 = String(w2[idx2])
            } else {
                char2 = ""
            }

            // Determine type based on characters - SAFE access without force unwrap
            let vowels = Set("aeiou")
            let liquids = Set("lr")
            let nasals = Set("mn")
            let fricatives = Set("fvszh")

            let type: PhoneticDifferenceType
            let char1Lower = char1.lowercased().first
            let char2Lower = char2.lowercased().first

            if let c1 = char1Lower, vowels.contains(c1) {
                type = .vowel
            } else if let c2 = char2Lower, vowels.contains(c2) {
                type = .vowel
            } else if let c1 = char1Lower, let c2 = char2Lower, liquids.contains(c1) && liquids.contains(c2) {
                type = .liquids
            } else if let c1 = char1Lower, nasals.contains(c1) {
                type = .nasals
            } else if let c2 = char2Lower, nasals.contains(c2) {
                type = .nasals
            } else if let c1 = char1Lower, fricatives.contains(c1) {
                type = .fricatives
            } else if let c2 = char2Lower, fricatives.contains(c2) {
                type = .fricatives
            } else if position == "initial" {
                type = .initialConsonant
            } else if position == "final" {
                type = .finalConsonant
            } else {
                type = .consonantCluster
            }

            return (type, char1, char2, position)
        }

        return AIAnalysisReport(
            generatedDate: Date(),
            totalMissedWords: features.missedWords.count,
            totalMissedSentences: 0, // TODO: track separately
            overallAccuracy: features.overallAccuracy,
            recommendations: recommendations,
            frequencyAnalysis: frequencyAnalysis,
            phoneticAnalysis: phoneticAnalysis,
            topProblematicWords: Array(topProblematic),
            phoneticErrors: Array(phoneticErrors),
            aiInsights: aiInsights,
            rawFeatures: features
        )
    }

    // MARK: - API Key Management
    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "openai_api_key")
    }

    func hasAPIKey() -> Bool {
        return !apiKey.isEmpty
    }
}

// MARK: - Data Models

// Raw practice data
struct RawPracticeData {
    let sessions: [PracticeSession]
    let collectionDate: Date
}

// Normalized transcript
struct NormalizedTranscript {
    let sessionId: UUID
    let date: Date
    let exerciseType: ExerciseType
    let expectedText: String
    let recognizedText: String
    let expectedWords: [String]
    let recognizedWords: [String]
    let expectedPhonemes: [PhonemeSegment]
    let recognizedPhonemes: [PhonemeSegment]
    let score: Double
    let duration: TimeInterval
}

// Phoneme segment
struct PhonemeSegment {
    let text: String
    let category: PhoneticCategory
    let position: Int
}

// Preprocessed data
struct PreprocessedData {
    let transcripts: [NormalizedTranscript]
}

// Missed word
struct MissedWord: Codable {
    let word: String
    let context: String
    let date: Date
    let exerciseType: ExerciseType
}

// Phonetic confusion
struct PhoneticConfusion: Codable {
    let expectedSound: String
    let heardSound: String
    let category: PhoneticCategory
    let date: Date
}

// Repeated pattern
struct RepeatedPattern: Codable {
    let pattern: String
    let occurrences: Int
    let category: String
    let severity: String
}

// Extracted features
struct ExtractedFeatures: Codable {
    let missedWords: [MissedWord]
    let phoneticConfusions: [PhoneticConfusion]
    let repeatedPatterns: [RepeatedPattern]
    let totalSessions: Int
    let totalErrors: Int
    let overallAccuracy: Double
}

// AI Insights (from ChatGPT)
struct AIInsights: Codable {
    let identifiedTrends: [String]
    let hypotheses: [String]
    let possibleAdjustments: [String]
    let summary: String
}

// MARK: - Error Types
enum AIAnalysisError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not configured"
        case .invalidURL:
            return "Invalid API endpoint URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .apiError(let code):
            return "API error: HTTP \(code)"
        }
    }
}
