//
//  FeedItemProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/16/24.
//

import Foundation
import SwinjectAutoregistration

protocol FeedItemProvider {
    func fetchNextFeedItems() async throws -> [FeedItem]
}

class DefaultFeedItemProvider: FeedItemProvider {
        
    private let feedItemRepo = iocContainer~>FeedItemRepository.self
    
    private let limit = 5
    private var cursor: FeedItem? = nil
    
    func fetchNextFeedItems() async throws -> [FeedItem] {
        let feedItems = try await feedItemRepo.getFeedItemsNewestToOldest(after: cursor, limit: 5)
        if !feedItems.isEmpty {
            cursor = feedItems.last
        }
        return feedItems
    }
}
