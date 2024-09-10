//
//  ArticleCollectionFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

protocol ArticleCursor { }

protocol ArticleCollectionFetcher {
    func fetchArticlesOldestFirst(
        newerThan article: Article?,
        limit: Int
    ) async throws -> [Article]
    
    func fetchArticlesNewestFirst(
        olderThan article: Article?,
        limit: Int
    ) async throws -> [Article]
    
    func fetchTrendingArticles(in timeFrame: TimeFrame) async throws -> [String]
    
    func fetchLikedArticles(in timeFrame: TimeFrame) async throws -> [String]
}

class MockArticleCollectionFetcher: ArticleCollectionFetcher {
    
    var articles: [Article] = [ .sample, .sample2 ]
    var error: Error? = nil
    
    func fetchArticlesOldestFirst(
        newerThan article: Article?,
        limit: Int
    ) async throws -> [Article] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return articles
    }
    
    func fetchArticlesNewestFirst(
        olderThan article: Article?,
        limit: Int
    ) async throws -> [Article] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return articles
    }
    
    func fetchTrendingArticles(in timeFrame: TimeFrame) async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return articles.map { $0.id }
    }
    
    func fetchLikedArticles(in timeFrame: TimeFrame) async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return articles.map { $0.id }
    }
}
