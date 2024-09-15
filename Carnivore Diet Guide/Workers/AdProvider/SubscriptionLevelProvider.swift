//
//  SubscriptionLevelProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import Foundation

class SubscriptionLevelProvider {
    
    enum SubscriptionLevel {
        case none
        case carnivorePlus
    }
    
    @Published public private(set) var subscriptionLevel: SubscriptionLevel = .none
    var subscriptionLevelPublisher: Published<SubscriptionLevel>.Publisher { $subscriptionLevel }
    
    public static let instance: SubscriptionLevelProvider = {
        .init()
    }()
    
    private init() {}
    
    func set(subscriptionLevel: SubscriptionLevel) {
        self.subscriptionLevel = subscriptionLevel
    }
}
