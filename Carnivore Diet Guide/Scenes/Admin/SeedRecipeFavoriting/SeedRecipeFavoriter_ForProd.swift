//
//  SeedRecipeFavoriter_ForProd.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/15/25.
//

import Foundation

extension SeedRecipeFavoriter {
    static let forProd = SeedRecipeFavoriter(
        favoriteRecipeWithSeeds: { recipe, seeds in
            for seed in seeds {
                let resource = Resource(recipe)
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
