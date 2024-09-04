//
//  FirebaseFeedItemRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/18/24.
//

import Foundation
import FirebaseFirestore

class FirebaseFeedItemRepository {
    
    static let FEED_ITEMS = "FeedItems"
    private let PUBLICATION_DATE = FirestoreFeedItemDoc.CodingKeys.publicationDate.rawValue
    private let CREATOR_USER_ID = FirestoreFeedItemDoc.CodingKeys.creatorUserId.rawValue

    let feedItemsCollection = Firestore.firestore().collection(FEED_ITEMS)
    
    func deleteFeedItem(forResource resource: Resource) async throws {
        let resourceIdField = FirestoreFeedItemDoc.CodingKeys.resourceId.rawValue
        let typeField = FirestoreFeedItemDoc.CodingKeys.resourceType.rawValue

        let snapshot = try await feedItemsCollection
            .whereField(resourceIdField, isEqualTo: resource.id)
            .whereField(typeField, isEqualTo: resource.type.rawValue)
            .getDocuments()
        
        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
    }
}

extension FirebaseFeedItemRepository: FeedItemRepository {
    
    struct Cursor: FeedItemRepositoryCursor {
        let document: DocumentSnapshot
    }
    
    func getPublishedFeedItemsNewestToOldest(
        after cursor: inout FeedItemRepositoryCursor?,
        limit: Int,
        excludeItemsFrom userIdToExclude: String
    ) async throws -> [FeedItem] {
        var query = feedItemsCollection
            .whereField(PUBLICATION_DATE, isLessThan: Date.now)
            .whereField(CREATOR_USER_ID, isNotEqualTo: userIdToExclude)
            .order(by: PUBLICATION_DATE, descending: true)
            .limit(to: limit)
        if let cursor = cursor as? Cursor {
            query = query.start(afterDocument: cursor.document)
        }
        
        let snapshot = try await query.getDocuments()
        
        if let last = snapshot.documents.last {
            cursor = Cursor(document: last)
        }
        
        return try snapshot.documents
            .compactMap { try $0.data(as: FirestoreFeedItemDoc.self).toFeedItem() }
    }
    
    func create(feedItem: FeedItem) async throws {
        let doc = FirestoreFeedItemDoc.from(feedItem)
        try await feedItemsCollection.addDocument(from: doc)
    }
    
}
