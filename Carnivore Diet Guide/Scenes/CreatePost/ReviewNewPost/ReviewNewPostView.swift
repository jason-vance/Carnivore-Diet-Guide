//
//  ReviewNewPostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI

struct ReviewNewPostView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    private let itemHorizontalPadding: CGFloat = 8
    
    public let postData: ReviewPostData
    
    private var feedItem: FeedItem {
        FeedItem(
            id: UUID().uuidString,
            type: .post,
            resourceId: postData.id,
            userId: postData.userId,
            imageUrls: postData.imageUrls,
            title: postData.title,
            summary: postData.markdownContent.markdownToFeedItemSummary()
        )
    }
    
    private var post: Post {
        Post(
            id: UUID().uuidString,
            title: postData.title,
            imageUrl: postData.imageUrls.first?.absoluteString,
            author: postData.userId,
            markdownContent: postData.markdownContent,
            publicationDate: .now
        )
    }
    
    private func goBack() {
        dismiss()
    }
    
    private func postAndDismiss() {
        //TODO: Post and dismiss post creation UI
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(String(localized: "Review Your Post"))
            ScrollView {
                VStack {
                    PostView(post: post)
                    FeedItemView(feedItem: feedItem)
                }
                .padding(.horizontal, itemHorizontalPadding)
                .padding(.vertical)
                .padding(.bottom, .defaultBarHeight)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.background)
        .overlay(alignment: .bottom) {
            BottomControls()
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func BottomControls() -> some View {
        HStack {
            BackButton()
            LooksGoodButton()
        }
        .padding()
        .frame(height: .defaultBarHeight)
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            goBack()
        } label: {
            HStack {
                Image(systemName: "chevron.backward")
                Text("Edit")
            }
            .foregroundStyle(Color.accent)
            .bold()
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: Corners.radius, style: .continuous)
                    .stroke(style: .init(lineWidth: 2))
                    .foregroundStyle(Color.accent)
            }
            .background {
                RoundedRectangle(cornerRadius: Corners.radius, style: .continuous)
                    .foregroundStyle(Color.background)
            }
        }
    }
    
    @ViewBuilder func LooksGoodButton() -> some View {
        Button {
            postAndDismiss()
        } label: {
            HStack {
                Image(systemName: "hand.thumbsup")
                Text("Looks Good")
            }
            .foregroundStyle(Color.background)
            .bold()
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: Corners.radius, style: .continuous)
                    .foregroundStyle(Color.accent)
            }
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ReviewNewPostView(postData: ReviewPostData.sample)
    }
}
