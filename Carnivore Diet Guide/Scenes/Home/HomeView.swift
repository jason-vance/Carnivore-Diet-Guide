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
    @State private var selectedTab: HomeMenuBar.HomeMenuTab = .feed
    
    private var currentUserId: String {
        (iocContainer~>CurrentUserIdProvider.self).currentUserId!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                FeedView()
                    .opacity(selectedTab == .feed ? 1.0 : 0.0)
                KnowledgeBaseView()
                    .opacity(selectedTab == .knowledge ? 1.0 : 0.0)
                RecipesView()
                    .opacity(selectedTab == .recipes ? 1.0 : 0.0)
                UserProfileView(userId: currentUserId)
                    .opacity(selectedTab == .profile ? 1.0 : 0.0)
            }
            HomeMenuBar(selectedTab: $selectedTab, profileImageUrl: $model.userProfileImageUrl)
        }
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
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
