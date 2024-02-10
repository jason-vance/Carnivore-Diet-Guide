//
//  FirebaseCommentRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/9/24.
//

import Foundation
import FirebaseFirestore

class FirebaseCommentRepository {
    
    private static let RECIPES = FirebaseRecipeRepository.RECIPES
    private static let POSTS = FirebasePostRepository.POSTS
    private let COMMENTS = "Comments"
    
    let recipesCollection = Firestore.firestore().collection(RECIPES)
    let postsCollection = Firestore.firestore().collection(POSTS)

    func commentsCollection(ofResource resourceId: String, ofType resourceType: CommentSectionView.ResourceType) -> CollectionReference {
        switch resourceType {
        case .recipe:
            return recipesCollection.document(resourceId).collection(COMMENTS)
        case .post:
            return postsCollection.document(resourceId).collection(COMMENTS)
        }
    }
}

extension FirebaseCommentRepository: CommentSender {
    func sendComment(
        text: String,
        forResource resourceId: String,
        ofType resourceType: CommentSectionView.ResourceType
    ) async throws {
        guard let userId = FirebaseAuthenticationProvider.instance.currentUserId else {
            throw "User is not currently signed in"
        }
        
        let doc = FirestoreCommentDoc(
            userId: userId,
            text: text,
            date: .now
        )
        
        try await commentsCollection(ofResource: resourceId, ofType: resourceType).addDocument(from: doc)
    }
}
