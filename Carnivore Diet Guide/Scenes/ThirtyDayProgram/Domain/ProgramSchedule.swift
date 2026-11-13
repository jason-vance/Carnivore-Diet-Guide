//
//  ProgramSchedule.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation

enum ProgramDayAccess: Equatable {
    case available
    /// Days after the free first week need Carnivore+.
    case needsSubscription
    /// Opens on a later calendar day.
    case upcoming
}

/// Calendar rules for the program. A new day opens at local midnight, whether or not the previous one was finished,
/// because the "what's normal" notes follow how long the user has actually been eating this way.
enum ProgramSchedule {

    static let length = 30
    static let freeDayCount = 7
    static let reviewDays: Set<Int> = [7, 14, 21, 30]

    /// Calendar days since the start, counting the start day as 1. Keeps counting past the end of the program.
    static func elapsedDayNumber(startDate: Date, now: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: now)
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, days + 1)
    }

    /// The program day the user is on, from 1 to 30.
    static func currentDay(startDate: Date, now: Date, calendar: Calendar = .current) -> Int {
        min(length, elapsedDayNumber(startDate: startDate, now: now, calendar: calendar))
    }

    /// True once the calendar has moved past day 30.
    static func isFinished(startDate: Date, now: Date, calendar: Calendar = .current) -> Bool {
        elapsedDayNumber(startDate: startDate, now: now, calendar: calendar) > length
    }

    /// The start date that puts the user on `day` today.
    static func startDate(forCurrentDay day: Int, now: Date, calendar: Calendar = .current) -> Date {
        let clampedDay = min(max(day, 1), length)
        let today = calendar.startOfDay(for: now)
        return calendar.date(byAdding: .day, value: -(clampedDay - 1), to: today) ?? today
    }

    /// The local date a program day falls on.
    static func date(ofDay day: Int, startDate: Date, calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: startDate)
        return calendar.date(byAdding: .day, value: day - 1, to: start) ?? start
    }

    static func requiresSubscription(day: Int) -> Bool {
        day > freeDayCount
    }

    static func access(day: Int, currentDay: Int, isSubscribed: Bool) -> ProgramDayAccess {
        if day > currentDay { return .upcoming }
        if requiresSubscription(day: day) && !isSubscribed { return .needsSubscription }
        return .available
    }
}

/// How a measure has moved: the average of the first few ratings against the average of the latest few.
struct ProgramTrend: Equatable {
    /// The `ProgramMeasure` id.
    let measureId: String
    let from: Double
    let to: Double

    var change: Double { to - from }

    static func trend(for metric: ProgramMetric, in progress: ProgramProgress) -> ProgramTrend? {
        trend(for: .metric(metric), in: progress)
    }

    /// Needs at least two ratings. Compares single ratings until there are six, then the first and last three.
    /// Check-ins that didn't rate a tracker are skipped.
    static func trend(for measure: ProgramMeasure, in progress: ProgramProgress) -> ProgramTrend? {
        let ratings = progress.orderedCheckIns.compactMap { measure.rating(in: $0.checkIn) }.map(Double.init)
        guard ratings.count >= 2 else { return nil }

        let sampleSize = ratings.count >= 6 ? 3 : 1
        let first = ratings.prefix(sampleSize)
        let last = ratings.suffix(sampleSize)
        return .init(
            measureId: measure.id,
            from: first.reduce(0, +) / Double(first.count),
            to: last.reduce(0, +) / Double(last.count)
        )
    }
}
