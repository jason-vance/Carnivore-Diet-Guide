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
        onResource resource: Resource,
        reportedBy reporterId: String
    ) async throws {
        let doc = FirestoreReportedItemDoc(
            item: .itemFrom(comment: comment, onResource: resource),
            itemOwnerId: comment.userId,
            reporterId: reporterId,
            date: .now
        )
        
        try await reportedItemsCollection.addDocument(from: doc)
    }
}

extension FirebaseReportRepository: ResourceReporter {
    func reportResource(
        _ resource: Resource,
        reportedBy reporterId: String
    ) async throws {
        let doc = FirestoreReportedItemDoc(
            item: .itemFrom(resource: resource),
            itemOwnerId: resource.author,
            reporterId: reporterId,
            date: .now
        )
        
        try await reportedItemsCollection.addDocument(from: doc)
    }
}
