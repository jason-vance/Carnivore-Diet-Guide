//
//  RecipeFavoriteCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation

protocol RecipeFavoriteCountProvider {
    var favoriteCountPublisher: Published<UInt>.Publisher { get }
}

class MockRecipeFavoriteCountProvider: RecipeFavoriteCountProvider {
    
    private let recipe: Recipe
    
    @Published var favoriteCount: UInt = 0
    var favoriteCountPublisher: Published<UInt>.Publisher { $favoriteCount }
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
}
