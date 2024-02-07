//
//  FavoriteRecipeRepo.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import Combine

protocol FavoriteRecipeRepo {
    func listenToFavoriteStatusOf(
        recipe: Recipe,
        byUser userId: String,
        onUpdate: @escaping (Bool)->(),
        onError: ((Error)->())?
    ) -> AnyCancellable
    
    func addRecipe(_ recipe: Recipe, toFavoritesOf userId: String) async throws
    
    func removeRecipe(_ recipe: Recipe, fromFavoritesOf userId: String) async throws
}
