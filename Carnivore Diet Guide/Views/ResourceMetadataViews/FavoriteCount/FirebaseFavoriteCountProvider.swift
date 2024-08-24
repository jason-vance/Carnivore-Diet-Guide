//
//  FirebaseFavoriteCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/24/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

class FirebaseFavoriteCountProvider: FavoriteCountProvider {
    
    private let favoritersRepo = FirestoreFavoritersRepository()
    
    @Published var favoriteCount: UInt = 0
    var favoriteCountPublisher: Published<UInt>.Publisher { $favoriteCount }
    
    private var favoriteCountListener: AnyCancellable?
    
    public func startListening(to resource: Resource) {
        favoriteCountListener = favoritersRepo.listenToFavoriteCountOf(resource: resource) { [weak self] count in
            self?.favoriteCount = count
        } onError: { error in
            print("Failed to retrieve favorite count: \(error.localizedDescription)")
        }
    }
}
