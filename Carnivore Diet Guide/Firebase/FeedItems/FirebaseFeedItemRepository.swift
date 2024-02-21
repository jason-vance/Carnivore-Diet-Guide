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
    func getFeedItemsNewestToOldest(after: FeedItem?, limit: Int) async throws -> [FeedItem] {
        var query = feedItemsCollection
            .whereField(PUBLICATION_DATE, isLessThan: Date.now)
            .order(by: PUBLICATION_DATE, descending: true)
            .limit(to: limit)
        if let after = after {
            let docSnapshot = try await feedItemsCollection.document(after.id).getDocument()
            query = query.start(afterDocument: docSnapshot)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents
            .compactMap { try $0.data(as: FirestoreFeedItemDoc.self).toFeedItem() }
    }
    
}
