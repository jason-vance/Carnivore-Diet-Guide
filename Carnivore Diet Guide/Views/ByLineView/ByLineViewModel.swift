//
//  ByLineViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/15/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

@MainActor
class ByLineViewModel: ObservableObject {
    
    enum InitializationState {
        case uninitialized
        case initialized
    }
    
    private static let unknownAuthorName = String(localized: "Unknown Author")
    
    @Published var initializationState: InitializationState = .uninitialized
    @Published var authorDisplayName: String = unknownAuthorName
    @Published var authorProfilePicUrl: URL?
    
    private let userFetcher = iocContainer~>UserFetcher.self
    
    private var sub: AnyCancellable? = nil

    func set(userId: String) {
        authorDisplayName = Self.unknownAuthorName
        initializationState = .uninitialized
        
        sub = userFetcher.fetchUser(userId: userId)
            .receive(on: RunLoop.main)
            .sink { [weak self] userData in
                self?.authorProfilePicUrl = userData.profileImageUrl
                if let userFullName = userData.fullName?.value {
                    self?.authorDisplayName = String(localized: .init(userFullName))
                } else if let username = userData.username?.value {
                    self?.authorDisplayName = username
                }
                self?.initializationState = .initialized
            }
    }
}
