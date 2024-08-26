//
//  FirestoreReportedItemDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation
import FirebaseFirestore

struct FirestoreReportedItemDoc: Codable {
    
    enum Item: Codable {
        case recipe(recipeId: String?)
        case comment(commentId: String?, resourceId: String?, resourceType: String?)
        case post(postId: String?)
        
        public static func itemFrom(resource: Resource) -> Item {
            switch resource.type {
            case .post:
                return .post(postId: resource.id)
            case .recipe:
                return .recipe(recipeId: resource.id)
            }
        }
        
        public static func itemFrom(comment: Comment, onResource resource: Resource) -> Item {
            return .comment(
                commentId: comment.id,
                resourceId: resource.id,
                resourceType: resource.type.rawValue
            )
        }
    }
    
    @DocumentID var id: String?
    var item: Item?
    var itemOwnerId: String?
    var reporterId: String?
    var date: Date?
}
