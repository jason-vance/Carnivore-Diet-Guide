//
//  HomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeView: View {
    
    private let itemHorizontalPadding: CGFloat = 8
    
    @StateObject private var model = HomeViewModel()
    @State var showUserProfile: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    TitleBar()
                    ScrollView {
                        HomeContent(screenWidth: proxy.size.width)
                            .padding(.vertical)
                    }
                    .scrollIndicators(.hidden)
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [Color.background, Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 16)
                    }
                }
                .background(Color.background)
            }
        }
        .overlay {
            CreateMenu()
        }
        .sheet(isPresented: $showUserProfile) {
            if let userId = (iocContainer~>CurrentUserIdProvider.self).currentUserId {
                UserProfileView(userId: userId)
            }
        }
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
    }
    
    @ViewBuilder func TitleBar() -> some View {
        HStack {
            TitleText()
            Spacer()
        }
        .overlay(alignment: .trailing) {
            HStack {
                SearchButton()
                ProfileButton()
            }
            .padding(.trailing)
        }
    }
    
    @ViewBuilder func TitleText() -> some View {
        Text(Bundle.main.bundleName ?? "")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color.text)
            .padding()
    }
    
    @ViewBuilder func SearchButton() -> some View {
        Button {
            //TODO: Add ability to search
        } label: {
            Image(systemName: "magnifyingglass.circle.fill")
                .resizable()
                .foregroundStyle(Color.background)
                .padding(2)
                .background {
                    Circle()
                        .fill(Color.accentColor)
                }
                .frame(width: 32, height: 32)
        }
    }
    
    @ViewBuilder func ProfileButton() -> some View {
        Button {
            showUserProfile = true
        } label: {
            ProfileImageView(
                model.userProfileImageUrl,
                size: 32,
                padding: 2
            )
        }
    }
    
    @ViewBuilder func HomeContent(screenWidth: CGFloat) -> some View {
        VStack {
            InfinitePosts(screenWidth: screenWidth)
        }
    }
    
    @ViewBuilder func FeaturedContent() -> some View {
        
    }
    
    @ViewBuilder func InfinitePosts(screenWidth: CGFloat) -> some View {
        LazyVStack {
            ForEach(model.feedItems) { feedItem in
                NavigationLink {
                    Text("Hello")
                } label: {
                    FeedItemView(
                        feedItem: feedItem,
                        itemWidth: screenWidth - (2 * itemHorizontalPadding)
                    )
                }
                .padding(.horizontal, itemHorizontalPadding)
            }
            LoadNextFeedItemsView()
        }
        .overlay(alignment: .bottom) {
            if !model.canFetchMoreFeedItems {
                Image(systemName: "flag.checkered.2.crossed")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.text)
                    .offset(y: 150)
            }
        }
    }
    
    @ViewBuilder func LoadNextFeedItemsView() -> some View {
        if model.canFetchMoreFeedItems {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.accent)
                .onAppear {
                    model.fetchMoreFeedItems()
                }
                .padding(.vertical, 64)
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
