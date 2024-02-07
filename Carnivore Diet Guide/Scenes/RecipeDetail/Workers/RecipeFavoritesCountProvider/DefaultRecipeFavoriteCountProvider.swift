//
//  DefaultRecipeFavoriteCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

class DefaultRecipeFavoriteCountProvider: RecipeFavoriteCountProvider {
    
    private let recipe: Recipe
    private let recipeRepo = iocContainer~>RecipeFavoritersRepo.self
    
    @Published var favoriteCount: UInt = 0
    var favoriteCountPublisher: Published<UInt>.Publisher { $favoriteCount }
    
    private var favoriteCountListener: AnyCancellable?
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        startListening()
    }
    
    private func startListening() {
        favoriteCountListener = recipeRepo.listenToFavoriteCountOf(recipe: recipe) { [weak self] count in
            self?.favoriteCount = count
        } onError: { error in
            print("Failed to retrieve favorite count: \(error.localizedDescription)")
        }
    }
}
