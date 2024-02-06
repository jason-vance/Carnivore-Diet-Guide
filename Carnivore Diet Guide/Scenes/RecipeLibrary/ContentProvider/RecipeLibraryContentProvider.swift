//
//  RecipeLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/10/24.
//

import Foundation

protocol RecipeLibraryContentProvider {
    func loadRecipes() async throws -> [Recipe]
}

class MockRecipeLibraryContentProvider: RecipeLibraryContentProvider {
    
    var errorToThrow: Error? = nil
    
    func loadRecipes() async throws -> [Recipe] {
        try? await Task.sleep(for: .seconds(1))
        
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return Recipe.samples
    }
}
