//
//  UserFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/11/24.
//

import Foundation

protocol UserFetcher {
    func fetchUser(userId: String) async throws -> UserData
}

class MockUserFetcher: UserFetcher {
    
    var userData: UserData = .sample
    var error: Error?
    
    func fetchUser(userId: String) async throws -> UserData {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
        return userData
    }
}
