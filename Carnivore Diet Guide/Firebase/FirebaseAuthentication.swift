//
//  FirebaseAuthentication.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

class FirebaseAuthenticationProvider {
    
    @Published var currentUser: User?
    @Published var currentUserId: String?
    var currentUserIdPublisher: Published<String?>.Publisher { $currentUserId }

    @Published var userAuthState: UserAuthState = .working
    var userAuthStatePublisher: Published<UserAuthState>.Publisher { $userAuthState }
    
    var authStateChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    static let instance: FirebaseAuthenticationProvider = .init()

    private init() {
        listenForAuthStateChanges()
    }
    
    deinit {
        stopListeningForAuthStateChanges()
    }
    
    private func listenForAuthStateChanges() {
        authStateChangeListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.async { [weak self] in
                if let user = user {
                    self?.currentUser = user
                    self?.currentUserId = user.uid
                    self?.userAuthState = .loggedIn
                } else {
                    self?.currentUser = nil
                    self?.currentUserId = nil
                    self?.userAuthState = .loggedOut
                }
            }
        }
    }
    
    private func stopListeningForAuthStateChanges() {
        if let handle = authStateChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(withResult result: Result<ASAuthorization, Error>) async throws {
        switch result {
        case .success(let authorization):
            try await signIn(withAuthorization: authorization)
        case .failure(let error):
            throw error
        }
    }
    
    func signIn(withAuthorization authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw TextError("Unable to fetch credential")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw TextError("Unable to fetch identity token")
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw TextError("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        }
        
        DispatchQueue.main.sync {
            self.userAuthState = .working
        }
        
        // Initialize a Firebase credential, including the user's full name.
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nil,
            fullName: appleIDCredential.fullName)
        
        try await Auth.auth().signIn(with: credential)
    }
    
    private func reathenticate(withAuthorization authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw TextError("Unable to fetch credential")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw TextError("Unable to fetch identity token")
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw TextError("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        }
        guard let currentUser = currentUser else {
            throw TextError("User is not logged in")
        }
        
        // Initialize a Firebase credential, including the user's full name.
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nil,
            fullName: appleIDCredential.fullName)

        try await currentUser.reauthenticate(with: credential)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteUser(authorization: ASAuthorization) async throws {
        guard let currentUser = currentUser else {
            throw TextError("User is not logged in")
        }
        
        try await reathenticate(withAuthorization: authorization)
        try await currentUser.delete()
    }
}

extension FirebaseAuthenticationProvider: CurrentUserIdProvider {}

extension FirebaseAuthenticationProvider: ContentAuthenticationProvider {}

extension FirebaseAuthenticationProvider: SignInAuthenticationProvider {}

extension FirebaseAuthenticationProvider: UserProfileSignOutService {}
