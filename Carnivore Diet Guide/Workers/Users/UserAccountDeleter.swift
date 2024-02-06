//
//  UserAccountDeleter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/5/24.
//

import Foundation
import AuthenticationServices

protocol UserAccountDeleter {
    func deleteCurrentUserAccount(authorization: ASAuthorization) async throws
}

class MockUserAccountDeleter: UserAccountDeleter {
    func deleteCurrentUserAccount(authorization: ASAuthorization) async throws {}
}
