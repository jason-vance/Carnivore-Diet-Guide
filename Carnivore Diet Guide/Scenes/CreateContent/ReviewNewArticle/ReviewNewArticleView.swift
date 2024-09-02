//
//  ReviewNewArticleView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ReviewNewArticleView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    private let articlePoster = iocContainer~>ArticlePoster.self
    
    public let newArticleData: NewArticleData
    public let dismissAll: () -> ()
    
    @State private var isPosting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var feedItem: FeedItem {
        FeedItem(
            id: UUID().uuidString,
            publicationDate: .now,
            type: .article,
            resourceId: newArticleData.data.id.uuidString,
            userId: newArticleData.data.userId,
            imageUrls: newArticleData.data.imageUrls,
            title: newArticleData.data.title,
            summary: newArticleData.metadata.summary.text
        )
    }
    
    private var article: Article {
        Article(
            id: newArticleData.data.id.uuidString,
            author: newArticleData.data.userId,
            title: newArticleData.data.title,
            coverImageUrl: newArticleData.data.imageUrls[0],
            summary: newArticleData.metadata.summary,
            markdownContent: newArticleData.data.markdownContent,
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
                try await articlePoster.post(
                    article: article,
                    categories: newArticleData.metadata.categories,
                    keywords: newArticleData.metadata.searchKeywords,
                    feedItem: feedItem
                )
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
            ScreenTitleBar(String(localized: "Review Your Article"))
            ScrollView {
                VStack {
                    VStack {
                        ReviewContentSectionHeader(String(localized: "As seen in the Community Feed"))
                        FeedItemView(feedItem: feedItem)
                        ReviewContentSectionHeader(String(localized: "As seen in the Knowledge Base"))
                        KnowledgeBaseArticleViews()
                        ReviewContentSectionHeader(String(localized: "As seen while reading"))
                    }
                    .padding(.horizontal, .itemHorizontalPadding)
                    ArticleView(article: article)
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
    
    @ViewBuilder func KnowledgeBaseArticleViews() -> some View {
        VStack {
            ArticleItemView(article)
                .articleStyle(.largeVertical)
            HStack {
                ArticleItemView(article)
                    .articleStyle(.vertical)
                ArticleItemView(article)
                    .articleStyle(.vertical)
            }
            ArticleItemView(article)
                .articleStyle(.horizontal)

        }
    }
}

#Preview("Fails") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(ArticlePoster.self) {
            DefaultArticlePoster.forPreviewsWithFailure
        }
    } content: {
        ReviewNewArticleView(newArticleData: .sample) {}
    }
}
