//
//  ProgramTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/12/26.
//

import Foundation

/// Something the user rates every day on top of energy, digestion, sleep and cravings, like their sinuses or
/// joints. It's rated 1 to 5 like the built-in four, so it gets the same check-in row, chart and trend. Carnivore+.
struct ProgramTracker: Codable, Equatable, Identifiable {
    /// Random and permanent. Ratings are stored under it, so renaming a tracker keeps its history.
    let id: String
    var name: String
    var createdAt: Date
    /// Set when the user stops tracking it. Removed trackers stay in the list, hidden, so their ratings are kept
    /// and an older copy on another device can't bring them back when the two sync.
    var removedAt: Date?
    /// The last time it was added, renamed or removed. When two devices disagree, the later change wins.
    var updatedAt: Date

    var isActive: Bool { removedAt == nil }

    static let maxNameLength = 30
    /// Keeps the check-in short.
    static let maxActive = 5

    /// One-tap names offered when adding a tracker.
    static var suggestions: [String] {
        [
            String(localized: "Sinuses"),
            String(localized: "Joints"),
            String(localized: "Skin"),
            String(localized: "Headaches"),
            String(localized: "Mood"),
            String(localized: "Focus"),
            String(localized: "Bloating"),
        ]
    }

    /// Words for ratings 1 through 5. Every tracker reads worst to best, so 5 always means doing well.
    static var ratingLabels: [String] {
        [String(localized: "Very bad"), String(localized: "Bad"), String(localized: "Okay"), String(localized: "Good"), String(localized: "Great")]
    }

    /// Trims the name, squeezes runs of spaces and cuts it to the maximum length.
    static func cleaned(name: String) -> String {
        let words = name.split(whereSeparator: \.isWhitespace)
        return String(words.joined(separator: " ").prefix(maxNameLength))
    }
}

/// Why a name can't be used for a tracker.
enum ProgramTrackerNameProblem: Equatable {
    case empty
    /// It matches one of the built-in four or a tracker the user already has.
    case alreadyTracked
    /// The user already has the most trackers allowed.
    case tooMany

    var message: String {
        switch self {
        case .empty: return String(localized: "Give it a name.")
        case .alreadyTracked: return String(localized: "That's already in your check-in.")
        case .tooMany: return String(localized: "You can track up to \(ProgramTracker.maxActive) at once. Remove one to add another.")
        }
    }
}

extension ProgramProgress {

    /// Trackers the user hasn't removed, in the order they were added.
    var activeTrackers: [ProgramTracker] {
        trackers.filter(\.isActive).sorted { $0.createdAt < $1.createdAt }
    }

    func tracker(id: String) -> ProgramTracker? {
        trackers.first { $0.id == id }
    }

