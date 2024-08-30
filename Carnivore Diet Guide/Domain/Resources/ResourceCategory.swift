//
//  ResourceCategory.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

extension Resource {
    struct Category: Hashable {
        
        let name: String
        
        init?(_ name: String) {
            // Trim whitespace
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for minimum and maximum length
            guard trimmedName.count >= 2, trimmedName.count <= 30 else {
                return nil
            }
            
            // Check for allowed characters (alphanumeric and hyphens)
            let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "- +&"))
            guard trimmedName.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
                return nil
            }
            
            // Convert to lowercase
            self.name = trimmedName.capitalized
        }
    }
}
