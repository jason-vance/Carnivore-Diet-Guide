//
//  HomeViewContent.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation

struct HomeViewContent {
    
    let featuredContent: [FeaturedContentItem]
    let trendingRecipes: [Recipe]
    let trendingPosts: [Post]
    
    var isEmpty: Bool { featuredContent.isEmpty && trendingRecipes.isEmpty && trendingPosts.isEmpty }
}

extension HomeViewContent {
    static let empty: HomeViewContent = .init(
        featuredContent: [],
        trendingRecipes: [],
        trendingPosts: []
    )
    
    static let sample: HomeViewContent = .init(
        featuredContent: FeaturedContentItem.samples,
        trendingRecipes: Recipe.samples,
        trendingPosts: Post.samples
    )
}
