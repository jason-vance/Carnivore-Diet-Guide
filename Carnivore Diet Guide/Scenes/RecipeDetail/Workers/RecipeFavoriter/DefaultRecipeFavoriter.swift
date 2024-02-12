//
//  DefaultRecipeFavoriter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/6/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

class DefaultRecipeFavoriter: RecipeFavoriter {
    
    private let recipe: Recipe
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let favoritesRepo = iocContainer~>FavoriteRecipeRepo.self
    private let recipeFavoriters = iocContainer~>RecipeFavoritersRepo.self
    private let recipeActivities = iocContainer~>RecipeFavoriteActivityTracker.self

    @Published var isMarkedAsFavorite: Bool?
    var isMarkedAsFavoritePublisher: Published<Bool?>.Publisher { $isMarkedAsFavorite }
    
    private var isFavoriteListener: AnyCancellable?
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        listenToFavoriteStatus()
    }
    
    func toggleFavorite() async throws {
        guard let userId = currentUserIdProvider.currentUserId else { throw "Could not retrieve userId" }
        guard let isFavorited = isMarkedAsFavorite else { throw "Unknown favorite status" }
        
        if isFavorited {
            try await favoritesRepo.removeRecipe(recipe, fromFavoritesOf: userId)
            removeUserAsFavoriterOfRecipe()
            removeRecipeFavoritingActivity()
        } else {
            try await favoritesRepo.addRecipe(recipe, toFavoritesOf: userId)
            addUserAsFavoriterOfRecipe()
            addRecipeFavoritingActivity()
        }
    }
    
    private func listenToFavoriteStatus() {
        guard let userId = currentUserIdProvider.currentUserId else { return }
        
        isFavoriteListener = favoritesRepo.listenToFavoriteStatusOf(recipe: recipe, byUser: userId) { [weak self] isFavorite in
            self?.isMarkedAsFavorite = isFavorite
        } onError: { error in
            print("Failed to retrieve favorite status: \(error.localizedDescription)")
        }
    }
    
    private func addUserAsFavoriterOfRecipe() {
        guard let userId = currentUserIdProvider.currentUserId else { return }
        
        Task {
            do {
                try await recipeFavoriters.addUser(userId, asFavoriterOf: recipe)
            } catch {
                print("Failed to add user as favoriter of recipe: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeUserAsFavoriterOfRecipe() {
        guard let userId = currentUserIdProvider.currentUserId else { return }
        
        Task {
            do {
                try await recipeFavoriters.removeUser(userId, asFavoriterOf: recipe)
            } catch {
                print("Failed to remove user as favoriter of recipe: \(error.localizedDescription)")
            }
        }
    }
    
    private func addRecipeFavoritingActivity() {
        guard let userId = currentUserIdProvider.currentUserId else { return }
        
        Task {
            do {
                try await recipeActivities.addRecipe(recipe, wasFavoritedByUser: userId)
            } catch {
                print("Failed to add recipe favoriting activity: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeRecipeFavoritingActivity() {
        guard let userId = currentUserIdProvider.currentUserId else { return }
        
        Task {
            do {
                try await recipeActivities.removeRecipe(recipe, wasFavoritedByUser: userId)
            } catch {
                print("Failed to remove recipe favoriting activity: \(error.localizedDescription)")
            }
        }
    }
}
