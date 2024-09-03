//
//  ArticleDetailArticleFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/3/24.
//

import Foundation

protocol ArticleDetailArticleFetcher {
    func fetchArticle(withId articleId: String) async throws -> Article
}

class MockArticleDetailArticleFetcher: ArticleDetailArticleFetcher {
    
    public var article: Article = .sample
    public var error: Error? = nil
    
    func fetchArticle(withId articleId: String) async throws -> Article {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
        return article
    }
}
