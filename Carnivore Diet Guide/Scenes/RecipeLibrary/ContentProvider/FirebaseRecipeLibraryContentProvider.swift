//
//  FirebaseRecipeLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/10/24.
//

import Foundation

class FirebaseRecipeLibraryContentProvider: RecipeLibraryContentProvider {
    
    let recipeRepo = FirebaseRecipeRepository()
    
    func loadRecipes(onUpdate: @escaping ([Recipe]) -> (), onError: @escaping (Error) -> ()) {
        Task {
            do {
                let recipes = try await recipeRepo.getRecipesNewestToOldest()
                onUpdate(recipes)
            } catch {
                print(error)
                onError(error)
            }
        }
    }
}

