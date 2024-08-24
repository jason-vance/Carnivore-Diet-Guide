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
    
    private static let RECIPES = FirebaseRecipeRepository.RECIPES
    private static let POSTS = FirebasePostRepository.POSTS
    private let FAVORITERS = "Favoriters"

    let recipesCollection = Firestore.firestore().collection(RECIPES)
    let postsCollection = Firestore.firestore().collection(POSTS)
    
    private var currentUserId: String? {
        FirebaseAuthenticationProvider.instance.currentUserId
    }

    func favoritersCollection(forResource resource: Resource) -> CollectionReference {
        switch resource.type {
        case .post:
            return postsCollection.document(resource.id).collection(FAVORITERS)
        }
    }

    func markAsFavorite(resource: Resource) async throws {
        guard let userId = currentUserId else {
            throw "User is not currently signed in"
        }
        
        let doc = FirestoreFavoriterDoc(
            userId: userId,
            date: .now
        )
        
        try await favoritersCollection(forResource: resource)
            .document(userId)
            .setData(from: doc)
    }

    func unmarkAsFavorite(resource: Resource) async throws {
        guard let userId = currentUserId else {
            throw "User is not currently signed in"
        }
        
        try await favoritersCollection(forResource: resource)
            .document(userId)
            .delete()
    }
    
    func listenToFavoriteCountOf(
        resource: Resource,
        onUpdate: @escaping (UInt) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        let collection = favoritersCollection(forResource: resource)
        let listener = collection.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                onError?(error ?? "¯\\_(ツ)_/¯ While listening to recipe's favoriters")
                return
            }
            
            onUpdate(UInt(snapshot.count))
        }
        
        return .init({ listener.remove() })
    }
}

