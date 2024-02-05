//
//  ContentUserOnboardingStateProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation

protocol UserOnboardingStateProvider {
    var userOnboardingStatePublisher: Published<UserOnboardingState>.Publisher { get }
}

class MockUserOnboardingStateProvider: UserOnboardingStateProvider {
    @Published var userOnboardingState: UserOnboardingState = .unknown
    var userOnboardingStatePublisher: Published<UserOnboardingState>.Publisher { $userOnboardingState }
}
