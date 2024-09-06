//
//  FirebaseResourceActivityRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import FirebaseFirestore

class FirebaseResourceActivityRepository {
    
    private static let RESOURCE_ACTIVITIES = "ResourceActivities"

    let activitiesCollection = Firestore.firestore().collection(RESOURCE_ACTIVITIES)
    
    let dateField = FirestoreResourceActivityDoc.CodingKeys.date.rawValue
    let resourceTypeField = FirestoreResourceActivityDoc.CodingKeys.resourceType.rawValue
    let activityTypeField = FirestoreResourceActivityDoc.CodingKeys.activityType.rawValue

    func addActivity(
        _ type: FirestoreResourceActivityDoc.ActivityType,
        forResource resourceId: String,
        ofType resourceType: Resource.ResourceType,
        byUser userId: String
    ) async throws {
        let doc = FirestoreResourceActivityDoc(
            activityType: type.rawValue,
            userId: userId,
            resourceId: resourceId,
            resourceType: resourceType.rawValue,
            date: .now
        )
        
        try await activitiesCollection.addDocument(from: doc)
    }
    
    func deleteActivites(for resource: Resource) async throws {
        let resourceType = resource.type.rawValue
        
        let docs = try await activitiesCollection
            .whereField(FirestoreResourceActivityDoc.CodingKeys.resourceId.rawValue, isEqualTo: resource.id)
            .whereField(FirestoreResourceActivityDoc.CodingKeys.resourceType.rawValue, isEqualTo: resourceType)
            .getDocuments()
        
        for doc in docs.documents {
            try await doc.reference.delete()
        }
    }
    
    func fetchLikedResourceIds(ofType resourceType: Resource.ResourceType, after date: Date) async throws -> [String] {
        try await activitiesCollection
            .whereField(activityTypeField, isEqualTo: FirestoreResourceActivityDoc.ActivityType.favorite.rawValue)
            .whereField(resourceTypeField, isEqualTo: resourceType.rawValue)
            .whereField(dateField, isGreaterThan: date)
            .getDocuments()
            .documents
            .reduce(Dictionary<String,Int>()) { dict, document in
                guard let resourceId = try? document.data(as: FirestoreResourceActivityDoc.self).resourceId else { return dict }
                var dict = dict
                dict[resourceId] = dict[resourceId, default: 0] + 1
                return dict
            }
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
}

extension FirebaseResourceActivityRepository: ResourceFavoriteActivityTracker {
    func resource(_ resource: Resource, wasFavoritedByUser userId: String) async throws {
        try await addActivity(.favorite, forResource: resource.id, ofType: resource.type, byUser: userId)
    }
    
    func resource(_ resource: Resource, wasUnfavoritedByUser userId: String) async throws {
        let favorite = FirestoreResourceActivityDoc.ActivityType.favorite.rawValue
        let resourceType = resource.type.rawValue
        
        let docs = try await activitiesCollection
            .whereField(FirestoreResourceActivityDoc.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(FirestoreResourceActivityDoc.CodingKeys.resourceId.rawValue, isEqualTo: resource.id)
            .whereField(FirestoreResourceActivityDoc.CodingKeys.resourceType.rawValue, isEqualTo: resourceType)
            .whereField(FirestoreResourceActivityDoc.CodingKeys.activityType.rawValue, isEqualTo: favorite)
            .getDocuments()
        
        for doc in docs.documents {
            try await doc.reference.delete()
        }
    }
}

extension FirebaseResourceActivityRepository: ResourceViewActivityTracker {
    func resource(_ resource: Resource, wasViewedByUser userId: String) async throws {
        try await addActivity(.view, forResource: resource.id, ofType: resource.type, byUser: userId)
    }
}

extension FirebaseResourceActivityRepository: PopularResourceIdFetcher {
    
    func getPopularResourceIds(
        ofType resourceType: Resource.ResourceType,
        since date: Date,
        limit: Int
    ) async throws -> [String] {
        let activityCounts = try await getActivityEventCounts(ofType: resourceType, since: date)
        return activityCounts
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
    
    private func getActivityEventCounts(
        ofType resourceType: Resource.ResourceType,
        since date: Date
    ) async throws -> [String:Int] {
        let resourceType = resourceType.rawValue
        
        let docs = try await activitiesCollection
            .whereField(FirestoreResourceActivityDoc.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: date)
            .whereField(FirestoreResourceActivityDoc.CodingKeys.resourceType.rawValue, isEqualTo: resourceType)
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: FirestoreResourceActivityDoc.self) }
        
        var activityCounts: [String:Int] = [:]
        
        docs.forEach { doc in
            guard let resourceId = doc.resourceId else { return }
            activityCounts[resourceId] = (activityCounts[resourceId] ?? 0) + 1
        }
        
        return activityCounts
    }
}

extension FirebaseResourceActivityRepository: ResourceCommentActivityTracker {
    func resource(_ resource: Resource, wasCommentedOnByUser userId: String) async throws {
        try await addActivity(.comment, forResource: resource.id, ofType: resource.type, byUser: userId)
    }
}

extension FirebaseResourceActivityRepository: ResourceCreatedActivityTracker {
    func resource(_ resource: Resource, wasCreatedByUser userId: String) async throws {
        try await addActivity(.creation, forResource: resource.id, ofType: resource.type, byUser: userId)
    }
}
 
