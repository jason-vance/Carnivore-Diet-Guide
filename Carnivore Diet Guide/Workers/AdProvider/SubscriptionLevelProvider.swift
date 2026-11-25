//
//  SubscriptionLevelProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import Combine
import Foundation
import StoreKit
import SwiftUI
import SwinjectAutoregistration

enum SubscriptionError: Error {
    case productNotFound
    case verificationFailed
    case pending
    case unknown
    
    var message: String {
        switch self {
        case .productNotFound:
            return "Subscription product not found"
        case .verificationFailed:
            return "Failed to verify purchase"
        case .pending:
            return "Purchase is pending"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

class SubscriptionLevelProvider: ObservableObject {
    
    private let subscriptionLevelKey = "subscriptionLevelKey"

    enum SubscriptionLevel: String {
        case none
        case carnivorePlus
    }
    
    static let carnivorePlusSubscriptionGroupId = "21537446"
    static let monthlyProductId = "carnivorePlus499"
    static let yearlyProductId = "carnivorePlusYearly"
    static let discountMonthlyProductId = "carnivorePlusMonthlyDiscounted"
    static let discountYearlyProductId = "carnivorePlusYearlyDiscounted"
    
    static let fullPriceProductIds = [
        monthlyProductId,
        yearlyProductId,
    ]
    
    static let discountProductIds = [
        discountMonthlyProductId,
        discountYearlyProductId,
    ]
    
    static var allProductIds: [String] { fullPriceProductIds + discountProductIds }
    
    /// Carnivore+ from the App Store on this device, or from any store through the server (a subscription bought
    /// on the web or in the Android app). See `Docs/Firebase/CarnivorePlusEverywhere.md`.
    @Published public private(set) var subscriptionLevel: SubscriptionLevel = .none
    var subscriptionLevelPublisher: Published<SubscriptionLevel>.Publisher { $subscriptionLevel }

    /// Where the Carnivore+ is billed, or nil without it. The App Store wins when there's more than one.
    @Published private(set) var carnivorePlusSource: CarnivorePlusSource?

    /// False until both StoreKit and the server have answered since launch. Before that, `subscriptionLevel` is
    /// the level saved on the device last time, which can be out of date (a lapsed subscription, or a fresh
    /// install).
    @Published private(set) var hasConfirmedLevel = false
    var hasConfirmedLevelPublisher: Published<Bool>.Publisher { $hasConfirmedLevel }

    /// What the App Store says on this device, and whether it has answered since launch.
    private var storeKitLevel: SubscriptionLevel = .none
    private var storeKitHasAnswered = false
    /// What the server says, from any store, and whether it has answered (or taken too long) since launch.
    private var serverEntitlement: ServerEntitlement?
    private var serverHasAnswered = false
    /// How long to wait for the server before deciding without it, e.g. offline on a fresh install.
    private static let serverAnswerTimeout: TimeInterval = 5
    private var cancellables = Set<AnyCancellable>()

    /// Fires when the user subscribes in the app, through a purchase or an offer code, so it can be celebrated.
    /// Restores and renewals don't count.
    let newSubscriptionPublisher = PassthroughSubject<Void, Never>()
    
    @Published var fullPriceProducts: [String: Product] = [:]
    @Published var discountProducts: [String: Product] = [:]

    enum ProductsLoadState {
        case loading
        case loaded
        case failed
    }
    @Published private(set) var productsLoadState: ProductsLoadState = .loading

    @AppStorage("LimitedTimeOfferStartTimeKey") private var limitedTimeOfferStart: Double = 0
    var limitedTimeOfferStartDate: Date? {
        get {
            guard limitedTimeOfferStart > 0 else { return nil }
            return Date(timeIntervalSince1970: limitedTimeOfferStart)
        }
        set {
            limitedTimeOfferStart = newValue.map(\.timeIntervalSince1970) ?? 0
        }
    }
    
    private var products: [String: Product] {
        .init(uniqueKeysWithValues: fullPriceProducts.map(\.self) + discountProducts.map(\.self))
    }

    private var updates: Task<Void, Never>? = nil
    
    public static let instance: SubscriptionLevelProvider = {
        .init()
    }()
    
    private init() {
        refreshProducts()
        checkSubscriptionStatus()
        updates = updatesListenerTask()
        listenToServer()
    }

    private func listenToServer() {
        guard let entitlementService = iocContainer.resolve(CarnivorePlusEntitlementService.self) else {
            serverHasAnswered = true
            return
        }

        entitlementService.entitlementPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entitlement in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.serverEntitlement = entitlement
                    self.serverHasAnswered = true
                    self.updateLevel()
                }
            }
            .store(in: &cancellables)

        // Report this device's App Store subscription to each account that signs in, guests included, so it
        // works on the account's other platforms. Also covers launch.
        entitlementService.accountPublisher
            .sink { [weak self] _ in
                Task { await self?.syncWithServer() }
            }
            .store(in: &cancellables)

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.serverAnswerTimeout) { [weak self] in
            MainActor.assumeIsolated {
                guard let self, !self.serverHasAnswered else { return }
                self.serverHasAnswered = true
                self.updateLevel()
            }
        }

        // Carnivore+ from the server ends at its date even if no update arrives while the app is open.
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in MainActor.assumeIsolated { self?.updateLevel() } }
            .store(in: &cancellables)
    }

    /// Sends this device's current App Store subscriptions to the server, plus `signedTransactions` from a
    /// purchase that may not show up in `Transaction.currentEntitlements` yet.
    func syncWithServer(including signedTransactions: [String] = []) async {
        guard let entitlementService = iocContainer.resolve(CarnivorePlusEntitlementService.self) else { return }
        var signed = signedTransactions
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Self.allProductIds.contains(transaction.productID),
               !signed.contains(result.jwsRepresentation) {
                signed.append(result.jwsRepresentation)
            }
        }
        // Nothing to report: the server keeps what other devices told it, and lapsed ones end on their own.
        guard !signed.isEmpty else { return }
        do {
            try await entitlementService.syncAppStoreTransactions(signed)
        } catch {
            print("SubscriptionLevelProvider: couldn't report App Store purchases. \(error.localizedDescription)")
        }
    }
    
    func refreshProducts() {
        Task {
            await loadProducts()
        }
    }
    
    @MainActor
    private func loadProducts() async {
        productsLoadState = .loading
        do {
            // One request for every product, so a failure can't leave one set loaded and the other empty.
            let loaded = try await Product.products(for: Self.allProductIds)
            fullPriceProducts = Self.productsById(loaded, matching: Self.fullPriceProductIds)
            discountProducts = Self.productsById(loaded, matching: Self.discountProductIds)
            // StoreKit can return an empty list instead of throwing (e.g. offline), so treat that as a failure too.
            productsLoadState = loaded.isEmpty ? .failed : .loaded
            print("Loaded products: \(products)")
        } catch {
            print("Failed to load products: \(error)")
            productsLoadState = .failed
        }
    }

    private static func productsById(_ products: [Product], matching ids: [String]) -> [String: Product] {
        Dictionary(
            products.filter { ids.contains($0.id) }.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    private func updatesListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                handle(transactionUpdate: verificationResult)
                // Unfinished transactions (renewals, offer codes, Ask to Buy) are redelivered on every launch.
                if case .verified(let transaction) = verificationResult {
                    await transaction.finish()
                    if Self.allProductIds.contains(transaction.productID) {
                        await syncWithServer(including: [verificationResult.jwsRepresentation])
                    }
                }
            }
        }
    }
        
    private func checkSubscriptionStatus() {
        subscriptionLevel = SubscriptionLevel(rawValue: UserDefaults.standard.string(forKey: subscriptionLevelKey) ?? "") ?? .none
        
        Task(priority: .userInitiated) {
            await set(subscriptionLevel: await isSubscribed() ? .carnivorePlus : .none)
        }
    }
    
    func isSubscribed() async -> Bool {
        // Check every entitlement: returning on the first one gave a wrong "false" when an
        // entitlement for some other product (e.g. the legacy food logging subscription) came first.
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, Self.allProductIds.contains(transaction.productID) {
                return true
            }
        }
        return false
    }
    
    private func handle(transactionUpdate verificationResult: VerificationResult<StoreKit.Transaction>) {
        print("SubscriptionManager; handle(updatedTransaction:)")
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }
        guard Self.allProductIds.contains(transaction.productID) else {
            // Ignore transactions we don't know how to handle.
            return
        }


        if let _ = transaction.revocationDate {
            // Remove access to the product identified by transaction.productID.
            // Transaction.revocationReason provides details about
            // the revoked transaction.
            Task {
                await set(subscriptionLevel: .none)
            }
        } else if let expirationDate = transaction.expirationDate,
            expirationDate < Date() {
            // Do nothing, this subscription is expired.
            return
        } else if transaction.isUpgraded {
            // Do nothing, there is an active transaction
            // for a higher level of service.
            return
        } else {
            // Provide access to the product identified by
            // transaction.productID.
            if Self.allProductIds.contains(transaction.productID) {
                Task {
                    await set(subscriptionLevel: .carnivorePlus)
                }
            }
        }
    }
    
    /// `source` is what opened the paywall, logged with the outcome so subscriptions can be traced to it.
    func purchase(productId: String, source: PaywallSource) async throws -> Bool {
        let analytics = iocContainer.resolve(Analytics.self)
        analytics?.logPurchaseTapped(productId: productId, source: source)
        func fail(_ reason: PurchaseFailureReason, _ error: Error) -> Error {
            analytics?.logPurchaseFailed(productId: productId, source: source, reason: reason)
            return error
        }

        guard let product = products[productId] else {
            throw fail(.productNotFound, SubscriptionError.productNotFound)
        }

        let result: Product.PurchaseResult
        do {
            result = try await product.purchase()
        } catch {
            throw fail(.storeError, error)
        }

        switch result {
        case .success(let verification):
            // Check if the transaction is verified
            switch verification {
            case .verified(let transaction):
                // Update the user's subscription status
                await set(subscriptionLevel: .carnivorePlus)
                analytics?.logTransaction(transaction)
                analytics?.logPurchaseCompleted(productId: productId, source: source)
                await transaction.finish()
                newSubscriptionPublisher.send()
                Task { await syncWithServer(including: [verification.jwsRepresentation]) }
                return true
            case .unverified:
                throw fail(.verificationFailed, SubscriptionError.verificationFailed)
            }
        case .userCancelled:
            analytics?.logPurchaseCancelled(productId: productId, source: source)
            // Leave the level alone: an existing subscriber who opens the paywall and cancels must keep Carnivore+.
            return false
        case .pending:
            throw fail(.pending, SubscriptionError.pending)
        @unknown default:
            throw fail(.unknown, SubscriptionError.unknown)
        }
    }

    func restorePurchases(source: PaywallSource) async throws {
        try? await AppStore.sync()
        let isSubscribed = await isSubscribed()
        iocContainer.resolve(Analytics.self)?.logPurchasesRestored(source: source, found: isSubscribed)
        await set(subscriptionLevel: isSubscribed ? .carnivorePlus : .none)
        await syncWithServer()
    }

    /// Called once the offer code sheet closes. Logs a redemption if the user now subscribes. The subscription
    /// itself arrives through `Transaction.updates`.
    func offerCodeSheetClosed(source: PaywallSource) async {
        if await isSubscribed() {
            iocContainer.resolve(Analytics.self)?.logOfferCodeRedeemed(source: source)
            newSubscriptionPublisher.send()
        }
    }

    /// Sets what the App Store says on this device. The admin screen also uses it to try both levels.
    @MainActor
    func set(subscriptionLevel: SubscriptionLevel) {
        storeKitLevel = subscriptionLevel
        storeKitHasAnswered = true
        updateLevel()
    }

    /// Combines the App Store and the server into `subscriptionLevel`.
    @MainActor
    private func updateLevel(now: Date = .now) {
        let fromServer = serverEntitlement?.unlocksCarnivorePlus(now: now) == true
        let level: SubscriptionLevel = storeKitLevel == .carnivorePlus || fromServer ? .carnivorePlus : .none

        // Until both have answered, keep the level saved last time unless one already says Carnivore+, so a
        // subscriber from another platform doesn't see the paywall flash up while the server answers.
        guard storeKitHasAnswered && serverHasAnswered else {
            if level == .carnivorePlus { apply(level: level, fromServer: fromServer) }
            return
        }
        apply(level: level, fromServer: fromServer)
        if !hasConfirmedLevel { hasConfirmedLevel = true }
    }

    @MainActor
    private func apply(level: SubscriptionLevel, fromServer: Bool) {
        let source: CarnivorePlusSource? = storeKitLevel == .carnivorePlus
            ? .appStore
            : fromServer ? serverEntitlement?.source : nil
        if carnivorePlusSource != source { carnivorePlusSource = source }
        if subscriptionLevel != level { subscriptionLevel = level }
        UserDefaults.standard.set(level.rawValue, forKey: subscriptionLevelKey)
        iocContainer.resolve(Analytics.self)?.setIsSubscriber(level == .carnivorePlus)
    }
}
