//
//  ContentCategory.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

struct ContentCategory: Identifiable, Equatable {
    
    var id: String { name }
    let name: String
    let image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    static let allCategories: [ContentCategory] = [
        all, featured, trending, liked, recent, food, exercise, faqs, science
    ]
    
    static let all: ContentCategory = .init(
        name: "All",
        image: "rectangle.grid.3x2.fill"
    )
    static let trending: ContentCategory = .init(
        name: "Trending",
        image: "arrowshape.up.fill"
    )
    static let featured: ContentCategory = .init(
        name: "Featured",
        image: "star.fill"
    )
    static let liked: ContentCategory = .init(
        name: "Liked",
        image: "heart.fill"
    )
    static let recent: ContentCategory = .init(
        name: "Recent",
        image: "clock.fill"
    )
    static let food: ContentCategory = .init(
        name: "Food",
        image: "fork.knife"
    )
    static let exercise: ContentCategory = .init(
        name: "Exercise",
        image: "dumbbell.fill"
    )
    static let faqs: ContentCategory = .init(
        name: "FAQs",
        image: "questionmark"
    )
    static let science: ContentCategory = .init(
        name: "Science",
        image: "testtube.2"
    )

}
