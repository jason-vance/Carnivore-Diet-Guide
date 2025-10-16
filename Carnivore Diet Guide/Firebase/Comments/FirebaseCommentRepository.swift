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
    
    private static let ARTICLES = FirebaseArticleRepository.ARTICLES
    private static let POSTS = FirebasePostRepository.POSTS
    private static let RECIPES = FirebaseRecipeRepository.RECIPES

    private let COMMENTS = "Comments"
    private let DATE = "date"

    let articlesCollection = Firestore.firestore().collection(ARTICLES)
    let postsCollection = Firestore.firestore().collection(POSTS)
    let recipesCollection = Firestore.firestore().collection(RECIPES)

    func commentsCollection(forResource resource: Resource) -> CollectionReference {
        switch resource.type {
        case .article:
            return articlesCollection.document(resource.id).collection(COMMENTS)
        case .post:
            return postsCollection.document(resource.id).collection(COMMENTS)
        case .recipe:
            return recipesCollection.document(resource.id).collection(COMMENTS)
        }
    }
    
    func listenToCommentCountOf(
        resource: Resource,
        onUpdate: @escaping (UInt) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        let timer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true
        ) { _ in
            Task {
                do {
                    let count = try await self.getCommentCountOf(resource: resource)
                    onUpdate(count)
                } catch {
                    onError?(error)
                }
            }
        }
        timer.fire()
        
        return .init({ timer.invalidate() })
    }
    
    func getCommentCountOf(resource: Resource) async throws -> UInt {
        let count = try await commentsCollection(forResource: resource)
            .count
            .getAggregation(source: .server)
            .count
            .intValue
        return UInt(count)
    }
}

extension FirebaseCommentRepository: CommentProvider {
    func listenForCommentsOrderedByDate(
        onResource resource: Resource,
        onUpdate: @escaping ([Comment]) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        let timer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true
        ) { _ in
            Task {
                do {
                    let comments = try await self.getCommentsOrderedByDate(resource: resource)
                    onUpdate(comments)
                } catch {
                    onError?(error)
                }
            }
        }
        timer.fire()
        
        return .init({ timer.invalidate() })
    }
    
    func getCommentsOrderedByDate(resource: Resource) async throws -> [Comment] {
        try await commentsCollection(forResource: resource)
            .order(by: DATE)
            .getDocuments()
            .documents
            .compactMap {
                try? $0.data(as: FirestoreCommentDoc.self).toComment()
            }
    }
}

extension FirebaseCommentRepository: CommentSender {
    func sendComment(
        text: String,
        toResource resource: Resource,
        commentProxyContainer: CommentProxyContainer
    ) async throws -> Comment {
        guard let userId = commentProxyContainer.proxyUserId ?? FirebaseAuthenticationProvider.instance.currentUserId else {
            throw TextError("User is not currently signed in")
        }
        
        var doc = FirestoreCommentDoc(
            userId: userId,
            text: text,
            date: .now
        )
        let reference = try await commentsCollection(forResource: resource).addDocument(from: doc)
        doc.id = reference.documentID
        
        guard let comment = doc.toComment() else {
            throw NSError(domain: "Failure to create comment", code: 1001, userInfo: nil)
        }
        return comment
    }
}

extension FirebaseCommentRepository: CommentDeleter {
    func deleteComment(_ comment: Comment, onResource resource: Resource) async throws {
        try await commentsCollection(forResource: resource).document(comment.id).delete()
    }
}
