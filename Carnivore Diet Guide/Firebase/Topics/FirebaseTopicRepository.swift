//
//  FirebaseTopicRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation
import FirebaseFirestore

class FirebaseTopicRepository {
    
    private static let topicsName = "Topics"
    
    private let topicCollection = Firestore.firestore().collection(topicsName)
}

extension FirebaseTopicRepository: TopicProvider {
    func fetchTopics() async throws -> [Topic] {
        let snapshot = try await topicCollection.getDocuments()
        
        return try snapshot.documents
            .compactMap { try $0.data(as: FirebaseTopicDoc.self).toTopic() }
    }
}
