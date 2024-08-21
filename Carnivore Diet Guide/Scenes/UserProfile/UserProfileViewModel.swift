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
    public var fullName: String? { userData.fullName?.value }
    public var profileImageUrl: URL? { userData.profileImageUrl }

    private let userDataProvider: UserDataProvider
    private let signOutService: UserProfileSignOutService
    
    private var subs: Set<AnyCancellable> = []
    
    init(
        userDataProvider: UserDataProvider,
        signOutService: UserProfileSignOutService
    ) {
        self.userDataProvider = userDataProvider
        self.signOutService = signOutService
    }
    
    public func listenForUserData(userId: String) {
        userDataProvider.startListeningToUser(withId: userId)
        userDataProvider.userDataPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: receive(userData:))
            .store(in: &subs)
    }
    
    private func receive(userData: UserData) {
        self.userData = userData
    }
    
    public func signOut() throws {
        try signOutService.signOut()
    }
}
