//
//  PostFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation

protocol PostFetcher {
    func fetchPost(withId: String) async throws -> Post
}

class DefaultPostFetcher: PostFetcher {
    
    private let fetchAction: (String) async throws -> Post
    
    init(fetchAction: @escaping (String) async throws -> Post) {
        self.fetchAction = fetchAction
    }
    
    func fetchPost(withId postId: String) async throws -> Post {
        try await fetchAction(postId)
    }
}

extension DefaultPostFetcher {
    static var forPreviewsWithSuccess: PostFetcher {
        return DefaultPostFetcher { _ in
            try await Task.sleep(for: .seconds(1))
            return .sample
        }
    }
    
    static var forPreviewsWithFailure: PostFetcher {
        return DefaultPostFetcher { _ in
            try await Task.sleep(for: .seconds(1))
            throw "Test failure"
        }
    }
}
