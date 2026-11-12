//
//  ProgramReminderScheduler.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation
import UserNotifications

/// Schedules one local notification per remaining program day, at the user's chosen time.
class ProgramReminderScheduler {

    static let identifierPrefix = "program.day."

    private var notificationCenter: UNUserNotificationCenter { .current() }

    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("ProgramReminderScheduler: authorization failed. \(error.localizedDescription)")
            return false
        }
    }

    /// Replaces every pending program reminder. Today's reminder is skipped once the user has checked in, and
    /// non-subscribers get reminders through day 8, which tells them week 2 is ready.
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

        let allIdentifiers = (1...ProgramSchedule.length).map { "\(Self.identifierPrefix)\($0)" }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: allIdentifiers)
        requests.forEach { notificationCenter.add($0) }
    }

    func cancelAll() {
        let allIdentifiers = (1...ProgramSchedule.length).map { "\(Self.identifierPrefix)\($0)" }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: allIdentifiers)
    }

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

        return (currentDay...lastDay).compactMap { dayNumber in
            if dayNumber == currentDay && progress.checkIn(forDay: dayNumber) != nil { return nil }

            let day = ProgramSchedule.date(ofDay: dayNumber, startDate: progress.startDate, calendar: calendar)
            guard let fireDate = calendar.date(bySettingHour: settings.hour, minute: settings.minute, second: 0, of: day),
                  fireDate > now
            else { return nil }

            let programDay = FirstThirtyDays.day(dayNumber)
            let content = UNMutableNotificationContent()
            content.title = String(localized: "Day \(dayNumber): \(programDay.title)")
            if ProgramSchedule.requiresSubscription(day: dayNumber) && !isSubscribed {
                content.body = String(localized: "You finished week 1. Week 2 is ready with Carnivore+.")
            } else {
                content.body = programDay.task
            }
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            return UNNotificationRequest(
                identifier: "\(identifierPrefix)\(dayNumber)",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )
        }
    }
}
