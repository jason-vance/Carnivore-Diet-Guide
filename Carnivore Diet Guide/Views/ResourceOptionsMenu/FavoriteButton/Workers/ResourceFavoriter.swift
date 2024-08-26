//
//  ResourceFavoriter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation
import Combine

class ResourceFavoriter {
    
    @Published public var isMarkedAsFavorite: Bool? = nil
    
    private let isMarkedAsFavoritePublisher: AnyPublisher<Bool?, Never>
    private let listenToFavoriteStatus: (Resource) -> AnyCancellable
    private let markFavorite: (Resource) async -> ()
    private let unmarkFavorite: (Resource) async -> ()
    
    private var isMarkedAsFavoriteListener: AnyCancellable? = nil
    private var isMarkedAsFavoriteSub: AnyCancellable? = nil

    init(
        isMarkedAsFavoritePublisher: AnyPublisher<Bool?, Never>,
        listenToFavoriteStatus: @escaping (Resource) -> AnyCancellable,
        markFavorite: @escaping (Resource) async -> (),
        unmarkFavorite: @escaping (Resource) async -> ()
    ) {
        self.isMarkedAsFavoritePublisher = isMarkedAsFavoritePublisher
        self.listenToFavoriteStatus = listenToFavoriteStatus
        self.markFavorite = markFavorite
        self.unmarkFavorite = unmarkFavorite
    }
    
    public func listenToFavoriteStatus(of resource: Resource) {
        isMarkedAsFavoriteListener = listenToFavoriteStatus(resource)
        
        isMarkedAsFavoriteSub = isMarkedAsFavoritePublisher
            .receive(on: RunLoop.main)
            .sink { isFavorite in
                self.isMarkedAsFavorite = isFavorite
            }
    }
    
    public func toggleFavorite(resource: Resource) async {
        guard let isMarkedAsFavorite = isMarkedAsFavorite else { return }
        
        if isMarkedAsFavorite {
            await unmarkFavorite(resource)
        } else {
            await markFavorite(resource)
        }
    }
}

extension ResourceFavoriter {
    static var forPreviews: ResourceFavoriter {
        let subject = CurrentValueSubject<Bool?, Never>(false)
        
        return ResourceFavoriter(
            isMarkedAsFavoritePublisher: subject.eraseToAnyPublisher(),
            listenToFavoriteStatus: { resource in .init({}) },
            markFavorite: { resource in subject.send(true) },
            unmarkFavorite: { resource in subject.send(false) }
        )
    }
}
