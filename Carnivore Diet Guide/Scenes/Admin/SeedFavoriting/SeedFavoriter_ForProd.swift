//
//  SeedFavoriter_ForProd.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/15/25.
//

import Foundation

extension SeedFavoriter {
    static let forProd = SeedFavoriter(
        favoriteArticleWithSeeds: { article, seeds in
            for seed in seeds {
                let resource = Resource(article)
                // Add favoriter to article
                try await FirestoreFavoritersRepository().markAsFavorite(resource: resource, of: seed)
                // Add article to user doc
                try await FirebaseUserRepository().add(resource: resource, toFavoritesOf: seed)
                // Add ResourceActivity
                try await FirebaseResourceActivityRepository().addActivity(.favorite, forResource: resource.id, ofType: resource.type, byUser: seed)
            }
        }
    )
}
