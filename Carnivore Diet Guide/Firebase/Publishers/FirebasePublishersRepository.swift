//
//  FirebasePublishersRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/11/24.
//

import Foundation
import FirebaseFirestore

class FirebasePublishersRepository {
    
    public static let PUBLISHERS = "Publishers"
    
    private let publishersCollection = Firestore.firestore().collection(PUBLISHERS)
    
}

extension FirebasePublishersRepository: PublishersFetcher {
    func fetchPublishers() async throws -> [String] {
        try await publishersCollection
            .getDocuments()
            .documents
            .map { $0.documentID }
    }
}

extension FirebasePublishersRepository: IsPublisherChecker {
    func isPublisher(userId: String) async throws -> Bool {
        try await publishersCollection.document(userId).getDocument().exists
    }
}
 
