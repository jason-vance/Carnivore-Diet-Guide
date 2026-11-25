//
//  FirebaseCarnivorePlusEntitlementService.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/25/26.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

/// Listens to `Entitlements/{uid}`, which the Cloud Functions write from every store, and reports App Store
/// purchases to the `syncAppStoreTransactions` function. See `Docs/Firebase/CarnivorePlusEverywhere.md`.
final class FirebaseCarnivorePlusEntitlementService {

    static let ENTITLEMENTS = "Entitlements"

    static let instance = FirebaseCarnivorePlusEntitlementService()

    /// The outer nil means the server hasn't answered yet. Both subjects keep their latest value, so whoever
    /// subscribes after the first answer still gets it.
    private let entitlement = CurrentValueSubject<ServerEntitlement??, Never>(nil)
    private let account = CurrentValueSubject<String?, Never>(nil)
    private var listener: ListenerRegistration?
    private var authListener: AuthStateDidChangeListenerHandle?
    private var hasSeenAuthState = false

    private init() {
        // Firebase's own listener rather than FirebaseAuthenticationProvider's: the uid is what matters
        // here, guests included.
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.accountChanged(to: user?.uid)
        }
    }

    deinit {
        listener?.remove()
        if let authListener { Auth.auth().removeStateDidChangeListener(authListener) }
    }

    private func accountChanged(to uid: String?) {
        guard !hasSeenAuthState || uid != account.value else { return }
        hasSeenAuthState = true
        listener?.remove()
        listener = nil
        account.send(uid)

        guard let uid else {
            entitlement.send(.some(nil))
            return
        }
        listener = Firestore.firestore()
            .collection(Self.ENTITLEMENTS)
            .document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error {
                    // Until the rules let accounts read their own entitlement, this is "permission denied".
                    // Treat it as nothing from the other platforms, so the App Store still decides.
                    print("FirebaseCarnivorePlusEntitlementService: \(error.localizedDescription)")
                    self?.entitlement.send(.some(nil))
                    return
                }
                self?.entitlement.send(.some(Self.entitlement(from: snapshot?.data())))
            }
    }

    static func entitlement(from data: [String: Any]?) -> ServerEntitlement? {
        guard let carnivorePlus = data?["carnivorePlus"] as? [String: Any],
              let isActive = carnivorePlus["isActive"] as? Bool else {
            return nil
        }
        // Documents written before every store reported here are Stripe's.
        let source = (carnivorePlus["source"] as? String).flatMap(CarnivorePlusSource.init(rawValue:)) ?? .stripe
        return ServerEntitlement(
            isActive: isActive,
            source: source,
            periodEndsAt: (carnivorePlus["periodEndsAt"] as? Timestamp)?.dateValue(),
            willRenew: carnivorePlus["willRenew"] as? Bool ?? false
        )
    }
}

extension FirebaseCarnivorePlusEntitlementService: CarnivorePlusEntitlementService {

    var entitlementPublisher: AnyPublisher<ServerEntitlement?, Never> {
        entitlement
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var accountPublisher: AnyPublisher<String, Never> {
        account
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    func syncAppStoreTransactions(_ signedTransactions: [String]) async throws {
        guard Auth.auth().currentUser != nil else { return }
        _ = try await Functions.functions()
            .httpsCallable("syncAppStoreTransactions")
            .call(["signedTransactions": signedTransactions])
    }
}
