//
//  DefaultRecipeCommentCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

class DefaultRecipeCommentCountProvider: RecipeCommentCountProvider {
    
    private let recipe: Recipe
    private let recipeRepo = iocContainer~>RecipeCommentsRepo.self
    
    @Published var commentCount: UInt = 0
    var commentCountPublisher: Published<UInt>.Publisher { $commentCount }
    
    private var commentCountListener: AnyCancellable?
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        startListening()
    }
    
    private func startListening() {
        commentCountListener = recipeRepo.listenToCommentCountOf(recipe: recipe) { [weak self] count in
            self?.commentCount = count
        } onError: { error in
            print("Failed to retrieve comment count: \(error.localizedDescription)")
        }
    }
}
