//
//  FeedView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/20/24.
//

import SwiftUI
import SwinjectAutoregistration


struct FeedView: View {
    
    private let itemHorizontalPadding: CGFloat = 8
    
    @StateObject private var model = FeedViewModel(
        feedItemProvider: iocContainer~>FeedViewContentProvider.self
    )
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenTitleBar(String(localized: "Community Feed"))
                ScrollView {
                    Feed()
                        .padding(.vertical)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.background)
            .refreshable { model.refreshNewsFeed() }
            .onAppear { UIRefreshControl.appearance().tintColor = .accent }
        }
    }
    
    @ViewBuilder func Feed() -> some View {
        LazyVStack {
            ForEach(model.feedItems) { feedItem in
                NavigationLink {
                    FeedItemDetailView(feedItem)
                } label: {
                    FeedItemView(feedItem: feedItem)
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
    
    @ViewBuilder func FeedItemDetailView(_ feedItem: FeedItem) -> some View {
        switch feedItem.type {
        case .article:
            //TODO: Uncomment this when ArticleDetailView exists
            Text(feedItem.title)
//            ArticleDetailView(articleId: feedItem.resourceId)
        case .post:
            PostDetailView(postId: feedItem.resourceId)
        case .recipe:
            RecipeDetailView(recipeId: feedItem.resourceId)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        FeedView()
    }
}
