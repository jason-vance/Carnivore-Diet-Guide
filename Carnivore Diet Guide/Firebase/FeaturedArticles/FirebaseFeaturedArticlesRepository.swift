//
//  FirebaseFeaturedArticlesRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import Foundation
import FirebaseFirestore

class FirebaseFeaturedArticlesRepository {
    
    public static let FEATURED_ARTICLES = "FeaturedArticles"
    
    private let featuredArticlesCollection = Firestore.firestore().collection(FEATURED_ARTICLES)
    
    let publicationDateField = FirebaseFeaturedArticlesDoc.CodingKeys.publicationDate.rawValue
}

extension FirebaseFeaturedArticlesRepository: FeaturedArticlesPoster {
    func post(featuredArticles: FeaturedArticles) async throws {
        let doc = FirebaseFeaturedArticlesDoc.from(featuredArticles)
        try await featuredArticlesCollection.addDocument(from: doc)
    }
}
 
extension FirebaseFeaturedArticlesRepository: FeaturedArticlesFetcher {
    func fetchFeaturedArticles() async throws -> FeaturedArticles {
        guard let rv = try await featuredArticlesCollection
            .whereField(publicationDateField, isLessThan: Date.now)
            .order(by: publicationDateField, descending: true)
            .limit(to: 1)
            .getDocuments()
            .documents
            .first?
            .data(as: FirebaseFeaturedArticlesDoc.self)
            .toFeaturedArticles() 
        else {
            throw "Couldn't read FeaturedArticles from Firebase"
        }
        
        return rv
    }
}
