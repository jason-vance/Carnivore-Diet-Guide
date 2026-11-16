//
//  ProgramSettingsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import SwinjectAutoregistration

/// Reminder times, which day the user is on, their goal, their own trackers, and starting over.
struct ProgramSettingsView: View {

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @ObservedObject private var subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    @Environment(\.dismiss) private var dismiss

    @State private var morningOn = false
    @State private var morningTime: Date = .now
    @State private var eveningOn = false
    @State private var eveningTime: Date = .now
    @State private var currentDay = 1
    @State private var goal = ""
    @State private var showRestartConfirmation = false
    @State private var showPermissionDenied = false
    @State private var showTrackers = false
    @State private var showMarketing = false

    private var isSubscribed: Bool { subscriptionManager.subscriptionLevel == .carnivorePlus }

    /// Says when the evening reminder comes next if it won't come tonight, so a time picked for later today
    /// doesn't look broken. It's skipped once today's check-in is done.
    private var eveningNote: String? {
        guard eveningOn,
              let progress = store.progress,
              let today = store.currentDay(),
              !store.isFinished(),
              store.access(forDay: today, isSubscribed: isSubscribed) == .available
        else { return nil }

        let calendar = Calendar.current
        let settings = ProgramReminderSettings(
            morning: .init(isEnabled: morningOn, time: morningTime),
            evening: .init(isEnabled: true, time: eveningTime)
        )
        let next = store.nextReminderDate(.evening, settings: settings)
        if let next, calendar.isDateInToday(next) { return nil }

        let isCheckedIn = progress.checkIn(forDay: today) != nil
        guard let next else {
            return isCheckedIn
                ? String(localized: "Today's check-in is done, so there's no evening reminder tonight.")
                : String(localized: "That time has passed today, so there's no evening reminder tonight.")
        }
        let time = next.formatted(date: .omitted, time: .shortened)
        let when = calendar.isDateInTomorrow(next)
            ? String(localized: "tomorrow at \(time)")
            : String(localized: "\(next.formatted(.dateTime.weekday(.wide))) at \(time)")
        return isCheckedIn
            ? String(localized: "Today's check-in is done, so your next evening reminder is \(when).")
            : String(localized: "That time has passed today, so your next evening reminder is \(when).")
    }

    private func load() {
        let settings = store.reminderSettings
        morningOn = settings.morning.isEnabled
        morningTime = settings.morning.time()
        eveningOn = settings.evening.isEnabled
        eveningTime = settings.evening.time()
        currentDay = store.currentDay() ?? 1
        goal = store.progress?.goal ?? ""
    }

