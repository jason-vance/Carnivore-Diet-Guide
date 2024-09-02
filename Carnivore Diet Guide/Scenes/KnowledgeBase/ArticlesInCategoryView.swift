//
//  ArticlesInCategoryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ArticlesInCategoryView: View {
    
    private let fetchArticlesLimit: Int = 10
    
    public var category: Resource.Category
    
    @State private var articles: [Article] = []
    @State private var articleCursor: ArticleCursor? = nil
    @State private var canFetchMore: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let articleFetcher = iocContainer~>ArticleFetcher.self
    
    func refresh() {
        articles = []
        articleCursor = nil
        canFetchMore = true
    }
    
    func fetchMoreArticles() {
        Task {
            do {
                let newArticles = try await articleFetcher.fetchArticles(
                    in: category,
                    after: &articleCursor,
                    limit: fetchArticlesLimit
                )
                withAnimation(.snappy) {
                    canFetchMore = !newArticles.isEmpty
                }
                
                articles.append(contentsOf: newArticles)
            } catch {
                print("Failed to fetch articles. \(error.localizedDescription)")
                show(alert: "Failed to fetch articles. \(error.localizedDescription)")
            }
        }
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    var body: some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(articles) { article in
                    ArticleItemView(article)
                }
            }
            LoadMoreArticlesView()
        }
        .padding(.horizontal)
        .onChange(of: category, initial: true) { _, newCategory in
            refresh()
        }
        .alert(alertMessage, isPresented: $showAlert) {}
    }
    
    @ViewBuilder func LoadMoreArticlesView() -> some View {
        if canFetchMore {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accent)
                    .padding(.vertical, 64)
                Spacer()
            }
            .onAppear { fetchMoreArticles() }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
            .id(UUID())
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ArticlesInCategoryView(category: .samples.first!)
    }
}
