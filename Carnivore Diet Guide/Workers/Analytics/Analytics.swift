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
    func logProgramCheckIn(day: Int, symptomCount: Int, trackerCount: Int)
    func logProgramTaskCompleted(day: Int)
    func logProgramLockedDayTapped(day: Int)
    func logProgramHomeCardTapped(day: Int, action: ProgramHomeCardAction, isCheckedIn: Bool)
    /// Tracker names are the user's own health details, so only counts are logged.
    func logProgramTrackerAdded(isSuggestion: Bool, activeCount: Int)
    func logProgramTrackerRemoved(activeCount: Int)
    func logProgramTrackersLockedTapped(source: ProgramTrackersSource)
}

/// What the user tapped on the First 30 Days card on Home.
enum ProgramHomeCardAction: String {
    case checkIn = "check_in"
    case openDay = "open_day"
}

/// Where the user tapped to add their own trackers.
enum ProgramTrackersSource: String {
    case checkIn = "check_in"
    case settings = "settings"
}

class MockAnalytics: Analytics {
    func logScreenView(screenName: String, screenClass: Any) { }
    func logNutrientLoggerPromoTapped(placement: String) { }
    func logPremiumCTATapped(placement: PremiumCTAPlacement) { }
    func logReviewRequested(contentReadCount: Int) { }
    func logProgramStarted(startDay: Int, hasGoal: Bool) { }
    func logProgramCheckIn(day: Int, symptomCount: Int, trackerCount: Int) { }
    func logProgramTaskCompleted(day: Int) { }
    func logProgramLockedDayTapped(day: Int) { }
    func logProgramHomeCardTapped(day: Int, action: ProgramHomeCardAction, isCheckedIn: Bool) { }
    func logProgramTrackerAdded(isSuggestion: Bool, activeCount: Int) { }
    func logProgramTrackerRemoved(activeCount: Int) { }
    func logProgramTrackersLockedTapped(source: ProgramTrackersSource) { }
}
