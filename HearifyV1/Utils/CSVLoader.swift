//
//  CSVLoader.swift
//  HearifyV1
//
//  CSV data loading utilities
//

import Foundation

// NOTE: The Word struct is defined in TestModels.swift
// NOTE: WordList, JSONWORDLIST, and convertCSVIntoArray may be defined elsewhere
// This file appears to be a duplicate. Consider removing this file or the duplicate declarations.

// If these are truly needed here, they should be moved to avoid conflicts:

// MARK: - CSV Loading Function (Alternate Implementation)
private func loadCSVIntoWordList(CSV: String) {
    guard let filepath = Bundle.main.path(forResource: CSV, ofType: "csv") else {
        print("Error: Cannot find CSV file: \(CSV).csv")
        return
    }

    var data = ""
    do {
        data = try String(contentsOfFile: filepath)
    } catch {
        print("Error reading CSV file \(CSV): \(error.localizedDescription)")
        return
    }

    let rows = data.components(separatedBy: "\n")
    var validRowCount = 0
    var loadedWords: [Word] = []

    for (index, row) in rows.enumerated() {
        let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedRow.isEmpty else {
            continue
        }

        let columns = trimmedRow.components(separatedBy: ",")

        guard columns.count == 3 else {
            print("Warning: Invalid row format at line \(index + 1) in \(CSV).csv - expected 3 columns, got \(columns.count)")
            continue
        }

        let fw = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let lw = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let cy = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)

        guard !fw.isEmpty && !lw.isEmpty && !cy.isEmpty else {
            print("Warning: Empty values in row \(index + 1) of \(CSV).csv")
            continue
        }

        let word = Word(firstWord: fw, lastWord: lw, category: cy)
        loadedWords.append(word)
        validRowCount += 1
    }

    print("Loaded \(validRowCount) valid words from \(CSV).csv")
    // Note: This function returns an array instead of modifying a global variable
    // This is commented out to avoid conflicts with duplicate declarations
    // return loadedWords
}
