//
//  SeedRecipeFavoriter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/15/25.
//

import Foundation

class SeedRecipeFavoriter: ObservableObject {
    
    private let favoriteRecipeWithSeeds: (Recipe, [String]) async throws -> Void
    
    init(favoriteRecipeWithSeeds: @escaping (Recipe, [String]) async throws -> Void) {
        self.favoriteRecipeWithSeeds = favoriteRecipeWithSeeds
    }
    
    func favorite(recipe: Recipe, withSeeds seeds: [String]) async throws {
        try await favoriteRecipeWithSeeds(recipe, seeds)
    }
}

extension SeedRecipeFavoriter {
    static let forTesting = SeedRecipeFavoriter(
        favoriteRecipeWithSeeds: { _, _ in try await Task.sleep(for: .seconds(1)) }
    )
}
