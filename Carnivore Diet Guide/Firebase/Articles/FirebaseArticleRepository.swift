//
//  FirebaseArticleRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation
import FirebaseFirestore


class FirebaseArticleRepository {
    
    private static let articlesName = "Articles"
    
    private let articlesCollection = Firestore.firestore().collection(articlesName)
    
}

extension FirebaseArticleRepository: ArticleFetcher {
    func fetchArticles(
        byCategory category: ArticleCategory,
        after cursor: inout (any ArticleCursor)?,
        limit: Int
    ) async throws -> [Article] {
        //TODO: Implement this
        throw "Not Implemented"
    }
}
