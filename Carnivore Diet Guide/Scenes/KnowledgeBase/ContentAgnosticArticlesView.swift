//
//  ContentAgnosticArticlesView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/5/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ContentAgnosticArticlesView: View {
    
    static func canHandle(category: Resource.Category) -> Bool {
        let asdf: [Resource.Category] = [ .liked, .trending ]
        return asdf.contains(category)
    }
    
    @Binding public var navigationPath: NavigationPath
    public var category: Resource.Category
    public var keywords: Set<SearchKeyword>
    
    @State private var isWorking: Bool = false
    @State private var allArticles: [Article] = []
    @State private var timeFrame: TimeFrame = .past7Days
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let articleFetcher = iocContainer~>ArticleCollectionFetcher.self
    private let articleLibrary = iocContainer~>ArticleLibrary.self
    
    private var displayArticles: [Article] {
        var articles = allArticles
        
        if !keywords.isEmpty {
            articles = articles.filter { $0.relevanceTo(keywords) > 0 }
        }
        
        return articles
    }
    
    private func fetchArticles() {
        isWorking = true
        allArticles = []
        
        Task {
            do {
                var articleIds: [String] = []
                
                if category == .liked {
                    articleIds = try await articleFetcher.fetchLikedArticles(in: timeFrame)
                } else if category == .trending {
                    articleIds = try await articleFetcher.fetchTrendingArticles(in: timeFrame)
                }
                
                allArticles = articleIds.compactMap { articleLibrary.getArticle(byId: $0) }
            } catch {
                show(alert: "Error fetching articles. \(error.localizedDescription)")
            }
            isWorking = false
        }
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    var body: some View {
        Container()
            .padding(.horizontal)
            .alert(alertMessage, isPresented: $showAlert) {}
            .onChange(of: category, initial: true) { _, _ in fetchArticles() }
            .onChange(of: timeFrame, initial: false) { _, _ in fetchArticles() }
    }
    
    @ViewBuilder func Container() -> some View {
        if displayArticles.isEmpty && !isWorking {
            EmptyArticlesView()
        } else {
            ArticleGrid()
        }
    }
    
    @ViewBuilder func ArticleGrid() -> some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        VStack(spacing: 24) {
            TimeFramePicker(timeFrame: $timeFrame)
            if isWorking {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accent)
                    .padding(.vertical, 64)
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(displayArticles) { article in
                        Button {
                            navigationPath.append(article)
                        } label: {
                            ArticleItemView(article)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder func EmptyArticlesView() -> some View {
        ContentUnavailableView(
            "Nothing to see here.\nTry back later.",
            systemImage: "magnifyingglass"
        )
        .foregroundStyle(Color.text)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ContentAgnosticArticlesView(
            navigationPath: .constant(.init()),
            category: .liked,
            keywords: []
        )
    }
}
