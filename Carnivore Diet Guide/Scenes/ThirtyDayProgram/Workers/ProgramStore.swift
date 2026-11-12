//
//  ProgramStore.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Combine
import Foundation
import SwinjectAutoregistration

/// The user's First 30 Days progress.
///
/// Progress always lives on the device, so guests can use the program. Once the user is signed in to an account
/// it's also synced to Firestore: on sign-in the two copies are merged (which is how a guest's progress moves into
/// their new account), and every later change is uploaded. Signing out clears the device copy.
///
/// Call the mutating methods from the main thread.
final class ProgramStore: ObservableObject {

    static let programId = "firstThirtyDays"

    @Published private(set) var progress: ProgramProgress?
    @Published private(set) var reminderSettings: ProgramReminderSettings
    /// Set when the user opens a program reminder. HomeView switches to the program tab and clears it.
    @Published var pendingOpenFromReminder: Bool = false

    private let localStore: ProgramLocalStore
    private let repository: ProgramProgressRepository
    private let reminderScheduler: ProgramReminderScheduler
    private let calendar: Calendar

    private var isSubscribed = false
    private var lastSettledAuthState: UserAuthState?
    /// The account progress is currently synced with. Nil for guests, signed-out users and before the first sync.
    private var syncedUserId: String?
    private var syncingUserId: String?
    private var subscriptions = Set<AnyCancellable>()

    static let instance: ProgramStore = {
        let store = ProgramStore(
            localStore: .init(),
            repository: FirestoreProgramProgressRepository(),
            reminderScheduler: .init()
        )
        store.listenForAccountAndSubscriptionChanges()
        return store
    }()

    init(
        localStore: ProgramLocalStore,
        repository: ProgramProgressRepository,
        reminderScheduler: ProgramReminderScheduler,
        calendar: Calendar = .current
    ) {
        self.localStore = localStore
        self.repository = repository
        self.reminderScheduler = reminderScheduler
        self.calendar = calendar
        self.progress = localStore.load()
        self.reminderSettings = .load()
    }

    // MARK: Reading

    var hasStarted: Bool { progress != nil }

    func currentDay(now: Date = .now) -> Int? {
        guard let progress else { return nil }
        return ProgramSchedule.currentDay(startDate: progress.startDate, now: now, calendar: calendar)
    }

    func isFinished(now: Date = .now) -> Bool {
        guard let progress else { return false }
        return ProgramSchedule.isFinished(startDate: progress.startDate, now: now, calendar: calendar)
    }

    func access(forDay day: Int, isSubscribed: Bool, now: Date = .now) -> ProgramDayAccess {
        guard let currentDay = currentDay(now: now) else { return .upcoming }
        return ProgramSchedule.access(day: day, currentDay: currentDay, isSubscribed: isSubscribed)
    }

    /// True when today's day is open but hasn't been checked in yet.
    func needsCheckInToday(isSubscribed: Bool, now: Date = .now) -> Bool {
        guard let progress, let day = currentDay(now: now), !isFinished(now: now) else { return false }
        guard access(forDay: day, isSubscribed: isSubscribed, now: now) == .available else { return false }
        return progress.checkIn(forDay: day) == nil
    }

    // MARK: Changing

    /// Starts the program with today as `day` (1 for people starting today, more for people already under way).
    func start(onDay day: Int, goal: String?, now: Date = .now) {
        commit(ProgramProgress(
            startDate: ProgramSchedule.startDate(forCurrentDay: day, now: now, calendar: calendar),
            goal: Self.cleaned(goal: goal),
            completedDays: [],
            checkIns: [:],
            updatedAt: now
        ))
    }

    func setTask(day: Int, isDone: Bool) {
        guard var progress else { return }
        if isDone {
            progress.completedDays.insert(day)
        } else {
            progress.completedDays.remove(day)
        }
        commit(progress)
    }

    func save(checkIn: ProgramCheckIn, forDay day: Int) {
        guard var progress else { return }
        progress.checkIns[day] = checkIn
        commit(progress)
    }

    func setCurrentDay(_ day: Int, now: Date = .now) {
        guard var progress else { return }
        progress.startDate = ProgramSchedule.startDate(forCurrentDay: day, now: now, calendar: calendar)
        commit(progress)
    }

    func update(goal: String?) {
        guard var progress else { return }
        progress.goal = Self.cleaned(goal: goal)
        commit(progress)
    }

    /// Deletes all progress, on this device and in the account.
    func restart() {
        commit(nil)
    }

    /// Turning reminders on asks for notification permission. Returns false if the user declined.
    @discardableResult
    func setReminders(isEnabled: Bool, hour: Int, minute: Int) async -> Bool {
        var granted = true
        if isEnabled {
            granted = await reminderScheduler.requestAuthorization()
        }
        await MainActor.run {
            reminderSettings = .init(isEnabled: isEnabled && granted, hour: hour, minute: minute)
            reminderSettings.save()
            rescheduleReminders()
        }
        return granted
    }

