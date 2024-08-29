//
//  ArticleCategory.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

struct ArticleCategory: Identifiable, Equatable {
    
    var id: String { name }
    let name: String
    let image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    static let allCategories: [ArticleCategory] = [
        all, featured, trending, liked, food, exercise, science, faqs
    ]
    
    static let metadataBasedCategories: [ArticleCategory] = [
        all, featured, trending, liked
    ]
    
    // Metadata-based Categories
    static let all: ArticleCategory = .init(
        name: "All",
        image: "rectangle.grid.3x2.fill"
    )
    static let trending: ArticleCategory = .init(
        name: "Trending",
        image: "arrowshape.up.fill"
    )
    static let featured: ArticleCategory = .init(
        name: "Featured",
        image: "star.fill"
    )
    static let liked: ArticleCategory = .init(
        name: "Liked",
        image: "heart.fill"
    )
    
    // Content-based Categories
    static let food: ArticleCategory = .init(
        name: "Food",
        image: "fork.knife"
    )
    static let exercise: ArticleCategory = .init(
        name: "Exercise",
        image: "dumbbell.fill"
    )
    static let faqs: ArticleCategory = .init(
        name: "FAQs",
        image: "questionmark"
    )
    static let science: ArticleCategory = .init(
        name: "Science",
        image: "testtube.2"
    )

}
