//
//  FirebaseReportRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation
import FirebaseFirestore

class FirebaseReportRepository {
    
    static let REPORTED_ITEMS = "ReportedItems"

    let reportedItemsCollection = Firestore.firestore().collection(REPORTED_ITEMS)
}

extension FirebaseReportRepository: CommentReporter {
    func reportComment(
        _ comment: Comment,
        onResource resource: CommentSectionResource,
        reportedBy reporterId: String
    ) async throws {
        let doc = FirestoreReportedItemDoc(
            item: .comment(
                commentId: comment.id,
                resourceId: resource.id,
                resourceType: resource.type.rawValue
            ),
            itemOwnerId: comment.userId,
            reporterId: reporterId,
            date: .now
        )
        
        try await reportedItemsCollection.addDocument(from: doc)
    }
}

extension FirebaseReportRepository: RecipeReporter {
    func reportRecipe(
        _ recipe: Recipe,
        reportedBy reporterId: String
    ) async throws {
        let doc = FirestoreReportedItemDoc(
            item: .recipe(recipeId: recipe.id),
            itemOwnerId: recipe.authorUserId,
            reporterId: reporterId,
            date: .now
        )
        
        try await reportedItemsCollection.addDocument(from: doc)
    }
}
