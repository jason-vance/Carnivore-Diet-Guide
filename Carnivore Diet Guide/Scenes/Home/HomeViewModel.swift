//
//  HomeViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/16/24.
//

import Foundation
import SwinjectAutoregistration

@MainActor
class HomeViewModel: ObservableObject {
        
    @Published var userProfileImageUrl: URL?
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let userDataProvider = iocContainer~>CurrentUserDataProvider.self
    
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
    
    func refreshNewsFeed() {
        (iocContainer~>FeedViewContentProvider.self).refresh()
    }
}
