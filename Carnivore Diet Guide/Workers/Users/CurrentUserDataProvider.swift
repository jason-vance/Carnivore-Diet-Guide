//
//  CurrentUserDataProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import Foundation

protocol CurrentUserDataProvider {
    func fetchCurrentUserData() async throws -> UserData
}

class MockCurrentUserDataProvider: CurrentUserDataProvider {
    
    func fetchCurrentUserData() async throws -> UserData {
        try? await Task.sleep(for: .seconds(1))
        return .sample
    }
}
