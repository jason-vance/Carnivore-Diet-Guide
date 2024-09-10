//
//  FirebaseIsPublisherChecker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/10/24.
//

import Foundation
import FirebaseFirestore

class FirebaseIsPublisherChecker: IsPublisherChecker {
    
    public static let PUBLISHERS = "Publishers"
    
    private let publishersCollection = Firestore.firestore().collection(PUBLISHERS)
    
    func isPublisher(userId: String) async throws -> Bool {
        try await publishersCollection.document(userId).getDocument().exists
    }
}
