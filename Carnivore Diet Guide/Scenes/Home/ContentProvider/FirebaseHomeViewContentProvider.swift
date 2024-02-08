//
//  FirebaseHomeViewContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation

class FirebaseHomeViewContentProvider: HomeViewContentProvider {
    
    private let itemLimit = 5
    
    private let recipesRepo = FirebaseRecipeRepository()
    private let postsRepo = FirebasePostRepository()
    
    func loadContent() async throws -> HomeViewContent {
        //TODO: get trending items by recent activity
        let recipes = try await recipesRepo.getPublishedRecipesNewestToOldest(limit: itemLimit)
        let posts = try await postsRepo.getPublishedPostsNewestToOldest(limit: itemLimit)
        
        guard let featuredPost = posts.first else { throw "Could not find any featured content" }
        guard let featuredRecipe = recipes.first else { throw "Could not find any featured recipes" }
        
        let featuredContent = [
            FeaturedContentItem.from(post: featuredPost),
            FeaturedContentItem.from(recipe: featuredRecipe)
        ]
        let trendingRecipes = Array(recipes.suffix(from: 1).prefix(itemLimit - 1))
        let trendingPosts = Array(posts.suffix(from: 1).prefix(itemLimit - 1))
        
        guard !trendingRecipes.isEmpty else { throw "Could not find any trending recipes" }
        guard !trendingPosts.isEmpty else { throw "Could not find any trending content" }

        return .init(
            featuredContent: featuredContent,
            trendingRecipes: trendingRecipes,
            trendingPosts: trendingPosts
        )
    }
}
