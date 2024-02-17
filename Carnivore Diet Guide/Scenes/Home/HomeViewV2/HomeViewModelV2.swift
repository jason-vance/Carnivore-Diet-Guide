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
    
    private let userDataProvider = iocContainer~>CurrentUserDataProvider.self
    
    init() {
        fetchCurrentUserData()
    }
    
    private func fetchCurrentUserData() {
        Task {
            let userData = try? await userDataProvider.fetchCurrentUserData()
            userProfileImageUrl = userData?.profileImageUrl
        }
    }
}
