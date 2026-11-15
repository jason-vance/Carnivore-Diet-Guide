//
//  ProgramLocalStore.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation

/// Keeps program progress on the device, so it works for guests and offline. Pass a nil URL for an in-memory store.
class ProgramLocalStore {

    private let fileURL: URL?
    private var inMemory: ProgramProgress?

    init(fileURL: URL? = ProgramLocalStore.defaultFileURL) {
        self.fileURL = fileURL
    }

    static var defaultFileURL: URL? {
        try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("FirstThirtyDaysProgress.json")
    }

    func load() -> ProgramProgress? {
        guard let fileURL else { return inMemory }
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        do {
            return try JSONDecoder().decode(ProgramProgress.self, from: data)
        } catch {
            print("ProgramLocalStore: couldn't read progress. \(error.localizedDescription)")
            return nil
        }
    }

    func save(_ progress: ProgramProgress?) {
        guard let fileURL else {
            inMemory = progress
            return
        }
        do {
            if let progress {
                let data = try JSONEncoder().encode(progress)
                // Check-ins are health information, so keep them encrypted while the device is locked.
                try data.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
            } else if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("ProgramLocalStore: couldn't save progress. \(error.localizedDescription)")
        }
    }
}

/// Daily reminder preferences. Kept on the device only, since reminders are scheduled per device.
///
/// There are two a day: a morning one with what to watch for that day, and an evening one to check in.
struct ProgramReminderSettings: Codable, Equatable {

    struct Reminder: Codable, Equatable {
        var isEnabled: Bool
        var hour: Int
        var minute: Int
    }

    var morning: Reminder
    var evening: Reminder

    var isEnabled: Bool { morning.isEnabled || evening.isEnabled }

    static let defaultMorning = Reminder(isEnabled: false, hour: 8, minute: 0)
    static let defaultEvening = Reminder(isEnabled: false, hour: 20, minute: 0)
    static let `default` = ProgramReminderSettings(morning: defaultMorning, evening: defaultEvening)

    func reminder(_ kind: ProgramReminderKind) -> Reminder {
        switch kind {
        case .morning: return morning
        case .evening: return evening
        }
    }

    private static let key = "programReminderSettings.v2"
    /// Earlier builds had a single daily reminder, saved here as {isEnabled, hour, minute}.
    private static let legacyKey = "programReminderSettings"

    static func load(from defaults: UserDefaults = .standard) -> ProgramReminderSettings {
        if let data = defaults.data(forKey: key),
           let settings = try? JSONDecoder().decode(ProgramReminderSettings.self, from: data) {
            return settings
        }
        if let data = defaults.data(forKey: legacyKey),
           let legacy = try? JSONDecoder().decode(Reminder.self, from: data) {
            // The old reminder becomes the morning one, and anyone who had it on gets the evening one too.
            return ProgramReminderSettings(
                morning: legacy,
                evening: Reminder(isEnabled: legacy.isEnabled, hour: defaultEvening.hour, minute: defaultEvening.minute)
            )
        }
        return .default
    }

    func save(to defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: Self.key)
        defaults.removeObject(forKey: Self.legacyKey)
    }
}

extension ProgramReminderSettings.Reminder {
    /// From a time picker's date. Only the hour and minute are kept.
    init(isEnabled: Bool, time: Date, calendar: Calendar = .current) {
        let components = calendar.dateComponents([.hour, .minute], from: time)
        self.init(isEnabled: isEnabled, hour: components.hour ?? 0, minute: components.minute ?? 0)
    }

    /// Today at the reminder's time, for a time picker.
    func time(calendar: Calendar = .current, now: Date = .now) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
    }
}