    /// Call when the app comes to the foreground, so reminders roll forward and respect the Settings toggle.
    func rescheduleReminders(now: Date = .now) {
        reminderScheduler.reschedule(
            progress: progress,
            settings: reminderSettings,
            isSubscribed: isSubscribed,
            notificationsAllowed: (iocContainer.resolve(NotificationService.self)?.shouldSendNotifications) ?? true,
            now: now,
            calendar: calendar
        )
    }

    // MARK: Saving and syncing

    private func commit(_ newProgress: ProgramProgress?, now: Date = .now) {
        var newProgress = newProgress
        newProgress?.updatedAt = now
        progress = newProgress
        localStore.save(newProgress)
        upload(newProgress)
        rescheduleReminders(now: now)
    }

    private func upload(_ progress: ProgramProgress?) {
        guard let userId = syncedUserId else { return }
        let repository = repository
        Task {
            do {
                if let progress {
                    try await repository.save(progress, programId: Self.programId, userId: userId)
                } else {
                    try await repository.deleteProgress(programId: Self.programId, userId: userId)
                }
            } catch {
                print("ProgramStore: upload failed. \(error.localizedDescription)")
            }
        }
    }

    private func listenForAccountAndSubscriptionChanges() {
        iocContainer.resolve(ContentAuthenticationProvider.self)?
            .userAuthStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.onAuthStateChanged(state) }
            .store(in: &subscriptions)

        iocContainer.resolve(SubscriptionLevelProvider.self)?
            .subscriptionLevelPublisher
            .map { $0 == .carnivorePlus }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSubscribed in
                self?.isSubscribed = isSubscribed
                self?.rescheduleReminders()
            }
            .store(in: &subscriptions)
    }

    private func onAuthStateChanged(_ state: UserAuthState) {
        switch state {
        case .working:
            return
        case .loggedIn:
            if let userId = iocContainer.resolve(CurrentUserIdProvider.self)?.currentUserId {
                sync(withAccount: userId)
            }
        case .guest:
            syncedUserId = nil
        case .loggedOut:
            syncedUserId = nil
            // Signing out (or deleting the account) leaves the device for the next person, so drop this
            // account's copy. It's still in the account if they sign back in.
            if lastSettledAuthState == .loggedIn {
                progress = nil
                localStore.save(nil)
                reminderScheduler.cancelAll()
            }
        }
        lastSettledAuthState = state
    }

    private func sync(withAccount userId: String) {
        guard syncedUserId != userId, syncingUserId != userId else { return }
        syncingUserId = userId
        let repository = repository
        let calendar = calendar

        Task {
            do {
                let remote = try await repository.fetchProgress(programId: Self.programId, userId: userId)
                await MainActor.run {
                    // Merge with whatever is on the device now, including changes made while the fetch was running.
                    let merged = ProgramProgress.merge(local: self.progress, remote: remote, calendar: calendar)
                    self.syncingUserId = nil
                    self.syncedUserId = userId
                    if merged != self.progress {
                        self.progress = merged
                        self.localStore.save(merged)
                        self.rescheduleReminders()
                    }
                    if let merged, merged != remote {
                        self.upload(merged)
                    }
                }
            } catch {
                print("ProgramStore: sync failed. \(error.localizedDescription)")
                await MainActor.run { self.syncingUserId = nil }
            }
        }
    }

    // MARK: Account deletion

    /// Removes the account's stored progress. Called before the account itself is deleted.
    func deleteAccountProgress(userId: String) async throws {
        try await repository.deleteAllProgress(userId: userId)
    }

    private static func cleaned(goal: String?) -> String? {
        guard let goal = WhyCarnivore(goal)?.value, !goal.isEmpty else { return nil }
        return goal
    }
}

extension ProgramStore {
    /// A store for previews, with nothing saved to disk or synced.
    static func preview(progress: ProgramProgress?) -> ProgramStore {
        let localStore = ProgramLocalStore(fileURL: nil)
        localStore.save(progress)
        return ProgramStore(
            localStore: localStore,
            repository: MockProgramProgressRepository(),
            reminderScheduler: .init()
        )
    }
}

extension ProgramProgress {
    static func sample(currentDay: Int = 9, now: Date = .now) -> ProgramProgress {
        let checkIns: [Int: ProgramCheckIn] = Dictionary(uniqueKeysWithValues: (1..<currentDay).map { day in
            let improving = min(5, 1 + day / 2)
            return (day, ProgramCheckIn(
                energy: improving,
                digestion: min(5, 2 + day / 3),
                sleep: day % 2 == 0 ? 4 : 3,
                cravings: min(5, 1 + day / 2),
                symptoms: day < 5 ? [.headache, .fatigue] : [],
                note: nil,
                loggedAt: now
            ))
        })
        return ProgramProgress(
            startDate: ProgramSchedule.startDate(forCurrentDay: currentDay, now: now),
            goal: "Lose 20 pounds and stop the afternoon crashes",
            completedDays: Set(1..<currentDay),
            checkIns: checkIns,
            updatedAt: now
        )
    }
}
