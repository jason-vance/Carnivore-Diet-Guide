//
//  RecipeDetailMetadataViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

@MainActor
class RecipeDetailMetadataViewModel: ObservableObject {
    
    var recipe: Recipe? {
        didSet {
            setup()
        }
    }
    
    @Published var commentCount: UInt = 123
    @Published var favoriteCount: UInt = 0

    private var favoriteCountProvider: RecipeFavoriteCountProvider?
    
    private var subs: Set<AnyCancellable> = []
    
    private func setup() {
        let recipe = recipe!
        
        favoriteCountProvider = iocContainer.resolve(RecipeFavoriteCountProvider.self, argument: recipe)
        favoriteCountProvider!.favoriteCountPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.favoriteCount = $0 }
            .store(in: &subs)
    }
}
