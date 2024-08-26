//
//  FirebaseCommentRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/9/24.
//

import Foundation
import FirebaseFirestore
import Combine

class FirebaseCommentRepository {
    
    private static let RECIPES = FirebaseRecipeRepository.RECIPES
    private static let POSTS = FirebasePostRepository.POSTS

    private let COMMENTS = "Comments"
    private let DATE = "date"

    let recipesCollection = Firestore.firestore().collection(RECIPES)
    let postsCollection = Firestore.firestore().collection(POSTS)

    func commentsCollection(forResource resource: Resource) -> CollectionReference {
        switch resource.type {
        case .recipe:
            return recipesCollection.document(resource.id).collection(COMMENTS)
        case .post:
            return postsCollection.document(resource.id).collection(COMMENTS)
        }
    }
    
    func listenToCommentCountOf(
        resource: Resource,
        onUpdate: @escaping (UInt) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        let listener = commentsCollection(forResource: resource)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    onError?(error ?? "¯\\_(ツ)_/¯ While listening to recipe's comments")
                    return
                }
                
                onUpdate(UInt(snapshot.count))
            }
        
        return .init({ listener.remove() })
    }
}

extension FirebaseCommentRepository: CommentProvider {
    func listenForCommentsOrderedByDate(
        onResource resource: Resource,
        onUpdate: @escaping ([Comment]) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        let listener = commentsCollection(forResource: resource)
            .order(by: DATE)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    onError?(error ?? "¯\\_(ツ)_/¯ While listening for comments on \(resource.type) `\(resource.id)`")
                    return
                }
                
                let comments = snapshot.documents.compactMap {
                    try? $0.data(as: FirestoreCommentDoc.self).toComment()
                }
                onUpdate(comments)
            }
        
        return .init({ listener.remove() })
    }
}

extension FirebaseCommentRepository: CommentSender {
    func sendComment(
        text: String,
        toResource resource: Resource
    ) async throws {
        guard let userId = FirebaseAuthenticationProvider.instance.currentUserId else {
            throw "User is not currently signed in"
        }
        
        let doc = FirestoreCommentDoc(
            userId: userId,
            text: text,
            date: .now
        )
        
        try await commentsCollection(forResource: resource).addDocument(from: doc)
    }
}

extension FirebaseCommentRepository: CommentDeleter {
    func deleteComment(_ comment: Comment, onResource resource: Resource) async throws {
        try await commentsCollection(forResource: resource).document(comment.id).delete()
    }
}
