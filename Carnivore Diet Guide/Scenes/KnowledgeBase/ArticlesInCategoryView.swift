//
//  ArticlesInCategoryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Combine
import SwiftUI
import SwinjectAutoregistration

struct ArticlesInCategoryView: View {
    
    private let fetchArticlesLimit: Int = 20
    
    @Binding public var navigationPath: NavigationPath
    public var category: Resource.Category
    public var keywords: Set<SearchKeyword>
    
    @State private var allArticles: [Article] = []
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let articleLibrary = iocContainer~>ArticleLibrary.self
    private var articlePublisher: AnyPublisher<[Article],Never> {
        articleLibrary.publishedArticlesPublisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private var displayArticles: [Article] {
        var articles = allArticles
            .sorted { $0.publicationDate > $1.publicationDate }
        
        if category != .all {
            articles = articles.filter { $0.categories.contains(category) }
        }
        
        if !keywords.isEmpty {
            articles = articles
                .map { ($0, $0.relevanceTo(keywords)) }
                .filter { $0.1 > 0 }
                .sorted { $0.1 > $1.1 }
                .map { $0.0 }
        }
        
        return articles
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    var body: some View {
        Container()
            .padding(.horizontal)
            .alert(alertMessage, isPresented: $showAlert) {}
            .onReceive(articlePublisher) { allArticles = $0 }
    }
    
    @ViewBuilder func Container() -> some View {
        if displayArticles.isEmpty {
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
    
    @ViewBuilder func EmptyArticlesView() -> some View {
        ContentUnavailableView(
            "Nothing to see here.\nTry changing your search criteria.",
            systemImage: "magnifyingglass"
        )
        .foregroundStyle(Color.text)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        StatefulPreviewContainer(NavigationPath()) { navPath in
            NavigationStack(path: navPath) {
                ArticlesInCategoryView(
                    navigationPath: navPath,
                    category: .samples.first!,
                    keywords: []
                )
                .navigationDestination(for: Article.self) { article in
                    ArticleDetailView(article: article)
                }
            }
        }
    }
}
