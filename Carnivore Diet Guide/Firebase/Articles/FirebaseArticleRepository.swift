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
    
    private let categoriesField: String = FirebaseArticleDoc.CodingKeys.categories.rawValue
    private let publicationDateField: String = FirebaseArticleDoc.CodingKeys.publicationDate.rawValue

    func create(article: Article) async throws {
        let doc = FirebaseArticleDoc.from(article)
        try await articlesCollection.document(article.id).setData(from: doc)
    }
    
    func fetchAllArticles (
        after cursor: inout (any ArticleCursor)?,
        limit: Int,
        whereFunc: ((Query) -> Query)? = nil
    ) async throws -> [Article] {
        var query = articlesCollection
            .order(by: publicationDateField, descending: true)
            .limit(to: limit)
        
        if let whereFunc = whereFunc {
            query = whereFunc(query)
        }
        
        if let cursor = cursor as? Cursor {
            query = query.start(afterDocument: cursor.document)
        }
        
        let snapshot = try await query.getDocuments()
        
        if let last = snapshot.documents.last {
            cursor = Cursor(document: last)
        }
        
        return try snapshot
            .documents
            .compactMap { try $0.data(as: FirebaseArticleDoc.self).toArticle() }
    }
}

extension FirebaseArticleRepository: ArticleFetcher {
    
    struct Cursor: ArticleCursor {
        let document: DocumentSnapshot
    }
    
    private func fetchArticlesIn(
        contentAgnosticCategory category: Resource.Category,
        after cursor: inout (any ArticleCursor)?,
        limit: Int
    ) async throws -> [Article] {
        if category == .featured {
            //TODO: Handle .featured category
            return []
        }
        if category == .trending {
            //TODO: Handle .trending category
            return []
        }
        if category == .liked {
            //TODO: Handle .liked category
            return []
        }

        return try await fetchAllArticles(after: &cursor, limit: limit)
    }
    
    private func fetchArticlesIn(
        contentBasedCategory category: Resource.Category,
        after cursor: inout (any ArticleCursor)?,
        limit: Int
    ) async throws -> [Article] {
        return try await fetchAllArticles(
            after: &cursor,
            limit: limit,
            whereFunc: { query in
                query.whereField(self.categoriesField, arrayContains: category.id)
            }
        )
    }
    
    func fetchArticles(
        in category: Resource.Category,
        after cursor: inout (any ArticleCursor)?,
        limit: Int
    ) async throws -> [Article] {
        if category.isContentAgnostic {
            return try await fetchArticlesIn(contentAgnosticCategory: category, after: &cursor, limit: limit)
        } else {
            return try await fetchArticlesIn(contentBasedCategory: category, after: &cursor, limit: limit)
        }
    }
}
