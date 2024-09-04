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
    
    @State private var filter: Set<SearchKeyword> = []
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
        allArticles.sorted { $0.publicationDate > $1.publicationDate }
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
        
        LazyVGrid(columns: columns) {
            ForEach(displayArticles) { article in
                Button {
                    navigationPath.append(article)
                } label: {
                    ArticleItemView(article)
                }
            }
        }
        .padding(.horizontal)
        .alert(alertMessage, isPresented: $showAlert) {}
        .onReceive(articlePublisher) { allArticles = $0 }
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
