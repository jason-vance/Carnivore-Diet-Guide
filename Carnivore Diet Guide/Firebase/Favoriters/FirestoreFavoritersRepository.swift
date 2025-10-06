//
//  FirestoreFavoritersRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation
import FirebaseFirestore
import Combine

class FirestoreFavoritersRepository {
    
    private static let ARTICLES = FirebaseArticleRepository.ARTICLES
    private static let POSTS = FirebasePostRepository.POSTS
    private static let RECIPES = FirebaseRecipeRepository.RECIPES
    private let FAVORITERS = "Favoriters"

    let articlesCollection = Firestore.firestore().collection(ARTICLES)
    let postsCollection = Firestore.firestore().collection(POSTS)
    let recipesCollection = Firestore.firestore().collection(RECIPES)

    private var currentUserId: String? {
        FirebaseAuthenticationProvider.instance.currentUserId
    }

    func favoritersCollection(forResource resource: Resource) -> CollectionReference {
        switch resource.type {
        case .article:
            return articlesCollection.document(resource.id).collection(FAVORITERS)
        case .post:
            return postsCollection.document(resource.id).collection(FAVORITERS)
        case .recipe:
            return recipesCollection.document(resource.id).collection(FAVORITERS)
        }
    }

    func markAsFavorite(resource: Resource) async throws {
        guard let userId = currentUserId else {
            throw TextError("User is not currently signed in")
        }
        
        let doc = FirestoreFavoriterDoc(userId: userId, date: .now)
        try await favoritersCollection(forResource: resource)
            .document(userId)
            .setData(from: doc)
        
        addFavoritedActivity(resource: resource, userId: userId)
    }
    
    private func addFavoritedActivity(resource: Resource, userId: String) {
        Task {
            let repo = FirebaseResourceActivityRepository()
            try? await repo.resource(resource, wasFavoritedByUser: userId)
        }
    }

    func unmarkAsFavorite(resource: Resource) async throws {
        guard let userId = currentUserId else {
            throw TextError("User is not currently signed in")
        }
        
        try await favoritersCollection(forResource: resource)
            .document(userId)
            .delete()
        
        removeFavoritedActivity(resource: resource, userId: userId)
    }
    
    private func removeFavoritedActivity(resource: Resource, userId: String) {
        Task {
            let repo = FirebaseResourceActivityRepository()
            try? await repo.resource(resource, wasUnfavoritedByUser: userId)
        }
    }
    
    func listenToFavoriteCountOf(
        resource: Resource,
        onUpdate: @escaping (UInt) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        let timer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true
        ) { _ in
            Task {
                do {
                    let count = try await self.getFavoriteCountOf(resource: resource)
                    onUpdate(count)
                } catch {
                    onError?(error)
                }
            }
        }
        timer.fire()
        
        return .init({ timer.invalidate() })
    }
    
    func getFavoriteCountOf(resource: Resource) async throws -> UInt {
        let count = try await favoritersCollection(forResource: resource)
            .count
            .getAggregation(source: .server)
            .count
            .intValue
        return UInt(count)
    }
}

