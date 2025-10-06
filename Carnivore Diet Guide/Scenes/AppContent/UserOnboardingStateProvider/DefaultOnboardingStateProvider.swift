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
            .sink(receiveValue: onUpdate(userData:))
    }
    
    private func onUpdate(currentUserId: String?) {
        //TODO: I might need to pass a special polling period parameter into here
        userDataProvider.startListeningToUser(withId: currentUserId)
    }
    
    private func onUpdate(userData: UserData) {
        Task {
            await setUserOnboardingState(from: userData)
        }
    }
    
    @MainActor
    private func setUserOnboardingState(from userData: UserData) {
        if userData.id.isEmpty {
            self.userOnboardingState = .unknown
        } else if userData.isFullyOnboarded {
            self.userOnboardingState = .fullyOnboarded
        } else {
            self.userOnboardingState = .notOnboarded
        }
    }
}
