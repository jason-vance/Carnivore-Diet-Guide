//
//  FirebaseRecipeFavoriter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/6/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

protocol FavoriteRecipeRepo {
    func listenToFavoriteStatusOf(
        recipe: Recipe,
        byUser userId: String,
        onUpdate: @escaping (Bool)->(),
        onError: ((Error)->())?
    ) -> AnyCancellable
    
    func addRecipe(_ recipe: Recipe, toFavoritesOf userId: String) async throws
    
    func removeRecipe(_ recipe: Recipe, fromFavoritesOf userId: String) async throws
}

class DefaultRecipeFavoriter: RecipeFavoriter {
    
    private let recipe: Recipe
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let favoritesRepo = iocContainer~>FavoriteRecipeRepo.self
    
    @Published var isMarkedAsFavorite: Bool?
    var isMarkedAsFavoritePublisher: Published<Bool?>.Publisher { $isMarkedAsFavorite }
    
    private var favoriteListener: AnyCancellable?
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        listenToFavoriteStatus()
    }
    
    func toggleFavorite() async throws {
        guard let userId = currentUserIdProvider.currentUserId else { throw "Could not retrieve userId" }
        guard let isFavorited = isMarkedAsFavorite else { throw "Unknown favorite status" }
        
        if isFavorited {
            try await favoritesRepo.removeRecipe(recipe, fromFavoritesOf: userId)
        } else {
            try await favoritesRepo.addRecipe(recipe, toFavoritesOf: userId)
        }
    }
    
    private func listenToFavoriteStatus() {
        guard let userId = currentUserIdProvider.currentUserId else { return }
        
        favoriteListener = favoritesRepo.listenToFavoriteStatusOf(recipe: recipe, byUser: userId) { [weak self] isFavorite in
            self?.isMarkedAsFavorite = isFavorite
        } onError: { error in
            print("Failed to retrieve favorite status: \(error.localizedDescription)")
        }
    }
}
