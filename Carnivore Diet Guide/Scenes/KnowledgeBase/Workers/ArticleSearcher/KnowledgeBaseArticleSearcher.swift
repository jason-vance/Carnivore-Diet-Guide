//
//  KnowledgeBaseArticleSearcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/3/24.
//

import Foundation

protocol KnowledgeBaseArticleSearcher {
    func searchArticles(in category: Resource.Category, query: String) async throws -> [Article]
}

class MockKnowledgeBaseArticleSearcher: KnowledgeBaseArticleSearcher {
    
    public var articles: [Article] = [ .sample, .sample2 ]
    public var error: Error? = nil
    
    func searchArticles(in category: Resource.Category, query: String) async throws -> [Article] {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
        return articles
    }
}
