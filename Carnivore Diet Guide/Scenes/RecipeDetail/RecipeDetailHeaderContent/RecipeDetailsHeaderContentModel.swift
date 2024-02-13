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
    
    private let currentUserIdProvider = iocContainer~>CurrentUserIdProvider.self
    private var recipeFavoriter: RecipeFavoriter?
    
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
}
