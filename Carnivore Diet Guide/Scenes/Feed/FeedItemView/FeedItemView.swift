//
//  FeedItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/15/24.
//

import SwiftUI
import Kingfisher
import Swinject

struct FeedItemView: View {
    
    @State var feedItem: FeedItem
    
    @State var isPremium: Bool = true
    
    func checkIsPremium(resourceId: String) {
        Task {
            switch feedItem.type {
            case .post:
                isPremium = false
            case .recipe:
                guard let recipeLibrary = iocContainer.resolve(RecipeLibrary.self) else { return }
                isPremium = await recipeLibrary.getRecipe(byId: feedItem.resourceId)?.isPremium ?? true
            case .article:
                guard let articleLibrary = iocContainer.resolve(ArticleLibrary.self) else { return }
                isPremium = await articleLibrary.getArticle(byId: feedItem.resourceId)?.isPremium ?? true
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ItemImage()
            VStack(spacing: 4) {
                FeedItemMetadata()
                ItemCalloutText()
                ItemTitle()
                ByLineView(userId: feedItem.userId)
                ItemSummary()
            }
            .padding(8)
            .padding(.bottom, 4)
        }
        .taggedAsPremiumContent(isPremium)
        .foregroundStyle(Color.text)
        .background(Color.background)
        .clipShape(RoundedRectangle(
            cornerRadius: .cornerRadiusMedium,
            style: .continuous
        ))
        .clipped()
        .shadow(color: Color.text, radius: 4)
        .onChange(of: feedItem.resourceId, initial: true) { _, newResourceId in
            checkIsPremium(resourceId: newResourceId)
        }
    }
    
    @ViewBuilder func ItemImage() -> some View {
        if feedItem.imageUrls.isEmpty {
            //Do nothing, leave it blank
        } else {
            ResourceImageViewPager(urls: feedItem.imageUrls)
        }
    }
    
    @ViewBuilder func FeedItemMetadata() -> some View {
        HStack {
            PublicationDateView(date: feedItem.publicationDate)
            Spacer()
            CommentCountView(resource: .init(feedItem))
            MetadataSeparatorView()
            FavoriteCountView(resource: .init(feedItem))
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
