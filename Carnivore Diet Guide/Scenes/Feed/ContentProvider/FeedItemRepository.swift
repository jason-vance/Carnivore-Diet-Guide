//
//  FeedItemRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/16/24.
//

import Foundation

protocol FeedItemRepositoryCursor { }

protocol FeedItemRepository {
    func getFeedItemsNewestToOldest(
        after cursor: inout FeedItemRepositoryCursor?,
        limit: Int,
        excludeItemsFrom userIdToExclude: String
    ) async throws -> [FeedItem]
}

class MockFeedItemRepository: FeedItemRepository {
    
    struct Cursor: FeedItemRepositoryCursor {
        let id: Int
    }
    
    let totalFeedItems: Int = 22
    
    func getFeedItemsNewestToOldest(
        after cursor: inout FeedItemRepositoryCursor?,
        limit: Int,
        excludeItemsFrom userIdToExclude: String
    ) async throws -> [FeedItem] {
        try await Task.sleep(for: .seconds(0.5))
        
        var limit = limit
        var indexOffset = 0
        if let cursor = cursor as? Cursor {
            indexOffset = cursor.id + 1
        }
        
        if indexOffset + limit > totalFeedItems {
            limit = totalFeedItems - indexOffset
        }
        
        let feedItems = (indexOffset..<(indexOffset+limit)).map { i in
            getRandomFeedItem(i)
        }
        if let last = feedItems.last {
            cursor = Cursor(id: Int(last.id)!)
        }
        return feedItems
    }
    
    private func getRandomFeedItem(_ i: Int) -> FeedItem {
        let sampleIndex = i % FeedItem.samples.count
        var feedItem = FeedItem.samples[sampleIndex]
        feedItem.id = "\(i)"
        return feedItem
    }
}
