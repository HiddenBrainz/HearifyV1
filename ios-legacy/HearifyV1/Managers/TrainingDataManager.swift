//
//  TrainingDataManager.swift
//  HearifyV1
//
//  Manages loading and accessing training data
//

import Foundation

class TrainingDataManager: ObservableObject {
    @Published var hearingLossSentences: [TrainingSentence] = []
    @Published var hearingAidsSentences: [TrainingSentence] = []
    @Published var cochlearImplantsSentences: [TrainingSentence] = []
    @Published var cochlearImplantsWords: [TrainingSentence] = []
    @Published var isLoading = false
    @Published var error: String?

    init() {
        loadAllData()
    }

    func loadAllData() {
        isLoading = true

        hearingLossSentences = loadSentences(
            from: "HearingLossTrainingData",
            moduleType: .hearingLoss
        )

        hearingAidsSentences = loadSentences(
            from: "HearingAidsTrainingData",
            moduleType: .hearingAids
        )

        cochlearImplantsSentences = loadSentences(
            from: "CochlearImplantsTrainingData",
            moduleType: .cochlearImplants
        )

        cochlearImplantsWords = loadSentences(
            from: "CochlearImplantsWordsData",
            moduleType: .cochlearImplants
        )

        isLoading = false
    }

    private func loadSentences(from filename: String, moduleType: TrainingModuleType) -> [TrainingSentence] {
        guard let filepath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            print("Error: Cannot find CSV file: \(filename).csv")
            error = "Cannot find \(filename).csv"
            return []
        }

        var data = ""
        do {
            data = try String(contentsOfFile: filepath)
        } catch {
            print("Error reading CSV file \(filename): \(error.localizedDescription)")
            self.error = "Error reading \(filename): \(error.localizedDescription)"
            return []
        }

        var sentences: [TrainingSentence] = []
        let rows = data.components(separatedBy: "\n")

        for (index, row) in rows.enumerated() {
            // Skip header row
            if index == 0 { continue }

            let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedRow.isEmpty else { continue }

            let columns = trimmedRow.components(separatedBy: ",")
            guard columns.count >= 8 else {
                print("Warning: Invalid row format at line \(index + 1) in \(filename).csv")
                continue
            }

            let sentence = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let choice1 = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let choice2 = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let choice3 = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let choice4 = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let difficultyStr = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
            let category = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
            let blankWordsStr = columns[7].trimmingCharacters(in: .whitespacesAndNewlines)

            // Parse difficulty
            let difficulty: DifficultyLevel
            switch difficultyStr.lowercased() {
            case "easy": difficulty = .easy
            case "medium": difficulty = .medium
            case "hard": difficulty = .hard
            default: difficulty = .medium
            }

            // Parse blank words
            let blankWords = blankWordsStr.components(separatedBy: " ")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            let trainingSentence = TrainingSentence(
                content: sentence,
                choices: [choice1, choice2, choice3, choice4],
                blankWords: blankWords,
                difficulty: difficulty,
                moduleType: moduleType,
                category: category
            )

            sentences.append(trainingSentence)
        }

        print("Loaded \(sentences.count) sentences from \(filename).csv")
        return sentences
    }

    func getSentences(
        for moduleType: TrainingModuleType,
        difficulty: DifficultyLevel? = nil
    ) -> [TrainingSentence] {
        let allSentences: [TrainingSentence]

        switch moduleType {
        case .hearingLoss:
            allSentences = hearingLossSentences
        case .hearingAids:
            allSentences = hearingAidsSentences
        case .cochlearImplants:
            allSentences = cochlearImplantsSentences
        }

        if let difficulty = difficulty {
            return allSentences.filter { $0.difficulty == difficulty }
        }

        return allSentences
    }

    func getRandomSentences(
        for moduleType: TrainingModuleType,
        difficulty: DifficultyLevel,
        count: Int
    ) -> [TrainingSentence] {
        let sentences = getSentences(for: moduleType, difficulty: difficulty)
        return Array(sentences.shuffled().prefix(count))
    }

    // MARK: - Cochlear Implant Level-based Methods

    /// Get sentences for a specific cochlear implant level
    func getSentences(
        for level: CochlearImplantLevel,
        difficulty: DifficultyLevel? = nil
    ) -> [TrainingSentence] {
        let allSentences: [TrainingSentence]

        // Get appropriate content based on level
        switch level.contentCategory {
        case .words:
            allSentences = cochlearImplantsWords
        case .sentences:
            allSentences = cochlearImplantsSentences
        }

        // Filter by difficulty if specified
        if let difficulty = difficulty {
            return allSentences.filter { $0.difficulty == difficulty }
        }

        return allSentences
    }

    /// Get random sentences for a specific cochlear implant level
    func getRandomSentences(
        for level: CochlearImplantLevel,
        difficulty: DifficultyLevel,
        count: Int
    ) -> [TrainingSentence] {
        let sentences = getSentences(for: level, difficulty: difficulty)
        return Array(sentences.shuffled().prefix(count))
    }

    /// Get sentences by content category for cochlear implants
    func getCochlearSentences(
        category: CochlearContentCategory,
        difficulty: DifficultyLevel? = nil
    ) -> [TrainingSentence] {
        let allSentences: [TrainingSentence]

        switch category {
        case .words:
            allSentences = cochlearImplantsWords
        case .sentences:
            allSentences = cochlearImplantsSentences
        }

        if let difficulty = difficulty {
            return allSentences.filter { $0.difficulty == difficulty }
        }

        return allSentences
    }
}
