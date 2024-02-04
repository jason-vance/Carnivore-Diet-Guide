//
//  FirebaseUserRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation
import FirebaseFirestore

class FirebaseUserRepository {
    
    static let USERS = "Users"
    
    let usersCollection = Firestore.firestore().collection(USERS)
    
    func createOrUpdateUserDocument(with userData: UserData) async throws {
        if try await usersCollection.document(userData.id).getDocument().exists {
            try await updateUserDocument(with: userData)
        } else {
            try await createUserDocument(with: userData)
        }
        //TODO: Feature: Add search metadata to user doc
    }
    
    private func createUserDocument(with userData: UserData) async throws {
        let userDoc = FirestoreUserDoc.from(userData)
        try await withCheckedThrowingContinuation { (continuation:CheckedContinuation<Void,Error>) in
            do {
                try usersCollection.document(userData.id).setData(from: userDoc) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func updateUserDocument(with userData: UserData) async throws {
        var dict: [AnyHashable : Any] = [:]
        dict[FirestoreUserDoc.CodingKeys.fullName.rawValue] = userData.fullName.value
        dict[FirestoreUserDoc.CodingKeys.username.rawValue] = userData.username.value
        dict[FirestoreUserDoc.CodingKeys.profileImageUrl.rawValue] = userData.profileImageUrl.absoluteString

        try await usersCollection.document(userData.id).updateData(dict)
    }
    
    func listenToUserDocument(withId id: String, onUpdate: @escaping (FirestoreUserDoc?)->(), onError: ((Error)->())? = nil) -> ListenerRegistration {
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
}
