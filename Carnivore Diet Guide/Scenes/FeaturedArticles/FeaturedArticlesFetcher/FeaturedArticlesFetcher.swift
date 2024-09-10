//
//  FeaturedArticlesFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import Foundation

protocol FeaturedArticlesFetcher {
    func fetchFeaturedArticles() async throws -> FeaturedArticles
}

class MockFeaturedArticlesFetcher: FeaturedArticlesFetcher {
    
    var featuredArticles: FeaturedArticles = .sample
    
    func fetchFeaturedArticles() async throws -> FeaturedArticles {
        try await Task.sleep(for: .seconds(1))
        return featuredArticles
    }
}
