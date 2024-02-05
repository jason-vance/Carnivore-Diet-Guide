//
//  FirebaseCurrentUserDataProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import Foundation

class FirebaseCurrentUserDataProvider: CurrentUserDataProvider {
    
    let authProvider: FirebaseAuthenticationProvider
    let userRepo: FirebaseUserRepository

    init(
        authProvider: FirebaseAuthenticationProvider,
        userRepo: FirebaseUserRepository
    ) {
        self.authProvider = authProvider
        self.userRepo = userRepo
    }
    
    func fetchCurrentUserData() async throws -> UserData {
        guard let userId = authProvider.currentUserId else { throw "User is not currently logged in" }
        
        let userDoc = try await userRepo.fetchUserDocument(withId: userId)
        
        return UserData(
            id: userId,
            fullName: PersonName(userDoc?.fullName ?? authProvider.currentUser?.displayName ?? ""),
            profileImageUrl: userDoc?.profileImageUrl
        )
    }

}
