//
//  CarnivorePlusEntitlementService.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/25/26.
//

import Combine
import Foundation

/// Where a Carnivore+ subscription is billed. Raw values match `Entitlements/{uid}` (see
/// `Docs/Firebase/CarnivorePlusEverywhere.md`).
enum CarnivorePlusSource: String {
    case appStore
    case googlePlay
    case stripe
}

/// The account's Carnivore+ as the server sees it, from any store: `Entitlements/{uid}.carnivorePlus`.
struct ServerEntitlement: Equatable {
    let isActive: Bool
    let source: CarnivorePlusSource
    let periodEndsAt: Date?
    let willRenew: Bool

    /// A late renewal notice gets a day's slack. Without the date check, a missed notification would leave
    /// Carnivore+ on for good.
    static let renewalSlack: TimeInterval = 24 * 60 * 60

    func unlocksCarnivorePlus(now: Date = .now) -> Bool {
        guard isActive else { return false }
        guard let periodEndsAt else { return true }
        return now < periodEndsAt.addingTimeInterval(Self.renewalSlack)
    }
}

/// Reads the account's Carnivore+ from the server and tells the server about App Store purchases, so a
/// subscription from any platform works on every platform.
protocol CarnivorePlusEntitlementService {
    /// The signed-in account's entitlement (a guest's too), or nil without one. Emits once the server (or the
    /// device's cache of it) has answered, and on every change after that.
    var entitlementPublisher: AnyPublisher<ServerEntitlement?, Never> { get }
    /// Emits the uid whenever a different account (or guest) signs in, so its purchases can be reported.
    var accountPublisher: AnyPublisher<String, Never> { get }
    /// Sends the App Store's signed transactions (`VerificationResult.jwsRepresentation`) to the server, which
    /// checks them with Apple and records them for this account.
    func syncAppStoreTransactions(_ signedTransactions: [String]) async throws
}

class MockCarnivorePlusEntitlementService: CarnivorePlusEntitlementService {

    let entitlement = CurrentValueSubject<ServerEntitlement?, Never>(nil)
    let account = PassthroughSubject<String, Never>()
    private(set) var syncedTransactions: [[String]] = []

    var entitlementPublisher: AnyPublisher<ServerEntitlement?, Never> { entitlement.eraseToAnyPublisher() }
    var accountPublisher: AnyPublisher<String, Never> { account.eraseToAnyPublisher() }

    func syncAppStoreTransactions(_ signedTransactions: [String]) async throws {
        syncedTransactions.append(signedTransactions)
    }
}
