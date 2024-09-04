//
//  ArticleLibrary.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/4/24.
//

import Foundation
import SwinjectAutoregistration

class ArticleLibrary {
    
    private typealias ArticleCache = Cache<String, ArticleCacheEntry>
    private static let cacheName = "ArticlesCache"
    
    private var articles: [Article] = []
    
    private let articleFetcher: ArticleFetcher

    private let articleCache = Cache.readFromDiskOrDefault(ArticleCache.self, withName: ArticleLibrary.cacheName)
    
    public static func getInstance() -> ArticleLibrary { instance }
    public static let instance: ArticleLibrary = {
        .init(articleFetcher: iocContainer~>ArticleFetcher.self)
    }()
    
    private init(
        articleFetcher: ArticleFetcher
    ) {
        self.articleFetcher = articleFetcher
        
        fetchArticles()
    }
    
    private func fetchArticles() {
        fetchCachedArticles()
        
        Task {
            try? await fetchNewerArticles()
            try? await fetchOlderArticles()
            
            try? articleCache.saveToDisk(withName: ArticleLibrary.cacheName)
        }
    }
    
    private func fetchCachedArticles() {
        articles = articleCache.values.compactMap { $0.toArticle() }
    }
    
    private func fetchNewerArticles() async throws {
        guard var newestArticle = (articles.max { $0.publicationDate > $1.publicationDate }) else { return }
        
        var canFetchMore = true
        
        while canFetchMore {
            do {
                let fetchedArticles = try await articleFetcher.fetchArticlesNewestToOldest(
                    newerThan: newestArticle,
                    limit: 20
                )
                
                canFetchMore = !fetchedArticles.isEmpty
                newestArticle = fetchedArticles.first ?? newestArticle
                
                articles.append(contentsOf: fetchedArticles)
                fetchedArticles.forEach { articleCache[$0.id] = .from($0) }
            } catch {
                print("ArticleLibrary.fetchNewerArticles failed. \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchOlderArticles() async throws {
        guard var oldestArticle = (articles.min { $0.publicationDate < $1.publicationDate }) else { return }
        
        var canFetchMore = true
        
        while canFetchMore {
            do {
                let fetchedArticles = try await articleFetcher.fetchArticlesNewestToOldest(
                    olderThan: oldestArticle,
                    limit: 20
                )
                
                canFetchMore = !fetchedArticles.isEmpty
                oldestArticle = fetchedArticles.last ?? oldestArticle
                
                articles.append(contentsOf: fetchedArticles)
                fetchedArticles.forEach { articleCache[$0.id] = .from($0) }
            } catch {
                print("ArticleLibrary.fetchOlderArticles failed. \(error.localizedDescription)")
            }
        }
    }
}
