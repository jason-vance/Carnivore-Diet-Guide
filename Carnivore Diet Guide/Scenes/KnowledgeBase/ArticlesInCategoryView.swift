//
//  ArticlesInCategoryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ArticlesInCategoryView: View {
    
    private let fetchArticlesLimit: Int = 20
    
    @Binding public var navigationPath: NavigationPath
    public var category: Resource.Category
    
    @State private var filter: Set<SearchKeyword> = []
    @State private var articles: [Article] = []
    @State private var articleCursor: ArticleCursor? = nil
    @State private var canFetchMore: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    //TODO: Use the articleLibrary to populate the articles
    private let articleLibrary = iocContainer~>ArticleLibrary.self
    
    func refresh() {
        articles = []
        articleCursor = nil
        canFetchMore = true
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    var body: some View {
        //TODO: ContentUnavailableView
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(articles) { article in
                    Button {
                        navigationPath.append(article)
                    } label: {
                        ArticleItemView(article)
                    }
                }
            }
        }
        .padding(.horizontal)
        .onChange(of: category, initial: true) { _, newCategory in
            refresh()
        }
        .alert(alertMessage, isPresented: $showAlert) {}
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
                    category: .samples.first!
                )
                .navigationDestination(for: Article.self) { article in
                    ArticleDetailView(article: article)
                }
            }
        }
    }
}
