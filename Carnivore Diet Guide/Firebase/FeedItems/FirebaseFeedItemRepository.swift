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
    private let PUBLICATION_DATE = "publicationDate"
    
    let feedItemsCollection = Firestore.firestore().collection(FEED_ITEMS)
}

extension FirebaseFeedItemRepository: FeedItemRepository {
    
    struct Cursor: FeedItemRepositoryCursor {
        let document: DocumentSnapshot
    }
    
    func getFeedItemsNewestToOldest(after cursor: inout FeedItemRepositoryCursor?, limit: Int) async throws -> [FeedItem] {
        var query = feedItemsCollection
            .whereField(PUBLICATION_DATE, isLessThan: Date.now)
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
