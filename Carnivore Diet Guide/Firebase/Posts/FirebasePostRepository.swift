//
//  FirebasePostRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import FirebaseFirestore

class FirebasePostRepository {
    
    private static let POSTS = "BlogPosts"
    private let PUBLICATION_DATE = "publicationDate"
    
    let postsCollection = Firestore.firestore().collection(POSTS)
    
    func getPublishedPostsNewestToOldest(limit: Int? = nil) async throws -> [BlogPost] {
        var query = postsCollection
            .whereField(PUBLICATION_DATE, isLessThan: Date.now)
            .order(by: PUBLICATION_DATE, descending: true)
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents
            .compactMap { try $0.data(as: FirestorePostDoc.self).toBlogPost() }
    }
}
