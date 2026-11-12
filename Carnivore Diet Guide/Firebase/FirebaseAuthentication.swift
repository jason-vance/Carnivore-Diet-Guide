//
//  FirebaseAuthentication.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import FirebaseAnalytics

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
                self?.apply(user: user)
            }
        }
    }

    /// A guest is a Firebase anonymous user: signed in as far as Firestore rules are concerned, but
    /// `currentUserId` stays nil so everything tied to an account (favorites, comments, profile)
    /// treats them as not signed in.
    @MainActor
    private func apply(user: User?) {
        currentUser = user
        if let user, !user.isAnonymous {
            currentUserId = user.uid
            userAuthState = .loggedIn
            FirebaseAnalytics.Analytics.setUserID(user.uid)
        } else {
            currentUserId = nil
            userAuthState = user == nil ? .loggedOut : .guest
            FirebaseAnalytics.Analytics.setUserID(nil)
        }
    }

    func signInAsGuest() async throws {
        await MainActor.run { userAuthState = .working }
        do {
            try await Auth.auth().signInAnonymously()
        } catch {
            await MainActor.run { apply(user: Auth.auth().currentUser) }
            throw error
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
        
        // Initialize a Firebase credential, including the user's full name.
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nil,
            fullName: appleIDCredential.fullName)

        if let guest = Auth.auth().currentUser, guest.isAnonymous {
            try await upgradeGuest(guest, with: credential)
            return
        }

        await MainActor.run { userAuthState = .working }
        do {
            try await Auth.auth().signIn(with: credential)
        } catch {
            // The auth state listener doesn't fire on failure, so put the state back ourselves.
            await MainActor.run { apply(user: Auth.auth().currentUser) }
            throw error
        }
    }

    /// Turns a guest's anonymous account into an Apple account, keeping its uid. If this Apple ID
    /// already has an account, signs in to that one instead and the anonymous account is abandoned.
    private func upgradeGuest(_ guest: User, with credential: AuthCredential) async throws {
        do {
            let result = try await guest.link(with: credential)
            // Firestore rules only let real accounts write, so make sure the next request carries the
            // Apple sign-in token rather than the cached anonymous one.
            _ = try? await result.user.getIDTokenResult(forcingRefresh: true)
            // Linking keeps the same user, so the auth state listener doesn't fire.
            await MainActor.run { apply(user: result.user) }
        } catch let error as NSError where error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
            // Apple identity tokens are single use; Firebase hands back a fresh credential for this case.
            guard let existingAccountCredential = error.userInfo[AuthErrors.userInfoUpdatedCredentialKey] as? AuthCredential else {
                throw error
            }
            try await Auth.auth().signIn(with: existingAccountCredential)
        }
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
