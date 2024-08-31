//
//  CreateArticleMetadataViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation
import SwiftUI

@MainActor
class CreateArticleMetadataViewModel: ObservableObject {
    
    
    @Published public var articleSummary: Resource.Summary? = nil
    @Published public var articleCategories: Set<Resource.Category> = []
    @Published public var articleSearchKeywords: Set<SearchKeyword> = []
    
    public var isFormEmpty: Bool {
        articleSummary == nil && articleCategories.isEmpty && articleSearchKeywords.isEmpty
    }
    
    public func getContentMetadata(id: UUID) -> ContentMetadata? {
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
        articleCategories.insert(category)
    }
    
    public func remove(category: Resource.Category) {
        articleCategories.remove(category)
    }
    
    public func add(keyword: SearchKeyword) {
        articleSearchKeywords.insert(keyword)
    }
}
