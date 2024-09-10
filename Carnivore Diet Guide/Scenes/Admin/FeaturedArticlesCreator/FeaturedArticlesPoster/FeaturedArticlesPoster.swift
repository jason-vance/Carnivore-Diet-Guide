//
//  FeaturedArticlesPoster.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import Foundation

protocol FeaturedArticlesPoster {
    func post(featuredArticles: FeaturedArticles) async throws
}

class MockFeaturedArticlesPoster: FeaturedArticlesPoster {
    func post(featuredArticles: FeaturedArticles) async throws { }
}
