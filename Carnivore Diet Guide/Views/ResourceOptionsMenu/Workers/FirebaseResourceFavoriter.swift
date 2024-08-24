//
//  FirebaseResourceFavoriter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation
import Combine
import SwinjectAutoregistration

extension ResourceFavoriter {
    static var forProd: ResourceFavoriter {
        let userRepo = FirebaseUserRepository()
        let userIdProvider = iocContainer~>CurrentUserIdProvider.self
        
        let subject = CurrentValueSubject<Bool?, Never>(nil)
        
        return .init(
            isMarkedAsFavoritePublisher: subject.eraseToAnyPublisher(),
            listenToFavoriteStatus: { resource in
                let userId = userIdProvider.currentUserId!
                
                return userRepo.listenToFavoriteStatusOf(
                    resource: resource,
                    byUser: userId
                ) { isFavorite in
                    subject.send(isFavorite)
                }
            },
            markFavorite: { resource in
                let userId = userIdProvider.currentUserId!
                
                do {
                    try await userRepo.add(resource:resource, toFavoritesOf: userId)
                    
                    Task {
                        let repo = FirestoreFavoritersRepository()
                        try? await repo.markAsFavorite(resource: resource)
                    }
                } catch {
                    print("Failed to add resource to user's favorites")
                }
            },
            unmarkFavorite: { resource in
                let userId = userIdProvider.currentUserId!
                
                do {
                    try await userRepo.remove(resource:resource, fromFavoritesOf: userId)
                    
                    Task {
                        let repo = FirestoreFavoritersRepository()
                        try? await repo.unmarkAsFavorite(resource: resource)
                    }
                } catch {
                    print("Failed to remove resource from user's favorites")
                }
            }
        )
    }
}
