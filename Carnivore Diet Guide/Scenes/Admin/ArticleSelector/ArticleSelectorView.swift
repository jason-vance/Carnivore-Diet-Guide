//
//  ArticleSelectorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import Combine
import SwiftUI
import SwinjectAutoregistration

struct ArticleSelectorView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    public let saveAction: (Article) -> ()
    
    @State private var articles: [Article] = []
    
    private let articleLibrary = iocContainer~>ArticleLibrary.self
    
    private var articlesPublisher: AnyPublisher<[Article],Never> {
        articleLibrary
            .publishedArticlesPublisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private var displayArticles: [Article] {
        articles.sorted { $0.publicationDate > $1.publicationDate }
    }
    
    private func saveAndDismiss(article: Article) {
        saveAction(article)
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                ForEach(displayArticles) { article in
                    ArticleRow(article)
                }
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .onReceive(articlesPublisher) { articles = $0 }
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar("Select Article", leadingContent: BackButton)
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func ArticleRow(_ article: Article) -> some View {
        Button {
            saveAndDismiss(article: article)
        } label: {
            ArticleItemView(article)
                .articleStyle(.horizontal)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ArticleSelectorView { article in }
    }
}