    private func save() {
        if currentDay != store.currentDay() {
            store.setCurrentDay(currentDay)
        }
        if goal != (store.progress?.goal ?? "") {
            store.update(goal: goal)
        }

        let settings = ProgramReminderSettings(
            morning: .init(isEnabled: morningOn, time: morningTime),
            evening: .init(isEnabled: eveningOn, time: eveningTime)
        )
        guard settings != store.reminderSettings else {
            dismiss()
            return
        }
        Task {
            let granted = await store.setReminders(settings)
            await MainActor.run {
                if settings.isEnabled && !granted {
                    morningOn = false
                    eveningOn = false
                    showPermissionDenied = true
                } else {
                    dismiss()
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(Color.accentColor)
                Spacer()
                Text("Program Settings")
                    .font(.headline)
                    .foregroundStyle(Color.text)
                Spacer()
                Button("Save") { save() }
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }
            .padding()
            .overlay(alignment: .bottom) { BarDivider() }

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily reminders")
                            .font(.headline)
                            .foregroundStyle(Color.text)
                        ReminderRow(
                            title: String(localized: "Morning"),
                            detail: String(localized: "What to watch for today"),
                            isOn: $morningOn,
                            time: $morningTime
                        )
                        ReminderRow(
                            title: String(localized: "Evening"),
                            detail: String(localized: "A nudge to check in"),
                            isOn: $eveningOn,
                            time: $eveningTime,
                            note: eveningNote
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current day")
                            .font(.headline)
                            .foregroundStyle(Color.text)
                        Stepper(value: $currentDay, in: 1...ProgramSchedule.length) {
                            Text("Today is day \(currentDay)")
                                .foregroundStyle(Color.text)
                        }
                        Text("Move this if you started earlier or later than the app thinks.")
                            .font(.caption)
                            .foregroundStyle(Color.text.opacity(0.6))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why you're doing this")
                            .font(.headline)
                            .foregroundStyle(Color.text)
                        TextField(
                            "Weight loss, energy, gut health, skin...",
                            text: $goal,
                            prompt: Text("Weight loss, energy, gut health, skin...").foregroundStyle(Color.text.opacity(0.4)),
                            axis: .vertical
                        )
                        .lineLimit(1...3)
                        .foregroundStyle(Color.text)
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                                .stroke(Color.text.opacity(0.2), lineWidth: .borderWidthThin)
                        }
                        .onChange(of: goal) { _, newValue in
                            if newValue.count > WhyCarnivore.maxLength {
                                goal = String(newValue.prefix(WhyCarnivore.maxLength))
                            }
                        }
                    }

                    TrackersSection()

                    Button(role: .destructive) {
                        showRestartConfirmation = true
                    } label: {
                        Label("Start Over", systemImage: "arrow.counterclockwise")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.red)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.background)
        .onAppear(perform: load)
        .confirmationDialog(
            "Start over?",
            isPresented: $showRestartConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete My Progress and Start Over", role: .destructive) {
                store.restart()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your check-ins, trackers and completed tasks will be deleted. This can't be undone.")
        }
        .sheet(isPresented: $showTrackers) {
            ProgramTrackersView()
                .presentationBackground(Color.background)
        }
        .fullScreenCover(isPresented: $showMarketing) {
            MarketingView()
        }
        .alert("Notifications are off", isPresented: $showPermissionDenied) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("To get daily reminders, allow notifications for Carnivore Diet Guide in the Settings app.")
        }
    }

    @ViewBuilder private func ReminderRow(
        title: String,
        detail: String,
        isOn: Binding<Bool>,
        time: Binding<Date>,
        note: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: isOn.animation(.snappy)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.text)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                }
            }
            .tint(Color.accentColor)
            if isOn.wrappedValue {
                DatePicker(String(localized: "\(title) time"), selection: time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .tint(Color.accentColor)
                if let note {
                    Label(note, systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    /// Tracker changes save as they're made, separately from this screen's Save button.
    @ViewBuilder private func TrackersSection() -> some View {
        let trackers = store.progress?.activeTrackers ?? []
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("Your trackers")
                    .font(.headline)
                    .foregroundStyle(Color.text)
                Spacer()
                if !isSubscribed {
                    Label("Carnivore+", systemImage: "lock.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.text.opacity(0.6))
                }
            }
            Text(isSubscribed && !trackers.isEmpty
                 ? trackers.map(\.name).formatted(.list(type: .and))
                 : String(localized: "Rate anything else each day, like your sinuses or joints, and see it charted next to the rest."))
                .font(.subheadline)
                .foregroundStyle(Color.text.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
            Button {
                if isSubscribed {
                    showTrackers = true
                } else {
                    iocContainer.resolve(Analytics.self)?.logProgramTrackersLockedTapped(source: .settings)
                    showMarketing = true
                }
            } label: {
                ProgramSecondaryButtonLabel(
                    title: !isSubscribed
                        ? String(localized: "Unlock with Carnivore+")
                        : trackers.isEmpty ? String(localized: "Add a Tracker") : String(localized: "Change Trackers"),
                    systemImage: !isSubscribed ? "lock.fill" : trackers.isEmpty ? "plus" : "slider.horizontal.3"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        let store = ProgramStore.preview(progress: .sample(currentDay: 9))
        iocContainer.autoregister(ProgramStore.self) { store }
    } content: {
        ProgramSettingsView()
    }
}
