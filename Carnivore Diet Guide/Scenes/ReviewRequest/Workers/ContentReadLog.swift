//
//  ContentReadLog.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation

/// Remembers, on this device, which articles and recipes have been opened and on which days.
/// Works the same for guests and signed-in users. Feeds `ReviewRequestTrigger`.
final class ContentReadLog {

    static let shared = ContentReadLog()

    private static let readIdsKey = "contentReadLog.readIds"
    private static let readDaysKey = "contentReadLog.readDays"
    /// Only the thresholds in `ReviewRequestTrigger` matter, so the stored sets stop growing well past them.
    private static let maxStoredIds = 100
    private static let maxStoredDays = 30

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// How many different articles and recipes have been read.
    var readCount: Int { readIds.count }

    /// How many different calendar days something was read on.
    var readingDayCount: Int { readDays.count }

    func recordRead(resourceId: String, on date: Date = .now, calendar: Calendar = .current) {
        var ids = readIds
        if !ids.contains(resourceId), ids.count < Self.maxStoredIds {
            ids.append(resourceId)
            defaults.set(ids, forKey: Self.readIdsKey)
        }

        let day = Self.dayKey(for: date, calendar: calendar)
        var days = readDays
        if !days.contains(day), days.count < Self.maxStoredDays {
            days.append(day)
            defaults.set(days, forKey: Self.readDaysKey)
        }
    }

    private var readIds: [String] { defaults.stringArray(forKey: Self.readIdsKey) ?? [] }
    private var readDays: [String] { defaults.stringArray(forKey: Self.readDaysKey) ?? [] }

    /// "2026-11-11" in the user's calendar, so a day means the user's day.
    private static func dayKey(for date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}
