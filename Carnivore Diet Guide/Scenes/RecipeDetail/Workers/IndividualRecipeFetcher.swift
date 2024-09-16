//
//  IndividualRecipeFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import Foundation

protocol IndividualRecipeFetcher {
    func fetchRecipe(withId recipeId: String) async throws -> Recipe
}

class MockIndividualRecipeFetcher: IndividualRecipeFetcher {
    
    public var recipe: Recipe = .sample
    public var error: Error? = nil
    
    func fetchRecipe(withId recipeId: String) async throws -> Recipe {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
        return recipe
    }
}
