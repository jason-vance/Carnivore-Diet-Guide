//
//  RecipeCollectionFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/16/24.
//

import Foundation

protocol RecipeCursor { }

protocol RecipeCollectionFetcher {
    func fetchRecipesOldestFirst(
        newerThan recipe: Recipe?,
        limit: Int
    ) async throws -> [Recipe]
    
    func fetchRecipesNewestFirst(
        olderThan recipe: Recipe?,
        limit: Int
    ) async throws -> [Recipe]
    
    func fetchTrendingRecipes(in timeFrame: TimeFrame) async throws -> [String]
    
    func fetchLikedRecipes(in timeFrame: TimeFrame) async throws -> [String]
}

class MockRecipeCollectionFetcher: RecipeCollectionFetcher {
    
    var recipes: [Recipe] = [ .sample, .longNamedSample ]
    var error: Error? = nil
    
    func fetchRecipesOldestFirst(
        newerThan recipe: Recipe?,
        limit: Int
    ) async throws -> [Recipe] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return recipes
    }
    
    func fetchRecipesNewestFirst(
        olderThan recipe: Recipe?,
        limit: Int
    ) async throws -> [Recipe] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return recipes
    }
    
    func fetchTrendingRecipes(in timeFrame: TimeFrame) async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return recipes.map { $0.id }
    }
    
    func fetchLikedRecipes(in timeFrame: TimeFrame) async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return recipes.map { $0.id }
    }
}
