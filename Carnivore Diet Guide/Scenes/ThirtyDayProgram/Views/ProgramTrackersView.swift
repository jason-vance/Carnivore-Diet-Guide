//
//  ProgramTrackersView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/12/26.
//

import SwiftUI
import SwinjectAutoregistration

/// Where Carnivore+ subscribers add, rename and remove their own trackers. Changes save right away.
struct ProgramTrackersView: View {

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @Environment(\.dismiss) private var dismiss

    @State private var newName = ""
    @State private var renaming: ProgramTracker?
    @State private var renameText = ""
    @State private var removing: ProgramTracker?

    private var trackers: [ProgramTracker] { store.progress?.activeTrackers ?? [] }
    private var isFull: Bool { trackers.count >= ProgramTracker.maxActive }

    /// Nil until the user types something, so an empty field isn't flagged.
    private var newNameProblem: ProgramTrackerNameProblem? {
        guard !ProgramTracker.cleaned(name: newName).isEmpty else { return nil }
        return store.progress?.problem(withTrackerName: newName)
    }

    private var canAdd: Bool {
        !ProgramTracker.cleaned(name: newName).isEmpty && newNameProblem == nil
    }

    private var suggestions: [String] {
        ProgramTracker.suggestions.filter { store.progress?.problem(withTrackerName: $0) == nil }
    }

    private func add(_ name: String, isSuggestion: Bool) {
        withAnimation(.snappy) {
            guard store.addTracker(named: name) != nil else { return }
            if !isSuggestion { newName = "" }
        }
        iocContainer.resolve(Analytics.self)?.logProgramTrackerAdded(isSuggestion: isSuggestion, activeCount: trackers.count)
    }

    private func remove(_ tracker: ProgramTracker) {
        withAnimation(.snappy) {
            store.removeTracker(id: tracker.id)
        }
        iocContainer.resolve(Analytics.self)?.logProgramTrackerRemoved(activeCount: trackers.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            Header()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Rate anything else you want to watch each day, like your sinuses or joints. Each one gets its own row in your check-in and its own chart in your trends.")
                        .font(.subheadline)
                        .foregroundStyle(Color.text.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)

                    if !trackers.isEmpty {
                        TrackerList()
                    }

                    if isFull {
                        Text(ProgramTrackerNameProblem.tooMany.message)
                            .font(.subheadline)
                            .foregroundStyle(Color.text.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        AddTracker()
                    }

                    Text("Removing a tracker takes it out of your check-in. Its past ratings are kept, and adding the same name again brings them back.")
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.background)
        .alert(
            "Rename tracker",
            isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } }),
            presenting: renaming
        ) { tracker in
            TextField("Name", text: $renameText)
            Button("Save") {
                store.renameTracker(id: tracker.id, to: renameText)
            }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("Its past ratings stay with it.")
        }
        .confirmationDialog(
            removing.map { String(localized: "Stop tracking \($0.name)?") } ?? "",
            isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } }),
            titleVisibility: .visible,
            presenting: removing
        ) { tracker in
            Button("Stop Tracking", role: .destructive) { remove(tracker) }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("It leaves your check-in and charts. Your past ratings are kept.")
        }
        .onAppear {
            iocContainer.resolve(Analytics.self)?.logScreenView(screenName: "ProgramTrackersView", screenClass: ProgramTrackersView.self)
        }
    }

    @ViewBuilder private func Header() -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Carnivore+")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.text.opacity(0.6))
                Text("Your trackers")
                    .font(.title2.bold())
                    .foregroundStyle(Color.text)
            }
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
    }

    @ViewBuilder private func TrackerList() -> some View {
        VStack(spacing: 0) {
            ForEach(trackers) { tracker in
                TrackerRow(tracker)
                if tracker.id != trackers.last?.id {
                    Divider().padding(.leading, 16)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .foregroundStyle(Color.text.opacity(0.06))
        }
    }

    @ViewBuilder private func TrackerRow(_ tracker: ProgramTracker) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(tracker.name)
                    .font(.headline)
                    .foregroundStyle(Color.text)
                if let firstDay = store.progress?.firstDay(of: tracker) {
                    Text("Since day \(firstDay)")
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                }
            }
            Spacer(minLength: 8)
            Button {
                renameText = tracker.name
                renaming = tracker
            } label: {
                Image(systemName: "pencil")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Rename \(tracker.name)"))
            Button {
                removing = tracker
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.red)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Stop tracking \(tracker.name)"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder private func AddTracker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // The problem sits beside the heading, not under the field, where the keyboard would cover it.
            HStack(alignment: .firstTextBaseline) {
                Text("Add a tracker")
                    .font(.headline)
                    .foregroundStyle(Color.text)
                Spacer(minLength: 8)
                if let newNameProblem {
                    Text(newNameProblem.message)
                        .font(.caption)
                        .foregroundStyle(Color.red)
                        .multilineTextAlignment(.trailing)
                }
            }
            HStack(spacing: 8) {
                TextField(
                    "Name",
                    text: $newName,
                    prompt: Text("Sinuses, knees, eczema…").foregroundStyle(Color.text.opacity(0.4))
                )
                .foregroundStyle(Color.text)
                .submitLabel(.done)
                .onSubmit { if canAdd { add(newName, isSuggestion: false) } }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                        .stroke(Color.text.opacity(0.2), lineWidth: .borderWidthThin)
                }
                .onChange(of: newName) { _, value in
                    if value.count > ProgramTracker.maxNameLength {
                        newName = String(value.prefix(ProgramTracker.maxNameLength))
                    }
                }
                Button {
                    add(newName, isSuggestion: false)
                } label: {
                    Text("Add")
                        .font(.headline)
                        .foregroundStyle(Color.background)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                                .foregroundStyle(Color.accentColor.gradient)
                        }
                }
                .buttonStyle(.plain)
                .disabled(!canAdd)
                .opacity(canAdd ? 1 : 0.5)
            }
            if !suggestions.isEmpty {
                Text("Or pick one")
                    .font(.caption)
                    .foregroundStyle(Color.text.opacity(0.6))
                    .padding(.top, 4)
                ProgramFlowLayout(spacing: 8) {
                    ForEach(suggestions, id: \.self) { name in
                        Button {
                            add(name, isSuggestion: true)
                        } label: {
                            Label(name, systemImage: "plus")
                                .font(.subheadline)
                                .foregroundStyle(Color.text)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background {
                                    Capsule().foregroundStyle(Color.text.opacity(0.08))
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Add \(name)"))
                    }
                }
            }
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        var progress = ProgramProgress.sample(currentDay: 12)
        progress.addTracker(named: "Sinuses", now: .now)
        let store = ProgramStore.preview(progress: progress)
        iocContainer.autoregister(ProgramStore.self) { store }
    } content: {
        ProgramTrackersView()
    }
}
