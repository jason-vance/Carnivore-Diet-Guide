//
//  UserProfileViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import Foundation
import Combine

@MainActor
class UserProfileViewModel: ObservableObject {
    
    @Published public var userData: UserData = .empty
    @Published public var isAdmin: Bool = false
    public var screenTitle: String { userData.username?.value ?? String(localized: "User Profile") }
    public var profileImageUrl: URL? { userData.profileImageUrl }

    private let userDataProvider: UserDataProvider
    private let isAdminChecker: IsAdminChecker
    
    private var subs: Set<AnyCancellable> = []
    
    init(
        userDataProvider: UserDataProvider,
        isAdminChecker: IsAdminChecker
    ) {
        self.userDataProvider = userDataProvider
        self.isAdminChecker = isAdminChecker
    }
    
    public func listenForUserData(userId: String) {
        userDataProvider.startListeningToUser(withId: userId)
        userDataProvider.userDataPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: receive(userData:))
            .store(in: &subs)
        
        checkIsAdmin(userId: userId)
    }
    
    func checkIsAdmin(userId: String) {
        Task {
            guard let isAdmin = try? await isAdminChecker.isAdmin(userId: userId) else { return }
            self.isAdmin = isAdmin
        }
    }
    
    private func receive(userData: UserData) {
        self.userData = userData
    }
}
