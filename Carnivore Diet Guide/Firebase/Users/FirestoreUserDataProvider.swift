//
//  FirestoreUserDataProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import Foundation
import FirebaseFirestore

class FirestoreUserDataProvider: UserDataProvider {
    
    @Published var userData: UserData = .empty
    var userDataPublisher: Published<UserData>.Publisher { $userData }
    
    var userDocListener: ListenerRegistration?
    
    let userRepo: FirebaseUserRepository
    
    init(userRepo: FirebaseUserRepository) {
        self.userRepo = userRepo
    }
    
    deinit {
        cleanUpListeners()
    }
    
    private func cleanUpListeners() {
        userDocListener?.remove()
        userDocListener = nil
    }
    
    func startListeningToUser(withId id: String?) {
        cleanUpListeners()
        
        guard let id = id, !id.isEmpty else { return }
        
        userDocListener = userRepo.listenToUserDocument(withId: id) { userDoc in
            if let userData = userDoc?.toUserData() {
                self.userData = userData
            } else {
                self.userData = UserData(id: id, fullName: nil, profileImageUrl: nil)
            }
        }
    }
}
