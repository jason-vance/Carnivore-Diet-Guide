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
}
