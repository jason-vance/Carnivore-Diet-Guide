//
//  RecipeRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/31/24.
//

import Foundation
import FirebaseFirestore
import Combine

class FirebaseRecipeRepository {
    
    private static let RECIPES = "Recipes"
    private let FAVORITERS = "Favoriters"
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

extension FirebaseRecipeRepository: RecipeFavoritersRepo {
    
    func addUser(_ userId: String, asFavoriterOf recipe: Recipe) async throws {
        let favoriterDoc = FirestoreRecipeFavoriterDoc(userId: userId, date: .now)
        
        let favoritersCollection = recipesCollection.document(recipe.id).collection(FAVORITERS)
        try await favoritersCollection.document(userId).setData(from: favoriterDoc)
    }
    
    func removeUser(_ userId: String, asFavoriterOf recipe: Recipe) async throws {
        let favoritersCollection = recipesCollection.document(recipe.id).collection(FAVORITERS)
        try await favoritersCollection.document(userId).delete()
    }
    
    func listenToFavoriteCountOf(
        recipe: Recipe,
        onUpdate: @escaping (UInt) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        let listener = recipesCollection.document(recipe.id).collection(FAVORITERS).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                onError?(error ?? "¯\\_(ツ)_/¯ While listening to recipe's favoriters")
                return
            }
            
            onUpdate(UInt(snapshot.count))
        }
        
        return .init({ listener.remove() })
    }
}
