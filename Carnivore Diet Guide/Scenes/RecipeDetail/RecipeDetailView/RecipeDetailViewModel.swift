//
//  RecipeDetailViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import SwinjectAutoregistration
import Combine


//TODO: Reevaluate if I actually need this class or not
@MainActor
class RecipeDetailViewModel: ObservableObject {
    
    var recipe: Recipe? {
        didSet {
            setup()
        }
    }
    
    private var subs: Set<AnyCancellable> = []
    
    private func setup() {
//        let recipe = recipe!
    }
}
