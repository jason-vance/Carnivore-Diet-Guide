//
//  ProgramReminderScheduler.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation
import UserNotifications

/// The two daily program reminders.
enum ProgramReminderKind: String, CaseIterable {
    /// What's normal and what to watch for today.
    case morning
    /// A nudge to check in on how the day went.
    case evening
}

/// Schedules the morning and evening program reminders for the days ahead, at the user's chosen times.
class ProgramReminderScheduler {

    static let identifierPrefix = "program.day."
    /// iOS keeps at most 64 pending notifications per app, and two a day for the whole program would come close.
    /// Reminders are rescheduled every time the app comes to the foreground, so two weeks ahead is plenty.
    static let daysAhead = 14

    private var notificationCenter: UNUserNotificationCenter { .current() }

    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("ProgramReminderScheduler: authorization failed. \(error.localizedDescription)")
            return false
        }
    }

    /// Replaces every pending program reminder.
    func reschedule(
        progress: ProgramProgress?,
        settings: ProgramReminderSettings,
        isSubscribed: Bool,
        notificationsAllowed: Bool,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let requests = Self.requests(
            progress: progress,
            settings: settings,
            isSubscribed: isSubscribed,
            notificationsAllowed: notificationsAllowed,
            now: now,
            calendar: calendar
        )

        notificationCenter.removePendingNotificationRequests(withIdentifiers: Self.allIdentifiers)
        requests.forEach { notificationCenter.add($0) }
        // An evening reminder that already showed is done once its day has a check-in.
        let checkedInEvenings = (progress?.checkIns.keys).map { $0.map { Self.identifier(day: $0, kind: .evening) } } ?? []
        notificationCenter.removeDeliveredNotifications(withIdentifiers: checkedInEvenings)
    }

    func cancelAll() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: Self.allIdentifiers)
    }

    static func identifier(day: Int, kind: ProgramReminderKind) -> String {
        "\(identifierPrefix)\(day).\(kind.rawValue)"
    }

    /// The day and kind of a program reminder, from its identifier. Reminders from earlier builds, which had one
    /// a day and no kind in the identifier, read as morning ones.
    static func reminder(fromIdentifier identifier: String) -> (day: Int, kind: ProgramReminderKind)? {
        guard identifier.hasPrefix(identifierPrefix) else { return nil }
        let parts = identifier.dropFirst(identifierPrefix.count).split(separator: ".")
        guard let first = parts.first, let day = Int(first) else { return nil }
        let kind = parts.count > 1 ? ProgramReminderKind(rawValue: String(parts[1])) : .morning
        return kind.map { (day: day, kind: $0) }
    }

    /// Every identifier this scheduler could have used, including the one-a-day identifiers of earlier builds.
    private static var allIdentifiers: [String] {
        (1...ProgramSchedule.length).flatMap { day in
            ["\(identifierPrefix)\(day)"] + ProgramReminderKind.allCases.map { identifier(day: day, kind: $0) }
        }
    }

    /// Non-subscribers get reminders through day 8, whose morning reminder tells them week 2 is ready. They get no
    /// evening reminder on a day they can't open. The evening reminder is skipped once today's check-in is done.
    static func requests(
        progress: ProgramProgress?,
        settings: ProgramReminderSettings,
        isSubscribed: Bool,
        notificationsAllowed: Bool,
        now: Date,
        calendar: Calendar
    ) -> [UNNotificationRequest] {
        guard let progress, settings.isEnabled, notificationsAllowed else { return [] }

        let lastDay = isSubscribed ? ProgramSchedule.length : ProgramSchedule.freeDayCount + 1
        let currentDay = ProgramSchedule.currentDay(startDate: progress.startDate, now: now, calendar: calendar)
        guard currentDay <= lastDay else { return [] }
        let windowEnd = min(lastDay, currentDay + daysAhead - 1)

        return (currentDay...windowEnd).flatMap { dayNumber in
            ProgramReminderKind.allCases.compactMap { kind -> UNNotificationRequest? in
                let reminder = settings.reminder(kind)
                guard reminder.isEnabled else { return nil }

                let isLocked = ProgramSchedule.requiresSubscription(day: dayNumber) && !isSubscribed
                if kind == .evening {
                    if isLocked { return nil }
                    if dayNumber == currentDay && progress.checkIn(forDay: dayNumber) != nil { return nil }
                }

                let day = ProgramSchedule.date(ofDay: dayNumber, startDate: progress.startDate, calendar: calendar)
                guard let fireDate = calendar.date(bySettingHour: reminder.hour, minute: reminder.minute, second: 0, of: day),
                      fireDate > now
                else { return nil }

                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
                return UNNotificationRequest(
                    identifier: identifier(day: dayNumber, kind: kind),
                    content: content(kind: kind, dayNumber: dayNumber, isLocked: isLocked),
                    trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                )
            }
        }
    }

    /// The evening text stays general, since notifications show on the lock screen and tracker names can be private.
    private static func content(kind: ProgramReminderKind, dayNumber: Int, isLocked: Bool) -> UNNotificationContent {
        let programDay = FirstThirtyDays.day(dayNumber)
        let content = UNMutableNotificationContent()
        switch kind {
        case .morning:
            content.title = String(localized: "Day \(dayNumber): \(programDay.title)")
            content.body = isLocked
                ? String(localized: "You finished week 1. Week 2 is ready with Carnivore+.")
                : programDay.whatsNormal
        case .evening:
            content.title = String(localized: "How did day \(dayNumber) go?")
            content.body = String(localized: "Take ten seconds to rate your day and note what you ate.")
        }
        content.sound = .default
        return content
    }
}
