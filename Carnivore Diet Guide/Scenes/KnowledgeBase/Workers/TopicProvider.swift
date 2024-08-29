//
//  TopicProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

protocol TopicProvider {
    func fetchTopics() async throws -> [Topic]
}

class MockTopicProvider: TopicProvider {
    
    var topics: [Topic] = Topic.samples
    var error: Error? = nil
    
    func fetchTopics() async throws -> [Topic] {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
        return topics
    }
}
