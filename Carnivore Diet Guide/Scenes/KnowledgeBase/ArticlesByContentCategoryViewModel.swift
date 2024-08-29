//
//  ArticlesByContentCategoryViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

//TODO: Implement ArticlesByContentCategoryViewModel
@MainActor
class ArticlesByContentCategoryViewModel: ObservableObject {
    
    @Published public var articles: [Article] = []
    
    private let articleFetcher: ArticleFetcher
    
    init(
        articleFetcher: ArticleFetcher
    ) {
        self.articleFetcher = articleFetcher
    }
}
