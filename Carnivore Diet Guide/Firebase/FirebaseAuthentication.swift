//
//  FirebaseAuthentication.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

class FirebaseAuthenticationProvider: ContentAuthenticationProvider, SignInAuthenticationProvider {
    
    @Published var currentUser: User?
    var currentUserId: String { currentUser?.uid ?? "" }
    
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
        authStateChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.currentUser = user
                self?.userAuthState = .loggedIn
            } else {
                self?.currentUser = nil
                self?.userAuthState = .loggedOut
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
            throw "Unable to fetch credential"
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw "Unable to fetch identity token"
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
        }
        
        userAuthState = .working
        
        // Initialize a Firebase credential, including the user's full name.
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nil,
            fullName: appleIDCredential.fullName)
        
        // Sign in with Firebase.
        do {
            try await Auth.auth().signIn(with: credential)
        } catch {
            throw "Unable to sign in with credential"
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
