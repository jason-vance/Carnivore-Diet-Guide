//
//  SeedFavoriter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/15/25.
//

import Foundation

class SeedFavoriter: ObservableObject {
    
    private let favoriteArticleWithSeeds: (Article, [String]) async throws -> Void
    
    init(favoriteArticleWithSeeds: @escaping (Article, [String]) async throws -> Void) {
        self.favoriteArticleWithSeeds = favoriteArticleWithSeeds
    }
    
    func favorite(article: Article, withSeeds seeds: [String]) async throws {
        try await favoriteArticleWithSeeds(article, seeds)
    }
}

extension SeedFavoriter {
    static let forTesting = SeedFavoriter(
        favoriteArticleWithSeeds: { _, _ in try await Task.sleep(for: .seconds(1)) }
    )
}
