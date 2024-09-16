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
    
    static let RECIPES = "Recipes"
    private let FAVORITERS = "Favoriters"
    private let COMMENTS = "Comments"
    
    private let publicationDateField = FirestoreRecipeDoc.CodingKeys.publicationDate.rawValue

    let recipesCollection = Firestore.firestore().collection(RECIPES)
    
    func getPublishedRecipesNewestToOldest(limit: Int? = nil) async throws -> [Recipe] {
        var query = recipesCollection
            .whereField(publicationDateField, isLessThan: Date.now)
            .order(by: publicationDateField, descending: true)
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents
            .compactMap { try $0.data(as: FirestoreRecipeDoc.self).toRecipe() }
    }
    
    func deleteRecipe(withId recipeId: String) async throws {
        try await recipesCollection.document(recipeId).delete()
    }
}

extension FirebaseRecipeRepository: RecipeRepository {
    
    func fetchRecipe(byId recipeId: String) async throws -> Recipe {
        guard let recipe = try await recipesCollection
            .document(recipeId)
            .getDocument()
            .data(as: FirestoreRecipeDoc.self)
            .toRecipe()
        else {
            throw "Could not map `RecipeDoc` to `Recipe`"
        }
        
        return recipe
    }
}

extension FirebaseRecipeRepository: RecipeFavoritersRepo {
    
    func addUser(_ userId: String, asFavoriterOf recipe: Recipe) async throws {
        let favoriterDoc = FirestoreFavoriterDoc(userId: userId, date: .now)
        
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

extension FirebaseRecipeRepository: RecipeCommentsRepo {
    func listenToCommentCountOf(
        recipe: Recipe,
        onUpdate: @escaping (UInt) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        let listener = recipesCollection.document(recipe.id).collection(COMMENTS).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                onError?(error ?? "¯\\_(ツ)_/¯ While listening to recipe's comments")
                return
            }
            
            onUpdate(UInt(snapshot.count))
        }
        
        return .init({ listener.remove() })
    }
}

extension FirebaseRecipeRepository: RecipeCollectionFetcher {
    
    private func getCursor(for recipe: Recipe?) async throws -> DocumentSnapshot? {
        if let recipe = recipe {
            let doc = try await recipesCollection.document(recipe.id).getDocument()
            if doc.exists { return doc }
        }
        return nil
    }
    
    func fetchRecipesOldestFirst(
        newerThan recipe: Recipe?,
        limit: Int
    ) async throws -> [Recipe] {
        var query = recipesCollection
            .order(by: publicationDateField, descending: false)
            .limit(to: limit)
        
        if let cursor = try await getCursor(for: recipe) {
            query = query.start(afterDocument: cursor)
        }
        
        return try await query
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: FirestoreRecipeDoc.self).toRecipe() }
    }
    
    func fetchRecipesNewestFirst(
        olderThan recipe: Recipe?,
        limit: Int
    ) async throws -> [Recipe] {
        var query = recipesCollection
            .order(by: publicationDateField, descending: true)
            .limit(to: limit)
        
        if let cursor = try await getCursor(for: recipe) {
            query = query.start(afterDocument: cursor)
        }
        
        return try await query
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: FirestoreRecipeDoc.self).toRecipe() }
    }
    
    func fetchTrendingRecipes(in timeFrame: TimeFrame) async throws -> [String] {
        let timeFrameAgo = Calendar.current.date(byAdding: .day, value: -timeFrame.numberOfDays, to: .now)!

        let repo = FirebaseResourceActivityRepository()
        let articleIds = try await repo.fetchTrendingResourceIds(
            ofType: .recipe,
            after: timeFrameAgo
        )
        
        return articleIds
    }
    
    func fetchLikedRecipes(in timeFrame: TimeFrame) async throws -> [String] {
        let timeFrameAgo = Calendar.current.date(byAdding: .day, value: -timeFrame.numberOfDays, to: .now)!
        
        let repo = FirebaseResourceActivityRepository()
        let articleIds = try await repo.fetchLikedResourceIds(
            ofType: .recipe,
            after: timeFrameAgo
        )
        
        return articleIds
    }
}

extension FirebaseRecipeRepository: IndividualRecipeFetcher {
    
    func fetchRecipe(withId recipeId: String) async throws -> Recipe {
        let doc = try await recipesCollection.document(recipeId).getDocument()
        guard doc.exists else { throw Resource.Errors.doesNotExist }
        
        guard let recipe = try doc.data(as: FirestoreRecipeDoc.self).toRecipe() else {
            throw "Could convert Firestore doc to Recipe"
        }
        return recipe
    }
}
