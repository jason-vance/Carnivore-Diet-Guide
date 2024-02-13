//
//  RecipeCommentCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation

protocol RecipeCommentCountProvider {
    var commentCountPublisher: Published<UInt>.Publisher { get }
}

class MockRecipeCommentCountProvider: RecipeCommentCountProvider {
    
    private let recipe: Recipe
    
    @Published var commentCount: UInt = 0
    var commentCountPublisher: Published<UInt>.Publisher { $commentCount }
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
}
