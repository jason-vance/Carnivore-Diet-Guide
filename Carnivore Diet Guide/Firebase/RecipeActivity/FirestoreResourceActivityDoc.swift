//
//  FirestoreResourceActivityDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirestoreResourceActivityDoc: Codable {
    
    enum ActivityType: String, Codable {
        case creation
        case view
        case favorite
        case comment
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case activityType
        case userId
        case resourceId
        case resourceType
        case date
    }
    
    @DocumentID var id: String?
    var activityType: String?
    var userId: String?
    var resourceId: String?
    var resourceType: String?
    var date: Date?
}
