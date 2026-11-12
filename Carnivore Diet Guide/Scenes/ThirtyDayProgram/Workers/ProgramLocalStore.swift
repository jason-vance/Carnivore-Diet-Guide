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
struct ProgramReminderSettings: Codable, Equatable {
    var isEnabled: Bool
    var hour: Int
    var minute: Int

    static let `default` = ProgramReminderSettings(isEnabled: false, hour: 8, minute: 0)

    private static let key = "programReminderSettings"

    static func load(from defaults: UserDefaults = .standard) -> ProgramReminderSettings {
        guard let data = defaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(ProgramReminderSettings.self, from: data)
        else { return .default }
        return settings
    }

    func save(to defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
