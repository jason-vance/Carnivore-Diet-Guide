//
//  ResourceCategory.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

extension Resource {
    struct Category: Identifiable, Hashable {
        
        let id: String
        let name: String
        let image: String?
        
        init?(_ name: String, image: String? = nil, id: String = UUID().uuidString) {
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
            self.id = id
        }
        
        static let samples: [Resource.Category] = [
            .init("Test Category", image: "signature", id: UUID().uuidString)!,
            .init("Exercise", image: "dumbbell.fill", id: UUID().uuidString)!,
            .init("FAQs", image: "questionmark", id: UUID().uuidString)!,
            .init("Science", image: "testtube.2", id: UUID().uuidString)!,
        ]
    }
}
