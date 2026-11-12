//
//  UserAuthState.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation

enum UserAuthState {
    case working
    case loggedIn
    /// Browsing without an account. Backed by a Firebase anonymous user, so Firestore reads that
    /// require `request.auth` still succeed, but there is no user ID or profile.
    case guest
    case loggedOut

    /// Whether articles and recipes can be fetched from Firestore.
    var canReadContent: Bool {
        self == .loggedIn || self == .guest
    }
}
