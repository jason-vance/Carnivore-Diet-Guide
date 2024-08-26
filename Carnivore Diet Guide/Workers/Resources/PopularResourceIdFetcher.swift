//
//  PopularResourceIdFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation

protocol PopularResourceIdFetcher {
    func getPopularResourceIds(
        ofType resourceType: Resource.ResourceType,
        since date: Date,
        limit: Int
    ) async throws -> [String]
}

class MockRecipePopularityFetcher: PopularResourceIdFetcher {
    func getPopularResourceIds(
        ofType resourceType: Resource.ResourceType,
        since date: Date,
        limit: Int
    ) async throws -> [String] {
        Recipe.samples.map { $0.id }
    }
}
