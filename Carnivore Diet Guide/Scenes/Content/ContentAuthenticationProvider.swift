//
//  ContentAuthenticationProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation

protocol ContentAuthenticationProvider {
    var userAuthStatePublisher: Published<UserAuthState>.Publisher { get }
}

class MockContentAuthenticationProvider: ContentAuthenticationProvider {
    @Published var userAuthState: UserAuthState = .loggedOut
    var userAuthStatePublisher: Published<UserAuthState>.Publisher { $userAuthState }
}
