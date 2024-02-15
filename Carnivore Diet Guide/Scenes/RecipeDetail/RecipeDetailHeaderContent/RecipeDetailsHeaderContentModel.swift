//
//  RecipeDetailsHeaderContentModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

@MainActor
class RecipeDetailsHeaderContentModel: ObservableObject {
    
    var recipe: Recipe? {
        didSet {
            setup()
        }
    }
    
    @Published var recipeIsMine: Bool = false
    @Published var isMarkedAsFavorite: Bool?
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    private var recipeFavoriter: RecipeFavoriter?
    private let recipeReporter = iocContainer~>RecipeReporter.self
    
    private var subs: Set<AnyCancellable> = []
    
    private func setup() {
        guard let recipe = recipe else {
            assertionFailure("recipe was nil")
            return
        }
        
        recipeIsMine = recipe.authorUserId == currentUserIdProvider.currentUserId
        
        recipeFavoriter = iocContainer.resolve(RecipeFavoriter.self, argument: recipe)
        recipeFavoriter?.isMarkedAsFavoritePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.isMarkedAsFavorite = $0 }
            .store(in: &subs)
    }
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    func toggleFavorite() {
        Task {
            guard let isFavorited = isMarkedAsFavorite else { return }
            guard let recipeFavoriter = recipeFavoriter else { return }
            
            isMarkedAsFavorite = !isFavorited
            do {
                try await recipeFavoriter.toggleFavorite()
            } catch {
                isMarkedAsFavorite = isFavorited
            }
        }
    }
    
    func reportRecipe() {
        Task {
            do {
                guard let recipe = recipe else { throw "`recipe` was nil" }
                guard let userId = currentUserIdProvider.currentUserId else { throw "User is not logged in" }

                try await recipeReporter.reportRecipe(recipe, reportedBy: userId)
                show(alertMessage: String(localized: "This recipe has been reported. It will be reviewed to make sure it follows our content guidelines."))
            } catch {
                show(alertMessage: String(localized: "Failed to report recipe: \(error.localizedDescription)"))
            }
        }
    }
}
