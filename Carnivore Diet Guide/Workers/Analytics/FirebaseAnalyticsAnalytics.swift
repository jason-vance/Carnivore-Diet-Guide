//
//  FirebaseAnalyticsAnalytics.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/1/24.
//

import Foundation
import FirebaseAnalytics
import StoreKit

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

    func logProgramReminderOpened(day: Int, kind: ProgramReminderKind) {
        FirebaseAnalytics.Analytics.logEvent(
            "program_reminder_opened",
            parameters: ["day": day, "kind": kind.rawValue]
        )
    }

    // MARK: Subscriptions

    func setIsSubscriber(_ isSubscriber: Bool) {
        FirebaseAnalytics.Analytics.setUserProperty(isSubscriber ? "carnivore_plus" : "free", forName: "subscription_level")
    }

    func logTransaction(_ transaction: StoreKit.Transaction) {
        FirebaseAnalytics.Analytics.logTransaction(transaction)
    }

    func logPaywallShown(source: PaywallSource) {
        log("paywall_shown", ["source": source.analyticsValue])
    }

    func logPaywallDismissed(source: PaywallSource) {
        log("paywall_dismissed", ["source": source.analyticsValue])
    }

    func logPurchaseTapped(productId: String, source: PaywallSource) {
        log("purchase_tapped", ["product_id": productId, "source": source.analyticsValue])
    }

    func logPurchaseCompleted(productId: String, source: PaywallSource) {
        log("purchase_completed", ["product_id": productId, "source": source.analyticsValue])
    }

    func logPurchaseCancelled(productId: String, source: PaywallSource) {
        log("purchase_cancelled", ["product_id": productId, "source": source.analyticsValue])
    }

    func logPurchaseFailed(productId: String, source: PaywallSource, reason: PurchaseFailureReason) {
        log("purchase_failed", ["product_id": productId, "source": source.analyticsValue, "reason": reason.rawValue])
    }

    func logPurchasesRestored(source: PaywallSource, found: Bool) {
        log("purchases_restored", ["source": source.analyticsValue, "found": found ? 1 : 0])
    }

    func logOfferCodeRedeemed(source: PaywallSource) {
        log("offer_code_redeemed", ["source": source.analyticsValue])
    }

    // MARK: Content

    func logContentViewed(type: AnalyticsContentType, id: String, title: String, isPremium: Bool) {
        log(AnalyticsEventSelectContent, [
            AnalyticsParameterContentType: type.rawValue,
            AnalyticsParameterItemID: id,
            AnalyticsParameterItemName: Self.parameterValue(title),
            "is_premium": isPremium ? 1 : 0
        ])
    }

    func logContentSearch(type: AnalyticsContentType, category: String?, resultCount: Int, unmatchedText: String?) {
        var parameters: [String: Any] = ["content_type": type.rawValue, "result_count": resultCount]
        if let category { parameters["category"] = Self.parameterValue(category) }
        if let unmatchedText { parameters[AnalyticsParameterSearchTerm] = Self.parameterValue(unmatchedText.lowercased()) }
        log("content_search", parameters)
    }

    // MARK: First 30 Days

    func logProgramFinished(checkInCount: Int, tasksDone: Int) {
        log("program_finished", ["check_in_count": checkInCount, "tasks_done": tasksDone])
    }

    func logProgramMilestoneShown(day: Int) {
        log("program_milestone_shown", ["day": day])
    }

    func logProgramRestarted(day: Int, checkInCount: Int) {
        log("program_restarted", ["day": day, "check_in_count": checkInCount])
    }

    func logProgramRemindersChanged(_ settings: ProgramReminderSettings) {
        var parameters: [String: Any] = [
            "morning": settings.morning.isEnabled ? 1 : 0,
            "evening": settings.evening.isEnabled ? 1 : 0
        ]
        if settings.morning.isEnabled { parameters["morning_hour"] = settings.morning.hour }
        if settings.evening.isEnabled { parameters["evening_hour"] = settings.evening.hour }
        log("program_reminders_changed", parameters)
    }

    func logNotificationPermissionDenied() {
        log("notification_permission_denied", ["source": "program_reminders"])
    }

    // MARK: Helpers

    private func log(_ name: String, _ parameters: [String: Any]) {
        FirebaseAnalytics.Analytics.logEvent(name, parameters: parameters)
    }

    /// Firebase allows parameter values of up to 100 characters.
    private static func parameterValue(_ text: String) -> String {
        String(text.prefix(100))
    }
}
