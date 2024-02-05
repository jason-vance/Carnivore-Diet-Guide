//
//  UserDataProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import Foundation

protocol UserDataProvider {
    var userDataPublisher: Published<UserData>.Publisher { get }
    func startListeningToUser(withId id: String?)
}

class MockUserDataProvider: UserDataProvider {
    
    @Published var userData: UserData = .empty
    var userDataPublisher: Published<UserData>.Publisher { $userData }
    
    func startListeningToUser(withId id: String?) {
        userData = userData
    }
}
