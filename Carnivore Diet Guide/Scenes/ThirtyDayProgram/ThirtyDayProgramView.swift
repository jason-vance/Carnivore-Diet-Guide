//
//  ThirtyDayProgramView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI
import SwinjectAutoregistration

/// The 30 Days tab: an intro before the user starts, then today's day, trends and the full list of days.
struct ThirtyDayProgramView: View {

    @ObservedObject private var store = iocContainer~>ProgramStore.self
    @ObservedObject private var subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    @Environment(\.scenePhase) private var scenePhase

    @State private var navigationPath = NavigationPath()
    @State private var now: Date = .now
    @State private var showStart = false
    @State private var showSettings = false
    @State private var showMarketing = false

    private var isSubscribed: Bool { subscriptionManager.subscriptionLevel == .carnivorePlus }

    private func showPaywall(forDay day: Int) {
        iocContainer.resolve(Analytics.self)?.logProgramLockedDayTapped(day: day)
        showMarketing = true
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                TopBar()
                ScrollView {
                    if let progress = store.progress {
                        Overview(progress)
                            .padding()
                    } else {
                        ProgramIntroView(isSubscribed: isSubscribed) {
                            showStart = true
                        }
                        .padding()
                    }
                }
                .scrollIndicators(.hidden)
                // A fresh scroll view when the program starts or restarts, so it opens at the top.
                .id(store.hasStarted)
            }
            .background(Color.background)
            .navigationDestination(for: ProgramDayRoute.self) { route in
                ProgramDayView(dayNumber: route.day)
            }
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
        .requestsReviewOnReturn(navigationDepth: navigationPath.count)
        .sheet(isPresented: $showStart) {
            ProgramStartView()
                .presentationBackground(Color.background)
        }
        .sheet(isPresented: $showSettings) {
            ProgramSettingsView()
                .presentationBackground(Color.background)
        }
        .fullScreenCover(isPresented: $showMarketing) {
            MarketingView()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            now = .now
            store.rescheduleReminders()
        }
    }

    @ViewBuilder private func TopBar() -> some View {
        if store.hasStarted {
            ScreenTitleBar(String(localized: "30 Days"), trailingContent: {
                Button {
                    showSettings = true
                } label: {
                    ResourceMenuButtonLabel(sfSymbol: "slider.horizontal.3")
                }
                .accessibilityLabel(Text("Program settings"))
            })
        } else {
            ScreenTitleBar(String(localized: "30 Days"))
        }
    }

    @ViewBuilder private func Overview(_ progress: ProgramProgress) -> some View {
        let currentDay = ProgramSchedule.currentDay(startDate: progress.startDate, now: now)
        let isFinished = ProgramSchedule.isFinished(startDate: progress.startDate, now: now)

        VStack(alignment: .leading, spacing: 16) {
            Header(progress, currentDay: currentDay, isFinished: isFinished)
            if isFinished {
                FinishedCard()
            } else {
                TodayCard(progress, currentDay: currentDay)
            }
            ProgramTrendsView(progress: progress)
            ForEach(FirstThirtyDays.weeks) { week in
                WeekSection(week, progress: progress, currentDay: currentDay)
            }
            ProgramDisclaimer()
        }
    }

    @ViewBuilder private func Header(_ progress: ProgramProgress, currentDay: Int, isFinished: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isFinished ? String(localized: "30 of 30 days") : String(localized: "Day \(currentDay) of 30"))
                .font(.largeTitle.bold())
                .foregroundStyle(Color.text)
            ProgressView(value: Double(isFinished ? ProgramSchedule.length : currentDay), total: Double(ProgramSchedule.length))
                .tint(Color.accentColor)
            if let goal = progress.goal {
                Text("Your why: \u{201C}\(goal)\u{201D}")
                    .font(.subheadline)
                    .foregroundStyle(Color.text.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder private func TodayCard(_ progress: ProgramProgress, currentDay: Int) -> some View {
        let day = FirstThirtyDays.day(currentDay)
        let access = ProgramSchedule.access(day: currentDay, currentDay: currentDay, isSubscribed: isSubscribed)

        ProgramCard(tint: Color.accentColor, tintOpacity: 0.12) {
            ProgramCardHeading(title: String(localized: "Today"), systemImage: "sun.max.fill")
            Text(day.title)
                .font(.title2.bold())
                .foregroundStyle(Color.text)
                .fixedSize(horizontal: false, vertical: true)
            if access == .available {
                Text(day.task)
                    .font(.subheadline)
                    .foregroundStyle(Color.text.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    StatusPill(
                        title: progress.isTaskDone(day: currentDay) ? String(localized: "Task done") : String(localized: "Task to do"),
                        isDone: progress.isTaskDone(day: currentDay)
                    )
                    StatusPill(
                        title: progress.checkIn(forDay: currentDay) == nil ? String(localized: "Not checked in") : String(localized: "Checked in"),
                        isDone: progress.checkIn(forDay: currentDay) != nil
                    )
                }
                NavigationLink(value: ProgramDayRoute(day: currentDay)) {
                    ProgramPrimaryButtonLabel(title: String(localized: "Open Day \(currentDay)"), systemImage: "arrow.right")
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            } else {
                Text("You finished the free first week. Days 8 to 30 are part of Carnivore+.")
                    .font(.subheadline)
                    .foregroundStyle(Color.text.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    showPaywall(forDay: currentDay)
                } label: {
                    ProgramPrimaryButtonLabel(title: String(localized: "Unlock Day \(currentDay)"), systemImage: "lock.open.fill")
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder private func FinishedCard() -> some View {
        ProgramCard(tint: Color.accentColor, tintOpacity: 0.12) {
            ProgramCardHeading(title: String(localized: "Finished"), systemImage: "trophy.fill")
            Text("You finished your first 30 days.")
                .font(.title2.bold())
                .foregroundStyle(Color.text)
            Text("Look back at your trends and your why. You can reread any day below, or start over from program settings.")
                .font(.subheadline)
                .foregroundStyle(Color.text.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            NavigationLink(value: ProgramDayRoute(day: ProgramSchedule.length)) {
                ProgramPrimaryButtonLabel(title: String(localized: "Open Day 30"), systemImage: "arrow.right")
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    @ViewBuilder private func StatusPill(title: String, isDone: Bool) -> some View {
        Label(title, systemImage: isDone ? "checkmark.circle.fill" : "circle")
            .font(.caption.weight(.semibold))
            .foregroundStyle(isDone ? Color.accentColor : Color.text.opacity(0.6))
    }

    @ViewBuilder private func WeekSection(_ week: ProgramWeek, progress: ProgramProgress, currentDay: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Week \(week.number) · \(week.title)")
                    .font(.headline)
                    .foregroundStyle(Color.text)
                Spacer()
                if week.number == 1 && !isSubscribed {
                    Text("Free")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                } else if week.number > 1 && !isSubscribed {
                    Label("Carnivore+", systemImage: "lock.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.text.opacity(0.6))
                }
            }
            .padding(.bottom, 8)
            VStack(spacing: 0) {
                ForEach(Array(week.days), id: \.self) { dayNumber in
                    DayRow(dayNumber, progress: progress, currentDay: currentDay)
                    if dayNumber != week.days.upperBound {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .foregroundStyle(Color.text.opacity(0.04))
            }
        }
    }

    @ViewBuilder private func DayRow(_ dayNumber: Int, progress: ProgramProgress, currentDay: Int) -> some View {
        let access = ProgramSchedule.access(day: dayNumber, currentDay: currentDay, isSubscribed: isSubscribed)
        let isDone = progress.isTaskDone(day: dayNumber) || progress.checkIn(forDay: dayNumber) != nil
        let label = DayRowLabel(dayNumber, access: access, isDone: isDone, isToday: dayNumber == currentDay)

        switch access {
        case .available:
            NavigationLink(value: ProgramDayRoute(day: dayNumber)) { label }
                .buttonStyle(.plain)
        case .needsSubscription:
            Button { showPaywall(forDay: dayNumber) } label: { label }
                .buttonStyle(.plain)
        case .upcoming:
            label
                .accessibilityHint(Text("Opens on day \(dayNumber)"))
        }
    }

    private func DayRowLabel(_ dayNumber: Int, access: ProgramDayAccess, isDone: Bool, isToday: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .foregroundStyle(isDone ? Color.accentColor : Color.clear)
                Circle()
                    .stroke(isToday ? Color.accentColor : Color.text.opacity(0.25), lineWidth: .borderWidthMedium)
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.background)
                } else {
                    Text("\(dayNumber)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.text)
                }
            }
            .frame(width: 28, height: 28)

            Text(FirstThirtyDays.day(dayNumber).title)
                .font(.subheadline.weight(isToday ? .bold : .regular))
                .foregroundStyle(Color.text)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 8)

            switch access {
            case .available:
                if isToday {
                    Text("Today")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.background)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background { Capsule().foregroundStyle(Color.accentColor) }
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.text.opacity(0.4))
            case .needsSubscription:
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(Color.text.opacity(0.5))
            case .upcoming:
                EmptyView()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .opacity(access == .upcoming ? 0.45 : 1)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Day \(dayNumber): \(FirstThirtyDays.day(dayNumber).title)"))
        .accessibilityValue(Text(isDone ? String(localized: "Done") : access == .needsSubscription ? String(localized: "Locked") : ""))
    }
}

/// What the tab shows before the user starts.
struct ProgramIntroView: View {

    let isSubscribed: Bool
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your first 30 days on carnivore")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.text)
                    .fixedSize(horizontal: false, vertical: true)
                Text("A guided month that tells you what to do each day and what's normal to feel, so the hard first weeks don't catch you off guard.")
                    .font(.body)
                    .foregroundStyle(Color.text.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 16) {
                Feature(icon: "book", title: String(localized: "A short lesson each day"), detail: String(localized: "Salt, fat, cravings, digestion, eating out, and more, in the order you'll need them."))
                Feature(icon: "checkmark.circle", title: String(localized: "One small task"), detail: String(localized: "Something concrete to do today, from stocking your fridge to trying liver."))
                Feature(icon: "stethoscope", title: String(localized: "What's normal right now"), detail: String(localized: "Headaches in the first week, loose stools while your gut adjusts, and what usually fixes them."))
                Feature(icon: "chart.line.uptrend.xyaxis", title: String(localized: "A 10-second check-in"), detail: String(localized: "Rate your energy, digestion, sleep and cravings, and watch them change."))
            }

            if !isSubscribed {
                Text("Week 1 is free. Days 8 to 30 are included with Carnivore+.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
            }

            Button(action: onStart) {
                ProgramPrimaryButtonLabel(title: String(localized: "Start My 30 Days"))
            }
            .buttonStyle(.plain)

            ProgramCard {
                ProgramCardHeading(title: String(localized: "Before you start"), systemImage: "cross.case", color: Color.red)
                Text(FirstThirtyDays.safetyNote)
                    .font(.subheadline)
                    .foregroundStyle(Color.text)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ProgramDisclaimer()
        }
        .onAppear {
            iocContainer.resolve(Analytics.self)?.logScreenView(screenName: "ProgramIntroView", screenClass: ProgramIntroView.self)
        }
    }

    @ViewBuilder private func Feature(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.text)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Color.text.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview("Not started") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ThirtyDayProgramView()
    }
}

#Preview("Day 9") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        let store = ProgramStore.preview(progress: .sample(currentDay: 9))
        iocContainer.autoregister(ProgramStore.self) { store }
    } content: {
        ThirtyDayProgramView()
    }
}
