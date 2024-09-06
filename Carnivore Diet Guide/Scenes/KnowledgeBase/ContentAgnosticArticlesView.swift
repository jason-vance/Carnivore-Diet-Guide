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
        return category == .liked
        //TODO: Add .trending
        //TODO: Add .featured
    }
    
    @Binding public var navigationPath: NavigationPath
    public var category: Resource.Category
    public var keywords: Set<SearchKeyword>
    
    @State private var articleIds: [String] = []
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let articleFetcher = iocContainer~>ArticleCollectionFetcher.self
    
    private func fetchArticles() {
        Task {
            do {
                if category == .liked {
                    articleIds = try await articleFetcher.fetchLikedArticles()
                }
            } catch {
                show(alert: "Error fetching articles. \(error.localizedDescription)")
            }
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
            .onAppear { fetchArticles() }
    }
    
    @ViewBuilder func Container() -> some View {
        if articleIds.isEmpty {
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
            ForEach(articleIds, id: \.self) { articleId in
                LazyArticleItemView(articleId: articleId)
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
