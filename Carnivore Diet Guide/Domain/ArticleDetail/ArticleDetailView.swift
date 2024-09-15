//
//  ArticleDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/3/24.
//

import Combine
import MarkdownUI
import SwiftUI
import SwinjectAutoregistration

struct ArticleDetailView: View {
    
    private let articleLibrary = iocContainer~>ArticleLibrary.self
    private let activityTracker = iocContainer~>ResourceViewActivityTracker.self
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var articleId: String
    @State private var article: Article?
    @State private var isWorking: Bool = false
    
    @State private var showArticleFailedToFetch: Bool = false
    @State private var showArticleNoLongerAvailable: Bool = false
    
    @State private var showAds: Bool = false
    private var showAdsPublisher: AnyPublisher<Bool,Never> {
        (iocContainer~>SubscriptionLevelProvider.self)
            .subscriptionLevelPublisher
            .receive(on: RunLoop.main)
            .map { $0 == SubscriptionLevelProvider.SubscriptionLevel.none }
            .eraseToAnyPublisher()
    }

    init(articleId: String) {
        self.article = nil
        self.articleId = articleId
    }
    
    init(article: Article) {
        self.article = article
        self.articleId = article.id
    }
    
    private var thisArticleWasRemoved: AnyPublisher<Article, Never> {
        articleLibrary.removedArticlePublisher
            .receive(on: RunLoop.main)
            .filter { $0.id == articleId }
            .eraseToAnyPublisher()
    }
    
    private func fetchArticle(withId articleId: String) {
        guard articleId != article?.id else { return }
        
        if let article = articleLibrary.getArticle(byId: articleId) {
            self.article = article
        } else {
            print("Article failed to fetch")
            showArticleFailedToFetch = true
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
    
    private func updateArticleDataIfNecessary() {
        guard let article = article else { return }
        articleLibrary.updateArticleDataIfNecessary(article)
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar()
            if let article = article, !isWorking {
                ScrollView {
                    VStack(spacing: 0) {
                        if showAds { AdRow() }
                        ArticleView(article: article)
                            .onAppear { markAsViewed() }
                            .onAppear { updateArticleDataIfNecessary() }
                            .onReceive(thisArticleWasRemoved) { _ in
                                isWorking = true
                                showArticleNoLongerAvailable = true
                            }
                    }
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
        .onReceive(showAdsPublisher) { showAds = $0 }
        .alert("The article could not be fetched", isPresented: $showArticleFailedToFetch) {
            AlertOkDismissButton()
        }
        .alert("This article is no longer available", isPresented: $showArticleNoLongerAvailable) {
            AlertOkDismissButton()
        }
    }
    
    @ViewBuilder func AlertOkDismissButton() -> some View {
        Button("OK", role: .cancel) {
            dismiss()
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
        iocContainer.autoregister(IndividualArticleFetcher.self) {
            let fetcher = MockIndividualArticleFetcher()
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
