//
//  FeedItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/15/24.
//

import SwiftUI
import Kingfisher

struct FeedItemView: View {
    
    //TODO: I would probably prefer to pass an id instead of a full feed item for Firebase's sake
    @State var feedItem: FeedItem
    @State var itemWidth: CGFloat?
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
        } else if feedItem.imageUrls.count == 1 {
            KFImage(feedItem.imageUrls[0])
                .resizable()
                .cacheOriginalImage()
                .diskCacheExpiration(.days(7))
                .placeholder(PlaceholderView)
                .scaledToFill()
                .frame(width: itemWidth, height: itemWidth)
        } else {
            //TODO: Handle an array of FeedItem images
        }
    }
    
    @ViewBuilder func PlaceholderView() -> some View {
        if let imageSize = itemWidth {
            ZStack {
                Rectangle()
                    .fill(Color.text.opacity(0.8))
                Image(systemName: "photo")
                    .font(.system(size: imageSize/2))
                    .foregroundStyle(Color.background)
            }
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

#Preview("Article") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        GeometryReader { proxy in
            FeedItemView(feedItem: .sampleArticle, itemWidth: proxy.size.width)
        }
    }
}

#Preview("Discussion") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        GeometryReader { proxy in
            FeedItemView(feedItem: .sampleDiscussion, itemWidth: proxy.size.width)
        }
    }
}

#Preview("Recipe") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        GeometryReader { proxy in
            FeedItemView(feedItem: .sampleRecipe, itemWidth: proxy.size.width)
        }
    }
}

#Preview("Home Screen") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeViewV2()
    }
}
