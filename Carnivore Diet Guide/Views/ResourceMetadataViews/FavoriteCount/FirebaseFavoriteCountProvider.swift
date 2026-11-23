//
//  FirebaseFavoriteCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/24/24.
//

import Foundation

class FirebaseFavoriteCountProvider: FavoriteCountProvider {

    private let favoritersRepo = FirestoreFavoritersRepository()

    func favoriteCount(of resource: Resource) async throws -> UInt {
        try await favoritersRepo.getFavoriteCountOf(resource: resource)
    }
}
