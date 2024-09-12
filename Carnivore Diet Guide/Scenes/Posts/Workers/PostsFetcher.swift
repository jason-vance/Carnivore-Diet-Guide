//
//  PostsFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import Foundation

protocol PostsFetcherCursor { }

protocol PostsFetcher {
    func fetchPosts(
        byUser userId: String,
        after cursor: inout PostsFetcherCursor?,
        limit: Int
    ) async throws -> [Post]
}

class MockPostsFetcher: PostsFetcher {
    
    struct MockCursor: PostsFetcherCursor {}
    
    var posts: [Post] = Post.samples
    var error: Error? = nil
    
    func fetchPosts(
        byUser userId: String,
        after cursor: inout PostsFetcherCursor?,
        limit: Int
    ) async throws -> [Post] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        guard cursor == nil else { return [] }
        
        cursor = MockCursor()
        return posts
    }
}
