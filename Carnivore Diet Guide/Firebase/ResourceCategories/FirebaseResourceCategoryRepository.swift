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
    
}

extension FirebaseResourceCategoryRepository: ResourceCategoryProvider {
    func fetchAllCategories() async throws -> [Resource.Category] {
        try await categoriesCollection
            .getDocuments()
            .documents
            .compactMap { try $0.data(as: FirebaseResourceCategoryDoc.self).toCategory() }
    }
}
