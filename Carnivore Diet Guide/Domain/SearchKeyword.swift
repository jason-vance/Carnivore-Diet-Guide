//
//  SearchKeyword.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

struct SearchKeyword: Identifiable, Hashable {
    //TODO: I think I need to add a relevanceScore
    //(would make an article that mentions "exercise" 5x show up before one that mentions it 1x)
    
    var id: String { text }
    let text: String
    
    init?(_ text: String) {
        // Trim whitespace
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for minimum and maximum length
        guard trimmedText.count >= 3, trimmedText.count <= 30 else {
            return nil
        }
        
        // Check for allowed characters (alphanumeric and hyphens)
        let allowedCharacters = CharacterSet.alphanumerics.subtracting(.decimalDigits)
        guard trimmedText.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
            return nil
        }
        
        // Convert to lowercase
        self.text = trimmedText.lowercased()
    }
    
    static let samples: Set<SearchKeyword> = {
        let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        let keywords = text
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .split(separator: " ")
            .compactMap { SearchKeyword(String($0)) }
        let set = Set(keywords)
        return set
    }()
}
