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
}

extension FirebaseFeaturedArticlesRepository: FeaturedArticlesPoster {
    func post(featuredArticles: FeaturedArticles) async throws {
        let doc = FirebaseFeaturedArticlesDoc.from(featuredArticles)
        try await featuredArticlesCollection.addDocument(from: doc)
    }
}
    
