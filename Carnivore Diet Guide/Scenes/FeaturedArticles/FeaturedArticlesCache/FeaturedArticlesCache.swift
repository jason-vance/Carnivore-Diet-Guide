//
//  FeaturedArticlesCache.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/24/24.
//

import Foundation

class FeaturedArticlesCache {
    
    private typealias FeaturedCache = Cache<String, FeaturedArticlesCacheEntry>
    private static let cacheName = "FeaturedArticlesCache"

    private let cache = Cache.readFromDiskOrDefault(FeaturedCache.self, withName: FeaturedArticlesCache.cacheName)
    
    private static var instance: FeaturedArticlesCache? = nil
    public static func getInstance() -> FeaturedArticlesCache {
        if instance == nil {
            instance = .init()
        }
        return instance!
    }
    
    func cache(featuredArticles: FeaturedArticles) {
        cache["key"] = .from(featuredArticles)
        try? cache.saveToDisk(withName: FeaturedArticlesCache.cacheName)
    }
    
    func retrieveFeaturedArticles() -> FeaturedArticles? {
        if let key = cache.keys.first {
            return cache[key]?.toFeaturedArticles()
        }
        return nil
    }
}
