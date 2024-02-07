//
//  RecipeFavoritersRepo.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import Combine

protocol RecipeFavoritersRepo {
    func addUser(_ userId: String, asFavoriterOf recipe: Recipe) async throws
    func removeUser(_ userId: String, asFavoriterOf recipe: Recipe) async throws
    func listenToFavoriteCountOf(
        recipe: Recipe,
        onUpdate: @escaping (UInt) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable
}
