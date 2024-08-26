//
//  ResourceReporter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation

protocol ResourceReporter {
    func reportResource(
        _ resource: Resource,
        reportedBy reporterId: String
    ) async throws
}

class MockResourceReporter: ResourceReporter {
    
    var error: Error?
    
    func reportResource(
        _ resource: Resource,
        reportedBy reporterId: String
    ) async throws {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
    }
}
