//
//  ProgramCheckInView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import SwinjectAutoregistration

/// The quick daily check-in: four 1-to-5 ratings plus the user's own trackers, what the user ate, any symptoms,
/// and an optional note.
struct ProgramCheckInView: View {

    let dayNumber: Int

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @ObservedObject private var subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    @Environment(\.dismiss) private var dismiss

    /// Keyed by `ProgramMeasure` id. Also holds ratings for trackers that aren't shown (removed ones, or all of
    /// them after Carnivore+ lapses) so editing a check-in doesn't drop them.
    @State private var ratings: [String: Int] = [:]
    @State private var symptoms: Set<ProgramSymptom> = []
    /// Nil until answered. Empty means only meat, fish and eggs.
    @State private var addedFoods: Set<ProgramFoodGroup>? = nil
    @State private var note: String = ""
    @State private var showTrackers = false
    @State private var showMarketing = false

    private var isSubscribed: Bool { subscriptionManager.subscriptionLevel == .carnivorePlus }

    private var measures: [ProgramMeasure] {
        store.progress?.measures(includingTrackers: isSubscribed) ?? ProgramMetric.allCases.map(ProgramMeasure.metric)
    }

    /// The built-in four always, and each tracker from the day it was added. Earlier days can rate a tracker
    /// but don't have to.
    private var requiredMeasures: [ProgramMeasure] {
        measures.filter { measure in
            guard case .tracker(let tracker) = measure, let progress = store.progress else { return true }
            return dayNumber >= progress.firstDay(of: tracker)
        }
    }

    private var hasAllRatings: Bool {
        requiredMeasures.allSatisfy { ratings[$0.id] != nil }
    }

    private var isComplete: Bool {
        hasAllRatings && addedFoods != nil
    }

    /// Says what's still needed, since the food question can sit below the fold on small screens.
    private var missingHint: String? {
        let count = requiredMeasures.count
        switch (!hasAllRatings, addedFoods == nil) {
        case (true, true):
            return count == ProgramMetric.allCases.count
                ? String(localized: "Rate all four and pick what you ate to save.")
                : String(localized: "Rate all \(count) and pick what you ate to save.")
        case (true, false):
            return count == ProgramMetric.allCases.count
                ? String(localized: "Rate all four to save.")
                : String(localized: "Rate all \(count) to save.")
        case (false, true): return String(localized: "Pick what you ate to save.")
        case (false, false): return nil
        }
    }

    private func loadExisting() {
        guard let existing = store.progress?.checkIn(forDay: dayNumber) else { return }
        var loaded = existing.trackerRatings ?? [:]
        for metric in ProgramMetric.allCases {
            loaded[metric.rawValue] = existing.rating(for: metric)
        }
        ratings = loaded
        symptoms = existing.symptoms
        addedFoods = existing.addedFoods
        note = existing.note ?? ""
    }

    private func save() {
        guard isComplete else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let isFirstCheckIn = store.progress?.checkIn(forDay: dayNumber) == nil
        let builtInIds = Set(ProgramMetric.allCases.map(\.rawValue))
        let trackerRatings = ratings.filter { !builtInIds.contains($0.key) }
        store.save(
            checkIn: .init(
                energy: ratings[ProgramMetric.energy.rawValue] ?? 3,
                digestion: ratings[ProgramMetric.digestion.rawValue] ?? 3,
                sleep: ratings[ProgramMetric.sleep.rawValue] ?? 3,
                cravings: ratings[ProgramMetric.cravings.rawValue] ?? 3,
                symptoms: symptoms,
                addedFoods: addedFoods,
                trackerRatings: trackerRatings.isEmpty ? nil : trackerRatings,
                note: trimmedNote.isEmpty ? nil : String(trimmedNote.prefix(ProgramCheckIn.maxNoteLength)),
                loggedAt: .now
            ),
            forDay: dayNumber
        )
        if isFirstCheckIn {
            let ratedTrackerCount = measures.filter { measure in
                guard case .tracker = measure else { return false }
                return ratings[measure.id] != nil
            }.count
            iocContainer.resolve(Analytics.self)?.logProgramCheckIn(day: dayNumber, symptomCount: symptoms.count, trackerCount: ratedTrackerCount)
        }
        dismiss()
    }

    var body: some View {
        VStack(spacing: 0) {
            Header()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(measures) { measure in
                        RatingRow(measure)
                    }
                    TrackersLink()
                    FoodPicker()
                    SymptomPicker()
                    NoteField()
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            VStack(spacing: 8) {
                if let missingHint {
                    Text(missingHint)
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                }
                Button(action: save) {
                    ProgramPrimaryButtonLabel(title: String(localized: "Save Check-in"))
                }
                .disabled(!isComplete)
                .opacity(isComplete ? 1 : 0.5)
            }
            .padding()
        }
        .background(Color.background)
        .onAppear(perform: loadExisting)
        .sheet(isPresented: $showTrackers) {
            ProgramTrackersView()
                .presentationBackground(Color.background)
        }
        .fullScreenCover(isPresented: $showMarketing) {
            MarketingView()
        }
        .onAppear {
            iocContainer.resolve(Analytics.self)?.logScreenView(screenName: "ProgramCheckInView", screenClass: ProgramCheckInView.self)
        }
    }

    @ViewBuilder private func Header() -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(dayNumber) check-in")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.text.opacity(0.6))
                Text("How are you feeling?")
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

