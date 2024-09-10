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
    
    
    func deleteArticle(withId articleId: String) async throws {
        try await articlesCollection.document(articleId).delete()
    }
    
    
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

extension FirebaseArticleRepository: ArticleCollectionFetcher {
    
    private func getCursor(for article: Article?) async throws -> DocumentSnapshot? {
        if let article = article {
            let doc = try await articlesCollection.document(article.id).getDocument()
            if doc.exists { return doc }
        }
        return nil
    }
    
    func fetchArticlesOldestFirst(newerThan article: Article?, limit: Int) async throws -> [Article] {
        var query = articlesCollection
            .order(by: publicationDateField, descending: false)
            .limit(to: limit)
        
        if let cursor = try await getCursor(for: article) {
            query = query.start(afterDocument: cursor)
        }
        
        let categories = try await getCategoryDict()
        return try await query
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: FirebaseArticleDoc.self).toArticle(categoryDict: categories) }
    }
    
    func fetchArticlesNewestFirst(olderThan article: Article?, limit: Int) async throws -> [Article] {
        var query = articlesCollection
            .order(by: publicationDateField, descending: true)
            .limit(to: limit)
        
        if let cursor = try await getCursor(for: article) {
            query = query.start(afterDocument: cursor)
        }
        
        let categories = try await getCategoryDict()
        return try await query
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: FirebaseArticleDoc.self).toArticle(categoryDict: categories) }
    }
    
    func fetchTrendingArticles(in timeFrame: TimeFrame) async throws -> [String] {
        let timeFrameAgo = Calendar.current.date(byAdding: .day, value: -timeFrame.numberOfDays, to: .now)!

        let repo = FirebaseResourceActivityRepository()
        let articleIds = try await repo.fetchTrendingResourceIds(
            ofType: .article,
            after: timeFrameAgo
        )
        
        return articleIds
    }
    
    func fetchLikedArticles(in timeFrame: TimeFrame) async throws -> [String] {
        let timeFrameAgo = Calendar.current.date(byAdding: .day, value: -timeFrame.numberOfDays, to: .now)!
        
        let repo = FirebaseResourceActivityRepository()
        let articleIds = try await repo.fetchLikedResourceIds(
            ofType: .article,
            after: timeFrameAgo
        )
        
        return articleIds
    }
}

extension FirebaseArticleRepository: IndividualArticleFetcher {
    
    func fetchArticle(withId articleId: String) async throws -> Article {
        let doc = try await articlesCollection.document(articleId).getDocument()
        guard doc.exists else { throw Resource.Errors.doesNotExist }
        
        let categories = try await getCategoryDict()
        
        guard let article = try doc.data(as: FirebaseArticleDoc.self).toArticle(categoryDict: categories) else {
            throw "Could convert Firestore doc to Article"
        }
        return article
    }
}
