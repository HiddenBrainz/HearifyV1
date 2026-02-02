//
//  CSVLoader.swift
//  HearifyV1
//
//  CSV data loading utilities
//

import Foundation

// MARK: - Global Word List
var WordList = [Word]()

// MARK: - JSON Word List Structure
struct JSONWORDLIST: Codable {
    var jsonlist: [Word] = []
}

// MARK: - CSV Loading Function
func convertCSVIntoArray(CSV: String) {
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
        WordList.append(word)
        validRowCount += 1
    }

    print("Loaded \(validRowCount) valid words from \(CSV).csv")
}
