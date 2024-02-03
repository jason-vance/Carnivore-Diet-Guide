//
//  UserProfileDataProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation

protocol UserProfileDataProvider {
    var userProfileDataPublisher: Published<UserProfileData>.Publisher { get }
    func startListeningToUser(withId id: String)
}

class MockUserProfileDataProvider: UserProfileDataProvider {
    
    @Published var userProfileData: UserProfileData = .sample
    var userProfileDataPublisher: Published<UserProfileData>.Publisher { $userProfileData }
    
    func startListeningToUser(withId id: String) {
        userProfileData = userProfileData
    }
}
