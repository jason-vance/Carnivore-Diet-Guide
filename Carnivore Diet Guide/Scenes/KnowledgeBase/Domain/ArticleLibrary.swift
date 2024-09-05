//
//  ArticleLibrary.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/4/24.
//

import Foundation
import Combine

//TODO: Re-fetch article every now and then in ArticleDetailView
//TODO: Remove articles that fail to load in ArticleDetailView
class ArticleLibrary {
    
    private typealias ArticleCache = Cache<String, ArticleCacheEntry>
    private static let cacheName = "ArticlesCache"
    
    private var articlesSubject: CurrentValueSubject<[Article],Never> = .init([])
    
    public var publishedArticlesPublisher: AnyPublisher<[Article],Never> {
        articlesSubject
            .map { $0.filter { $0.publicationDate < .now } }
            .eraseToAnyPublisher()
    }
    
    private let articleFetcher: ArticleFetcher
    private let resourceDeleter: ResourceDeleter
    
    private var articleDeletedSub: AnyCancellable? = nil

    private let articleCache = Cache.readFromDiskOrDefault(ArticleCache.self, withName: ArticleLibrary.cacheName)
    
    private static var _instance: ArticleLibrary? = nil
    public static var instance: ArticleLibrary { _instance! }
    public static func makeInstance(
        articleFetcher: ArticleFetcher,
        resourceDeleter: ResourceDeleter
    ) {
        assert(_instance == nil)
        _instance = .init(
            articleFetcher: articleFetcher,
            resourceDeleter: resourceDeleter
        )
    }
    
    private var newestPublishedArticle: Article? {
        articlesSubject.value
            .filter { $0.publicationDate < .now }
            .max { $0.publicationDate < $1.publicationDate }
    }
    
    private init(
        articleFetcher: ArticleFetcher,
        resourceDeleter: ResourceDeleter
    ) {
        self.articleFetcher = articleFetcher
        self.resourceDeleter = resourceDeleter
        
        fetchArticles()
        listenForDeletedArticles()
    }
    
    private func listenForDeletedArticles() {
        articleDeletedSub = resourceDeleter.deletedResourcePublisher
            .filter { $0.type == .article }
            .sink(receiveValue: onArticleDeleted(resource:))
    }
    
    private func onArticleDeleted(resource: Resource) {
        articlesSubject.value
            .removeAll { $0.id == resource.id }
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
        articlesSubject.value = articleCache.values.compactMap { $0.toArticle() }
    }
    
    private func fetchNewerArticles() async throws {
        guard var newestArticle = newestPublishedArticle else { return }
        print(newestArticle.publicationDate)
        
        var canFetchMore = true
        
        while canFetchMore {
            do {
                let fetchedArticles = try await articleFetcher.fetchArticlesOldestFirst(
                    newerThan: newestArticle,
                    limit: 20
                )
                
                canFetchMore = !fetchedArticles.isEmpty
                newestArticle = fetchedArticles.last ?? newestArticle
                
                articlesSubject.value.append(contentsOf: fetchedArticles)
                fetchedArticles.forEach { articleCache[$0.id] = .from($0) }
                print("ArticleLibrary.fetchNewerArticles found \(fetchedArticles.count) articles")
            } catch {
                print("ArticleLibrary.fetchNewerArticles failed. \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchOlderArticles() async throws {
        var oldestArticle = articlesSubject.value.min { $0.publicationDate < $1.publicationDate }
        
        var canFetchMore = true
        
        while canFetchMore {
            do {
                let fetchedArticles = try await articleFetcher.fetchArticlesNewestFirst(
                    olderThan: oldestArticle,
                    limit: 20
                )
                
                canFetchMore = !fetchedArticles.isEmpty
                oldestArticle = fetchedArticles.last ?? oldestArticle
                
                articlesSubject.value.append(contentsOf: fetchedArticles)
                fetchedArticles.forEach { articleCache[$0.id] = .from($0) }
                print("ArticleLibrary.fetchOlderArticles found \(fetchedArticles.count) articles")
            } catch {
                print("ArticleLibrary.fetchOlderArticles failed. \(error.localizedDescription)")
            }
        }
    }
}
