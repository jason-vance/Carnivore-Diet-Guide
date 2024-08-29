//
//  ArticleFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

protocol ArticleCursor { }

protocol ArticleFetcher {
    func fetchArticles(
        byCategory category: ArticleCategory,
        after cursor: inout ArticleCursor?,
        limit: Int
    ) async throws -> [Article]
}

class MockArticleFetcher: ArticleFetcher {
    
    struct MockCursor: ArticleCursor {}
    
    var articles: [Article] = [ .sample, .sample2 ]
    var error: Error? = nil
    
    func fetchArticles(
        byCategory category: ArticleCategory,
        after cursor: inout ArticleCursor?,
        limit: Int
    ) async throws -> [Article] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        guard cursor == nil else { return [] }
        
        cursor = MockCursor()
        return articles
    }
}
