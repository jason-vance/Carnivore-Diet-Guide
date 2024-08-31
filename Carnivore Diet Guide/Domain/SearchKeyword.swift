//
//  SearchKeyword.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

struct SearchKeyword: Hashable {
    let text: String
    
    init?(_ text: String) {
        // Trim whitespace
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for minimum and maximum length
        guard trimmedText.count >= 1, trimmedText.count <= 30 else {
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
    
    static let samples: [SearchKeyword] = {
        let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        return text
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .split(separator: " ")
            .compactMap { SearchKeyword(String($0)) }
    }()
}
