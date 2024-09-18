//
//  FirebaseRecipePoster.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/17/24.
//

import Foundation

extension DefaultRecipePoster {
    static var forProd: RecipePoster {
        DefaultRecipePoster { recipe, feedItem in
            let recipeRepo = FirebaseRecipeRepository()
            let feedItemRepo = FirebaseFeedItemRepository()
            
            do {
                try await recipeRepo.create(recipe: recipe)
            } catch {
                print("Failed to create Recipe. \(error.localizedDescription)")
                throw error
            }
            
            do {
                try await feedItemRepo.create(feedItem: feedItem)
            } catch {
                print("Failed to create FeedItem. \(error.localizedDescription)")
                //Purposely ignoring error for this
            }
        }
    }
}
