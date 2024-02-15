//
//  RecipeReporter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation

protocol RecipeReporter {
    func reportRecipe(
        _ recipe: Recipe,
        reportedBy reporterId: String
    ) async throws
}

class MockRecipeReporter: RecipeReporter {
    
    var error: Error?
    
    func reportRecipe(
        _ recipe: Recipe,
        reportedBy reporterId: String
    ) async throws {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
    }
}
