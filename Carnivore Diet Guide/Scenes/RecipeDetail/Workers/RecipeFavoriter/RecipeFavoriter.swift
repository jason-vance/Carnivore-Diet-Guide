//
//  RecipeFavoriter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/6/24.
//

import Foundation

protocol RecipeFavoriter {
    var isMarkedAsFavoritePublisher: Published<Bool?>.Publisher { get }
    func toggleFavorite() async throws
}

class MockRecipeFavoriter: RecipeFavoriter {
    
    private let recipe: Recipe
    
    var error: Error? = nil
    
    @Published var isMarkedAsFavorite: Bool?
    var isMarkedAsFavoritePublisher: Published<Bool?>.Publisher { $isMarkedAsFavorite }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        if isMarkedAsFavorite == nil {
            isMarkedAsFavorite = false
        }
    }
    
    func toggleFavorite() async throws {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        guard let isFavorited = isMarkedAsFavorite else { throw "Unknown favorite status" }
        isMarkedAsFavorite = !isFavorited
    }
}
