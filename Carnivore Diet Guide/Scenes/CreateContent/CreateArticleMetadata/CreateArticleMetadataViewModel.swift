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
    
    @Published public var articleTitle: String = ""
    @Published public var articleContent: String = ""
    @Published public var articleSummary: Resource.Summary? = nil
    @Published public var articlePublicationDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
    @Published public var articleCategories: Set<Resource.Category> = []
    
    public var articleSearchKeywords: Set<SearchKeyword> {
        let keywordText = "\(articleTitle)\n\(articleContent)\n\(articleSummary?.text ?? "")"
        return SearchKeyword.keywordsFrom(string: keywordText)
    }
    
    public var isFormChanged: Bool {
        articleSummary != nil 
        || articleCategories.count > 0
    }
    
    public func getArticleMetadata(id: UUID) -> ArticleMetadata? {
        guard let articleSummary = articleSummary else { return nil }
        guard !articleCategories.isEmpty else { return nil }
        guard !articleSearchKeywords.isEmpty else { return nil }

        return .init(
            id: id,
            summary: articleSummary,
            publicationDate: articlePublicationDate,
            categories: articleCategories
        )
    }
    
    public func set(title: String, markdownContent: String) {
        self.articleTitle = title
        self.articleContent = markdownContent.stripMarkdown()
    }
    
    public func add(category: Resource.Category) {
        articleCategories.insert(category)
    }
    
    public func remove(category: Resource.Category) {
        articleCategories.remove(category)
    }
}
