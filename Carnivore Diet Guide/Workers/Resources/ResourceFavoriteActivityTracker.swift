//
//  RecipeFavoriteActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation

protocol ResourceFavoriteActivityTracker {
    func resource(_ resource: Resource, wasFavoritedByUser userId: String) async throws
    func resource(_ resource: Resource, wasUnfavoritedByUser userId: String) async throws
}

class MockResourceFavoriteActivityTracker: ResourceFavoriteActivityTracker {
    func resource(_ resource: Resource, wasFavoritedByUser userId: String) async throws { }
    func resource(_ resource: Resource, wasUnfavoritedByUser userId: String) async throws { }
}
