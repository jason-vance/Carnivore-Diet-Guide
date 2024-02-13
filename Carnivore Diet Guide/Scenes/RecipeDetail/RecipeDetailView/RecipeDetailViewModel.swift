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
    
    @Published var loadingAuthor: Bool = false
    @Published var authorFullName: String = ""
    @Published var authorProfilePicUrl: URL?
    
    private let userFetcher = iocContainer~>UserFetcher.self
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    private let recipeActivities = iocContainer~>RecipeViewActivityTracker.self

    private func setup() {
        let recipe = recipe!
        
        fetchAuthor(userId: recipe.authorUserId)
        addRecipeViewedActivity(recipe: recipe)
    }
    
    private func fetchAuthor(userId: String) {
        Task {
            loadingAuthor = true
            do {
                let userData = try await userFetcher.fetchUser(userId: userId)
                
                authorProfilePicUrl = userData.profileImageUrl
                
                if let userFullName = userData.fullName?.value {
                    authorFullName = String(localized: .init(userFullName))
                } else {
                    authorFullName = String(localized: "Unknown Author")
                }
            }
            loadingAuthor = false
        }
    }
    
    private func addRecipeViewedActivity(recipe: Recipe) {
        Task {
            guard let userId = currentUserIdProvider.currentUserId else { return }
            try? await recipeActivities.recipe(recipe, wasViewedByUser: userId)
        }
    }
}
