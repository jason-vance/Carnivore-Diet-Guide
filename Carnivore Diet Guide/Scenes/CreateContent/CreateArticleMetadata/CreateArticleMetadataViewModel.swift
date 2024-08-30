//
//  CreateArticleMetadataViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

@MainActor
class CreateArticleMetadataViewModel: ObservableObject {
    
    
    @Published public var articleSummary: Resource.Summary? = nil
    @Published public var articleCategories: [Resource.Category] = []
    @Published public var articleSearchKeywords: [SearchKeyword] = []
    
    public var isFormEmpty: Bool {
        articleSummary == nil || articleCategories.isEmpty || articleSearchKeywords.isEmpty
    }
    
    public func contentMetadata(id: UUID) -> ContentMetadata? {
        guard let articleSummary = articleSummary else { return nil }
        guard !articleCategories.isEmpty else { return nil }
        guard !articleSearchKeywords.isEmpty else { return nil }

        return .init(
            id: id,
            summary: articleSummary,
            categories: articleCategories,
            searchKeywords: articleSearchKeywords
        )
    }
    
    public func add(category: Resource.Category) {
        articleCategories.append(category)
    }
    
    public func add(keyword: SearchKeyword) {
        articleSearchKeywords.append(keyword)
    }
}
