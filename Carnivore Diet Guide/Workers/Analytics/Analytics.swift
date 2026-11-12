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
    func logReviewRequested(contentReadCount: Int)
    func logProgramStarted(startDay: Int, hasGoal: Bool)
    func logProgramCheckIn(day: Int, symptomCount: Int)
    func logProgramTaskCompleted(day: Int)
    func logProgramLockedDayTapped(day: Int)
}

class MockAnalytics: Analytics {
    func logScreenView(screenName: String, screenClass: Any) { }
    func logNutrientLoggerPromoTapped(placement: String) { }
    func logPremiumCTATapped(placement: PremiumCTAPlacement) { }
    func logReviewRequested(contentReadCount: Int) { }
    func logProgramStarted(startDay: Int, hasGoal: Bool) { }
    func logProgramCheckIn(day: Int, symptomCount: Int) { }
    func logProgramTaskCompleted(day: Int) { }
    func logProgramLockedDayTapped(day: Int) { }
}
