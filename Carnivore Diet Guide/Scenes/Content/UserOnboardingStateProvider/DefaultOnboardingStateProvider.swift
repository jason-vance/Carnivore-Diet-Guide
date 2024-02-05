//
//  DefaultOnboardingStateProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import Foundation
import Combine

class DefaultUserOnboardingStateProvider: UserOnboardingStateProvider {
    
    @Published var userOnboardingState: UserOnboardingState = .unknown
    var userOnboardingStatePublisher: Published<UserOnboardingState>.Publisher { $userOnboardingState }

    let userIdProvider: CurrentUserIdProvider
    let userDataProvider: UserDataProvider
    
    var userIdSub: AnyCancellable? = nil
    var userDataSub: AnyCancellable? = nil

    init(userIdProvider: CurrentUserIdProvider, userDataProvider: UserDataProvider) {
        self.userIdProvider = userIdProvider
        self.userDataProvider = userDataProvider

        listenToUserDataChanges()
    }
    
    private func listenToUserDataChanges() {
        userIdSub = userIdProvider.currentUserIdPublisher
            .sink(receiveValue: onUpdate(currentUserId:))
        userDataSub = userDataProvider.userDataPublisher
            .filter { !$0.id.isEmpty }
            .sink(receiveValue: onUpdate(userData:))
    }
    
    private func onUpdate(currentUserId: String?) {
        userDataProvider.startListeningToUser(withId: currentUserId)
    }
    
    private func onUpdate(userData: UserData) {
        if userData.isFullyOnboarded {
            self.userOnboardingState = .fullyOnboarded
        } else {
            self.userOnboardingState = .notOnboarded
        }
    }
}
