//
//  FirebaseAnalyticsAnalytics.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/1/24.
//

import Foundation
import FirebaseAnalytics

class FirebaseAnalyticsAnalytics: Analytics {
    func logScreenView(screenName: String, screenClass: Any) {
        FirebaseAnalytics.Analytics.logEvent(
            AnalyticsEventScreenView,
            parameters: [
                AnalyticsParameterScreenName: screenName,
                AnalyticsParameterScreenClass: String(describing: screenClass)
            ]
        )
    }

    func logNutrientLoggerPromoTapped(placement: String) {
        FirebaseAnalytics.Analytics.logEvent(
            "nutrient_logger_promo_tapped",
            parameters: ["placement": placement]
        )
    }

    func logPremiumCTATapped(placement: PremiumCTAPlacement) {
        FirebaseAnalytics.Analytics.logEvent(
            "premium_cta_tapped",
            parameters: ["placement": placement.rawValue]
        )
    }

    func logReviewRequested(contentReadCount: Int) {
        FirebaseAnalytics.Analytics.logEvent(
            "review_requested",
            parameters: ["content_read_count": contentReadCount]
        )
    }

    func logProgramStarted(startDay: Int, hasGoal: Bool) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_started",
            parameters: ["start_day": startDay, "has_goal": hasGoal ? 1 : 0]
        )
    }

    func logProgramCheckIn(day: Int, symptomCount: Int, trackerCount: Int) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_check_in",
            parameters: ["day": day, "symptom_count": symptomCount, "tracker_count": trackerCount]
        )
    }

    func logProgramTaskCompleted(day: Int) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_task_completed",
            parameters: ["day": day]
        )
    }

    func logProgramLockedDayTapped(day: Int) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_locked_day_tapped",
            parameters: ["day": day]
        )
    }

    func logProgramHomeCardTapped(day: Int, action: ProgramHomeCardAction, isCheckedIn: Bool) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_home_card_tapped",
            parameters: ["day": day, "action": action.rawValue, "checked_in": isCheckedIn ? 1 : 0]
        )
    }

    func logProgramTrackerAdded(isSuggestion: Bool, activeCount: Int) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_tracker_added",
            parameters: ["suggested": isSuggestion ? 1 : 0, "active_count": activeCount]
        )
    }

    func logProgramTrackerRemoved(activeCount: Int) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_tracker_removed",
            parameters: ["active_count": activeCount]
        )
    }

    func logProgramTrackersLockedTapped(source: ProgramTrackersSource) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_trackers_locked_tapped",
            parameters: ["source": source.rawValue]
        )
    }
}
