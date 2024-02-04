//
//  ContentAuthenticationProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation

protocol ContentAuthenticationProvider {
    var userAuthStatePublisher: Published<UserAuthState>.Publisher { get }
    var currentUserIdPublisher: Published<String?>.Publisher { get }
}

class MockContentAuthenticationProvider: ContentAuthenticationProvider {
    @Published var userAuthState: UserAuthState = .loggedIn
    var userAuthStatePublisher: Published<UserAuthState>.Publisher { $userAuthState }
    
    @Published var currentUserId: String? = "userId"
    var currentUserIdPublisher: Published<String?>.Publisher { $currentUserId }
}
