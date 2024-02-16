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
    @State var imageSize: CGFloat
    @StateObject private var model = FeedItemViewModel()
    
    var body: some View {
        VStack(spacing: 4) {
            ItemImage(size: imageSize)
            VStack(spacing: 4) {
                ItemCategory()
                ItemTitle()
                ByLineView(userId: feedItem.userId)
                ItemSummary()
            }
            .padding(8)
            .padding(.bottom, 8)
        }
        .foregroundStyle(Color.text)
        .clipped()
        .background(Color.background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: Corners.radius,
                style: .continuous
            )
        )
        .shadow(color: Color.text, radius: 4)
    }
    
    @ViewBuilder func ItemImage(size: CGFloat) -> some View {
        //TODO: single image, array of images, no image
        if !feedItem.imageUrls.isEmpty {
            KFImage(feedItem.imageUrls[0])
                .resizable()
                .cacheOriginalImage()
                .diskCacheExpiration(.days(7))
                .placeholder(PlaceholderView)
                .scaledToFill()
                .frame(width: size, height: size)
        }
    }
    
    @ViewBuilder func PlaceholderView() -> some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .foregroundStyle(Color.background)
            .clipShape(Circle())
    }
    
    @ViewBuilder func ItemCategory() -> some View {
        if let category = feedItem.category {
            Text(category)
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
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder func ItemSummary() -> some View {
        Text(feedItem.summary)
            .font(.body)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        FeedItemView(feedItem: .sample, imageSize: 375)
    }
}
