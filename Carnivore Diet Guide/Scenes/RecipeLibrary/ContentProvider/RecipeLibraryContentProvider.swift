//
//  RecipeLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/10/24.
//

import Foundation

protocol RecipeLibraryContentProvider {
    func loadRecipes(onUpdate: @escaping ([Recipe]) -> (), onError: @escaping (Error) -> ())
}

class MockRecipeLibraryContentProvider: RecipeLibraryContentProvider {
    func loadRecipes(onUpdate: @escaping ([Recipe]) -> (), onError: @escaping (Error) -> ()) {
        Task {
            try? await Task.sleep(for: .seconds(1))
            onUpdate(Recipe.samples)
        }
    }
}
