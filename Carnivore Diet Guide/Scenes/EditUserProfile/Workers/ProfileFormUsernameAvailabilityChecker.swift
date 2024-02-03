//
//  ProfileFormUsernameAvailabilityChecker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/2/24.
//

import Foundation

protocol ProfileFormUsernameAvailabilityChecker {
    func checkIsAvailable(username: Username) async throws -> Bool
}

class MockProfileFormUsernameAvailabilityChecker: ProfileFormUsernameAvailabilityChecker {
    
    var returnsIsAvailable = true
    var willThrow = false
    
    func checkIsAvailable(username: Username) async throws -> Bool {
        try? await Task.sleep(for: .seconds(1))
        if willThrow { throw "error" }
        return returnsIsAvailable
    }
}
