//
//  FirebaseRecipeActivityRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import FirebaseFirestore

class FirebaseRecipeActivityRepository {
    
    private static let RECIPE_ACTIVITY = "RecipeActivity"

    let activityCollection = Firestore.firestore().collection(RECIPE_ACTIVITY)
}

extension FirebaseRecipeActivityRepository: RecipeFavoriteActivityTracker {
    func addRecipe(_ recipe: Recipe, wasFavoritedByUser userId: String) async throws {
        let doc = FirestoreRecipeActivityDoc(
            activityType: .favorite,
            userId: userId,
            recipeId: recipe.id,
            date: .now
        )
        
        try await activityCollection.addDocument(from: doc)
    }
    
    func removeRecipe(_ recipe: Recipe, wasFavoritedByUser userId: String) async throws {
        let favorite = FirestoreRecipeActivityDoc.RecipeActivityType.favorite.rawValue
        
        let docs = try await activityCollection
            .whereField(FirestoreRecipeActivityDoc.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(FirestoreRecipeActivityDoc.CodingKeys.recipeId.rawValue, isEqualTo: recipe.id)
            .whereField(FirestoreRecipeActivityDoc.CodingKeys.activityType.rawValue, isEqualTo: favorite)
            .getDocuments()
        
        docs.documents.forEach { doc in
            doc.reference.delete()
        }
    }
}
