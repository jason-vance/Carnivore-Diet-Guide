//
//  ReviewNewPostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ReviewNewPostView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    private let itemHorizontalPadding: CGFloat = 8
    
    private let postPoster = iocContainer~>PostPoster.self
    
    public let postData: ReviewPostData
    public let dismissAll: () -> ()
    
    @State private var isPosting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var feedItem: FeedItem {
        FeedItem(
            id: UUID().uuidString,
            publicationDate: .now,
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
            id: postData.id,
            title: postData.title,
            imageUrls: postData.imageUrls,
            author: postData.userId,
            markdownContent: postData.markdownContent,
            publicationDate: .now
        )
    }
    
    private func goBack() {
        dismiss()
    }
    
    private func postAndDismiss() {
        Task {
            do {
                withAnimation(.snappy) { isPosting = true }
                try await postPoster.post(post: post, feedItem: feedItem)
                dismissAll()
            } catch {
                withAnimation(.snappy) { isPosting = false }
                show(alert: "Failed to post. Please try again later.\n\(error.localizedDescription)")
            }
        }
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(String(localized: "Review Your Post"))
            ScrollView {
                VStack {
                    VStack {
                        SectionHeader("As seen in the Community Feed")
                        FeedItemView(feedItem: feedItem)
                        SectionHeader("As seen while reading")
                    }
                    .padding(.horizontal, itemHorizontalPadding)
                    PostView(post: post)
                }
                .padding(.bottom, .defaultBarHeight)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.background)
        .overlay(alignment: .bottom) {
            BottomControls()
        }
        .overlay {
            ProgressSpinner()
        }
        .navigationBarBackButtonHidden()
        .alert(alertMessage, isPresented: $showAlert) {}
    }
    
    @ViewBuilder func ProgressSpinner() -> some View {
        if isPosting {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundStyle(Color.text)
                    .opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accentColor)
                    .padding()
                    .background(Color.background)
                    .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
            }
        }
    }
    
    @ViewBuilder func SectionHeader(_ text: String) -> some View {
        ZStack {
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.text)
            Text(text)
                .font(.callout)
                .padding(.horizontal, 8)
                .background(Color.background)
                .foregroundStyle(Color.text)
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    @ViewBuilder func BottomControls() -> some View {
        if !isPosting {
            HStack {
                BackButton()
                LooksGoodButton()
            }
            .padding()
            .frame(height: .defaultBarHeight)
        }
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
            .padding(.vertical)
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
            .padding(.vertical)
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
        
        iocContainer.autoregister(PostPoster.self, initializer: { DefaultPostPoster.forPreviewsWithFailure })
    } content: {
        ReviewNewPostView(postData: ReviewPostData.sample) {}
    }
}
