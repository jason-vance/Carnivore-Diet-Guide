//
//  HomeViewContent.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation

struct HomeViewContent {
    let featuredBlogPost: BlogPost
    let featuredRecipe: Recipe
    let trendingRecipes: [Recipe]
    let trendingBlogPosts: [BlogPost]
}

extension HomeViewContent {
    static let sample: HomeViewContent = .init(
        featuredBlogPost: .sample,
        featuredRecipe: .sample,
        trendingRecipes: Recipe.samples,
        trendingBlogPosts: BlogPost.samples
    )
}
