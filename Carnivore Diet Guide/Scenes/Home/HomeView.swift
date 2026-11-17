//
//  HomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeView: View {
    
    private let defaultPadding: CGFloat = 8

    @StateObject private var model = HomeViewModel()
    @ObservedObject private var programStore = iocContainer~>ProgramStore.self
    @State private var selectedTab: HomeMenuBar.HomeMenuTab = .knowledge
    /// Tabs are built the first time they're opened, then kept so each one stays where the user left it. Building
    /// all four at launch froze the app for a second or more before it responded.
    @State private var openedTabs: Set<HomeMenuBar.HomeMenuTab> = []
    /// The big moment being celebrated over everything else.
    @State private var celebration: Celebration?

    private enum Celebration: Equatable {
        case milestone(ProgramMilestone)
        case carnivorePlusWelcome
    }

    /// Waits a moment so whatever was on screen (the check-in sheet, a paywall) has finished closing.
    private func celebrate(_ newCelebration: Celebration) {
        Task {
            try? await Task.sleep(for: .milliseconds(newCelebration == .carnivorePlusWelcome ? 700 : 450))
            withAnimation(.easeIn(duration: 0.2)) { celebration = newCelebration }
        }
    }

    private func endCelebration() {
        if case .milestone(let milestone) = celebration, milestone.isFinish {
            selectedTab = .program
        }
        withAnimation(.easeOut(duration: 0.25)) { celebration = nil }
    }

    private func isBuilt(_ tab: HomeMenuBar.HomeMenuTab) -> Bool {
        tab == selectedTab || openedTabs.contains(tab)
    }
    
    /// Nil for guests.
    private var currentUserId: String? {
        (iocContainer~>CurrentUserIdProvider.self).currentUserId
    }
    
    private func logScreenView(_ selectedTab: HomeMenuBar.HomeMenuTab) {
        guard let analytics = iocContainer.resolve(Analytics.self) else { return }

        var screenName = ""
        var screenClass: Any = KnowledgeBaseView.self
        switch selectedTab {
        case .knowledge:
            screenName = "KnowledgeBaseView"
            screenClass = KnowledgeBaseView.self
        case .program:
            screenName = "ThirtyDayProgramView"
            screenClass = ThirtyDayProgramView.self
        case .recipes:
            screenName = "RecipesView"
            screenClass = RecipesView.self
        case .profile:
            if currentUserId == nil {
                screenName = "GuestProfileView"
                screenClass = GuestProfileView.self
            } else {
                screenName = "UserProfileView"
                screenClass = UserProfileView.self
            }
        }
        
        analytics.logScreenView(screenName: screenName, screenClass: screenClass)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if isBuilt(.knowledge) {
                    KnowledgeBaseView()
                        .opacity(selectedTab == .knowledge ? 1.0 : 0.0)
                }
                if isBuilt(.program) {
                    ThirtyDayProgramView()
                        .opacity(selectedTab == .program ? 1.0 : 0.0)
                }
                if isBuilt(.recipes) {
                    RecipesView()
                        .opacity(selectedTab == .recipes ? 1.0 : 0.0)
                }
                if isBuilt(.profile) {
                    Group {
                        if let currentUserId {
                            UserProfileView(userId: currentUserId)
                        } else {
                            GuestProfileView()
                        }
                    }
                    .opacity(selectedTab == .profile ? 1.0 : 0.0)
                }
            }
            HomeMenuBar(selectedTab: $selectedTab, profileImageUrl: $model.userProfileImageUrl)
        }
        .ignoresSafeArea(.keyboard)
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
        .onChange(of: selectedTab, initial: true) { _, tab in
            openedTabs.insert(tab)
            logScreenView(tab)
        }
        .onChange(of: programStore.pendingOpenProgramTab, initial: true) { _, shouldOpen in
            guard shouldOpen else { return }
            selectedTab = .program
            programStore.pendingOpenProgramTab = false
        }
        // An overlay rather than a sheet, so it can't collide with a sheet or paywall that's closing.
        .overlay {
            switch celebration {
            case .milestone(let milestone):
                ProgramMilestoneView(milestone: milestone, onDone: endCelebration)
                    .transition(.opacity)
            case .carnivorePlusWelcome:
                CarnivorePlusWelcomeView(onDone: endCelebration)
                    .transition(.opacity)
            case nil:
                EmptyView()
            }
        }
        .onChange(of: programStore.pendingMilestone, initial: true) { _, pending in
            guard let pending else { return }
            programStore.pendingMilestone = nil
            celebrate(.milestone(pending))
        }
        .onReceive((iocContainer~>SubscriptionLevelProvider.self).newSubscriptionPublisher.receive(on: RunLoop.main)) {
            celebrate(.carnivorePlusWelcome)
        }
    }
    
    @ViewBuilder func TabItemLabel(text: String, image: String) -> some View {
        LabeledContent(text) {
            Image(systemName: image)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeView()
    }
}
