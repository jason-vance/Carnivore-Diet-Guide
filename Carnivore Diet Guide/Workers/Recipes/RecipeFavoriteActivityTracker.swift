//
//  RecipeFavoriteActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation

protocol RecipeFavoriteActivityTracker {
    func addRecipe(_ recipe: Recipe, wasFavoritedByUser userId: String) async throws
    func removeRecipe(_ recipe: Recipe, wasFavoritedByUser userId: String) async throws
}
