//
//  HomeViewContent.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation

struct HomeViewContent {
    let featuredPost: Post
    let featuredRecipe: Recipe
    let trendingRecipes: [Recipe]
    let trendingPosts: [Post]
}

extension HomeViewContent {
    static let sample: HomeViewContent = .init(
        featuredPost: .sample,
        featuredRecipe: .sample,
        trendingRecipes: Recipe.samples,
        trendingPosts: Post.samples
    )
}
