//
//  ArticleFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

protocol ArticleCursor { }

protocol ArticleFetcher {
    func fetchArticlesOldestFirst(
        newerThan article: Article,
        limit: Int
    ) async throws -> [Article]
    
    func fetchArticlesNewestFirst(
        olderThan article: Article?,
        limit: Int
    ) async throws -> [Article]
    
    //TODO: Change this to return a FeaturedArticle (with properties like featureCalloutText, etc)
    func fetchFeaturedArticles() async throws -> [String]
    
    func fetchTrendingArticles() async throws -> [String]
    
    func fetchLikedArticles() async throws -> [String]
}

class MockArticleFetcher: ArticleFetcher {
    
    var articles: [Article] = [ .sample, .sample2 ]
    var error: Error? = nil
    
    func fetchArticlesOldestFirst(
        newerThan article: Article,
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
    
    func fetchFeaturedArticles() async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return articles.map { $0.id }
    }
    
    func fetchTrendingArticles() async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return articles.map { $0.id }
    }
    
    func fetchLikedArticles() async throws -> [String] {
        try await Task.sleep(for: .seconds(1))
        
        if let error = error {
            throw error
        }
        
        return articles.map { $0.id }
    }
}
