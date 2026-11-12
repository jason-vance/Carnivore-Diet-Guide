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
                KnowledgeBaseView()
                    .opacity(selectedTab == .knowledge ? 1.0 : 0.0)
                ThirtyDayProgramView()
                    .opacity(selectedTab == .program ? 1.0 : 0.0)
                RecipesView()
                    .opacity(selectedTab == .recipes ? 1.0 : 0.0)
                Group {
                    if let currentUserId {
                        UserProfileView(userId: currentUserId)
                    } else {
                        GuestProfileView()
                    }
                }
                .opacity(selectedTab == .profile ? 1.0 : 0.0)
            }
            HomeMenuBar(selectedTab: $selectedTab, profileImageUrl: $model.userProfileImageUrl)
        }
        .ignoresSafeArea(.keyboard)
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
        .onChange(of: selectedTab, initial: true) { _, tab in logScreenView(tab) }
        .onChange(of: programStore.pendingOpenFromReminder, initial: true) { _, shouldOpen in
            guard shouldOpen else { return }
            selectedTab = .program
            programStore.pendingOpenFromReminder = false
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
