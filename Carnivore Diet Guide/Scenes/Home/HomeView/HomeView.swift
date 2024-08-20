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
                Feed()
                    .opacity(selectedTab == .feed ? 1.0 : 0.0)
                Text("Knowledge Base")
                    .opacity(selectedTab == .knowledge ? 1.0 : 0.0)
                Text("Create Post")
                    .opacity(selectedTab == .createPost ? 1.0 : 0.0)
                Text("Recipes")
                    .opacity(selectedTab == .recipes ? 1.0 : 0.0)
                UserProfileView(userId: currentUserId)
                    .opacity(selectedTab == .profile ? 1.0 : 0.0)
            }
            HomeMenuBar(selectedTab: $selectedTab, profileImageUrl: $model.userProfileImageUrl)
        }
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
    }
    
    @ViewBuilder func Feed() -> some View {
        GeometryReader { proxy in
            NavigationStack {
                VStack(spacing: 0) {
                    TitleBar()
                    ScrollView {
                        ScrollableHomeContent(screenWidth: proxy.size.width)
                            .padding(.vertical)
                    }
                }
                .scrollIndicators(.hidden)
                .background(Color.background)
                .refreshable { model.refreshNewsFeed() }
                .onAppear { UIRefreshControl.appearance().tintColor = .accent }
            }
        }
        .overlay { CreateMenu() }
    }
    
    @ViewBuilder func TabItemLabel(text: String, image: String) -> some View {
        LabeledContent(text) {
            Image(systemName: image)
        }
    }
    
    @ViewBuilder func TitleBar() -> some View {
        HStack {
            TitleText()
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 44)
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: 0.25)
                .foregroundStyle(Color.text)
                .opacity(0.25)
        }
    }
    
    @ViewBuilder func TitleText() -> some View {
        Text("Community Feed")
            .font(.title.bold())
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func ScrollableHomeContent(screenWidth: CGFloat) -> some View {            FeedView(screenWidth: screenWidth)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeView()
    }
}
