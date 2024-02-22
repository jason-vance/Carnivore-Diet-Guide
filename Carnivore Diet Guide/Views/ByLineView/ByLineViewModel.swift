//
//  ByLineViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/15/24.
//

import Foundation
import SwinjectAutoregistration

@MainActor
class ByLineViewModel: ObservableObject {
    
    enum InitializationState {
        case uninitialized
        case initialized
    }
    
    private static let unknownAuthorName = String(localized: "Unknown Author")
    
    @Published var initializationState: InitializationState = .uninitialized
    @Published var authorFullName: String = unknownAuthorName
    @Published var authorProfilePicUrl: URL?
    
    private let userFetcher = iocContainer~>UserFetcher.self

    func set(userId: String) {
        Task {
            initializationState = .uninitialized
            await fetchAuthor(userId: userId)
            initializationState = .initialized
        }
    }
    
    private func fetchAuthor(userId: String) async {
        authorFullName = Self.unknownAuthorName
        
        guard let userData = try? await userFetcher.fetchUser(userId: userId) else { return }
        
        authorProfilePicUrl = userData.profileImageUrl
        
        if let userFullName = userData.fullName?.value {
            authorFullName = String(localized: .init(userFullName))
        }
    }
}
