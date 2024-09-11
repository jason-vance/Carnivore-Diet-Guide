//
//  StringExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import NaturalLanguage

extension String: Error {}
extension String: LocalizedError {
    public var errorDescription: String? { self }
}

extension String {
    
    func lemmatized() -> [Lemma] {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = self

        var result = [Lemma]()

        tagger.enumerateTags(in: self.startIndex..<self.endIndex, unit: .word, scheme: .lemma) { tag, tokenRange in
            let stemForm = tag?.rawValue ?? String(self[tokenRange])
                .lowercased()
            if let lemma = Lemma(stemForm) {
                result.append(lemma)
            }
            return true
        }

        return result
    }
    
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

extension String {
    struct Lemma: Hashable {
        private static let stopWords: Set<String> = [
            "a", "about", "above", "after", "again", "against", "all", "am", "an", "and", "any", "are", "aren't", "as", "at", "be",
            "because", "been", "before", "being", "below", "between", "both", "but", "by", "can't", "cannot", "could", "couldn't",
            "did", "didn't", "do", "does", "doesn't", "doing", "don't", "down", "during", "each", "few", "for", "from", "further",
            "had", "hadn't", "has", "hasn't", "have", "haven't", "having", "he", "he'd", "he'll", "he's", "her", "here", "here's",
            "hers", "herself", "him", "himself", "his", "how", "how's", "i", "i'd", "i'll", "i'm", "i've", "if", "in", "into",
            "is", "isn't", "it", "it's", "its", "itself", "let's", "me", "more", "most", "mustn't", "my", "myself", "no", "nor",
            "not", "of", "off", "on", "once", "only", "or", "other", "ought", "our", "ours", "ourselves", "out", "over", "own",
            "same", "shan't", "she", "she'd", "she'll", "she's", "should", "shouldn't", "so", "some", "such", "than", "that",
            "that's", "the", "their", "theirs", "them", "themselves", "then", "there", "there's", "these", "they", "they'd",
            "they'll", "they're", "they've", "this", "those", "through", "to", "too", "under", "until", "up", "very", "was",
            "wasn't", "we", "we'd", "we'll", "we're", "we've", "were", "weren't", "what", "what's", "when", "when's", "where",
            "where's", "which", "while", "who", "who's", "whom", "why", "why's", "with", "won't", "would", "wouldn't", "you",
            "you'd", "you'll", "you're", "you've", "your", "yours", "yourself", "yourselves"
        ]
        
        let text: String
        
        init?(_ text: String) {
            // Trim whitespace
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for allowed characters (alphabet)
            let allowedCharacters = CharacterSet.alphanumerics.subtracting(.decimalDigits)
            guard trimmedText.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
                return nil
            }
            
            guard !Self.stopWords.contains(trimmedText) else {
                return nil
            }
            
            // Convert to lowercase
            self.text = trimmedText.lowercased()
        }
    }
}
