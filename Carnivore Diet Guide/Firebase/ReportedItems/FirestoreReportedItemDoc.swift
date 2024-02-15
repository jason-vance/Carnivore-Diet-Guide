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
    }
    
    @DocumentID var id: String?
    var item: Item?
    var itemOwnerId: String?
    var reporterId: String?
    var date: Date?
}
