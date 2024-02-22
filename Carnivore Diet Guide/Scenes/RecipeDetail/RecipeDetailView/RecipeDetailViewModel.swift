//
//  RecipeDetailViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import SwinjectAutoregistration

@MainActor
class RecipeDetailViewModel: ObservableObject {
    
    enum InitializationState {
        case uninitialized
        case initialized
    }
    
    @Published var initializationState: InitializationState = .uninitialized
    @Published var recipe: Recipe?
    
    private let recipeRepo = iocContainer~>RecipeRepository.self
    private let recipeActivities = iocContainer~>RecipeViewActivityTracker.self
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    
    func set(recipeId: String) {
        guard !recipeId.isEmpty else {
            assertionFailure("`recipeId` is empty")
            return
        }
        
        Task {
            initializationState = .uninitialized
            
            recipe = try await recipeRepo.fetchRecipe(byId: recipeId)
            addRecipeViewedActivity(recipe: recipe)

            initializationState = .initialized
        }
        
    }
    
    private func addRecipeViewedActivity(recipe: Recipe?) {
        Task {
            guard let recipe = recipe else { return }
            guard let userId = currentUserIdProvider.currentUserId else { return }
            try? await recipeActivities.recipe(recipe, wasViewedByUser: userId)
        }
    }
}
