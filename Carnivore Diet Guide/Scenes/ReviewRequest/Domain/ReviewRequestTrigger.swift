//
//  ReviewRequestTrigger.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation

/// When to show Apple's rating prompt: once someone has read at least 5 different articles or
/// recipes, across at least 2 days, and has just come back to a list from one. By then they've
/// gotten what the app is for more than once, so the rating reflects real use rather than a first
/// impression. (It used to fire seconds after onboarding, before anything had been read.)
/// Matches Nutrient Logger's `ReviewRequestTrigger`.
enum ReviewRequestTrigger {

    static let lastRequestedDateKey = "lastReviewRequestDate"

    static let minimumContentRead = 5
    static let minimumReadingDays = 2
    /// Apple shows the prompt at most 3 times a year, so asking more often only wastes them.
    static let minimumDaysBetweenRequests = 120

    static func shouldRequest(
        contentReadCount: Int,
        readingDayCount: Int,
        lastRequestedDate: Date?,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        guard contentReadCount >= minimumContentRead, readingDayCount >= minimumReadingDays else { return false }
        guard let lastRequestedDate else { return true }
        let daysSinceLastRequest = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: lastRequestedDate),
            to: calendar.startOfDay(for: now)
        ).day ?? 0
        return daysSinceLastRequest >= minimumDaysBetweenRequests
    }
}
