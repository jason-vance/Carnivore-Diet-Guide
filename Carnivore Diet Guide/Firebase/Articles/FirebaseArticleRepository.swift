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
}

extension FirebaseArticleRepository: ArticleFetcher {
    
    struct Cursor: ArticleCursor {
        let document: DocumentSnapshot
    }
    
    func fetchArticles(
        in category: Resource.Category,
        after cursor: inout (any ArticleCursor)?,
        limit: Int
    ) async throws -> [Article] {
        var query = articlesCollection
            .whereField(categoriesField, arrayContains: category.id)
            .order(by: publicationDateField, descending: true)
            .limit(to: limit)
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
