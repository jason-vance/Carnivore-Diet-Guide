//
//  FirebasePostRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import FirebaseFirestore

class FirebasePostRepository {
    
    static let POSTS = "Posts"
    private let PUBLICATION_DATE = "publicationDate"
    
    let postsCollection = Firestore.firestore().collection(POSTS)
    
    func getPublishedPostsNewestToOldest(limit: Int? = nil) async throws -> [Post] {
        var query = postsCollection
            .whereField(PUBLICATION_DATE, isLessThan: Date.now)
            .order(by: PUBLICATION_DATE, descending: true)
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents
            .compactMap { try $0.data(as: FirestorePostDoc.self).toPost() }
    }
    
    func create(post: Post) async throws {
        let doc = FirestorePostDoc.from(post)
        try await postsCollection.document(post.id).setData(from: doc)
    }
    
    func fetchPost(withId postId: String) async throws -> Post {
        let doc = try await postsCollection.document(postId).getDocument()
        guard let post = try doc.data(as: FirestorePostDoc.self).toPost() else {
            throw "Could convert Firestore doc to Post"
        }
        return post
    }
    
    func deletePost(withId postId: String) async throws {
        try await postsCollection.document(postId).delete()
    }
}

extension FirebasePostRepository: PostCountProvider {
    func fetchPostCount(forUser userId: String) async throws -> Int {
        let authorField = FirestorePostDoc.CodingKeys.author.rawValue
        
        return try await postsCollection
            .whereField(authorField, isEqualTo: userId)
            .count
            .getAggregation(source: .server)
            .count
            .intValue
    }
}
