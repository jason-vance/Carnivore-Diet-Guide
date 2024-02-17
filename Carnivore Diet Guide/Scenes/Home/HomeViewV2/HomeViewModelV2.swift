//
//  HomeViewModelV2.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/16/24.
//

import Foundation
import SwinjectAutoregistration

@MainActor
class HomeViewModelV2: ObservableObject {
    
    @Published var userProfileImageUrl: URL?
    @Published var feedItems: [FeedItem] = []
    @Published var canFetchMoreFeedItems: Bool = true
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let userDataProvider = iocContainer~>CurrentUserDataProvider.self
    private let feedItemProvider = iocContainer~>FeedItemProvider.self
    
    init() {
        fetchCurrentUserData()
    }
    
    private func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
    
    private func fetchCurrentUserData() {
        Task {
            let userData = try? await userDataProvider.fetchCurrentUserData()
            userProfileImageUrl = userData?.profileImageUrl
        }
    }
    
    func fetchMoreFeedItems() {
        Task {
            do {
                let newFeedItems = try await feedItemProvider.fetchNextFeedItems()
                feedItems.append(contentsOf: newFeedItems)
                
                if newFeedItems.isEmpty {
                    canFetchMoreFeedItems = false
                }
            } catch {
                show(alertMessage: "Could not retrieve next feed items: \(error.localizedDescription)")
            }
        }
    }
}
