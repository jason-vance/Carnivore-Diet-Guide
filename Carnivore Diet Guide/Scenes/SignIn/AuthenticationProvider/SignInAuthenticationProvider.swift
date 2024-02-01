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
    func signIn(withResult result: Result<ASAuthorization, Error>) async throws
}

class MockSignInAuthenticationProvider: SignInAuthenticationProvider {
    
    @Published var userAuthState: UserAuthState = .loggedOut
    var userAuthStatePublisher: Published<UserAuthState>.Publisher { $userAuthState }
    
    func signIn(withResult result: Result<ASAuthorization, Error>) async throws {
        userAuthState = .working
        Task {
            try? await Task.sleep(for: .seconds(2))
            userAuthState = .loggedIn
        }
    }
}
