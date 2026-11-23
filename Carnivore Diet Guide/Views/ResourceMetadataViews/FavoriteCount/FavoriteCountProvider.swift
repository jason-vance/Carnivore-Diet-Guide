//
//  FavoriteCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/24/24.
//

import Foundation

/// Fetches how many people have liked a resource. `ResourceCountStore.favorites` keeps the counts.
protocol FavoriteCountProvider {
    func favoriteCount(of resource: Resource) async throws -> UInt
}

class MockFavoriteCountProvider: FavoriteCountProvider {

    var favoriteCount: UInt = 0

    func favoriteCount(of resource: Resource) async throws -> UInt { favoriteCount }
}
