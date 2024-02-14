//
//  TrendingRecipeFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation
import SwinjectAutoregistration

protocol TrendingRecipeFetcher {
    func getTrendingRecipeIds(since date: Date, limit: Int) async throws -> [Recipe]
}


//TODO: Write tests for DefaultTrendingRecipeFetcher
class DefaultTrendingRecipeFetcher: TrendingRecipeFetcher {
    
    private let recipePopularityFetcher = iocContainer~>RecipePopularityFetcher.self
    private let recipesRepo = iocContainer~>RecipeRepository.self
    
    func getTrendingRecipeIds(since date: Date, limit: Int) async throws -> [Recipe] {
        let popularRecipeIds = try await getSortedPopularRecipeIds(since: date, limit: limit)
        //TODO: If popularRecipeIds isEmpty, then get some random recipeIds
        let recipeMap = try await getRecipeMap(popularRecipeIds)
        return sort(recipes: recipeMap, byPopularity: popularRecipeIds)
    }
    
    private func getSortedPopularRecipeIds(since date: Date, limit: Int) async throws -> [String] {
        let popularRecipes = try await recipePopularityFetcher.getPopularRecipes(since: date)
        return Array(popularRecipes
            .getSortedResourceIds()
            .prefix(limit))
    }
    
    private func getRecipeMap(_ recipeIds: [String]) async throws -> [String: Recipe] {
        return try await withThrowingTaskGroup(of: Recipe.self) { group -> [String: Recipe] in
            for recipeId in recipeIds {
                group.addTask { [self] in
                    try await recipesRepo.fetchRecipe(byId: recipeId)
                }
            }

            return try await group.reduce(into: [String: Recipe]()) { $0[$1.id] = $1 }
        }
    }
    
    private func sort(
        recipes: [String: Recipe],
        byPopularity popularityOrderedRecipeIds: [String]
    ) -> [Recipe] {
        var rv = [Recipe]()
        for recipeId in popularityOrderedRecipeIds {
            if let recipe = recipes[recipeId] {
                rv.append(recipe)
            }
        }
        return rv
    }
}
