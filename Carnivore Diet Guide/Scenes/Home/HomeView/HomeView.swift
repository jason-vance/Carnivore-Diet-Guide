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
    @State private var showUserProfile: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    HomeContent(screenWidth: proxy.size.width)
                        .padding(.vertical)
                }
                .scrollIndicators(.hidden)
                .background(Color.background)
                .toolbarRole(.navigationStack)
                .toolbar { NavigationBar() }
                .searchable(text: $model.searchString, placement: .navigationBarDrawer)
                .searchScopes($model.searchScope, activation: .onSearchPresentation) {
                    SearchScopes()
                }
                .onSubmit(of: .search) {
                    model.doSearch()
                }
                //TODO: Add .refreshable to HomeView
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
    
    @ToolbarContentBuilder func NavigationBar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            TitleText()
        }
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButton()
        }
    }
    
    @ViewBuilder func SearchScopes() -> some View {
        Text("All").tag(HomeViewModel.SearchScope.all)
        Text("Recipe").tag(HomeViewModel.SearchScope.recipe)
        Text("Article").tag(HomeViewModel.SearchScope.article)
        Text("Discussion").tag(HomeViewModel.SearchScope.discussion)
    }
    
    @ViewBuilder func TitleText() -> some View {
        Text(Bundle.main.bundleName ?? "")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color.text)
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
