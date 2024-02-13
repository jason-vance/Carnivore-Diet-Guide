//
//  RecipeViewActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation

protocol RecipeViewActivityTracker {
    func recipe(_ recipe: Recipe, wasViewedByUser userId: String) async throws
}

class MockRecipeViewActivityTracker: RecipeViewActivityTracker {
    func recipe(_ recipe: Recipe, wasViewedByUser userId: String) async throws {
    }
}
