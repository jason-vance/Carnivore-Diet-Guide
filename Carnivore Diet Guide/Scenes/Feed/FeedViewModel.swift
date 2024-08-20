//
//  FeedViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/20/24.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FeedViewModel: ObservableObject {
    
    @Published var feedItems: [FeedItem] = []
    @Published var canFetchMoreFeedItems: Bool = true
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let feedItemProvider: FeedViewContentProvider
    
    private var subs: Set<AnyCancellable> = []
    
    init(
        feedItemProvider: FeedViewContentProvider
    ) {
        self.feedItemProvider = feedItemProvider
        
        feedItemProvider.feedItemsPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: receive(feedItems:))
            .store(in: &subs)
        feedItemProvider.canFetchMoreFeedItemsPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: receive(canFetchMoreFeedItems:))
            .store(in: &subs)
    }
    
    private func receive(feedItems: [FeedItem]) {
        self.feedItems = feedItems
    }
    
    private func receive(canFetchMoreFeedItems: Bool) {
        withAnimation(.snappy) {
            self.canFetchMoreFeedItems = canFetchMoreFeedItems
        }
    }
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    func fetchMoreFeedItems() {
        Task {
            do {
                try await feedItemProvider.fetchMoreFeedItems()
            } catch {
                show(alertMessage: "Failed to get more feed items: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshNewsFeed() {
        feedItemProvider.refresh()
    }
}