    @ViewBuilder private func RatingRow(_ measure: ProgramMeasure) -> some View {
        let selected = ratings[measure.id]
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(measure.title)
                    .font(.headline)
                    .foregroundStyle(Color.text)
                Spacer()
                Text(selected.map { measure.label(forRating: $0) } ?? String(localized: "Tap to rate"))
                    .font(.subheadline)
                    .foregroundStyle(selected == nil ? Color.text.opacity(0.4) : Color.accentColor)
            }
            HStack(spacing: 8) {
                ForEach(Array(ProgramMetric.ratingRange), id: \.self) { rating in
                    let isSelected = selected == rating
                    Button {
                        withAnimation(.snappy) { ratings[measure.id] = rating }
                    } label: {
                        Text("\(rating)")
                            .font(.headline)
                            .foregroundStyle(isSelected ? Color.background : Color.text)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background {
                                RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                                    .foregroundStyle(isSelected ? Color.accentColor : Color.text.opacity(0.08))
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("\(measure.title): \(measure.label(forRating: rating))"))
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            HStack {
                Text(measure.label(forRating: 1))
                Spacer()
                Text(measure.label(forRating: 5))
            }
            .font(.caption)
            .foregroundStyle(Color.text.opacity(0.5))
            .accessibilityHidden(true)
        }
    }

    /// Subscribers open their trackers. Everyone else sees what Carnivore+ adds.
    @ViewBuilder private func TrackersLink() -> some View {
        let hasTrackers = !(store.progress?.activeTrackers.isEmpty ?? true)
        Button {
            if isSubscribed {
                showTrackers = true
            } else {
                iocContainer.resolve(Analytics.self)?.logProgramTrackersLockedTapped(source: .checkIn)
                showMarketing = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: !isSubscribed ? "lock.fill" : hasTrackers ? "slider.horizontal.3" : "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(isSubscribed && hasTrackers ? String(localized: "Change your trackers") : String(localized: "Track something else"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.text)
                    Text(!isSubscribed
                         ? String(localized: "Rate your sinuses, joints or anything else with Carnivore+")
                         : hasTrackers ? String(localized: "Add, rename or remove") : String(localized: "Like your sinuses, joints or skin"))
                        .font(.caption)
                        .foregroundStyle(Color.text.opacity(0.6))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
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
        .buttonStyle(.plain)
    }

    private func toggle(_ food: ProgramFoodGroup) {
        var foods = addedFoods ?? []
        if foods.contains(food) { foods.remove(food) } else { foods.insert(food) }
        // Unpicking the last food goes back to unanswered, so a strict day is always a deliberate tap.
        addedFoods = foods.isEmpty ? nil : foods
    }

    @ViewBuilder private func FoodPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("What did you eat?")
                    .font(.headline)
                    .foregroundStyle(Color.text)
                Spacer()
                Text(addedFoods.map { ProgramStrictness(addedFoods: $0).title } ?? String(localized: "Tap to answer"))
                    .font(.subheadline)
                    .foregroundStyle(addedFoods == nil ? Color.text.opacity(0.4) : Color.accentColor)
            }
            Text("Pick everything you had besides meat, fish and eggs. Butter and other animal fats count as meat.")
                .font(.caption)
                .foregroundStyle(Color.text.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
            ProgramFlowLayout(spacing: 8) {
                Chip(String(localized: "Only meat, fish and eggs"), isSelected: addedFoods?.isEmpty == true) {
                    addedFoods = addedFoods?.isEmpty == true ? nil : []
                }
                ForEach(ProgramFoodGroup.allCases) { food in
                    Chip(food.title, isSelected: addedFoods?.contains(food) == true) {
                        toggle(food)
                    }
                }
            }
        }
    }

    @ViewBuilder private func Chip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy, action)
        } label: {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(isSelected ? Color.background : Color.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .foregroundStyle(isSelected ? Color.accentColor : Color.text.opacity(0.08))
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private func SymptomPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Anything bothering you?")
                .font(.headline)
                .foregroundStyle(Color.text)
            Text("Optional. Pick any that apply and you'll get tips for them.")
                .font(.caption)
                .foregroundStyle(Color.text.opacity(0.6))
            ProgramFlowLayout(spacing: 8) {
                ForEach(ProgramSymptom.allCases) { symptom in
                    let isSelected = symptoms.contains(symptom)
                    Button {
                        withAnimation(.snappy) {
                            if isSelected { symptoms.remove(symptom) } else { symptoms.insert(symptom) }
                        }
                    } label: {
                        Text(symptom.title)
                            .font(.subheadline)
                            .foregroundStyle(isSelected ? Color.background : Color.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                Capsule()
                                    .foregroundStyle(isSelected ? Color.accentColor : Color.text.opacity(0.08))
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }

    @ViewBuilder private func NoteField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note")
                .font(.headline)
                .foregroundStyle(Color.text)
            TextField(
                "Anything else? Meals, stress, workouts…",
                text: $note,
                prompt: Text("Anything else? Meals, stress, workouts…").foregroundStyle(Color.text.opacity(0.4)),
                axis: .vertical
            )
            .lineLimit(2...5)
            .foregroundStyle(Color.text)
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                    .stroke(Color.text.opacity(0.2), lineWidth: .borderWidthThin)
            }
            .onChange(of: note) { _, newValue in
                if newValue.count > ProgramCheckIn.maxNoteLength {
                    note = String(newValue.prefix(ProgramCheckIn.maxNoteLength))
                }
            }
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ProgramCheckInView(dayNumber: 3)
    }
}
