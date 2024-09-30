//
//  RemoteUserDataFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/30/24.
//

import Foundation

protocol RemoteUserDataFetcher {
    func fetchUser(userId: String) async throws -> UserData
}

class MockRemoteUserDataFetcher: RemoteUserDataFetcher {
    func fetchUser(userId: String) async throws -> UserData {
        try? await Task.sleep(for: .seconds(1))
        return .sample
    }
}
