//
//  FeedViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/20/24.
//

import Foundation
import SwinjectAutoregistration
import SwiftUI

@MainActor
class FeedViewModel: ObservableObject {
    
    @Published var feedItems: [FeedItem] = []
    @Published var canFetchMoreFeedItems: Bool = true
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let feedItemProvider = iocContainer~>FeedItemProvider.self
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    func fetchMoreFeedItems() {
        Task {
            do {
                let newFeedItems = try await feedItemProvider.fetchNextFeedItems()
                feedItems.append(contentsOf: newFeedItems)
                
                if newFeedItems.isEmpty {
                    withAnimation(.snappy) {
                        canFetchMoreFeedItems = false
                    }
                }
            } catch {
                show(alertMessage: "Could not retrieve next feed items: \(error.localizedDescription)")
            }
        }
    }
}
