//
//  FirebasePostRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import FirebaseFirestore
import Combine

class FirebasePostRepository {
    
    static let POSTS = "Posts"
    
    private let publicationDateField = FirestorePostDoc.CodingKeys.publicationDate.rawValue
    private let authorField = FirestorePostDoc.CodingKeys.author.rawValue

    let postsCollection = Firestore.firestore().collection(POSTS)
    
    func getPublishedPostsNewestToOldest(limit: Int? = nil) async throws -> [Post] {
        var query = postsCollection
            .whereField(publicationDateField, isLessThan: Date.now)
            .order(by: publicationDateField, descending: true)
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
            throw TextError("Could convert Firestore doc to Post")
        }
        return post
    }
    
    func deletePost(withId postId: String) async throws {
        try await postsCollection.document(postId).delete()
    }
}

extension FirebasePostRepository: PostCountProvider {
    func listenToPostCount(
        forUser userId: String,
        onUpdate: @escaping (Int) -> (),
        onError: @escaping (Error) -> ()
    ) -> AnyCancellable {
        let listener = postsCollection
            .whereField(authorField, isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let snapshot = snapshot {
                    onUpdate(snapshot.count)
                } else {
                    onError(error ?? TextError("¯\\_(ツ)_/¯ While listening to recipe's favoriters"))
                }
            }
        
        return .init({ listener.remove() })
    }
}

extension FirebasePostRepository: PostsFetcher {
    
    struct Cursor: PostsFetcherCursor {
        let document: DocumentSnapshot
    }
    
    func fetchPosts(
        byUser userId: String,
        after cursor: inout PostsFetcherCursor?,
        limit: Int
    ) async throws -> [Post] {
        var query = postsCollection
            .whereField(authorField, isEqualTo: userId)
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
            .compactMap { try $0.data(as: FirestorePostDoc.self).toPost() }
    }
}
