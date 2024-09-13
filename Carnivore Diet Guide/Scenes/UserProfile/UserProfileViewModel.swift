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
    @Published public var isMe: Bool? = nil
    @Published public var isAdmin: Bool = false
    public var screenTitle: String { userData.username?.value ?? String(localized: "User Profile") }
    public var profileImageUrl: URL? { userData.profileImageUrl }

    private let currentUserIdProvider: CurrentUserIdProvider
    private let userDataProvider: UserDataProvider
    private let userDataSaver: UserDataSaver
    private let isAdminChecker: IsAdminChecker
    
    private var subs: Set<AnyCancellable> = []
    
    init(
        currentUserIdProvider: CurrentUserIdProvider,
        userDataProvider: UserDataProvider,
        userDataSaver: UserDataSaver,
        isAdminChecker: IsAdminChecker
    ) {
        self.currentUserIdProvider = currentUserIdProvider
        self.userDataProvider = userDataProvider
        self.userDataSaver = userDataSaver
        self.isAdminChecker = isAdminChecker
        
        checkIsAdmin()
    }
    
    public func listenForUserData(userId: String) {
        isMe = userId == currentUserIdProvider.currentUserId
        
        userDataProvider.startListeningToUser(withId: userId)
        userDataProvider.userDataPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: receive(userData:))
            .store(in: &subs)
    }
    
    func checkIsAdmin() {
        Task {
            guard let userId = currentUserIdProvider.currentUserId else { return }
            guard let isAdmin = try? await isAdminChecker.isAdmin(userId: userId) else { return }
            self.isAdmin = isAdmin
        }
    }
    
    private func receive(userData: UserData) {
        self.userData = userData
    }
    
    func save(userBio: String) {
        Task {
            try await userDataSaver.save(userBio: UserBio(userBio), toUser: userData.id)
        }
    }
}
