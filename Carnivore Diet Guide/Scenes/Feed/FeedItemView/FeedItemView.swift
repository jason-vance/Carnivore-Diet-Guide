//
//  FeedItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/15/24.
//

import SwiftUI
import Kingfisher

struct FeedItemView: View {
    
    @State var feedItem: FeedItem
    @StateObject private var model = FeedItemViewModel()
    
    var body: some View {
        VStack(spacing: 4) {
            ItemImage()
            VStack(spacing: 4) {
                ItemCalloutText()
                ItemTitle()
                ByLineView(userId: feedItem.userId)
                ItemSummary()
            }
            .padding(8)
            .padding(.bottom, 4)
        }
        .foregroundStyle(Color.text)
        .background(Color.background)
        .clipShape(RoundedRectangle(
            cornerRadius: Corners.radius,
            style: .continuous
        ))
        .clipped()
        .shadow(color: Color.text, radius: 4)
    }
    
    @ViewBuilder func ItemImage() -> some View {
        if feedItem.imageUrls.isEmpty {
            //Do nothing, leave it blank
        } else {
            ResourceImageViewPager(urls: feedItem.imageUrls)
        }
    }
    
    @ViewBuilder func ItemCalloutText() -> some View {
        if let calloutText = feedItem.calloutText {
            Text(calloutText)
                .font(.headline.weight(.black))
                .foregroundStyle(Color.accent)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder func ItemTitle() -> some View {
        Text(feedItem.title)
            .font(.title.weight(.bold))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder func ItemSummary() -> some View {
        Text(feedItem.summary)
            .font(.body)
            .multilineTextAlignment(.leading)
            .lineLimit(4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Post") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        VStack {
            FeedItemView(feedItem: .samplePost)
        }
    }
}

#Preview("Recipe") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        VStack {
            FeedItemView(feedItem: .sampleRecipe)
        }
    }
}

#Preview("Home Screen") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeView()
    }
}

#Preview("Review New Post") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ReviewNewPostView(
            postData: .sample,
            dismissAll: {})
    }
}
