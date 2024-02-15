//
//  FeaturedContentItem.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import Foundation

struct FeaturedContentItem: Identifiable {
    
    enum FeaturedContentType {
        case none
        case recipe(Recipe)
        case post(Post)
    }
    
    var id: String
    var title: String
    var imageUrl: String?
    var imageName: String?
    var type: FeaturedContentType
    
    static func from(recipe: Recipe) -> FeaturedContentItem {
        FeaturedContentItem(
            id: recipe.id,
            title: recipe.title,
            imageUrl: recipe.imageUrl,
            imageName: recipe.imageName,
            type: .recipe(recipe)
        )
    }
    
    static func from(post: Post) -> FeaturedContentItem {
        FeaturedContentItem(
            id: post.id,
            title: post.title,
            imageUrl: post.imageUrl,
            imageName: post.imageName,
            type: .post(post)
        )
    }
}

extension FeaturedContentItem {
    
    static let empty = FeaturedContentItem(id: "", title: "", type: .none)
    
    static let sampleRecipe = FeaturedContentItem.from(recipe: Recipe.sample)
    
    static let samplePost = FeaturedContentItem.from(post: Post.sample)
    
    static let samples = [samplePost, sampleRecipe]
}