    /// Why `name` can't be used, or nil if it can. Pass `renaming` to check a new name for an existing tracker.
    func problem(withTrackerName name: String, renaming id: String? = nil) -> ProgramTrackerNameProblem? {
        let cleaned = ProgramTracker.cleaned(name: name)
        guard !cleaned.isEmpty else { return .empty }

        let takenNames = ProgramMetric.allCases.map(\.title) + activeTrackers.filter { $0.id != id }.map(\.name)
        if takenNames.contains(where: { $0.compare(cleaned, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
            return .alreadyTracked
        }
        if id == nil && activeTrackers.count >= ProgramTracker.maxActive {
            return .tooMany
        }
        return nil
    }

    /// Adds a tracker and returns it, or nil if the name can't be used. Adding the name of a tracker the user
    /// removed brings that one back, with its past ratings.
    @discardableResult
    mutating func addTracker(named name: String, now: Date, id: String = UUID().uuidString) -> ProgramTracker? {
        guard problem(withTrackerName: name) == nil else { return nil }
        let cleaned = ProgramTracker.cleaned(name: name)

        if let index = trackers.firstIndex(where: { !$0.isActive && $0.name.compare(cleaned, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
            trackers[index].removedAt = nil
            trackers[index].name = cleaned
            trackers[index].updatedAt = now
            return trackers[index]
        }

        let tracker = ProgramTracker(id: id, name: cleaned, createdAt: now, removedAt: nil, updatedAt: now)
        trackers.append(tracker)
        return tracker
    }

    /// Returns false if the new name can't be used.
    @discardableResult
    mutating func renameTracker(id: String, to name: String, now: Date) -> Bool {
        guard let index = trackers.firstIndex(where: { $0.id == id }),
              problem(withTrackerName: name, renaming: id) == nil
        else { return false }
        trackers[index].name = ProgramTracker.cleaned(name: name)
        trackers[index].updatedAt = now
        return true
    }

    /// Hides the tracker. Its ratings stay in each check-in.
    mutating func removeTracker(id: String, now: Date) {
        guard let index = trackers.firstIndex(where: { $0.id == id }), trackers[index].isActive else { return }
        trackers[index].removedAt = now
        trackers[index].updatedAt = now
    }

    /// The program day a tracker was added on. The check-in asks for it from that day on; earlier days can be
    /// rated but don't have to be.
    func firstDay(of tracker: ProgramTracker, calendar: Calendar = .current) -> Int {
        ProgramSchedule.elapsedDayNumber(startDate: startDate, now: tracker.createdAt, calendar: calendar)
    }

    /// What a check-in asks for and the trends chart can show: the built-in four, then the user's trackers.
    /// Trackers are Carnivore+, so pass false for everyone else. Their ratings are kept for when they subscribe.
    func measures(includingTrackers: Bool) -> [ProgramMeasure] {
        let builtIn = ProgramMetric.allCases.map(ProgramMeasure.metric)
        guard includingTrackers else { return builtIn }
        return builtIn + activeTrackers.map(ProgramMeasure.tracker)
    }

    /// Combines two copies of the same run's trackers. Each tracker keeps its most recent change.
    static func mergedTrackers(_ first: [ProgramTracker], _ second: [ProgramTracker]) -> [ProgramTracker] {
        var byId: [String: ProgramTracker] = [:]
        for tracker in first + second {
            if let existing = byId[tracker.id], existing.updatedAt >= tracker.updatedAt { continue }
            byId[tracker.id] = tracker
        }
        return byId.values.sorted { $0.createdAt < $1.createdAt }
    }
}

/// Something rated 1 to 5 in each check-in: one of the built-in four, or a tracker the user added.
enum ProgramMeasure: Equatable, Identifiable {
    case metric(ProgramMetric)
    case tracker(ProgramTracker)

    /// The metric's name or the tracker's random id, so the two never collide.
    var id: String {
        switch self {
        case .metric(let metric): return metric.rawValue
        case .tracker(let tracker): return tracker.id
        }
    }

    var title: String {
        switch self {
        case .metric(let metric): return metric.title
        case .tracker(let tracker): return tracker.name
        }
    }

    /// For use mid-sentence. Built-in names are lowercased; the user's own are left as typed, so "IBS" stays "IBS".
    var inlineTitle: String {
        switch self {
        case .metric(let metric): return metric.title.lowercased()
        case .tracker(let tracker): return tracker.name
        }
    }

    var ratingLabels: [String] {
        switch self {
        case .metric(let metric): return metric.ratingLabels
        case .tracker: return ProgramTracker.ratingLabels
        }
    }

    func label(forRating rating: Int) -> String {
        let labels = ratingLabels
        let index = min(max(rating, 1), labels.count) - 1
        return labels[index]
    }

    /// Nil when a tracker wasn't rated that day.
    func rating(in checkIn: ProgramCheckIn) -> Int? {
        switch self {
        case .metric(let metric): return checkIn.rating(for: metric)
        case .tracker(let tracker): return checkIn.rating(forTracker: tracker.id)
        }
    }
}
