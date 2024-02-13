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
    func fetchRecipe(byId recipeId: String) async throws -> Recipe {
        .sample
    }
}
