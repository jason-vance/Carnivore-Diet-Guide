//
//  FirebaseHomeViewContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import SwinjectAutoregistration

class FirebaseHomeViewContentProvider: HomeViewContentProvider {
    
    private let itemLimit = 4
    
    private let recipesRepo = FirebaseRecipeRepository()
    private let recipeFetcher = iocContainer~>TrendingRecipeFetcher.self
    private let postsRepo = FirebasePostRepository()
    
    func loadContent() async throws -> HomeViewContent {
        guard let featuredRecipe = (try await recipesRepo.getPublishedRecipesNewestToOldest(limit: 1)).first else {
            throw "Could not find featured recipe"
        }
        
        let dayAgo = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        
        let trendingRecipes = try await recipeFetcher.getTrendingRecipeIds(since: dayAgo, limit: itemLimit)
        //TODO: get trending posts by recent activity
        let posts = try await postsRepo.getPublishedPostsNewestToOldest(limit: itemLimit)
        
        guard let featuredPost = posts.first else { throw "Could not find any featured content" }
        
        let featuredContent = [
            FeaturedContentItem.from(post: featuredPost),
            FeaturedContentItem.from(recipe: featuredRecipe)
        ]
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
