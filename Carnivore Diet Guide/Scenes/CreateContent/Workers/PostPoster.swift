//
//  PostPoster.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/22/24.
//

import Foundation

protocol PostPoster {
    func post(post: Post, feedItem: FeedItem) async throws
}

class DefaultPostPoster: PostPoster {
    
    let postAction: (Post, FeedItem) async throws -> ()
    
    init(postAction: @escaping (Post, FeedItem) async throws -> Void) {
        self.postAction = postAction
    }
    
    func post(post: Post, feedItem: FeedItem) async throws {
        try await postAction(post, feedItem)
    }
}

extension DefaultPostPoster {
    static var forPreviewsWithSuccess: PostPoster {
        DefaultPostPoster { post, feedItem in
            try await Task.sleep(for: .seconds(1))
        }
    }
    
    static var forPreviewsWithFailure: PostPoster {
        DefaultPostPoster { post, feedItem in
            try await Task.sleep(for: .seconds(1))
            throw TextError("Test Error")
        }
    }
}
