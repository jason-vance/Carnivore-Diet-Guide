//
//  RecipePopularityFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation

protocol RecipePopularityFetcher {
    func getPopularRecipes(since date: Date) async throws -> PopularResources
}

class MockRecipePopularityFetcher: RecipePopularityFetcher {
    func getPopularRecipes(since date: Date) async throws -> PopularResources {
        .sample
    }
}
