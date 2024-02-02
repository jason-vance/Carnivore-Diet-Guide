//
//  UserProfileSignOutService.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation

protocol UserProfileSignOutService {
    func signOut() throws
}

class MockUserProfileSignOutService: UserProfileSignOutService {
    func signOut() throws {
    }
}
