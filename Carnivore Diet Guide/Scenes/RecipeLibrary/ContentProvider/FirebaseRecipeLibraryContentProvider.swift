//
//  FirebaseRecipeLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/10/24.
//

import Foundation

class FirebaseRecipeLibraryContentProvider: RecipeLibraryContentProvider {
    
    let recipeRepo = FirebaseRecipeRepository()
    
    func loadRecipes() async throws -> [Recipe] {
        try await recipeRepo.getPublishedRecipesNewestToOldest()
    }
}

