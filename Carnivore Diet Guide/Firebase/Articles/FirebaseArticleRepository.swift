//
//  FirebaseArticleRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation
import FirebaseFirestore

class FirebaseArticleRepository {
    
    public static let ARTICLES = "Articles"
    
    private let articlesCollection = Firestore.firestore().collection(ARTICLES)
    
    private let categoriesField = FirebaseArticleDoc.CodingKeys.categories.rawValue
    private let publicationDateField = FirebaseArticleDoc.CodingKeys.publicationDate.rawValue
    private let keywordsField = FirebaseArticleDoc.CodingKeys.keywords.rawValue
    
    private func getCategoryDict() async throws -> Dictionary<String,Resource.Category> {
        let categoryRepo = FirebaseResourceCategoryRepository()
        let set = try await categoryRepo.fetchAllCategories(forType: .article)
        
        return Dictionary(uniqueKeysWithValues: set.map{ ($0.id, $0) })
    }

    
    func create(
        article: Article
    ) async throws {
        let doc = FirebaseArticleDoc.from(article: article)
        try await articlesCollection.document(article.id).setData(from: doc)
    }
    
    
//    private func fetchArticlesNewestToOldest(
//        after cursor: inout (any ArticleCursor)?,
//        limit: Int
//    ) async throws -> [Article] {
//        var query = articlesCollection
//            .order(by: publicationDateField, descending: true)
//            .limit(to: limit)
//        
//        return try await fetchArticles(withQuery: query, after: &cursor)
//    }
//    
//    
//    private func fetchArticles(
//        withQuery query: Query,
//        after cursor: inout (any ArticleCursor)?
//    ) async throws -> [Article] {
//        var query = query
//        if let cursor = cursor as? Cursor {
//            query = query.start(afterDocument: cursor.document)
//        }
//        
//        let snapshot = try await query.getDocuments()
//        
//        if let last = snapshot.documents.last {
//            cursor = Cursor(document: last)
//        }
//        
//        let categories = try await getCategoryDict()
//        return snapshot
//            .documents
//            .compactMap { try? $0.data(as: FirebaseArticleDoc.self).toArticle(categoryDict: categories) }
//    }
    
    
    func searchArticles(
        withKeyword keyword: SearchKeyword
    ) async throws -> [SearchResult<Article>] {
        let keywordField = keywordsField + ".\(keyword.text)"
        
        let query = articlesCollection
            .whereField(keywordField, isGreaterThan: 0)
        
        let categories = try await getCategoryDict()
        return try await query
            .getDocuments()
            .documents
            .compactMap {
                guard let articleDoc = try? $0.data(as: FirebaseArticleDoc.self) else { return nil }
                guard let score = articleDoc.keywords?[keyword.text] else { return nil }
                guard let article = articleDoc.toArticle(categoryDict: categories) else { return nil }
                
                return SearchResult(item: article, score: score)
            }
    }
}

extension FirebaseArticleRepository: ArticleFetcher {
    func fetchArticlesNewestToOldest(newerThan article: Article, limit: Int) async throws -> [Article] {
        //TODO: Implement FirebaseArticleRepository.fetchArticlesNewestToOldest
        throw "Not Implemented"
    }
    
    func fetchArticlesNewestToOldest(olderThan article: Article, limit: Int) async throws -> [Article] {
        //TODO: Implement FirebaseArticleRepository.fetchArticlesNewestToOldest
        throw "Not Implemented"
    }
    
    func fetchFeaturedArticles() async throws -> [String] {
        //TODO: Implement FirebaseArticleRepository.fetchFeaturedArticles
        throw "Not Implemented"
    }
    
    func fetchTrendingArticles() async throws -> [String] {
        //TODO: Implement FirebaseArticleRepository.fetchTrendingArticles
        throw "Not Implemented"
    }
    
    func fetchLikedArticles() async throws -> [String] {
        //TODO: Implement FirebaseArticleRepository.fetchLikedArticles
        throw "Not Implemented"
    }
    
    
//    struct Cursor: ArticleCursor {
//        let document: DocumentSnapshot
//    }
//    
//    private func fetchArticlesIn(
//        contentAgnosticCategory category: Resource.Category,
//        after cursor: inout (any ArticleCursor)?,
//        limit: Int
//    ) async throws -> [Article] {
//        if category == .featured {
//            //TODO: Handle .featured category
//            return []
//        }
//        if category == .trending {
//            //TODO: Handle .trending category
//            return []
//        }
//        if category == .liked {
//            //TODO: Handle .liked category
//            return []
//        }
//
//        return try await fetchAllArticles(after: &cursor, limit: limit)
//    }
//    
//    private func fetchArticlesIn(
//        contentBasedCategory category: Resource.Category,
//        after cursor: inout (any ArticleCursor)?,
//        limit: Int
//    ) async throws -> [Article] {
//        var query = articlesCollection
//            .whereField(self.categoriesField, arrayContains: category.id)
//            .order(by: publicationDateField, descending: true)
//            .limit(to: limit)
//        
//        return try await fetchArticles(withQuery: query, after: &cursor)
//    }
//    
//    public func fetchArticles(
//        in category: Resource.Category,
//        after cursor: inout (any ArticleCursor)?,
//        limit: Int
//    ) async throws -> [Article] {
//        if category.isContentAgnostic {
//            return try await fetchArticlesIn(contentAgnosticCategory: category, after: &cursor, limit: limit)
//        } else {
//            return try await fetchArticlesIn(contentBasedCategory: category, after: &cursor, limit: limit)
//        }
//    }
}

extension FirebaseArticleRepository: ArticleDetailArticleFetcher {
    
    func fetchArticle(withId articleId: String) async throws -> Article {
        let doc = try await articlesCollection.document(articleId).getDocument()
        let categories = try await getCategoryDict()
        guard let article = try doc.data(as: FirebaseArticleDoc.self).toArticle(categoryDict: categories) else {
            throw "Could convert Firestore doc to Article"
        }
        return article
    }
}
