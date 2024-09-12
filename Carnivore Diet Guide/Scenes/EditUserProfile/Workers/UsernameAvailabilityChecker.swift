//
//  UsernameAvailabilityChecker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import Foundation

protocol UsernameAvailabilityChecker {
    func isAvailable(username: Username, forUser userId: String) async throws -> Bool
}

class MockUsernameAvailabilityChecker: UsernameAvailabilityChecker {
    
    var isAvailable: Bool = true
    
    func isAvailable(username: Username, forUser userId: String) async throws -> Bool {
        try await Task.sleep(for: .seconds(1))
        return isAvailable
    }
}
