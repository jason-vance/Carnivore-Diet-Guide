//
//  ResourceCategoryProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

protocol ResourceCategoryProvider {
    func fetchAllCategories() async throws -> Set<Resource.Category>
}

class MockResourceCategoryProvider: ResourceCategoryProvider {
    
    public var categories: Set<Resource.Category> = Resource.Category.samples
    public var error: Error? = nil
    
    func fetchAllCategories() async throws -> Set<Resource.Category> {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
        return categories
    }
}
