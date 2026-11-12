//
//  ProgramCheckInView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import SwinjectAutoregistration

/// The quick daily check-in: four 1-to-5 ratings, any symptoms, and an optional note.
struct ProgramCheckInView: View {

    let dayNumber: Int

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @Environment(\.dismiss) private var dismiss

    @State private var ratings: [ProgramMetric: Int] = [:]
    @State private var symptoms: Set<ProgramSymptom> = []
    @State private var note: String = ""

    private var isComplete: Bool {
        ProgramMetric.allCases.allSatisfy { ratings[$0] != nil }
    }

    private func loadExisting() {
        guard let existing = store.progress?.checkIn(forDay: dayNumber) else { return }
        ratings = Dictionary(uniqueKeysWithValues: ProgramMetric.allCases.map { ($0, existing.rating(for: $0)) })
        symptoms = existing.symptoms
        note = existing.note ?? ""
    }

    private func save() {
        guard isComplete else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let isFirstCheckIn = store.progress?.checkIn(forDay: dayNumber) == nil
        store.save(
            checkIn: .init(
                energy: ratings[.energy] ?? 3,
                digestion: ratings[.digestion] ?? 3,
                sleep: ratings[.sleep] ?? 3,
                cravings: ratings[.cravings] ?? 3,
                symptoms: symptoms,
                note: trimmedNote.isEmpty ? nil : String(trimmedNote.prefix(ProgramCheckIn.maxNoteLength)),
                loggedAt: .now
            ),
            forDay: dayNumber
        )
        if isFirstCheckIn {
            iocContainer.resolve(Analytics.self)?.logProgramCheckIn(day: dayNumber, symptomCount: symptoms.count)
        }
        dismiss()
    }

    var body: some View {
        VStack(spacing: 0) {
            Header()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(ProgramMetric.allCases) { metric in
                        RatingRow(metric)
                    }
                    SymptomPicker()
                    NoteField()
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            Button(action: save) {
                ProgramPrimaryButtonLabel(title: String(localized: "Save Check-in"))
            }
            .disabled(!isComplete)
            .opacity(isComplete ? 1 : 0.5)
            .padding()
        }
        .background(Color.background)
        .onAppear(perform: loadExisting)
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

    @ViewBuilder private func RatingRow(_ metric: ProgramMetric) -> some View {
        let selected = ratings[metric]
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metric.title)
                    .font(.headline)
                    .foregroundStyle(Color.text)
                Spacer()
                Text(selected.map { metric.label(forRating: $0) } ?? String(localized: "Tap to rate"))
                    .font(.subheadline)
                    .foregroundStyle(selected == nil ? Color.text.opacity(0.4) : Color.accentColor)
            }
            HStack(spacing: 8) {
                ForEach(Array(ProgramMetric.ratingRange), id: \.self) { rating in
                    let isSelected = selected == rating
                    Button {
                        withAnimation(.snappy) { ratings[metric] = rating }
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
                    .accessibilityLabel(Text("\(metric.title): \(metric.label(forRating: rating))"))
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            HStack {
                Text(metric.label(forRating: 1))
                Spacer()
                Text(metric.label(forRating: 5))
            }
            .font(.caption)
            .foregroundStyle(Color.text.opacity(0.5))
            .accessibilityHidden(true)
        }
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
                "What did you eat? Anything you noticed?",
                text: $note,
                prompt: Text("What did you eat? Anything you noticed?").foregroundStyle(Color.text.opacity(0.4)),
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
