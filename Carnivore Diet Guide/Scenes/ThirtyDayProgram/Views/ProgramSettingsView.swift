//
//  ProgramSettingsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import SwinjectAutoregistration

/// Reminder time, which day the user is on, their goal, and starting over.
struct ProgramSettingsView: View {

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @Environment(\.dismiss) private var dismiss

    @State private var remindersOn = false
    @State private var reminderTime: Date = .now
    @State private var currentDay = 1
    @State private var goal = ""
    @State private var showRestartConfirmation = false
    @State private var showPermissionDenied = false

    private func load() {
        let settings = store.reminderSettings
        remindersOn = settings.isEnabled
        reminderTime = Calendar.current.date(bySettingHour: settings.hour, minute: settings.minute, second: 0, of: .now) ?? .now
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

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let hour = components.hour ?? 8
        let minute = components.minute ?? 0
        let settings = store.reminderSettings
        guard settings.isEnabled != remindersOn || settings.hour != hour || settings.minute != minute else {
            dismiss()
            return
        }
        Task {
            let granted = await store.setReminders(isEnabled: remindersOn, hour: hour, minute: minute)
            await MainActor.run {
                if remindersOn && !granted {
                    remindersOn = false
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
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Daily reminder", isOn: $remindersOn.animation(.snappy))
                            .font(.headline)
                            .foregroundStyle(Color.text)
                            .tint(Color.accentColor)
                        if remindersOn {
                            DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .foregroundStyle(Color.text)
                                .tint(Color.accentColor)
                        }
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
            Text("Your check-ins and completed tasks will be deleted. This can't be undone.")
        }
        .alert("Notifications are off", isPresented: $showPermissionDenied) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("To get daily reminders, allow notifications for Carnivore Diet Guide in the Settings app.")
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
