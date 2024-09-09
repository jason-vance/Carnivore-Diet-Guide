//
//  IsAdminChecker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/8/24.
//

import Foundation

protocol IsAdminChecker {
    func isAdmin(userId: String) async throws -> Bool
}

class MockIsAdminChecker: IsAdminChecker {
    
    public var isAdmin: Bool = false
    
    func isAdmin(userId: String) async throws -> Bool {
        try await Task.sleep(for: .seconds(1))
        return isAdmin
    }
}
