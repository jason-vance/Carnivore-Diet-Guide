//
//  FirestoreFeedItemDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/18/24.
//

import Foundation
import FirebaseFirestore

struct FirestoreFeedItemDoc: Codable {
    @DocumentID var id: String?
    var creatorUserId: String?
    var resourceType: String?
    var imageUrls: [String]?
    var publicationDate: Date?
    var resourceId: String?
    var summary: String?
    var title: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorUserId
        case resourceType
        case imageUrls
        case publicationDate
        case resourceId
        case summary
        case title
    }
    
    static func from(_ feedItem: FeedItem) -> FirestoreFeedItemDoc {
        return FirestoreFeedItemDoc(
            creatorUserId: feedItem.userId,
            resourceType: feedItem.type.rawValue,
            imageUrls: feedItem.imageUrls.map { $0.absoluteString },
            publicationDate: feedItem.publicationDate,
            resourceId: feedItem.resourceId,
            summary: feedItem.summary,
            title: feedItem.title
        )
    }
    
    func toFeedItem() -> FeedItem? {
        guard let id = id else { return nil }
        guard let publicationDate = publicationDate else { return nil }
        guard let resourceTypeStr = resourceType else { return nil }
        guard let resourceType = Resource.ResourceType.init(rawValue: resourceTypeStr) else { return nil }
        guard let resourceId = resourceId else { return nil }
        guard let creatorUserId = creatorUserId else { return nil }
        guard let summary = summary else { return nil }
        guard let title = title else { return nil }
        
        let imageUrls = imageUrls?.compactMap { URL(string: $0) } ?? []

        return FeedItem(
            id: id,
            publicationDate: publicationDate,
            type: resourceType,
            resourceId: resourceId,
            userId: creatorUserId,
            imageUrls: imageUrls,
            title: title,
            summary: summary
        )
    }
}
