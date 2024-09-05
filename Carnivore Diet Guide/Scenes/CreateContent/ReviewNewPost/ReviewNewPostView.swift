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
    
    private let postPoster = iocContainer~>PostPoster.self
    private let activityTracker = iocContainer~>ResourceCreatedActivityTracker.self
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    
    public let postData: ContentData
    public let dismissAll: () -> ()
    
    @State private var isPosting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var feedItem: FeedItem {
        FeedItem(
            id: UUID().uuidString,
            publicationDate: .now,
            type: .post,
            resourceId: postData.id.uuidString,
            userId: postData.userId,
            imageUrls: postData.imageUrls,
            title: postData.title,
            summary: postData.markdownContent.markdownToFeedItemSummary()
        )
    }
    
    private var post: Post {
        Post(
            id: postData.id.uuidString,
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
    
    private func addCreatedActivity() {
        guard let userId = userIdProvider.currentUserId else { return }
        Task {
            try? await activityTracker.resource(.init(post), wasCreatedByUser: userId)
        }
    }
    
    private func postAndDismiss() {
        Task {
            do {
                withAnimation(.snappy) { isPosting = true }
                try await postPoster.post(post: post, feedItem: feedItem)
                addCreatedActivity()
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
                        ReviewContentSectionHeader(String(localized: "As seen in the Community Feed"))
                        FeedItemView(feedItem: feedItem)
                        ReviewContentSectionHeader(String(localized: "As seen while reading"))
                    }
                    .padding(.horizontal, .itemHorizontalPadding)
                    PostView(post: post)
                }
                .padding(.bottom, .barHeight)
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
            ProgressSpinnerOverlay()
        }
    }
    
    @ViewBuilder func BottomControls() -> some View {
        if !isPosting {
            ReviewContentBottomControls(
                editAction: goBack,
                approvedAction: postAndDismiss
            )
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(PostPoster.self, initializer: { DefaultPostPoster.forPreviewsWithFailure })
    } content: {
        ReviewNewPostView(postData: ContentData.sample) {}
    }
}
