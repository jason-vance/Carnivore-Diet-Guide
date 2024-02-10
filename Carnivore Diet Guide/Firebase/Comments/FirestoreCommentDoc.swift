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
    
    func toComment() -> Comment? {
        guard let id = id else { return nil }
        guard let userId = userId else { return nil }
        guard let text = text else { return nil }
        guard let date = date else { return nil }

        return Comment(id: id, userId: userId, text: text, date: date)
    }
}
