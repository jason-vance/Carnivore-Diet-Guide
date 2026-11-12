//
//  ProgramDayView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import SwinjectAutoregistration

/// One program day: the lesson, related articles, the task, what's normal, and the check-in.
struct ProgramDayView: View {

    let dayNumber: Int

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @ObservedObject private var subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    @Environment(\.dismiss) private var dismiss

    @State private var articles: [Article] = []
    @State private var symptomArticles: [String: Article] = [:]
    @State private var showCheckIn = false
    @State private var showMarketing = false

    private var day: ProgramDay { FirstThirtyDays.day(dayNumber) }
    private var week: ProgramWeek { FirstThirtyDays.week(containing: dayNumber) }
    private var isSubscribed: Bool { subscriptionManager.subscriptionLevel == .carnivorePlus }
    private var access: ProgramDayAccess { store.access(forDay: dayNumber, isSubscribed: isSubscribed) }
    private var checkIn: ProgramCheckIn? { store.progress?.checkIn(forDay: dayNumber) }
    private var isTaskDone: Bool { store.progress?.isTaskDone(day: dayNumber) ?? false }

    private func loadArticles() async {
        guard let library = iocContainer.resolve(ArticleLibrary.self) else { return }
        var loaded: [Article] = []
        for id in day.articleIds {
            if let article = await library.getArticle(byId: id) {
                loaded.append(article)
            }
        }
        articles = loaded
    }

    private func loadSymptomArticles() async {
        guard let library = iocContainer.resolve(ArticleLibrary.self) else { return }
        for symptom in checkIn?.symptoms ?? [] {
            guard let id = symptom.articleId, symptomArticles[id] == nil else { continue }
            if let article = await library.getArticle(byId: id) {
                symptomArticles[id] = article
            }
        }
    }

    private func toggleTask() {
        let newValue = !isTaskDone
        store.setTask(day: dayNumber, isDone: newValue)
        if newValue {
            iocContainer.resolve(Analytics.self)?.logProgramTaskCompleted(day: dayNumber)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(String(localized: "Day \(dayNumber)"), leadingContent: {
                Button {
                    dismiss()
                } label: {
                    ResourceMenuButtonLabel(sfSymbol: "chevron.backward")
                }
                .accessibilityLabel(Text("Back"))
            })
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Title()
                    switch access {
                    case .available:
                        DayContent()
                    case .needsSubscription:
                        LockedContent()
                    case .upcoming:
                        Text("This day opens on day \(dayNumber) of your program.")
                            .foregroundStyle(Color.text.opacity(0.7))
                    }
                    ProgramDisclaimer()
                        .padding(.top, 8)
                }
                .padding()
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task(id: dayNumber) { await loadArticles() }
        .task(id: checkIn?.symptoms) { await loadSymptomArticles() }
        .sheet(isPresented: $showCheckIn) {
            ProgramCheckInView(dayNumber: dayNumber)
                .presentationBackground(Color.background)
        }
        .fullScreenCover(isPresented: $showMarketing) {
            MarketingView()
        }
        .onAppear {
            iocContainer.resolve(Analytics.self)?.logScreenView(screenName: "ProgramDayView", screenClass: ProgramDayView.self)
        }
    }

