//
//  FavoriteCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/24/24.
//

import Foundation

protocol FavoriteCountProvider {
    var favoriteCountPublisher: Published<UInt>.Publisher { get }
    func startListening(to resource: Resource)
}

class MockFavoriteCountProvider: FavoriteCountProvider {
    
    @Published var favoriteCount: UInt = 0
    var favoriteCountPublisher: Published<UInt>.Publisher { $favoriteCount }
    
    func startListening(to resource: Resource) {}
}
