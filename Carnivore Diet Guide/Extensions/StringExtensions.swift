//
//  StringExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation

extension String: Error {}
extension String: LocalizedError {
    public var errorDescription: String? { self }
}

extension String {
    func stripMarkdown() -> String {
        var strippedText = self

        // Remove markdown headers
        strippedText = strippedText.replacingOccurrences(of: "(^#+\\s+)", with: "", options: .regularExpression)
        strippedText = strippedText.replacingOccurrences(of: "(\\n#+\\s+)", with: "\n", options: .regularExpression)

        // Remove bold (both ** and __)
        strippedText = strippedText.replacingOccurrences(of: "(\\*\\*|__)(.*?)\\1", with: "$2", options: .regularExpression)

        // Remove italics (both * and _)
        strippedText = strippedText.replacingOccurrences(of: "(\\*|_)(.*?)\\1", with: "$2", options: .regularExpression)

        // Remove links [title](URL)
        strippedText = strippedText.replacingOccurrences(of: "\\[([^\\[]*?)\\]\\(([^\\)]*?)\\)", with: "$1", options: .regularExpression)

        // Remove images ![alt text](image URL)
        strippedText = strippedText.replacingOccurrences(of: "!\\[([^\\[]*?)\\]\\(([^\\)]*?)\\)", with: "$1", options: .regularExpression)
        strippedText = strippedText.replacingOccurrences(of: "!(\\w)", with: "$1", options: .regularExpression)

        // Remove inline code `code`
        strippedText = strippedText.replacingOccurrences(of: "`(.*?)`", with: "$1", options: .regularExpression)

        // Remove strikethrough ~~text~~
        strippedText = strippedText.replacingOccurrences(of: "~~(.*?)~~", with: "$1", options: .regularExpression)

        // Remove blockquotes >
        strippedText = strippedText.replacingOccurrences(of: "^>\\s?", with: "", options: .regularExpression)
        strippedText = strippedText.replacingOccurrences(of: "\\n>\\s?", with: "\n", options: .regularExpression)

        // Remove unordered list bullets
        strippedText = strippedText.replacingOccurrences(of: "^[-+*]\\s+", with: "", options: .regularExpression)
        strippedText = strippedText.replacingOccurrences(of: "\\n[-+*]\\s+", with: "\n", options: .regularExpression)

        // Remove ordered list numbers
        strippedText = strippedText.replacingOccurrences(of: "^\\d+\\.\\s+", with: "", options: .regularExpression)
        strippedText = strippedText.replacingOccurrences(of: "\\n\\d+\\.\\s+", with: "\n", options: .regularExpression)

        return strippedText
    }
    
    func markdownToFeedItemSummary() -> String {
        var summary = self.stripMarkdown()
        
        summary = summary.replacingOccurrences(of: "\\n+", with: " ", options: .regularExpression)
        
        return summary
    }
}
