//
//  RecipeCommentActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation

protocol RecipeCommentActivityTracker {
    func recipe(_ recipeId: String, wasCommentedOnByUser userId: String) async throws
}

class MockRecipeCommentActivityTracker: RecipeCommentActivityTracker {
    func recipe(_ recipeId: String, wasCommentedOnByUser userId: String) async throws {
    }
}
