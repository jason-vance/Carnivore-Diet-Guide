//
//  FirebaseAuthentication.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import FirebaseAnalytics
import GoogleSignIn
import UIKit

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

    /// Points Google Sign-In at this app's OAuth client. Call once, after `FirebaseApp.configure()`.
    static func configureGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("FirebaseAuthenticationProvider: GoogleService-Info.plist has no CLIENT_ID, so Google sign-in won't work.")
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
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
        try await signIn(with: appleCredential(from: authorization))
    }

    /// Shows Google's sign-in sheet and signs in with the account picked. When called by a guest, upgrades the
    /// guest to a full account. Returns without signing in if the user closes the sheet.
    func signInWithGoogle() async throws {
        guard let credential = try await googleCredential() else { return }
        try await signIn(with: credential)
    }

    private func signIn(with credential: AuthCredential) async throws {
        do {
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
        } catch let error as NSError where error.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
            // Each email address gets one account, so this email already signs in with the other provider.
            throw TextError(String(localized: "This email address already has an account that uses a different sign-in method. Sign in the way you did before."))
        }
    }

    /// Turns a guest's anonymous account into a full account, keeping its uid. If this Apple or Google
    /// account is already signed up, signs in to that one instead and the anonymous account is abandoned.
    private func upgradeGuest(_ guest: User, with credential: AuthCredential) async throws {
        do {
            let result = try await guest.link(with: credential)
            // Firestore rules only let real accounts write, so make sure the next request carries the
            // new sign-in token rather than the cached anonymous one.
            _ = try? await result.user.getIDTokenResult(forcingRefresh: true)
            // Linking keeps the same user, so the auth state listener doesn't fire.
            await MainActor.run { apply(user: result.user) }
        } catch let error as NSError where error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
            // Apple identity tokens are single use, so Firebase hands back a fresh credential for this case.
            // Google's tokens can be used again.
            let existingAccountCredential = error.userInfo[AuthErrors.userInfoUpdatedCredentialKey] as? AuthCredential ?? credential
            try await Auth.auth().signIn(with: existingAccountCredential)
        }
    }

    private func appleCredential(from authorization: ASAuthorization) throws -> AuthCredential {
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
        return OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nil,
            fullName: appleIDCredential.fullName)
    }

    /// Shows Google's sign-in sheet over the frontmost screen. Nil if the user closes it.
    @MainActor
    private func googleCredential() async throws -> AuthCredential? {
        guard let presenter = UIApplication.shared.frontmostViewController else {
            throw TextError("Unable to show Google sign-in")
        }
        let result: GIDSignInResult
        do {
            result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
        } catch let error as GIDSignInError where error.code == .canceled {
            return nil
        }
        guard let idToken = result.user.idToken?.tokenString else {
            throw TextError("Unable to fetch identity token")
        }
        return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
    }

    /// The ways the current account can sign in, so the user can confirm it's them with one of them.
    var signInMethods: [SignInMethod] {
        let providerIDs = currentUser?.providerData.map(\.providerID) ?? []
        return SignInMethod.allCases.filter { providerIDs.contains($0.firebaseProviderID) }
    }

    func signOut() throws {
        try Auth.auth().signOut()
        // Otherwise Google keeps the account signed in to this app until it's signed out there too.
        GIDSignIn.sharedInstance.signOut()
    }

    /// Re-authenticates the current user, which Firebase requires shortly before deleting an account.
    /// Returns false if the user closed Google's sign-in sheet.
    func reauthenticate(with reauthentication: AccountReauthentication) async throws -> Bool {
        guard let currentUser = currentUser else {
            throw TextError("User is not logged in")
        }

        let credential: AuthCredential
        switch reauthentication {
        case .apple(let authorization):
            credential = try appleCredential(from: authorization)
        case .google:
            guard let googleCredential = try await googleCredential() else { return false }
            credential = googleCredential
        }

        try await currentUser.reauthenticate(with: credential)
        return true
    }

    /// Deletes the current account. Call `reauthenticate(with:)` first.
    func deleteCurrentUser() async throws {
        guard let currentUser = currentUser else {
            throw TextError("User is not logged in")
        }

        try await currentUser.delete()
        GIDSignIn.sharedInstance.signOut()
    }
}

private extension SignInMethod {
    var firebaseProviderID: String {
        switch self {
        case .apple: "apple.com"
        case .google: "google.com"
        }
    }
}

private extension UIApplication {
    /// The view controller on top of the active window, including anything presented over it, like a sheet.
    var frontmostViewController: UIViewController? {
        let windowScenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        let activeScene = windowScenes.first { $0.activationState == .foregroundActive } ?? windowScenes.first
        var controller = activeScene?.keyWindow?.rootViewController
        while let presented = controller?.presentedViewController, !presented.isBeingDismissed {
            controller = presented
        }
        return controller
    }
}

extension FirebaseAuthenticationProvider: CurrentUserIdProvider {}

extension FirebaseAuthenticationProvider: ContentAuthenticationProvider {}

extension FirebaseAuthenticationProvider: SignInAuthenticationProvider {}

extension FirebaseAuthenticationProvider: UserProfileSignOutService {}
