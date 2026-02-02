//
//  NumberToWordConverter.swift
//  HearifyV1
//
//  Utility for converting numbers in text to their word equivalents
//

import Foundation

class NumberToWordConverter {

    // MARK: - Number Words
    private static let ones = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    private static let teens = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
    private static let tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]

    // MARK: - Public Methods

    /// Converts all numbers in a string to their word equivalents
    /// Example: "I have 5 apples and 23 oranges" -> "I have five apples and twenty three oranges"
    static func convertNumbersToWords(in text: String) -> String {
        // Use regex to find all numbers in the text
        let pattern = "\\b\\d+\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }

        var result = text
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

        // Process matches in reverse order to maintain correct indices
        for match in matches.reversed() {
            if let range = Range(match.range, in: text) {
                let numberString = String(text[range])
                if let number = Int(numberString) {
                    let words = numberToWords(number)
                    result = result.replacingOccurrences(of: numberString, with: words, options: [], range: range)
                }
            }
        }

        return result
    }

    /// Converts a single number to words
    /// Example: 123 -> "one hundred twenty three"
    static func numberToWords(_ number: Int) -> String {
        if number == 0 {
            return "zero"
        }

        if number < 0 {
            return "negative " + numberToWords(abs(number))
        }

        if number < 10 {
            return ones[number]
        }

        if number < 20 {
            return teens[number - 10]
        }

        if number < 100 {
            let tensDigit = number / 10
            let onesDigit = number % 10
            return tens[tensDigit] + (onesDigit > 0 ? " " + ones[onesDigit] : "")
        }

        if number < 1000 {
            let hundredsDigit = number / 100
            let remainder = number % 100
            return ones[hundredsDigit] + " hundred" + (remainder > 0 ? " " + numberToWords(remainder) : "")
        }

        if number < 1000000 {
            let thousands = number / 1000
            let remainder = number % 1000
            return numberToWords(thousands) + " thousand" + (remainder > 0 ? " " + numberToWords(remainder) : "")
        }

        if number < 1000000000 {
            let millions = number / 1000000
            let remainder = number % 1000000
            return numberToWords(millions) + " million" + (remainder > 0 ? " " + numberToWords(remainder) : "")
        }

        // For very large numbers
        let billions = number / 1000000000
        let remainder = number % 1000000000
        return numberToWords(billions) + " billion" + (remainder > 0 ? " " + numberToWords(remainder) : "")
    }
}
