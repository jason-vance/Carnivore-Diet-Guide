//
//  LazyArticleItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/5/24.
//

import SwiftUI
import SwinjectAutoregistration

struct LazyArticleItemView: View {
    
    public let articleId: String
    
    @State private var article: Article?
    
    private let articleFetcher = iocContainer~>IndividualArticleFetcher.self
    
    private func fetchArticle() {
        Task {
            do {
                article = try await articleFetcher.fetchArticle(withId: articleId)
            } catch {
                print("LazyArticleItemView: Error fetching article. \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        Container()
            .onAppear { fetchArticle() }
    }
    
    @ViewBuilder func Container() -> some View {
        if let article = article {
            ArticleItemView(article)
        } else {
            ArticleItemView(.sample)
                .redacted(reason: .placeholder)
                .shimmering()
                .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        LazyArticleItemView(articleId: Article.sample.id)
    }
}
