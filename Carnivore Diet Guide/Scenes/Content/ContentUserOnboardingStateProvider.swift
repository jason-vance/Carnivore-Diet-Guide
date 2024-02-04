//
//  ContentUserOnboardingStateProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation

protocol ContentUserOnboardingStateProvider {
    var userOnboardingStatePublisher: Published<UserOnboardingState>.Publisher { get }
}

class MockContentUserOnboardingStateProvider: ContentUserOnboardingStateProvider {
    @Published var userOnboardingState: UserOnboardingState = .unknown
    var userOnboardingStatePublisher: Published<UserOnboardingState>.Publisher { $userOnboardingState }
}
