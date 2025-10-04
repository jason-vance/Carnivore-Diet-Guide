//
//  FirestoreFavoriterDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import FirebaseFirestore

struct FirestoreFavoriterDoc: Codable {
    
    var userId: String?
    var date: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case date
    }
}
