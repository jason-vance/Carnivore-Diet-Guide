//
//  ResourceDeleter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import Foundation

protocol ResourceDeleter {
    func delete(resource: Resource) async throws
}

class MockResourceDeleter: ResourceDeleter {
    
    public var error: Error? = nil
    
    func delete(resource: Resource) async throws {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
    }
}
