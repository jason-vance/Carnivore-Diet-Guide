//
//  SignInAuthenticationProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import AuthenticationServices

protocol SignInAuthenticationProvider {
    var userAuthStatePublisher: Published<UserAuthState>.Publisher { get }
    /// Signs in with Apple. When called by a guest, upgrades the guest to a full account.
    func signIn(withResult result: Result<ASAuthorization, Error>) async throws
    /// Shows Google's sign-in sheet and signs in with the account picked. When called by a guest, upgrades
    /// the guest to a full account. Returns without signing in if the user closes the sheet.
    func signInWithGoogle() async throws
    func signInAsGuest() async throws
}

class MockSignInAuthenticationProvider: SignInAuthenticationProvider {

    @Published var userAuthState: UserAuthState = .loggedOut
    var userAuthStatePublisher: Published<UserAuthState>.Publisher { $userAuthState }

    func signIn(withResult result: Result<ASAuthorization, Error>) async throws {
        signInAfterADelay()
    }

    func signInWithGoogle() async throws {
        signInAfterADelay()
    }

    private func signInAfterADelay() {
        userAuthState = .working
        Task {
            try? await Task.sleep(for: .seconds(2))
            userAuthState = .loggedIn
        }
    }

    func signInAsGuest() async throws {
        userAuthState = .guest
    }
}
