//
//  FirebaseUserAccountDeleter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import Foundation
import AuthenticationServices

class FirebaseUserAccountDeleter: UserAccountDeleter {
    
    private let userRepo: FirebaseUserRepository = .init()
    private let profilePicStorage: FirebaseProfileImageStorage = .init()
    private let auth: FirebaseAuthenticationProvider = .instance
    
    func deleteCurrentUserAccount(authorization: ASAuthorization) async throws {
        guard let currentUserId = auth.currentUserId else { throw TextError("There is no user currently logged in") }
        try await profilePicStorage.deleteProfileImage(for: currentUserId)
        try await userRepo.deleteUserDoc(withId: currentUserId)
        try await auth.deleteUser(authorization: authorization)
    }
}
