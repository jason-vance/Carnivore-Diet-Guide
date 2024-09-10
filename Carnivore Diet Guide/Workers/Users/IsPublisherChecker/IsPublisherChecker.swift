//
//  IsPublisherChecker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/10/24.
//

import Foundation

protocol IsPublisherChecker {
    func isPublisher(userId: String) async throws -> Bool
}

class MockIsPublisherChecker: IsPublisherChecker{
    
    var isPublisher: Bool = true
    
    func isPublisher(userId: String) async throws -> Bool {
        try await Task.sleep(for: .seconds(1))
        return isPublisher
    }
}
