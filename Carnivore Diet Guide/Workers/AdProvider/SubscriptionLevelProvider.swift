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
    private let unverifiedCountKey = "unverifiedCountKey"

    enum SubscriptionLevel: String {
        case none
        case carnivorePlus
    }
    
    public let carnivorePlusSubscriptionGroupId = "21537446"
    public let carnivorePlusMonthlyId = "carnivorePlus499"
    public let carnivorePlusYearlyId = "carnivorePlusYearly"
    private var subscriptions: [String] { [carnivorePlusMonthlyId, carnivorePlusYearlyId] }
    
    @Published public private(set) var subscriptionLevel: SubscriptionLevel = .none
    var subscriptionLevelPublisher: Published<SubscriptionLevel>.Publisher { $subscriptionLevel }
    
    public static let instance: SubscriptionLevelProvider = {
        .init()
    }()
    
    private init() {
        checkSubscriptionStatus()
    }
    
    func checkSubscriptionStatus() {
        subscriptionLevel = SubscriptionLevel(rawValue: UserDefaults.standard.string(forKey: subscriptionLevelKey) ?? "") ?? .none
        
        Task {
            var foundTransaction = false
            
            for await verificationResult in Transaction.currentEntitlements {
                switch verificationResult {
                case .verified(let transaction):
                    if subscriptions.contains(transaction.productID) {
                        handle(verifiedTransaction: transaction)
                        foundTransaction = true
                    }
                case .unverified(let transaction, let error):
                    if subscriptions.contains(transaction.productID) {
                        handle(unverifiedTransaction: transaction, withError: error)
                        foundTransaction = true
                    }
                }
            }
            
            if !foundTransaction {
                set(subscriptionLevel: .none)
                saveVerifiedSubscriptionLevel()
            }
        }
    }
    
    func handle(verifiedTransaction: Transaction) {
        print("SubscriptionManager; Handling verified transaction `\(verifiedTransaction.productID)`.")
        set(subscriptionLevel: .carnivorePlus)
        saveVerifiedSubscriptionLevel()
    }
    
    func handle(unverifiedTransaction: Transaction, withError error: VerificationResult<Transaction>.VerificationError) {
        print("SubscriptionManager; Handling unverified transaction `\(unverifiedTransaction.productID)`. \(error.localizedDescription)")
        set(subscriptionLevel: .carnivorePlus)
        saveUnverifiedSubscriptionLevel()
    }
    
    private func saveVerifiedSubscriptionLevel() {
        UserDefaults.standard.set(subscriptionLevel.rawValue, forKey: subscriptionLevelKey)
        UserDefaults.standard.set(0, forKey: unverifiedCountKey)
    }
    
    private func saveUnverifiedSubscriptionLevel() {
        UserDefaults.standard.set(subscriptionLevel.rawValue, forKey: subscriptionLevelKey)
        let unverifiedCount = UserDefaults.standard.integer(forKey: unverifiedCountKey)
        if unverifiedCount < 3 {
            UserDefaults.standard.set(unverifiedCount + 1, forKey: unverifiedCountKey)
        } else {
            set(subscriptionLevel: .none)
            saveVerifiedSubscriptionLevel()
        }
    }
    
    func set(subscriptionLevel: SubscriptionLevel) {
        self.subscriptionLevel = subscriptionLevel
    }
}
