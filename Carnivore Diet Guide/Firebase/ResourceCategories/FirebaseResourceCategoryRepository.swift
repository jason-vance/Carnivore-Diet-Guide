//
//  FirebaseResourceCategoryRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation
import FirebaseFirestore

class FirebaseResourceCategoryRepository {
    
    public static let RESOURCE_CATEGORIES = "ResourceCategories"
    
    private let categoriesCollection = Firestore.firestore().collection(RESOURCE_CATEGORIES)
    
    private let resourceTypeField = FirebaseResourceCategoryDoc.CodingKeys.resourceType.rawValue
}

extension FirebaseResourceCategoryRepository: ResourceCategoryProvider {
    func fetchAllCategories(forType resourceType: Resource.ResourceType) async throws -> Set<Resource.Category> {
        let categories = try await categoriesCollection
            .whereField(resourceTypeField, isEqualTo: resourceType.rawValue)
            .getDocuments()
            .documents
            .compactMap { try $0.data(as: FirebaseResourceCategoryDoc.self).toCategory() }
        return Set(categories)
    }
}
