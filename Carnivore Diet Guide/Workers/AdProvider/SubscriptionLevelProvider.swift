//
//  SubscriptionLevelProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import Foundation
import StoreKit

class SubscriptionLevelProvider {
    
    private let subscriptionLevelKey = "subscriptionLevelKey"

    enum SubscriptionLevel: String {
        case none
        case carnivorePlus
    }
    
    public let carnivorePlusSubscriptionGroupId = "21537446"
    public let carnivorePlusMonthlyId = "carnivorePlus499"
    public let carnivorePlusYearlyId = "carnivorePlusYearly"
    private var subscriptions: [String] { [carnivorePlusMonthlyId, carnivorePlusYearlyId] }
    
    private var updates: Task<Void, Never>? = nil
    
    @Published public private(set) var subscriptionLevel: SubscriptionLevel = .none
    var subscriptionLevelPublisher: Published<SubscriptionLevel>.Publisher { $subscriptionLevel }
    
    public static let instance: SubscriptionLevelProvider = {
        .init()
    }()
    
    private init() {
        checkSubscriptionStatus()
        updates = updatesListenerTask()
    }
    
    private func updatesListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                handle(transactionUpdate: verificationResult)
            }
        }
    }
        
    func checkSubscriptionStatus() {
        subscriptionLevel = SubscriptionLevel(rawValue: UserDefaults.standard.string(forKey: subscriptionLevelKey) ?? "") ?? .none
        
        Task(priority: .userInitiated) {
            var foundTransaction = false
            
            for await verificationResult in Transaction.currentEntitlements {
                if case .verified(let transaction) = verificationResult,
                   carnivorePlusSubscriptionGroupId == transaction.subscriptionGroupID
                {
                    print("SubscriptionManager; found current entitlement")
                    set(subscriptionLevel: .carnivorePlus)
                    foundTransaction = true
                }
            }
            
            if !foundTransaction {
                print("SubscriptionManager; did not find current entitlement")
                set(subscriptionLevel: .none)
            }
        }
    }
    
    func handle(transactionUpdate verificationResult: VerificationResult<Transaction>) {
        print("SubscriptionManager; handle(updatedTransaction:)")
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }
        guard subscriptions.contains(transaction.productID) else {
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
            set(subscriptionLevel: .carnivorePlus)
        }
    }
    
    func set(subscriptionLevel: SubscriptionLevel) {
        self.subscriptionLevel = subscriptionLevel
        UserDefaults.standard.set(subscriptionLevel.rawValue, forKey: subscriptionLevelKey)
    }
}
