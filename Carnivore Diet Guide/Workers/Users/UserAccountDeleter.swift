//
//  UserAccountDeleter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import Foundation
import AuthenticationServices

/// A way to sign in to a Carnivore Diet Guide account.
enum SignInMethod: CaseIterable {
    case apple
    case google
}

/// How the user proves it's them before their account is deleted.
enum AccountReauthentication {
    /// The result of the Sign in with Apple button.
    case apple(ASAuthorization)
    /// Shows Google's sign-in sheet.
    case google
}

protocol UserAccountDeleter {
    /// The ways the current account signs in. Any of them can confirm deleting it.
    var signInMethods: [SignInMethod] { get }
    /// Confirms it's the user, then deletes their data and their account. Does nothing if they close
    /// Google's sign-in sheet.
    func deleteCurrentUserAccount(reauthentication: AccountReauthentication) async throws
}

class MockUserAccountDeleter: UserAccountDeleter {
    var signInMethods: [SignInMethod] = [.apple]
    func deleteCurrentUserAccount(reauthentication: AccountReauthentication) async throws {}
}
