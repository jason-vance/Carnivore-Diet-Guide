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
    
    let usernameField = FirestoreUserDoc.CodingKeys.username.rawValue
    
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
        dict[FirestoreUserDoc.CodingKeys.username.rawValue] = userData.username?.value
        dict[FirestoreUserDoc.CodingKeys.profileImageUrl.rawValue] = userData.profileImageUrl?.absoluteString
        if let termsOfServiceAcceptance = userData.termsOfServiceAcceptance {
            dict[FirestoreUserDoc.CodingKeys.termsOfServiceAcceptance.rawValue] = termsOfServiceAcceptance
        }
        if let privacyPolicyAcceptance = userData.privacyPolicyAcceptance {
            dict[FirestoreUserDoc.CodingKeys.privacyPolicyAcceptance.rawValue] = privacyPolicyAcceptance
        }

        try await usersCollection.document(userData.id).updateData(dict)
    }
    
    func listenToUserDocument(
        withId id: String,
        onUpdate: @escaping (FirestoreUserDoc?)->(),
        onError: ((Error)->())? = nil
    ) -> AnyCancellable {
        let timer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true
        ) { _ in
            Task {
                do {
                    let userDoc = try await self.fetchUserDocument(withId: id)
                    onUpdate(userDoc)
                } catch {
                    onError?(error)
                }
            }
        }
        timer.fire()
        
        return .init({ timer.invalidate() })
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
        let timer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true
        ) { _ in
            Task {
                do {
                    let doc = try await self.usersCollection.document(userId).getDocument()
                    let favoritesAsAny = doc.get(Self.favoritesField(for: resource))

                    guard let favorites = favoritesAsAny as? [String]? else {
                        onError?(TextError("Couldn't cast to array of favorites"))
                        return
                    }
                    
                    guard let favorites = favorites else {
                        onUpdate(false)
                        return
                    }
                    
                    onUpdate(favorites.contains { $0 == resource.id })
                } catch {
                    onError?(error)
                }
            }
        }
        timer.fire()
        
        return .init({ timer.invalidate() })
    }
    
    func add(resource: Resource, toFavoritesOf userId: String) async throws {
        guard !resource.id.isEmpty else { throw TextError("`resource.id` was empty.") }
        
        let field = Self.favoritesField(for: resource)

        try await usersCollection
            .document(userId)
            .updateData(
                [field : FieldValue.arrayUnion([resource.id])]
            )
    }
    
    func remove(resource: Resource, fromFavoritesOf userId: String) async throws {
        guard !resource.id.isEmpty else { throw TextError("`resource.id` was empty.") }
        
        let field = Self.favoritesField(for: resource)

        try await usersCollection
            .document(userId)
            .updateData(
                [field : FieldValue.arrayRemove([resource.id])]
            )
    }
    
    func createSeedUser(_ userData: UserData) async throws {
        let userDoc = FirestoreUserDoc.from(userData)

        try await usersCollection
            .document(userData.id)
            .setData(from: userDoc)
        
        var dict: [AnyHashable : Any] = [:]
        dict[FirestoreUserDoc.CodingKeys.bio.rawValue] = userData.bio?.value ?? FieldValue.delete()
        dict[FirestoreUserDoc.CodingKeys.whyCarnivore.rawValue] = userData.whyCarnivore?.value ?? FieldValue.delete()
        try await usersCollection.document(userData.id).updateData(dict)
    }
    
    func addProfileImageUrlToUser(using userData: UserData) async throws {
        var dict: [AnyHashable : Any] = [:]
        dict[FirestoreUserDoc.CodingKeys.profileImageUrl.rawValue] = userData.profileImageUrl?.absoluteString
        try await usersCollection.document(userData.id).updateData(dict)
    }
}

extension FirebaseUserRepository: UserDataSaver {
    func saveOnboarding(userData: UserData) async throws {
        try await createOrUpdateUserDocument(with: userData)
    }
    
    func save(userBio: UserBio?, toUser userId: String) async throws {
        var dict: [AnyHashable : Any] = [:]
        dict[FirestoreUserDoc.CodingKeys.bio.rawValue] = userBio?.value ?? FieldValue.delete()
        try await usersCollection.document(userId).updateData(dict)
    }
    
    func save(whyCarnivore: WhyCarnivore?, toUser userId: String) async throws {
        var dict: [AnyHashable : Any] = [:]
        dict[FirestoreUserDoc.CodingKeys.whyCarnivore.rawValue] = whyCarnivore?.value ?? FieldValue.delete()
        try await usersCollection.document(userId).updateData(dict)
    }
    
    func save(carnivoreSince: CarnivoreSince?, toUser userId: String) async throws {
        var dict: [AnyHashable : Any] = [:]
        dict[FirestoreUserDoc.CodingKeys.carnivoreSince.rawValue] = carnivoreSince?.date ?? FieldValue.delete()
        try await usersCollection.document(userId).updateData(dict)
    }
}

extension FirebaseUserRepository: RemoteUserDataFetcher {

    func fetchUser(userId: String) async throws -> UserData {
        guard !userId.isEmpty else { throw TextError("`userId` is empty") }
        
        let userData = try await usersCollection
            .document(userId)
            .getDocument()
            .data(as: FirestoreUserDoc.self)
            .toUserData()
        
        guard let userData = userData else { throw TextError("Could not transform FirestoreUserDoc to UserData") }
        
        return userData
    }
}

extension FirebaseUserRepository: UsernameAvailabilityChecker {
    func isAvailable(username: Username, forUser userId: String) async throws -> Bool {
        try await usersCollection
            .whereField(usernameField, isEqualTo: username.value)
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: FirestoreUserDoc.self) }
            .filter { $0.id != userId }
            .count == 0
    }
}
