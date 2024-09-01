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
    
    private var originalSearchKeywords: Set<SearchKeyword> = []
    
    public var isFormChanged: Bool {
        articleSummary != nil 
        || articleCategories.count > 0
        || articleSearchKeywords != originalSearchKeywords
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
    
    public func set(markdownContent: String) {
        var dict = Dictionary<String, UInt>()
        
        markdownContent
            .stripMarkdown()
            .lemmatized()
            .forEach { token in
                dict[token] = dict[token, default: 0] + 1
            }
        
        var keywords = Set<SearchKeyword>()
        dict.forEach { key, value in
            guard let keyword = SearchKeyword(key, score: value) else {
                return
            }
            keywords.insert(keyword)
        }
        
        originalSearchKeywords = Set(
            keywords
                .sorted { $0.score > $1.score }
                .prefix(50)
        )
        articleSearchKeywords = originalSearchKeywords
    }
    
    public func add(category: Resource.Category) {
        articleCategories.insert(category)
    }
    
    public func remove(category: Resource.Category) {
        articleCategories.remove(category)
    }
}
