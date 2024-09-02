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
        
        var isContentAgnostic: Bool { Self.contentAgnosticCategories.contains(self) }
        
        static var contentAgnosticCategories: [Category] = [ .all, .featured, .trending, .liked ]
        
        // Content Agnostic Categories (Not supplied by Firebase)
        static let all: Category = .init("All", image: "rectangle.grid.3x2.fill", id: UUID().uuidString)!
        static let featured: Category = .init("Featured", image: "star.fill", id: UUID().uuidString)!
        static let trending: Category = .init("Trending", image: "arrowshape.up.fill", id: UUID().uuidString)!
        static let liked: Category = .init("Liked", image: "heart.fill", id: UUID().uuidString)!
        
        static let samples: Set<Resource.Category> = [
            .init("Test Category", image: "signature", id: UUID().uuidString)!,
            .init("Exercise", image: "dumbbell.fill", id: UUID().uuidString)!,
            .init("FAQs", image: "questionmark", id: UUID().uuidString)!,
            .init("Science", image: "testtube.2", id: UUID().uuidString)!,
        ]
    }
}
