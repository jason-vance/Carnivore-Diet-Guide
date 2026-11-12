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
    @Published public var isPublisher: Bool = false
    public var canCreateContent: Bool { isAdmin || isPublisher }
    public var screenTitle: String { userData.username?.value ?? String(localized: "User Profile") }
    public var profileImageUrl: URL? { userData.profileImageUrl }

    private let currentUserIdProvider: CurrentUserIdProvider
    private let userDataProvider: UserDataProvider
    private let userDataSaver: UserDataSaver
    private let isAdminChecker: IsAdminChecker
    private let isPublisherChecker: IsPublisherChecker

    private var subs: Set<AnyCancellable> = []

    init(
        currentUserIdProvider: CurrentUserIdProvider,
        userDataProvider: UserDataProvider,
        userDataSaver: UserDataSaver,
        isAdminChecker: IsAdminChecker,
        isPublisherChecker: IsPublisherChecker
    ) {
        self.currentUserIdProvider = currentUserIdProvider
        self.userDataProvider = userDataProvider
        self.userDataSaver = userDataSaver
        self.isAdminChecker = isAdminChecker
        self.isPublisherChecker = isPublisherChecker

        checkIsAdmin()
        checkIsPublisher()
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

    func checkIsPublisher() {
        Task {
            guard let userId = currentUserIdProvider.currentUserId else { return }
            guard let isPublisher = try? await isPublisherChecker.isPublisher(userId: userId) else { return }
            self.isPublisher = isPublisher
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
    
    func save(whyCarnivore: String) {
        Task {
            try await userDataSaver.save(whyCarnivore: WhyCarnivore(whyCarnivore), toUser: userData.id)
        }
    }
    
    func save(carnivoreSince: Date?) {
        Task {
            let carnivoreSince = carnivoreSince == nil ? nil : CarnivoreSince(carnivoreSince!)
            try await userDataSaver.save(carnivoreSince: carnivoreSince, toUser: userData.id)
        }
    }
}
