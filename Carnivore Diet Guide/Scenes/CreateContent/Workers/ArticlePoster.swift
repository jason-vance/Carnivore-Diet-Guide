//
//  ArticlePoster.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import Foundation

protocol ArticlePoster {
    func post(
        article: Article,
        categories: Set<Resource.Category>,
        keywords: Set<SearchKeyword>,
        feedItem: FeedItem
    ) async throws
}

class DefaultArticlePoster: ArticlePoster {
    
    let postAction: (Article, Set<Resource.Category>, Set<SearchKeyword>, FeedItem) async throws -> ()
    
    init(postAction: @escaping (Article, Set<Resource.Category>, Set<SearchKeyword>, FeedItem) async throws -> Void) {
        self.postAction = postAction
    }
    
    func post(
        article: Article,
        categories: Set<Resource.Category>,
        keywords: Set<SearchKeyword>,
        feedItem: FeedItem
    ) async throws {
        try await postAction(article, categories, keywords, feedItem)
    }
}

extension DefaultArticlePoster {
    static var forPreviewsWithSuccess: ArticlePoster {
        DefaultArticlePoster { article, categories, keywords, feedItem in
            try await Task.sleep(for: .seconds(1))
        }
    }
    
    static var forPreviewsWithFailure: ArticlePoster {
        DefaultArticlePoster { article, categories, keywords, feedItem in
            try await Task.sleep(for: .seconds(1))
            throw "Test Error"
        }
    }
}
