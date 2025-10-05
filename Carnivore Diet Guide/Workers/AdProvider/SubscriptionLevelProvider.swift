//
//  SubscriptionLevelProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import Foundation
import StoreKit

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

class SubscriptionLevelProvider {
    
    private let subscriptionLevelKey = "subscriptionLevelKey"

    enum SubscriptionLevel: String {
        case none
        case carnivorePlus
    }
    
    static let carnivorePlusSubscriptionGroupId = "21537446"
    static let monthlyProductId = "carnivorePlus499"
    static let yearlyProductId = "carnivorePlusYearly"

    static let productIds = [
        monthlyProductId,
        yearlyProductId,
    ]
    
    @Published public private(set) var subscriptionLevel: SubscriptionLevel = .none
    var subscriptionLevelPublisher: Published<SubscriptionLevel>.Publisher { $subscriptionLevel }
    
    @Published var products: [String: Product] = [:]
    
    private var updates: Task<Void, Never>? = nil
    
    public static let instance: SubscriptionLevelProvider = {
        .init()
    }()
    
    private init() {
        refreshProducts()
        checkSubscriptionStatus()
        updates = updatesListenerTask()
    }
    
    func refreshProducts() {
        Task {
            await loadProducts()
        }
    }
    
    private func loadProducts() async {
        do {
            products = .init(uniqueKeysWithValues: try await Product.products(for: Self.productIds).map { ($0.id, $0) })
            print("Loaded products: \(products)")
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    private func updatesListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                handle(transactionUpdate: verificationResult)
            }
        }
    }
        
    private func checkSubscriptionStatus() {
        subscriptionLevel = SubscriptionLevel(rawValue: UserDefaults.standard.string(forKey: subscriptionLevelKey) ?? "") ?? .none
        
        Task(priority: .userInitiated) {
            set(subscriptionLevel: await isSubscribed() ? .carnivorePlus : .none)
        }
    }
    
    func isSubscribed() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                return Self.productIds.contains(transaction.productID)
            }
        }
        return false
    }
    
    private func handle(transactionUpdate verificationResult: VerificationResult<Transaction>) {
        print("SubscriptionManager; handle(updatedTransaction:)")
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }
        guard Self.productIds.contains(transaction.productID) else {
            // Ignore transactions we don't know how to handle.
            return
        }


        if let _ = transaction.revocationDate {
            // Remove access to the product identified by transaction.productID.
            // Transaction.revocationReason provides details about
            // the revoked transaction.
            set(subscriptionLevel: .none)
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
            if Self.productIds.contains(transaction.productID) {
                set(subscriptionLevel: .carnivorePlus)
            }
        }
    }
    
    func purchase(productId: String? = nil) async throws -> Bool {
        let productId = productId ?? Self.productIds.first!
        guard let product = products[productId] else {
            throw SubscriptionError.productNotFound
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check if the transaction is verified
            switch verification {
            case .verified(let transaction):
                // Update the user's subscription status
                set(subscriptionLevel: .carnivorePlus)
                await transaction.finish()
                return true
            case .unverified:
                throw SubscriptionError.verificationFailed
            }
        case .userCancelled:
            set(subscriptionLevel: .none)
            return false
        case .pending:
            throw SubscriptionError.pending
        @unknown default:
            throw SubscriptionError.unknown
        }
    }
    
    func restorePurchases() async throws {
        try? await AppStore.sync()
        set(subscriptionLevel: await isSubscribed() ? .carnivorePlus : .none)
    }
    
    func set(subscriptionLevel: SubscriptionLevel) {
        self.subscriptionLevel = subscriptionLevel
        UserDefaults.standard.set(subscriptionLevel.rawValue, forKey: subscriptionLevelKey)
    }
}
