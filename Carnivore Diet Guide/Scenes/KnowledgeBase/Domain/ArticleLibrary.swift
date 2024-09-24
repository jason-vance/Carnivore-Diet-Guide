//
//  ArticleLibrary.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/4/24.
//

import Foundation
import Combine

class ArticleLibrary {
    
    private typealias ArticleCache = Cache<String, ArticleCacheEntry>
    private static let cacheName = "ArticlesCache"
    
    private var articlesSubject: CurrentValueSubject<Dictionary<String, Article>,Never> = .init([:])
    private var removedArticleSubject: CurrentValueSubject<Article?, Never> = .init(nil)
    private var isLoggedIn: Bool = false
    
    public var publishedArticlesPublisher: AnyPublisher<[Article],Never> {
        articlesSubject
            .map {
                $0.filter { $0.value.publicationDate < .now }
                    .map { $0.value }
            }
            .eraseToAnyPublisher()
    }
    
    public var removedArticlePublisher: AnyPublisher<Article,Never> {
        removedArticleSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private let authProvider: ContentAuthenticationProvider
    private let articleCollectionFetcher: ArticleCollectionFetcher
    private let individualArticleFetcher: IndividualArticleFetcher
    private let resourceDeleter: ResourceDeleter
    
    private var userStateSub: AnyCancellable? = nil
    private var articleDeletedSub: AnyCancellable? = nil

    private let articleCache = Cache.readFromDiskOrDefault(ArticleCache.self, withName: ArticleLibrary.cacheName)
    
    private static var instance: ArticleLibrary? = nil
    public static func getInstance(
        authProvider: ContentAuthenticationProvider,
        articleCollectionFetcher: ArticleCollectionFetcher,
        individualArticleFetcher: IndividualArticleFetcher,
        resourceDeleter: ResourceDeleter
    ) -> ArticleLibrary {
        if instance == nil {
            instance = .init(
                authProvider: authProvider,
                articleCollectionFetcher: articleCollectionFetcher,
                individualArticleFetcher: individualArticleFetcher,
                resourceDeleter: resourceDeleter
            )
        }
        
        return instance!
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
        authProvider: ContentAuthenticationProvider,
        articleCollectionFetcher: ArticleCollectionFetcher,
        individualArticleFetcher: IndividualArticleFetcher,
        resourceDeleter: ResourceDeleter
    ) {
        self.authProvider = authProvider
        self.articleCollectionFetcher = articleCollectionFetcher
        self.individualArticleFetcher = individualArticleFetcher
        self.resourceDeleter = resourceDeleter
        
        listenToUserAuthState()
        listenForDeletedArticles()
    }
    
    private func onUpdate(authState: UserAuthState) {
        isLoggedIn = (authState == .loggedIn)
        fetchArticles()
    }
    
    public func getArticle(byId articleId: String) async -> Article? {
        if let article = articlesSubject.value[articleId] {
            return article
        }
        return try? await individualArticleFetcher.fetchArticle(withId: articleId)
    }
    
    private func listenToUserAuthState() {
        userStateSub = authProvider.userAuthStatePublisher
            .sink(receiveValue: onUpdate(authState:))
    }
    
    private func listenForDeletedArticles() {
        articleDeletedSub = resourceDeleter.deletedResourcePublisher
            .filter { $0.type == .article }
            .sink(receiveValue: removeArticleMatching(resource:))
    }
    
    public func resetArticleCache() {
        articleCache.removeAll()
        try? articleCache.saveToDisk(withName: Self.cacheName)
        
        fetchArticles()
    }
    
    private func removeArticleMatching(resource: Resource) {
        let article = articlesSubject.value[resource.id]
        articlesSubject.value[resource.id] = nil
        articleCache[resource.id] = nil
        removedArticleSubject.send(article)
        
        try? articleCache.saveToDisk(withName: Self.cacheName)
    }
    
    private func addToLibrary(articles: [Article]) {
        articles.forEach {
            articlesSubject.value[$0.id] = $0
            articleCache[$0.id] = .from($0)
        }
        
        try? articleCache.saveToDisk(withName: Self.cacheName)
    }
    
    private func fetchArticles() {
        fetchCachedArticles()
        
        Task {
            guard isLoggedIn else { return }
            try? await fetchNewerArticles()
            try? await fetchOlderArticles()
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
                let fetchedArticles = try await articleCollectionFetcher.fetchArticlesOldestFirst(
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
                let fetchedArticles = try await articleCollectionFetcher.fetchArticlesNewestFirst(
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
    
    func updateArticleDataIfNecessary(_ article: Article) {
        Task {
            do {
                guard let cacheEntry = articleCache[article.id] else { return }
                guard (cacheEntry.refreshAfterDate ?? .now) <= .now else { return }

                let article = try await individualArticleFetcher.fetchArticle(withId: article.id)

                addToLibrary(articles: [article])
            } catch Resource.Errors.doesNotExist {
                print("Article \(article.id) no longer exists remotely, removing")
                removeArticleMatching(resource: .init(article))
            } catch {
                print("Error updating article data for \(article.id). \(error.localizedDescription)")
            }
        }
    }
}

extension ArticleLibrary: ArticleCacheResetter {}
