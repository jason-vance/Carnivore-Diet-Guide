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
    
    func create(article: Article) async throws {
        let doc = FirebaseArticleDoc.from(article)
        try await articlesCollection.document(article.id).setData(from: doc)
    }
}

extension FirebaseArticleRepository: ArticleFetcher {
    func fetchArticles(
        byCategory category: Resource.Category,
        after cursor: inout (any ArticleCursor)?,
        limit: Int
    ) async throws -> [Article] {
        //TODO: Implement FirebaseArticleRepository.fetchArticles
        throw "Not Implemented"
    }
}
