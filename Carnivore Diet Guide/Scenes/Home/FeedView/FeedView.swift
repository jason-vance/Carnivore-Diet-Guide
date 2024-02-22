//
//  FeedView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/20/24.
//

import SwiftUI

struct FeedView: View {
    
    private let itemHorizontalPadding: CGFloat = 8
    
    var screenWidth: CGFloat
    @StateObject private var model = FeedViewModel()
    
    var body: some View {
        LazyVStack {
            ForEach(model.feedItems) { feedItem in
                NavigationLink {
                    FeedItemDetailView(feedItem)
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
    
    @ViewBuilder func FeedItemDetailView(_ feedItem: FeedItem) -> some View {
        switch feedItem.type {
        case .article:
            PostDetailView(post: .sample)
        case .recipe:
            RecipeDetailView(recipeId: feedItem.resourceId)
        case .discussion:
            Text(feedItem.title)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        GeometryReader { proxy in
            NavigationStack {
                ScrollView {
                    FeedView(screenWidth: proxy.size.width)
                }
            }
        }
    }
}
