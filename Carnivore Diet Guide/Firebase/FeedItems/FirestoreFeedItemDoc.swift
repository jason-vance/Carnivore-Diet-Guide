//
//  FirestoreFeedItemDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/18/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirestoreFeedItemDoc: Codable {
    @DocumentID var id: String?
    var creatorUserId: String?
    var feedItemType: FeedItem.FeedItemType?
    var imageUrls: [String]?
    var publicationDate: Date?
    var resourceId: String?
    var summary: String?
    var title: String?
    
    func toFeedItem() -> FeedItem? {
        guard let id = id else { return nil }
        guard let feedItemType = feedItemType else { return nil }
        guard let resourceId = resourceId else { return nil }
        guard let creatorUserId = creatorUserId else { return nil }
        guard let summary = summary else { return nil }
        guard let title = title else { return nil }
        
        let imageUrls = imageUrls?.compactMap { URL(string: $0) } ?? []

        return FeedItem(
            id: id,
            type: feedItemType,
            resourceId: resourceId,
            userId: creatorUserId,
            imageUrls: imageUrls,
            title: title,
            summary: summary
        )
    }
}
