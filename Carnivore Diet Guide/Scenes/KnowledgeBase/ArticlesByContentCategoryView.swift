//
//  ArticlesByContentCategoryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ArticlesByContentCategoryView: View {
    
    @State public var category: Resource.Category
    
    @StateObject private var model = ArticlesByContentCategoryViewModel(
        articleFetcher: iocContainer~>ArticleFetcher.self
    )
    
    var body: some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        LazyVGrid(columns: columns) {
            ForEach(model.articles) { article in
                ArticleItemView(article)
            }
            //TODO: LoadMoreArticlesView()
        }
        .padding(.horizontal)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ArticlesByContentCategoryView(category: .samples.first!)
    }
}
