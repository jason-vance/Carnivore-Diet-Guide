//
//  ResourceTag.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

extension Resource {
    struct Tag {
        let text: String
        
        init?(_ text: String) {
            // Trim whitespace
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for minimum and maximum length
            guard trimmedText.count >= 2, trimmedText.count <= 30 else {
                return nil
            }
            
            // Check for allowed characters (alphanumeric and hyphens)
            let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
            guard trimmedText.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
                return nil
            }
            
            // Convert to lowercase
            self.text = trimmedText.lowercased()
        }
    }
}
