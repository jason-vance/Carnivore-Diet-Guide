//
//  ArticleDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/3/24.
//

import SwiftUI
import MarkdownUI
import SwinjectAutoregistration

struct ArticleDetailView: View {
    
    private let articleFetcher = iocContainer~>ArticleDetailArticleFetcher.self
    private let activityTracker = iocContainer~>ResourceViewActivityTracker.self
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var articleId: String
    @State private var article: Article?
    @State private var isWorking: Bool = false
    
    @State private var showArticleFailedToFetch: Bool = false
    
    init(articleId: String) {
        self.article = nil
        self.articleId = articleId
    }
    
    init(article: Article) {
        self.article = article
        self.articleId = article.id
    }
    
    private func fetchArticle(withId articleId: String) {
        guard articleId != article?.id else { return }
        
        Task {
            do {
                article = try await articleFetcher.fetchArticle(withId: articleId)
            } catch {
                print("Article failed to fetch")
                showArticleFailedToFetch = true
            }
        }
    }
    
    private func markAsViewed() {
        guard let article = article else { return }
        guard let userId = userIdProvider.currentUserId else { return }
        guard article.author != userId else { return }
        
        Task {
            try? await activityTracker.resource(.init(article), wasViewedByUser: userId)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar()
            if let article = article, !isWorking {
                ScrollView {
                    ArticleView(article: article)
                        .onAppear { markAsViewed() }
                }
            } else {
                LoadingView()
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .onChange(of: articleId, initial: true) { _, newArticleId in
            fetchArticle(withId: newArticleId)
        }
        .alert("The article could not be fetched", isPresented: $showArticleFailedToFetch) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
    }
    
    @ViewBuilder func NavigationBar() -> some View {
        HStack {
            CloseButton()
            Spacer()
            OptionsMenu()
        }
        .padding()
        .frame(height: .barHeight)
        .overlay(alignment: .bottom) {
            BarDivider()
        }
    }
    
    @ViewBuilder func OptionsMenu() -> some View {
        if let article = article {
            let resource = Resource(article)
            
            HStack(spacing: 16) {
                ExtraOptionsButton(
                    resource: resource,
                    isWorking: $isWorking,
                    dismissResource: { dismiss() }
                )
                CommentButton(resource: resource)
                FavoriteButton(resource: resource)
            }
        }
    }
    
    @ViewBuilder private func LoadingView() -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.text)
                .opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.accentColor)
                .padding()
                .background(Color.background)
                .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
        }
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "chevron.backward")
        }
    }
}

#Preview("Default articleId init") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ArticleDetailView(articleId: Article.sample.id)
    }
}

#Preview("Default article init") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ArticleDetailView(article: Article.sample)
    }
}

#Preview("Fails to load") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        iocContainer.autoregister(ArticleDetailArticleFetcher.self) {
            let fetcher = MockArticleDetailArticleFetcher()
            fetcher.error = "Test failure"
            return fetcher
        }
    } content: {
        NavigationStack {
            NavigationLink {
                ArticleDetailView(articleId: Article.sample.id)
            } label: {
                HStack {
                    Text("Article Detail\n(Fails to Load)")
                    Image(systemName: "chevron.forward")
                }
                .foregroundStyle(Color.background)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(Color.accent)
                }
            }
        }
    }
}
