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
    
    private var articlesSubject: CurrentValueSubject<Dictionary<String, Article>,Never> = .init([:])
    
    public var publishedArticlesPublisher: AnyPublisher<[Article],Never> {
        articlesSubject
            .map {
                $0.filter { $0.value.publicationDate < .now }
                    .map { $0.value }
            }
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
            .filter { $0.value.publicationDate < .now }
            .map { $0.value }
            .max { $0.publicationDate < $1.publicationDate }
    }
    
    private var oldestPublishedArticle: Article? {
        articlesSubject.value
            .filter { $0.value.publicationDate < .now }
            .map { $0.value }
            .min { $0.publicationDate < $1.publicationDate }
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
        articlesSubject.value[resource.id] = nil
    }
    
    private func addToLibrary(articles: [Article]) {
        articles.forEach {
            articlesSubject.value[$0.id] = $0
            articleCache[$0.id] = .from($0)
        }
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
        let articles = articleCache.values.compactMap { $0.toArticle() }
        articlesSubject.value = Dictionary(uniqueKeysWithValues: articles.map{ ($0.id, $0) })
    }
    
    private func fetchNewerArticles() async throws {
        var newestArticle = newestPublishedArticle
        
        var canFetchMore = true
        while canFetchMore {
            do {
                let fetchedArticles = try await articleFetcher.fetchArticlesOldestFirst(
                    newerThan: newestArticle,
                    limit: 20
                )
                
                canFetchMore = !fetchedArticles.isEmpty
                newestArticle = fetchedArticles.last ?? newestArticle
                
                addToLibrary(articles: fetchedArticles)
                print("ArticleLibrary.fetchNewerArticles found \(fetchedArticles.count) articles")
            } catch {
                print("ArticleLibrary.fetchNewerArticles failed. \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchOlderArticles() async throws {
        var oldestArticle = oldestPublishedArticle
        
        var canFetchMore = true
        while canFetchMore {
            do {
                let fetchedArticles = try await articleFetcher.fetchArticlesNewestFirst(
                    olderThan: oldestArticle,
                    limit: 20
                )
                
                canFetchMore = !fetchedArticles.isEmpty
                oldestArticle = fetchedArticles.last ?? oldestArticle
                
                addToLibrary(articles: fetchedArticles)
                print("ArticleLibrary.fetchOlderArticles found \(fetchedArticles.count) articles")
            } catch {
                print("ArticleLibrary.fetchOlderArticles failed. \(error.localizedDescription)")
            }
        }
    }
}
