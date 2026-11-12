//
//  ProgramStartView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import SwinjectAutoregistration

/// Sets up the program: which day the user is on, their goal, and an optional daily reminder.
struct ProgramStartView: View {

    /// The goal typed during onboarding, kept for guests (signed-in users have it on their profile too).
    static let onboardingGoalKey = "onboardingWhyCarnivore"

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @Environment(\.dismiss) private var dismiss

    @State private var alreadyStarted = false
    @State private var currentDay = 2
    @State private var goal = ""
    @State private var remindersOn = true
    @State private var reminderTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    @State private var isStarting = false

    private func prefillGoal() {
        guard goal.isEmpty else { return }
        if let saved = UserDefaults.standard.string(forKey: Self.onboardingGoalKey), !saved.isEmpty {
            goal = saved
        }
        Task {
            guard iocContainer.resolve(CurrentUserIdProvider.self)?.currentUserId != nil,
                  let userData = try? await iocContainer.resolve(CurrentUserDataProvider.self)?.fetchCurrentUserData(),
                  let why = userData.whyCarnivore?.value, !why.isEmpty
            else { return }
            await MainActor.run {
                if goal.isEmpty { goal = why }
            }
        }
    }

    private func start() {
        isStarting = true
        let day = alreadyStarted ? currentDay : 1
        store.start(onDay: day, goal: goal)
        iocContainer.resolve(Analytics.self)?.logProgramStarted(startDay: day, hasGoal: !goal.trimmingCharacters(in: .whitespaces).isEmpty)

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        Task {
            if remindersOn {
                await store.setReminders(isEnabled: true, hour: components.hour ?? 8, minute: components.minute ?? 0)
            }
            await MainActor.run { dismiss() }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Set up your 30 days")
                    .font(.title2.bold())
                    .foregroundStyle(Color.text)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    ResourceMenuButtonLabel(sfSymbol: "xmark")
                }
                .accessibilityLabel(Text("Close"))
            }
            .padding()
            .overlay(alignment: .bottom) { BarDivider() }

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    StartingPoint()
                    GoalField()
                    Reminder()
                    ProgramCard {
                        ProgramCardHeading(title: String(localized: "Before you start"), systemImage: "cross.case", color: Color.red)
                        Text(FirstThirtyDays.safetyNote)
                            .font(.subheadline)
                            .foregroundStyle(Color.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)

            Button(action: start) {
                ProgramPrimaryButtonLabel(title: String(localized: "Start Day \(alreadyStarted ? currentDay : 1)"))
            }
            .disabled(isStarting)
            .padding()
        }
        .background(Color.background)
        .onAppear(perform: prefillGoal)
    }

    @ViewBuilder private func StartingPoint() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Where are you starting?")
                .font(.headline)
                .foregroundStyle(Color.text)
            ChoiceButton(
                title: String(localized: "Starting today"),
                detail: String(localized: "Today is day 1."),
                isSelected: !alreadyStarted
            ) {
                alreadyStarted = false
            }
            ChoiceButton(
                title: String(localized: "I've already started"),
                detail: String(localized: "Pick up on the day you're on."),
                isSelected: alreadyStarted
            ) {
                alreadyStarted = true
            }
            if alreadyStarted {
                Stepper(value: $currentDay, in: 2...ProgramSchedule.length) {
                    Text("Today is day \(currentDay)")
                        .foregroundStyle(Color.text)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder private func ChoiceButton(
        title: String,
        detail: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.snappy) { action() }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.text.opacity(0.4))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.text)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                }
                Spacer()
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : Color.text.opacity(0.15), lineWidth: .borderWidthMedium)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private func GoalField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why are you doing this?")
                .font(.headline)
                .foregroundStyle(Color.text)
            Text("Optional. We'll show it to you on review days.")
                .font(.caption)
                .foregroundStyle(Color.text.opacity(0.6))
            TextField(
                "Weight loss, energy, gut health, skin...",
                text: $goal,
                prompt: Text("Weight loss, energy, gut health, skin...").foregroundStyle(Color.text.opacity(0.4)),
                axis: .vertical
            )
            .lineLimit(1...3)
            .textInputAutocapitalization(.sentences)
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
    }

    @ViewBuilder private func Reminder() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $remindersOn.animation(.snappy)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily reminder")
                        .font(.headline)
                        .foregroundStyle(Color.text)
                    Text("A nudge with each day's task.")
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                }
            }
            .tint(Color.accentColor)
            if remindersOn {
                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .foregroundStyle(Color.text)
                    .tint(Color.accentColor)
            }
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ProgramStartView()
    }
}
