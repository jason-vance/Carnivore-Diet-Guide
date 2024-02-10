//
//  FirestoreCommentDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/9/24.
//

import Foundation
import FirebaseFirestore

struct FirestoreCommentDoc: Codable {
    @DocumentID var id: String?
    var userId: String?
    var text: String?
    var date: Date?
}
