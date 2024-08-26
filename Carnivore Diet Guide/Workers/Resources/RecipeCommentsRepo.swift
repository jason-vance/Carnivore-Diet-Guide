//
//  RecipeCommentsRepo.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation
import Combine

protocol RecipeCommentsRepo {
    func listenToCommentCountOf(
        recipe: Recipe,
        onUpdate: @escaping (UInt) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable
}
