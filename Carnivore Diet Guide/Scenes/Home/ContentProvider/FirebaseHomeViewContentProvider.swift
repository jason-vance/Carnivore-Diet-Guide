//
//  FirebaseHomeViewContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation

class FirebaseHomeViewContentProvider: HomeViewContentProvider {
    
    private let recipesRepo = FirebaseRecipeRepository()
    private let blogPostsRepo = FirebaseBlogPostRepository()
    
    func loadContent() async throws -> HomeViewContent {
        let recipes = try await recipesRepo.getRecipesNewestToOldest()
        let blogPosts = try await blogPostsRepo.getBlogPostsNewestToOldest()
        
        guard let featuredBlogPost = blogPosts.first else { throw "Could not find any featured content" }
        guard let featuredRecipe = recipes.first else { throw "Could not find any featured recipes" }
        
        let trendingRecipes = Array(recipes.suffix(from: 1).prefix(4))
        let trendingBlogPosts = Array(blogPosts.suffix(from: 1).prefix(4))
        
        guard !trendingRecipes.isEmpty else { throw "Could not find any trending recipes" }
        guard !trendingBlogPosts.isEmpty else { throw "Could not find any trending content" }

        return .init(
            featuredBlogPost: featuredBlogPost,
            featuredRecipe: featuredRecipe,
            trendingRecipes: trendingRecipes,
            trendingBlogPosts: trendingBlogPosts
        )
    }
}
