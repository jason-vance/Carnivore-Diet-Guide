//
//  FirebaseUserRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation
import FirebaseFirestore
import Combine

class FirebaseUserRepository {
    
    static let USERS = "Users"
    
    let usersCollection = Firestore.firestore().collection(USERS)
    
    func createOrUpdateUserDocument(with userData: UserData) async throws {
        if try await usersCollection.document(userData.id).getDocument().exists {
            try await updateUserDocument(with: userData)
        } else {
            try await createUserDocument(with: userData)
        }
    }
    
    private func createUserDocument(with userData: UserData) async throws {
        let userDoc = FirestoreUserDoc.from(userData)
        try await usersCollection.document(userData.id).setData(from: userDoc)
    }
    
    private func updateUserDocument(with userData: UserData) async throws {
        var dict: [AnyHashable : Any] = [:]
        dict[FirestoreUserDoc.CodingKeys.fullName.rawValue] = userData.fullName?.value
        dict[FirestoreUserDoc.CodingKeys.profileImageUrl.rawValue] = userData.profileImageUrl?.absoluteString

        try await usersCollection.document(userData.id).updateData(dict)
    }
    
    func listenToUserDocument(
        withId id: String,
        onUpdate: @escaping (FirestoreUserDoc?)->(),
        onError: ((Error)->())? = nil
    ) -> ListenerRegistration {
        usersCollection.document(id).addSnapshotListener { snapshot, error in
            if let snapshot = snapshot {
                let userDoc = try? snapshot.data(as: FirestoreUserDoc.self)
                onUpdate(userDoc)
            } else if let error = error {
                onError?(error)
            } else {
                onError?("¯\\_(ツ)_/¯ While listening to user doc changes")
            }
        }
    }
    
    func fetchUserDocument(withId id: String) async throws -> FirestoreUserDoc? {
        let snapshot = try await usersCollection.document(id).getDocument()
        return try? snapshot.data(as: FirestoreUserDoc.self)
    }
    
    func deleteUserDoc(withId userId: String) async throws {
        try await usersCollection.document(userId).delete()
    }
    
    private static func favoritesField(for resource: Resource) -> String {
        switch resource.type {
        case .article:
            return FirestoreUserDoc.CodingKeys.favoriteArticles.rawValue
        case .post:
            return FirestoreUserDoc.CodingKeys.favoritePosts.rawValue
        case .recipe:
            return FirestoreUserDoc.CodingKeys.favoriteRecipes.rawValue
        }
        
    }
    
    func listenToFavoriteStatusOf(
        resource: Resource,
        byUser userId: String,
        onUpdate: @escaping (Bool)->(),
        onError: ((Error)->())? = nil
    ) -> AnyCancellable {
        let listener = usersCollection.document(userId).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                onError?(error ?? "¯\\_(ツ)_/¯ While listening to user's recipe favorite status")
                return
            }
            
            let field = Self.favoritesField(for: resource)
            let favoritesAsAny = snapshot.get(field)
            
            guard let favorites = favoritesAsAny as? [String]? else {
                onError?("Couldn't cast to array of favorites")
                return
            }
            
            guard let favorites = favorites else {
                onUpdate(false)
                return
            }
            
            onUpdate(favorites.contains { $0 == resource.id })
        }
        
        return AnyCancellable({ listener.remove() })
    }
    
    func add(resource: Resource, toFavoritesOf userId: String) async throws {
        guard !resource.id.isEmpty else { throw "`resource.id` was empty." }
        
        let field = Self.favoritesField(for: resource)

        try await usersCollection
            .document(userId)
            .updateData(
                [field : FieldValue.arrayUnion([resource.id])]
            )
    }
    
    func remove(resource: Resource, fromFavoritesOf userId: String) async throws {
        guard !resource.id.isEmpty else { throw "`resource.id` was empty." }
        
        let field = Self.favoritesField(for: resource)

        try await usersCollection
            .document(userId)
            .updateData(
                [field : FieldValue.arrayRemove([resource.id])]
            )
    }
}

extension FirebaseUserRepository: UserDataSaver {
    func save(userData: UserData) async throws {
        try await createOrUpdateUserDocument(with: userData)
    }
}

extension FirebaseUserRepository: FavoriteRecipeRepo {
    func listenToFavoriteStatusOf(
        recipe: Recipe,
        byUser userId: String,
        onUpdate: @escaping (Bool)->(),
        onError: ((Error)->())? = nil
    ) -> AnyCancellable {
        let listener = usersCollection.document(userId).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                onError?(error ?? "¯\\_(ツ)_/¯ While listening to user's recipe favorite status")
                return
            }
            
            let favoritesAsAny = snapshot.get(FirestoreUserDoc.CodingKeys.favoriteRecipes.rawValue)
            
            guard let favorites = favoritesAsAny as? [String]? else {
                onError?("Couldn't cast to array of favorites")
                return
            }
            
            guard let favorites = favorites else {
                onUpdate(false)
                return
            }
            
            onUpdate(favorites.contains { $0 == recipe.id })
        }
        
        return AnyCancellable({ listener.remove() })
    }
    
    func addRecipe(_ recipe: Recipe, toFavoritesOf userId: String) async throws {
        guard !recipe.id.isEmpty else { throw "`recipe.id` was empty." }
        try await usersCollection
            .document(userId)
            .updateData(
                [FirestoreUserDoc.CodingKeys.favoriteRecipes.rawValue : FieldValue.arrayUnion([recipe.id])]
            )
    }
    
    func removeRecipe(_ recipe: Recipe, fromFavoritesOf userId: String) async throws {
        guard !recipe.id.isEmpty else { throw "`recipe.id` was empty." }
        try await usersCollection
            .document(userId)
            .updateData(
                [FirestoreUserDoc.CodingKeys.favoriteRecipes.rawValue : FieldValue.arrayRemove([recipe.id])]
            )
    }
}

extension FirebaseUserRepository: UserFetcher {

    func fetchUser(userId: String) async throws -> UserData {
        guard !userId.isEmpty else { throw "`userId` is empty" }
        
        let userData = try await usersCollection
            .document(userId)
            .getDocument()
            .data(as: FirestoreUserDoc.self)
            .toUserData()
        
        guard let userData = userData else { throw "Could not transform FirestoreUserDoc to UserData" }
        
        return userData
    }
}
