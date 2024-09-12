//
//  PublishersFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/11/24.
//

import Foundation

protocol PublishersFetcher {
    func fetchPublishers() async throws -> [String]
}

class MockPublishersFetcher: PublishersFetcher {
    
    var publishers: [String] = [UserData.sample.id]
    
    func fetchPublishers() async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        return publishers
    }
}
