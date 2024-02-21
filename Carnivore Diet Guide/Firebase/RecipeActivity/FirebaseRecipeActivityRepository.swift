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
    
    func addActivity(
        _ type: FirestoreRecipeActivityDoc.RecipeActivityType,
        forRecipe recipeId: String,
        byUser userId: String
    ) async throws {
        let doc = FirestoreRecipeActivityDoc(
            activityType: type,
            userId: userId,
            recipeId: recipeId,
            date: .now
        )
        
        try await activityCollection.addDocument(from: doc)
    }
}

extension FirebaseRecipeActivityRepository: RecipeFavoriteActivityTracker {
    func addRecipe(_ recipe: Recipe, wasFavoritedByUser userId: String) async throws {
        try await addActivity(.favorite, forRecipe: recipe.id, byUser: userId)
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

extension FirebaseRecipeActivityRepository: RecipeViewActivityTracker {
    func recipe(_ recipe: Recipe, wasViewedByUser userId: String) async throws {
        try await addActivity(.view, forRecipe: recipe.id, byUser: userId)
    }
}

extension FirebaseRecipeActivityRepository: PopularRecipeIdFetcher {
    
    func getPopularRecipeIds(since date: Date, limit: Int) async throws -> [String] {
        let recipeActivityCounts = try await getRecipeActivityEventCounts(since: date)
        return recipeActivityCounts
            .sorted { $0.value > $1.value }
            .map { $0.key }
    }
    
    private func getRecipeActivityEventCounts(since date: Date) async throws -> [String:Int] {
        let docs = try await activityCollection
            .whereField(FirestoreRecipeActivityDoc.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: date)
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: FirestoreRecipeActivityDoc.self) }
        
        var recipeActivityCounts: [String:Int] = [:]
        
        docs.forEach { doc in
            guard let recipeId = doc.recipeId else { return }
            recipeActivityCounts[recipeId] = (recipeActivityCounts[recipeId] ?? 0) + 1
        }
        
        return recipeActivityCounts
    }
}

extension FirebaseRecipeActivityRepository: RecipeCommentActivityTracker {
    func recipe(_ recipeId: String, wasCommentedOnByUser userId: String) async throws {
        try await addActivity(.comment, forRecipe: recipeId, byUser: userId)
    }
}
 
