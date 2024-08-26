//
//  FavoriteButtonModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/25/24.
//

import Foundation
import Combine

@MainActor
class FavoriteButtonModel: ObservableObject {
    
    @Published public var isMarkedAsFavorite: Bool? = nil
    @Published public var isWorking: Bool = false
    
    private let userIdProvider: CurrentUserIdProvider
    private let favoriter: ResourceFavoriter
    
    private var isFavoritedSub: AnyCancellable? = nil

    init(
        userIdProvider: CurrentUserIdProvider,
        favoriter: ResourceFavoriter
    ) {
        self.userIdProvider = userIdProvider
        self.favoriter = favoriter
    }
    
    public func listenToFavoriteStatus(of resource: Resource) {
        favoriter.listenToFavoriteStatus(of: resource)
        
        isFavoritedSub = favoriter.$isMarkedAsFavorite
            .receive(on: RunLoop.main)
            .sink { self.isMarkedAsFavorite = $0 }
    }
    
    public func toggleFavorite(resource: Resource) {
        isWorking = true
        Task {
            await favoriter.toggleFavorite(resource: resource)
            isWorking = false
        }
    }
}