    @ViewBuilder private func Title() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Week \(week.number) · \(week.title)")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(Color.accentColor)
            Text(day.title)
                .font(.largeTitle.bold())
                .foregroundStyle(Color.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder private func DayContent() -> some View {
        Text(day.lesson)
            .font(.body)
            .foregroundStyle(Color.text)
            .fixedSize(horizontal: false, vertical: true)

        TaskCard()
        WhatsNormalCard()
        CheckInCard()

        if let checkIn, !checkIn.symptoms.isEmpty {
            SymptomTips(checkIn.symptoms)
        }

        if ProgramSchedule.reviewDays.contains(dayNumber), let progress = store.progress {
            if let goal = progress.goal {
                GoalReminder(goal)
            }
            ProgramTrendsView(progress: progress)
        }

        if !articles.isEmpty {
            ReadMore()
        }

        NextDayLink()
    }

    @ViewBuilder private func TaskCard() -> some View {
        ProgramCard(tint: Color.accentColor, tintOpacity: 0.1) {
            ProgramCardHeading(title: String(localized: "Today's task"), systemImage: "checkmark.circle")
            Text(day.task)
                .foregroundStyle(Color.text)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: toggleTask) {
                Label(
                    isTaskDone ? String(localized: "Done") : String(localized: "Mark as done"),
                    systemImage: isTaskDone ? "checkmark.circle.fill" : "circle"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .contentTransition(.symbolEffect(.replace))
            }
            .padding(.top, 4)
            .sensoryFeedback(.success, trigger: isTaskDone) { _, isDone in isDone }
        }
    }

    @ViewBuilder private func WhatsNormalCard() -> some View {
        ProgramCard {
            ProgramCardHeading(title: String(localized: "What's normal"), systemImage: "stethoscope")
            Text(day.whatsNormal)
                .foregroundStyle(Color.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder private func CheckInCard() -> some View {
        ProgramCard {
            ProgramCardHeading(title: String(localized: "Check-in"), systemImage: "heart.text.square")
            if let checkIn {
                ProgramFlowLayout(spacing: 6) {
                    ForEach(ProgramMetric.allCases) { metric in
                        let rating = checkIn.rating(for: metric)
                        Text("\(metric.title): \(metric.label(forRating: rating))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.text)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background { Capsule().foregroundStyle(Color.text.opacity(0.08)) }
                    }
                }
                if let note = checkIn.note {
                    Text(note)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(Color.text.opacity(0.8))
                }
                Button {
                    showCheckIn = true
                } label: {
                    Text("Edit check-in")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
                .padding(.top, 4)
            } else {
                Text("Ten seconds: rate your energy, digestion, sleep and cravings so you can see how you're changing.")
                    .foregroundStyle(Color.text)
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    showCheckIn = true
                } label: {
                    ProgramPrimaryButtonLabel(title: String(localized: "Check In"), systemImage: "plus")
                }
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder private func SymptomTips(_ symptoms: Set<ProgramSymptom>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("For what you logged")
                .font(.title3.bold())
                .foregroundStyle(Color.text)
            ForEach(ProgramSymptom.allCases.filter { symptoms.contains($0) }) { symptom in
                ProgramCard(
                    tint: symptom.needsMedicalAttention ? Color.red : Color.text,
                    tintOpacity: symptom.needsMedicalAttention ? 0.12 : 0.06
                ) {
                    Label {
                        Text(symptom.title)
                            .font(.headline)
                            .foregroundStyle(Color.text)
                    } icon: {
                        Image(systemName: symptom.needsMedicalAttention ? "exclamationmark.triangle.fill" : "lightbulb")
                            .foregroundStyle(symptom.needsMedicalAttention ? Color.red : Color.accentColor)
                    }
                    Text(symptom.tip)
                        .font(.subheadline)
                        .foregroundStyle(Color.text)
                        .fixedSize(horizontal: false, vertical: true)
                    if let id = symptom.articleId, let article = symptomArticles[id] {
                        NavigationLink(value: article) {
                            Text("Read: \(article.title)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder private func GoalReminder(_ goal: String) -> some View {
        ProgramCard(tint: Color.accentColor, tintOpacity: 0.1) {
            ProgramCardHeading(title: String(localized: "Why you started"), systemImage: "flag")
            Text("\u{201C}\(goal)\u{201D}")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.text)
                .fixedSize(horizontal: false, vertical: true)
            Text("Is it moving? Your check-ins below show the trend.")
                .font(.subheadline)
                .foregroundStyle(Color.text.opacity(0.7))
        }
    }

    @ViewBuilder private func ReadMore() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Read more")
                .font(.title3.bold())
                .foregroundStyle(Color.text)
            ForEach(articles) { article in
                NavigationLink(value: article) {
                    ArticleItemView(article)
                        .articleStyle(.horizontal)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder private func NextDayLink() -> some View {
        let next = dayNumber + 1
        if next <= ProgramSchedule.length {
            switch store.access(forDay: next, isSubscribed: isSubscribed) {
            case .available:
                NavigationLink(value: ProgramDayRoute(day: next)) {
                    ProgramSecondaryButtonLabel(
                        title: String(localized: "Day \(next): \(FirstThirtyDays.day(next).title)"),
                        systemImage: "arrow.right"
                    )
                }
                .buttonStyle(.plain)
            case .needsSubscription:
                Button {
                    iocContainer.resolve(Analytics.self)?.logProgramLockedDayTapped(day: next)
                    showMarketing = true
                } label: {
                    ProgramSecondaryButtonLabel(title: String(localized: "Unlock days 8–30"), systemImage: "lock.fill")
                }
                .buttonStyle(.plain)
            case .upcoming:
                Text("Day \(next) opens tomorrow.")
                    .font(.subheadline)
                    .foregroundStyle(Color.text.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    @ViewBuilder private func LockedContent() -> some View {
        ProgramCard(tint: Color.accentColor, tintOpacity: 0.1) {
            ProgramCardHeading(title: String(localized: "Carnivore+"), systemImage: "lock.fill")
            Text("Week 1 is free. Days 8 to 30 are part of Carnivore+, along with every premium article and recipe.")
                .foregroundStyle(Color.text)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                iocContainer.resolve(Analytics.self)?.logProgramLockedDayTapped(day: dayNumber)
                showMarketing = true
            } label: {
                ProgramPrimaryButtonLabel(title: String(localized: "Unlock the Full 30 Days"))
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        NavigationStack {
            ProgramDayView(dayNumber: 3)
        }
    }
}
