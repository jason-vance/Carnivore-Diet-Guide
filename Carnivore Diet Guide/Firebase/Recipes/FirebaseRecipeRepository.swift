//
//  RecipeRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import FirebaseFirestore

class FirebaseRecipeRepository {
    
    private static let RECIPES = "Recipes"
    private let PUBLICATION_DATE = "publicationDate"

    let recipesCollection = Firestore.firestore().collection(RECIPES)
    
    func getPublishedRecipesNewestToOldest(limit: Int? = nil) async throws -> [Recipe] {
        var query = recipesCollection
            .whereField(PUBLICATION_DATE, isLessThan: Date.now)
            .order(by: PUBLICATION_DATE, descending: true)
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents
            .compactMap { try $0.data(as: FirestoreRecipeDoc.self).toRecipe() }
    }
}
