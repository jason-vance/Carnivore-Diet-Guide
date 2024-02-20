//
//  PopularRecipeIdFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation

protocol PopularRecipeIdFetcher {
    func getPopularRecipeIds(since date: Date, limit: Int) async throws -> [String]
}

class MockRecipePopularityFetcher: PopularRecipeIdFetcher {
    func getPopularRecipeIds(since date: Date, limit: Int) async throws -> [String] {
        Recipe.samples.map { $0.id }
    }
}
