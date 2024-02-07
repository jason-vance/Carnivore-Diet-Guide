//
//  FirebaseRecipeFavoriter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/6/24.
//

import Foundation
import SwinjectAutoregistration

protocol FavoriteRecipeRepo {
    func isRecipe(_ recipe: Recipe, markedAsFavoriteBy userId: String) async throws -> Bool
    func addRecipe(_ recipe: Recipe, toFavoritesOf userId: String) async throws
    func removeRecipe(_ recipe: Recipe, fromFavoritesOf userId: String) async throws
}

class DefaultRecipeFavoriter: RecipeFavoriter {
    
    private let recipe: Recipe
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let favoritesRepo = iocContainer~>FavoriteRecipeRepo.self
    
    @Published var isMarkedAsFavorite: Bool?
    var isMarkedAsFavoritePublisher: Published<Bool?>.Publisher { $isMarkedAsFavorite }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        checkFavoriteStatus()
    }
    
    func toggleFavorite(recipe: Recipe) async throws {
        guard let userId = currentUserIdProvider.currentUserId else { throw "Could not retrieve userId" }
        guard let isMarkedAsFavorite = isMarkedAsFavorite else { throw "Unknown favorite status" }
        
        if isMarkedAsFavorite {
            try await favoritesRepo.removeRecipe(recipe, fromFavoritesOf: userId)
        } else {
            try await favoritesRepo.addRecipe(recipe, toFavoritesOf: userId)
        }
    }
    
    private func checkFavoriteStatus() {
        Task {
            do {
                guard let userId = currentUserIdProvider.currentUserId else { return }
                let isFavorite = try await favoritesRepo.isRecipe(recipe, markedAsFavoriteBy: userId)
                RunLoop.main.perform {
                    self.isMarkedAsFavorite = isFavorite
                }
            } catch {
                print("Failed to checkFavoriteStatus: \(error.localizedDescription)")
            }
        }
    }
}
