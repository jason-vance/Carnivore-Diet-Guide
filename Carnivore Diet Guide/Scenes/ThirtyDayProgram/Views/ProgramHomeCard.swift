//
//  ProgramHomeCard.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/12/26.
//

import SwiftUI
import SwinjectAutoregistration

/// The First 30 Days reminder at the top of Home, shown only while the user is partway through the program.
///
/// Until they've checked in today it's a large card with a Check In button that opens the check-in right here.
/// After that, or on a day that needs Carnivore+, it shrinks to a one-line row. Either way, tapping the day opens it
/// on the 30 Days tab. While the 30 Days tab is asking a returning user which day they're on, the row points there
/// instead, even past day 30.
struct ProgramHomeCard: View {

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @ObservedObject private var subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    @Environment(\.scenePhase) private var scenePhase

    /// Refreshed whenever the app comes back to the foreground, so the card moves on to the next day overnight.
    @State private var now: Date = .now
    /// The day whose check-in sheet is open.
    @State private var checkInRoute: ProgramCheckInRoute?
    /// Bumped when today's check-in is saved, to pop the check mark on the collapsed card.
    @State private var checkInSparks = 0
    /// Keeps the big card up while this card's check-in sheet closes, so the user sees it fold away.
    @State private var holdsLargeCard = false

    private var isSubscribed: Bool { subscriptionManager.subscriptionLevel == .carnivorePlus }

    private var isCheckedInToday: Bool {
        guard let progress = store.progress else { return false }
        return progress.checkIn(forDay: ProgramSchedule.currentDay(startDate: progress.startDate, now: now)) != nil
    }

    private func openDay(_ dayNumber: Int, isCheckedIn: Bool) {
        iocContainer.resolve(Analytics.self)?.logProgramHomeCardTapped(day: dayNumber, action: .openDay, isCheckedIn: isCheckedIn)
        store.openDay(dayNumber)
    }

    /// After a check-in from this card, folds the big card into the small one, then pops its check mark.
    private func foldAfterCheckIn() {
        guard holdsLargeCard else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.snappy) { holdsLargeCard = false }
            try? await Task.sleep(for: .milliseconds(350))
            checkInSparks += 1
        }
    }

    private func checkIn(_ dayNumber: Int) {
        iocContainer.resolve(Analytics.self)?.logProgramHomeCardTapped(day: dayNumber, action: .checkIn, isCheckedIn: false)
        checkInRoute = ProgramCheckInRoute(day: dayNumber)
    }

    var body: some View {
        Group {
            if let welcomeBack = store.welcomeBack {
                WelcomeBackReminder(welcomeBack)
            } else if let progress = store.progress, !ProgramSchedule.isFinished(startDate: progress.startDate, now: now) {
                let dayNumber = ProgramSchedule.currentDay(startDate: progress.startDate, now: now)
                let access = ProgramSchedule.access(day: dayNumber, currentDay: dayNumber, isSubscribed: isSubscribed)
                let isCheckedIn = progress.checkIn(forDay: dayNumber) != nil

                Group {
                    if access == .available && (!isCheckedIn || holdsLargeCard) {
                        LargeReminder(dayNumber)
                    } else {
                        SmallReminder(dayNumber, isLocked: access != .available)
                    }
                }
                .animation(.snappy, value: isCheckedIn)
            }
        }
        .onAppear { now = .now }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { now = .now }
        }
        .onChange(of: isCheckedInToday) { wasCheckedIn, isCheckedIn in
            guard isCheckedIn, !wasCheckedIn else { return }
            if checkInRoute != nil {
                // Checked in from this card: fold it once the sheet is out of the way.
                holdsLargeCard = true
            } else {
                Task {
                    try? await Task.sleep(for: .milliseconds(450))
                    checkInSparks += 1
                }
            }
        }
        .sheet(item: $checkInRoute, onDismiss: foldAfterCheckIn) { route in
            ProgramCheckInView(dayNumber: route.day)
                .presentationBackground(Color.background)
        }
    }

    @ViewBuilder private func LargeReminder(_ dayNumber: Int) -> some View {
        let day = FirstThirtyDays.day(dayNumber)

        ProgramCard(tint: Color.accentColor, tintOpacity: 0.12) {
            Button {
                openDay(dayNumber, isCheckedIn: false)
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgramCardHeading(title: String(localized: "Day \(dayNumber) of 30"), systemImage: "list.bullet.clipboard.fill")
                        Text(day.title)
                            .font(.title3.bold())
                            .foregroundStyle(Color.text)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        ProgramProgressBar(day: dayNumber)
                    }
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.text.opacity(0.5))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.pressable)
            .accessibilityLabel(Text("Day \(dayNumber) of 30: \(day.title)"))
            .accessibilityHint(Text("Opens today's lesson"))

            Text("You haven't checked in today. It takes ten seconds.")
                .font(.subheadline)
                .foregroundStyle(Color.text.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)

            Button {
                checkIn(dayNumber)
            } label: {
                ProgramPrimaryButtonLabel(title: String(localized: "Check In"), systemImage: "plus")
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    @ViewBuilder private func WelcomeBackReminder(_ welcomeBack: ProgramWelcomeBack) -> some View {
        Button {
            iocContainer.resolve(Analytics.self)?.logProgramHomeCardTapped(day: welcomeBack.calendarDay, action: .welcomeBack, isCheckedIn: false)
            store.openWelcomeBack()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "hand.wave.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Welcome back to your 30 days")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.text)
                    Text("Which day are you on?")
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.text.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .foregroundStyle(Color.accentColor.opacity(0.12))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
    }

    @ViewBuilder private func SmallReminder(_ dayNumber: Int, isLocked: Bool) -> some View {
        Button {
            openDay(dayNumber, isCheckedIn: !isLocked)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isLocked ? "lock.fill" : "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(isLocked ? Color.text.opacity(0.5) : Color.accentColor)
                    .symbolEffect(.bounce, value: checkInSparks)
                    .overlay {
                        SizzleSparks(trigger: checkInSparks, count: 12, spread: 0.45)
                            .frame(width: 120, height: 120)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(isLocked ? String(localized: "Day \(dayNumber) of 30") : String(localized: "Day \(dayNumber) of 30 · Checked in"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.text)
                    Text(isLocked ? String(localized: "Continue with Carnivore+") : FirstThirtyDays.day(dayNumber).title)
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.text.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .foregroundStyle(Color.text.opacity(0.06))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
    }
}

#Preview("Not checked in") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        let store = ProgramStore.preview(progress: .sample(currentDay: 5))
        iocContainer.autoregister(ProgramStore.self) { store }
    } content: {
        ProgramHomeCard()
            .padding()
            .background(Color.background)
    }
}

#Preview("Checked in") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        var progress = ProgramProgress.sample(currentDay: 5)
        progress.checkIns[5] = progress.checkIns[4]
        let store = ProgramStore.preview(progress: progress)
        iocContainer.autoregister(ProgramStore.self) { store }
    } content: {
        ProgramHomeCard()
            .padding()
            .background(Color.background)
    }
}
