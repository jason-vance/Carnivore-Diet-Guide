//
//  ProgramProgressRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Foundation
import FirebaseFirestore

/// Where an account's program progress is kept, so it follows the user to a new device.
protocol ProgramProgressRepository {
    func fetchProgress(programId: String, userId: String) async throws -> ProgramProgress?
    func save(_ progress: ProgramProgress, programId: String, userId: String) async throws
    func deleteProgress(programId: String, userId: String) async throws
    /// Used when the account is deleted.
    func deleteAllProgress(userId: String) async throws
}

/// Stores progress at `Users/{userId}/Programs/{programId}`. Only the account itself can read or write it
/// (see the Firestore rules in Docs/Firebase).
class FirestoreProgramProgressRepository: ProgramProgressRepository {

    static let PROGRAMS = "Programs"

    private func programsCollection(userId: String) -> CollectionReference {
        Firestore.firestore()
            .collection(FirebaseUserRepository.USERS)
            .document(userId)
            .collection(Self.PROGRAMS)
    }

    func fetchProgress(programId: String, userId: String) async throws -> ProgramProgress? {
        let snapshot = try await programsCollection(userId: userId).document(programId).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: FirestoreProgramProgressDoc.self).toProgress()
    }

    func save(_ progress: ProgramProgress, programId: String, userId: String) async throws {
        // Firestore writes to its local cache right away and sends it when online; this awaits the server ack.
        try await programsCollection(userId: userId)
            .document(programId)
            .setData(from: FirestoreProgramProgressDoc.from(progress))
    }

    func deleteProgress(programId: String, userId: String) async throws {
        try await programsCollection(userId: userId).document(programId).delete()
    }

    func deleteAllProgress(userId: String) async throws {
        let snapshot = try await programsCollection(userId: userId).getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}

struct FirestoreProgramProgressDoc: Codable {

    struct CheckIn: Codable {
        var energy: Int?
        var digestion: Int?
        var sleep: Int?
        var cravings: Int?
        var symptoms: [String]?
        /// Nil when the check-in predates the food question; empty for a strict day.
        var addedFoods: [String]?
        /// Keyed by tracker id.
        var trackerRatings: [String: Int]?
        var note: String?
        var loggedAt: Date?
    }

    struct Tracker: Codable {
        var id: String?
        var name: String?
        var createdAt: Date?
        var removedAt: Date?
        var updatedAt: Date?
    }

    var startDate: Date?
    var goal: String?
    var completedDays: [Int]?
    /// Keyed by day number as a string, since Firestore map keys must be strings.
    var checkIns: [String: CheckIn]?
    var trackers: [Tracker]?
    var updatedAt: Date?

    static func from(_ progress: ProgramProgress) -> FirestoreProgramProgressDoc {
        .init(
            startDate: progress.startDate,
            goal: progress.goal,
            completedDays: progress.completedDays.sorted(),
            checkIns: Dictionary(uniqueKeysWithValues: progress.checkIns.map { day, checkIn in
                (String(day), CheckIn(
                    energy: checkIn.energy,
                    digestion: checkIn.digestion,
                    sleep: checkIn.sleep,
                    cravings: checkIn.cravings,
                    symptoms: checkIn.symptoms.map(\.rawValue).sorted(),
                    addedFoods: checkIn.addedFoods?.map(\.rawValue).sorted(),
                    trackerRatings: checkIn.trackerRatings,
                    note: checkIn.note,
                    loggedAt: checkIn.loggedAt
                ))
            }),
            trackers: progress.trackers.map { tracker in
                Tracker(
                    id: tracker.id,
                    name: tracker.name,
                    createdAt: tracker.createdAt,
                    removedAt: tracker.removedAt,
                    updatedAt: tracker.updatedAt
                )
            },
            updatedAt: progress.updatedAt
        )
    }

    func toProgress() -> ProgramProgress? {
        guard let startDate else { return nil }

        var checkInsByDay: [Int: ProgramCheckIn] = [:]
        for (key, doc) in checkIns ?? [:] {
            guard let day = Int(key),
                  let energy = doc.energy,
                  let digestion = doc.digestion,
                  let sleep = doc.sleep,
                  let cravings = doc.cravings
            else { continue }

            checkInsByDay[day] = ProgramCheckIn(
                energy: energy,
                digestion: digestion,
                sleep: sleep,
                cravings: cravings,
                // Unknown symptoms from a newer app version are dropped rather than failing the whole doc.
                symptoms: Set((doc.symptoms ?? []).compactMap(ProgramSymptom.init(rawValue:))),
                addedFoods: Self.addedFoods(from: doc.addedFoods),
                trackerRatings: doc.trackerRatings?.filter { ProgramMetric.ratingRange.contains($0.value) },
                note: doc.note,
                loggedAt: doc.loggedAt ?? startDate
            )
        }

        return ProgramProgress(
            startDate: startDate,
            goal: goal,
            completedDays: Set(completedDays ?? []),
            checkIns: checkInsByDay,
            trackers: (trackers ?? []).compactMap { doc in
                guard let id = doc.id, let name = doc.name else { return nil }
                let createdAt = doc.createdAt ?? startDate
                return ProgramTracker(
                    id: id,
                    name: name,
                    createdAt: createdAt,
                    removedAt: doc.removedAt,
                    updatedAt: doc.updatedAt ?? createdAt
                )
            },
            updatedAt: updatedAt ?? startDate
        )
    }

    /// Unknown foods from a newer app version are dropped. If that leaves nothing from a list that wasn't empty,
    /// the day is treated as unrecorded rather than misread as strict.
    static func addedFoods(from rawValues: [String]?) -> Set<ProgramFoodGroup>? {
        guard let rawValues else { return nil }
        let known = Set(rawValues.compactMap(ProgramFoodGroup.init(rawValue:)))
        return known.isEmpty && !rawValues.isEmpty ? nil : known
    }
}

class MockProgramProgressRepository: ProgramProgressRepository {

    var stored: [String: ProgramProgress] = [:]

    func fetchProgress(programId: String, userId: String) async throws -> ProgramProgress? {
        stored["\(userId)/\(programId)"]
    }

    func save(_ progress: ProgramProgress, programId: String, userId: String) async throws {
        stored["\(userId)/\(programId)"] = progress
    }

    func deleteProgress(programId: String, userId: String) async throws {
        stored["\(userId)/\(programId)"] = nil
    }

    func deleteAllProgress(userId: String) async throws {
        stored = stored.filter { !$0.key.hasPrefix("\(userId)/") }
    }
}
