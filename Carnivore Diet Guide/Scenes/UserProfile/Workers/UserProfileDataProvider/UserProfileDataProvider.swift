//
//  UserProfileDataProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation

protocol UserProfileDataProvider {
    var userDataPublisher: Published<UserData>.Publisher { get }
    func startListeningToUser(withId id: String)
}

class MockUserProfileDataProvider: UserProfileDataProvider {
    
    @Published var userData: UserData = .sample
    var userDataPublisher: Published<UserData>.Publisher { $userData }
    
    func startListeningToUser(withId id: String) {
        userData = userData
    }
}
