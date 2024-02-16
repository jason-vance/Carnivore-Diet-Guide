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
    
    @Published var loadingAuthor: Bool = false
    @Published var authorFullName: String = ""
    @Published var authorProfilePicUrl: URL?
    
    private let userFetcher = iocContainer~>UserFetcher.self

    func set(userId: String) {
        fetchAuthor(userId: userId)
    }
    
    private func fetchAuthor(userId: String) {
        Task {
            loadingAuthor = true
            do {
                let userData = try await userFetcher.fetchUser(userId: userId)
                
                authorProfilePicUrl = userData.profileImageUrl
                
                if let userFullName = userData.fullName?.value {
                    authorFullName = String(localized: .init(userFullName))
                } else {
                    authorFullName = String(localized: "Unknown Author")
                }
            }
            loadingAuthor = false
        }
    }
}
