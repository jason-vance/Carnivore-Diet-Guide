//
//  RecipeRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation

protocol RecipeRepository {
    func fetchRecipe(byId recipeId: String) async throws -> Recipe
}

class MockRecipeRepository: RecipeRepository {
    
    var error: Error?
    
    func fetchRecipe(byId recipeId: String) async throws -> Recipe {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
        return .sample
    }
}
