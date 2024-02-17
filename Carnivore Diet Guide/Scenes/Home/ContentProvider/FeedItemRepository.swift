//
//  FeedItemRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/16/24.
//

import Foundation

protocol FeedItemRepository {
    func getFeedItemsNewestToOldest(after: FeedItem?, limit: Int) async throws -> [FeedItem]
}

class MockFeedItemRepository: FeedItemRepository {
    
    let totalFeedItems: Int = 22
    
    func getFeedItemsNewestToOldest(after: FeedItem?, limit: Int) async throws -> [FeedItem] {
        try await Task.sleep(for: .seconds(0.5))
        
        var limit = limit
        var indexOffset = 0
        if let after = after {
            indexOffset = Int(after.id)! + 1
        }
        
        if indexOffset + limit > totalFeedItems {
            limit = totalFeedItems - indexOffset
        }
        
        return (indexOffset..<(indexOffset+limit)).map { i in
            getRandomFeedItem(i)
        }
    }
    
    private func getRandomFeedItem(_ i: Int) -> FeedItem {
        let sampleIndex = i % FeedItem.samples.count
        var feedItem = FeedItem.samples[sampleIndex]
        feedItem.id = "\(i)"
        print("Created FeedItem.id: \(feedItem.id)")
        return feedItem
    }
}
