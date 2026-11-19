//
//  Analytics.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/1/24.
//

import Foundation
import StoreKit

protocol Analytics {
    func logScreenView(screenName: String, screenClass: Any)
    func logNutrientLoggerPromoTapped(placement: String)
    func logPremiumCTATapped(placement: PremiumCTAPlacement)
    func logReviewRequested(contentReadCount: Int)

    // MARK: Subscriptions

    /// Sets whether the user subscribes, so every other event can be split by subscribers and free users.
    func setIsSubscriber(_ isSubscriber: Bool)
    /// Passes a StoreKit 2 purchase to the analytics service for revenue. Unlike StoreKit 1 purchases, these
    /// aren't picked up automatically.
    func logTransaction(_ transaction: StoreKit.Transaction)
    func logPaywallShown(source: PaywallSource)
    /// The user closed the paywall without subscribing.
    func logPaywallDismissed(source: PaywallSource)
    func logPurchaseTapped(productId: String, source: PaywallSource)
    func logPurchaseCompleted(productId: String, source: PaywallSource)
    func logPurchaseCancelled(productId: String, source: PaywallSource)
    func logPurchaseFailed(productId: String, source: PaywallSource, reason: PurchaseFailureReason)
    func logPurchasesRestored(source: PaywallSource, found: Bool)
    func logOfferCodeRedeemed(source: PaywallSource)

    // MARK: Content

    func logContentViewed(type: AnalyticsContentType, id: String, title: String, isPremium: Bool)
    /// The search text is only passed when nothing matched, since article searches can be about health.
    func logContentSearch(type: AnalyticsContentType, category: String?, resultCount: Int, unmatchedText: String?)

    // MARK: First 30 Days

    func logProgramStarted(startDay: Int, hasGoal: Bool)
    func logProgramCheckIn(day: Int, symptomCount: Int, trackerCount: Int)
    func logProgramTaskCompleted(day: Int)
    func logProgramLockedDayTapped(day: Int)
    func logProgramHomeCardTapped(day: Int, action: ProgramHomeCardAction, isCheckedIn: Bool)
    /// Tracker names are the user's own health details, so only counts are logged.
    func logProgramTrackerAdded(isSuggestion: Bool, activeCount: Int)
    func logProgramTrackerRemoved(activeCount: Int)
    func logProgramTrackersLockedTapped(source: ProgramTrackersSource)
    func logProgramReminderOpened(day: Int, kind: ProgramReminderKind)
    /// Logged once the program is past day 30. The counts tell people who saw it through from people who
    /// stopped early and still use the app.
    func logProgramFinished(checkInCount: Int, tasksDone: Int)
    /// The celebration after checking in on day 7, 14, 21 or 30.
    func logProgramMilestoneShown(day: Int)
    func logProgramRestarted(day: Int, checkInCount: Int)
    /// Back with Carnivore+ after days they couldn't open, asked whether they kept eating carnivore. Logged once
    /// per time away. `leftOffDay` is nil if they never checked in or did a task.
    func logProgramWelcomeBackShown(leftOffDay: Int?, calendarDay: Int)
    /// Their answer: stay on the calendar's day, or pick up the day after they left off.
    func logProgramWelcomeBackAnswered(stayedCarnivore: Bool, leftOffDay: Int?, calendarDay: Int)
    func logProgramRemindersChanged(_ settings: ProgramReminderSettings)
    func logNotificationPermissionDenied()
}

/// What opened the Carnivore+ paywall, so a subscription can be traced back to the upsell that led to it.
enum PaywallSource {
    case onboarding
    case limitedTimeOffer
    case premiumCTA(PremiumCTAPlacement)
    /// A premium article opened by someone who doesn't subscribe.
    case premiumArticle
    case premiumRecipe
    case programLockedDay
    case programTrackers(ProgramTrackersSource)

    var analyticsValue: String {
        switch self {
        case .onboarding: "onboarding"
        case .limitedTimeOffer: "limited_time_offer"
        case .premiumCTA(let placement): "cta_\(placement.rawValue)"
        case .premiumArticle: "premium_article"
        case .premiumRecipe: "premium_recipe"
        case .programLockedDay: "program_locked_day"
        case .programTrackers(let source): "program_trackers_\(source.rawValue)"
        }
    }
}

enum PurchaseFailureReason: String {
    case productNotFound = "product_not_found"
    case verificationFailed = "verification_failed"
    /// Waiting on Ask to Buy or a payment problem.
    case pending
    /// StoreKit threw, for example because the App Store couldn't be reached.
    case storeError = "store_error"
    case unknown
}

enum AnalyticsContentType: String {
    case article
    case recipe
}

/// What the user tapped on the First 30 Days card on Home.
enum ProgramHomeCardAction: String {
    case checkIn = "check_in"
    case openDay = "open_day"
    case welcomeBack = "welcome_back"
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
    func setIsSubscriber(_ isSubscriber: Bool) { }
    func logTransaction(_ transaction: StoreKit.Transaction) { }
    func logPaywallShown(source: PaywallSource) { }
    func logPaywallDismissed(source: PaywallSource) { }
    func logPurchaseTapped(productId: String, source: PaywallSource) { }
    func logPurchaseCompleted(productId: String, source: PaywallSource) { }
    func logPurchaseCancelled(productId: String, source: PaywallSource) { }
    func logPurchaseFailed(productId: String, source: PaywallSource, reason: PurchaseFailureReason) { }
    func logPurchasesRestored(source: PaywallSource, found: Bool) { }
    func logOfferCodeRedeemed(source: PaywallSource) { }
    func logContentViewed(type: AnalyticsContentType, id: String, title: String, isPremium: Bool) { }
    func logContentSearch(type: AnalyticsContentType, category: String?, resultCount: Int, unmatchedText: String?) { }
    func logProgramStarted(startDay: Int, hasGoal: Bool) { }
    func logProgramCheckIn(day: Int, symptomCount: Int, trackerCount: Int) { }
    func logProgramTaskCompleted(day: Int) { }
    func logProgramLockedDayTapped(day: Int) { }
    func logProgramHomeCardTapped(day: Int, action: ProgramHomeCardAction, isCheckedIn: Bool) { }
    func logProgramTrackerAdded(isSuggestion: Bool, activeCount: Int) { }
    func logProgramTrackerRemoved(activeCount: Int) { }
    func logProgramTrackersLockedTapped(source: ProgramTrackersSource) { }
    func logProgramReminderOpened(day: Int, kind: ProgramReminderKind) { }
    func logProgramFinished(checkInCount: Int, tasksDone: Int) { }
    func logProgramMilestoneShown(day: Int) { }
    func logProgramRestarted(day: Int, checkInCount: Int) { }
    func logProgramWelcomeBackShown(leftOffDay: Int?, calendarDay: Int) { }
    func logProgramWelcomeBackAnswered(stayedCarnivore: Bool, leftOffDay: Int?, calendarDay: Int) { }
    func logProgramRemindersChanged(_ settings: ProgramReminderSettings) { }
    func logNotificationPermissionDenied() { }
}
