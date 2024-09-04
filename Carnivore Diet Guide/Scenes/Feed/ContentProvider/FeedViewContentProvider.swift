//
//  FeedItemProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/16/24.
//

import Foundation
import SwinjectAutoregistration

protocol FeedViewContentProvider {
    var canFetchMoreFeedItemsPublisher: Published<Bool>.Publisher { get }
    var feedItemsPublisher: Published<[FeedItem]>.Publisher { get }
    func fetchMoreFeedItems() async throws
    func refresh()
}

class DefaultFeedViewContentProvider: FeedViewContentProvider {
    
    static let instance: DefaultFeedViewContentProvider = { .init() }()
    private static let limit = 5
    
    private var cursor: FeedItemRepositoryCursor? = nil
    @Published var feedItems: [FeedItem] = []
    @Published var canFetchMore: Bool = true
    
    var feedItemsPublisher: Published<[FeedItem]>.Publisher { $feedItems }
    var canFetchMoreFeedItemsPublisher: Published<Bool>.Publisher { $canFetchMore }
        
    private let feedItemRepo = iocContainer~>FeedItemRepository.self
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    
    private var currentUser: String { userIdProvider.currentUserId! }
    
    private init() {
        resetProperties()
    }
    
    private func resetProperties() {
        cursor = nil
        feedItems = []
        canFetchMore = true
    }
    
    func refresh() {
        resetProperties()
    }

    func fetchMoreFeedItems() async throws {
        let newFeedItems = try await feedItemRepo.getPublishedFeedItemsNewestToOldest(
            after: &cursor,
            limit: Self.limit,
            excludeItemsFrom: currentUser
        )
        if newFeedItems.isEmpty {
            canFetchMore = false
        }
        feedItems.append(contentsOf: newFeedItems)
    }
}
