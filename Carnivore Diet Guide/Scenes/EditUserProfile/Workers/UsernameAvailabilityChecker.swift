//
//  UsernameAvailabilityChecker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/2/24.
//

import Foundation

protocol UsernameAvailabilityChecker {
    func checkIsAvailable(username: Username) async throws -> Bool
}

class MockUsernameAvailabilityChecker: UsernameAvailabilityChecker {
    
    var returnsIsAvailable = false
    var willThrow = false
    
    func checkIsAvailable(username: Username) async throws -> Bool {
        try? await Task.sleep(for: .seconds(1))
        if willThrow { throw "error" }
        return returnsIsAvailable
    }
}
