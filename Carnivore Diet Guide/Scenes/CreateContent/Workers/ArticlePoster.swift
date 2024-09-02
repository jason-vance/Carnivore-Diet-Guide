//
//  ArticlePoster.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import Foundation

protocol ArticlePoster {
    func post(article: Article, feedItem: FeedItem) async throws
}

class DefaultArticlePoster: ArticlePoster {
    
    let postAction: (Article, FeedItem) async throws -> ()
    
    init(postAction: @escaping (Article, FeedItem) async throws -> Void) {
        self.postAction = postAction
    }
    
    func post(article: Article, feedItem: FeedItem) async throws {
        try await postAction(article, feedItem)
    }
}

extension DefaultArticlePoster {
    static var forPreviewsWithSuccess: ArticlePoster {
        DefaultArticlePoster { article, feedItem in
            try await Task.sleep(for: .seconds(1))
        }
    }
    
    static var forPreviewsWithFailure: ArticlePoster {
        DefaultArticlePoster { article, feedItem in
            try await Task.sleep(for: .seconds(1))
            throw "Test Error"
        }
    }
}
