//
//  Analytics.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/1/24.
//

import Foundation

protocol Analytics {
    func logScreenView(screenName: String, screenClass: Any)
    func logNutrientLoggerPromoTapped(placement: String)
    func logPremiumCTATapped(placement: PremiumCTAPlacement)
}

class MockAnalytics: Analytics {
    func logScreenView(screenName: String, screenClass: Any) { }
    func logNutrientLoggerPromoTapped(placement: String) { }
    func logPremiumCTATapped(placement: PremiumCTAPlacement) { }
}
