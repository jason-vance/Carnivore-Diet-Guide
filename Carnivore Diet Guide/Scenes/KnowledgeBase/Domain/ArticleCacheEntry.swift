//
//  ArticleCacheEntry.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/4/24.
//

import Foundation

struct ArticleCacheEntry: Codable {
    let id: String?
    let author: String?
    let title: String?
    let coverImageUrl: String?
    let summary: String?
    let markdownContent: String?
    let publicationDate: Date?
    let categories: Set<Resource.Category>?
    let keywords: Set<SearchKeyword>?
    
    static func from(
        _ article: Article
    ) -> ArticleCacheEntry {
        return .init(
            id: article.id,
            author: article.author,
            title: article.title,
            coverImageUrl: article.coverImageUrl.absoluteString,
            summary: article.summary.text,
            markdownContent: article.markdownContent,
            publicationDate: article.publicationDate,
            categories: article.categories,
            keywords: article.keywords
        )
    }
    
    func toArticle() -> Article? {
        guard let id = id else { return nil }
        guard let author = author else { return nil }
        guard let title = title else { return nil }
        guard let coverImageUrl = URL(string: coverImageUrl ?? "") else { return nil }
        guard let summaryText = summary else { return nil }
        guard let summary = Resource.Summary(summaryText) else { return nil }
        guard let markdownContent = markdownContent else { return nil }
        guard let publicationDate = publicationDate else { return nil }
        guard let categories = categories else { return nil }
        guard let keywords = keywords else { return nil }
        
        return Article(
            id: id,
            author: author,
            title: title,
            coverImageUrl: coverImageUrl,
            summary: summary,
            markdownContent: markdownContent,
            publicationDate: publicationDate,
            categories: categories,
            keywords: keywords
        )
    }
}
