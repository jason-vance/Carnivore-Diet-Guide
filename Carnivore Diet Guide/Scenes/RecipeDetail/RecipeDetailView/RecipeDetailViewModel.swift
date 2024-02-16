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
    
    var recipe: Recipe? {
        didSet {
            setup()
        }
    }
    
    private let recipeActivities = iocContainer~>RecipeViewActivityTracker.self
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self

    private func setup() {
        let recipe = recipe!
        
        addRecipeViewedActivity(recipe: recipe)
    }
    
    private func addRecipeViewedActivity(recipe: Recipe) {
        Task {
            guard let userId = currentUserIdProvider.currentUserId else { return }
            try? await recipeActivities.recipe(recipe, wasViewedByUser: userId)
        }
    }
}
