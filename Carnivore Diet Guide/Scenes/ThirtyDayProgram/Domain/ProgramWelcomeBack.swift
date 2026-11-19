//
//  ProgramWelcomeBack.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/18/26.
//

import Foundation

/// Someone back with Carnivore+ after days of the program they couldn't open: stopped at the Day 8 paywall, or
/// their Carnivore+ lapsed partway through.
///
/// The days kept counting while they were away, which is right if they kept eating carnivore, since each day's
/// notes follow how long they've been eating this way. If they stopped, they should pick up the day after they
/// left off. Only they know which, so the 30 Days tab asks. `ProgramStore` decides when.
struct ProgramWelcomeBack: Equatable {

    /// The last day they checked in or did the task. Nil if they never did either.
    let leftOffDay: Int?
    /// The day the calendar puts them on. Past 30 once the program has run out.
    let calendarDay: Int

    /// Away for at least this many days before it's worth asking. Missing a single day isn't.
    static let minimumDaysAway = 2

    /// The day they'd pick up on if they stopped eating carnivore while away.
    var pickUpDay: Int { (leftOffDay ?? 0) + 1 }

    /// Days the calendar moved on past where they'd pick up.
    var daysAway: Int { calendarDay - pickUpDay }

    var isPastEnd: Bool { calendarDay > ProgramSchedule.length }

    /// Nil when there's nothing to ask: they've been back long enough to check in, or they weren't gone long.
    init?(progress: ProgramProgress, now: Date, calendar: Calendar = .current) {
        let calendarDay = ProgramSchedule.elapsedDayNumber(startDate: progress.startDate, now: now, calendar: calendar)
        let activeDays = Set(progress.checkIns.keys).union(progress.completedDays).filter { $0 <= calendarDay }
        self.leftOffDay = activeDays.max()
        self.calendarDay = calendarDay

        guard pickUpDay <= ProgramSchedule.length, daysAway >= Self.minimumDaysAway else { return nil }
    }

    init(leftOffDay: Int?, calendarDay: Int) {
        self.leftOffDay = leftOffDay
        self.calendarDay = calendarDay
    }
}
