//
//  ResourceCategory.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

extension Resource {
    struct Category: Identifiable, Hashable {
        
        var id: String { name }
        let name: String
        let image: String?
        
        init?(_ name: String, image: String? = nil) {
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
            self.image = image
        }
    }
}
