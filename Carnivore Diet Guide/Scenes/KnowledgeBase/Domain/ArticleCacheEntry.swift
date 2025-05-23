//
//  ArticleCacheEntry.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/4/24.
//

import Foundation

struct ArticleCacheEntry: Codable {
    
    private static var randomRefreshAfterDate: Date {
        let minLifetimeDays = 5
        let maxLifetimeDays = 9
        let days = Int.random(in: minLifetimeDays...maxLifetimeDays)
        return Calendar.current.date(byAdding: .day, value: days, to: .now)!
    }
    
    let refreshAfterDate: Date?
    
    let id: String?
    let isPremium: Bool?
    let author: String?
    let title: String?
    let coverImageUrl: String?
    let summary: String?
    let markdownContent: String?
    let publicationDate: Date?
    let categories: Set<Resource.Category>?
    
    static func from(
        _ article: Article
    ) -> ArticleCacheEntry {
        return .init(
            refreshAfterDate: Self.randomRefreshAfterDate,
            id: article.id,
            isPremium: article.isPremium,
            author: article.author,
            title: article.title,
            coverImageUrl: article.coverImageUrl.absoluteString,
            summary: article.summary.text,
            markdownContent: article.markdownContent,
            publicationDate: article.publicationDate,
            categories: article.categories
        )
    }
    
    func toArticle() -> Article? {
        guard let id = id else { return nil }
        guard let isPremium = isPremium else { return nil }
        guard let author = author else { return nil }
        guard let title = title else { return nil }
        guard let coverImageUrl = URL(string: coverImageUrl ?? "") else { return nil }
        guard let summaryText = summary else { return nil }
        guard let summary = Resource.Summary(summaryText) else { return nil }
        guard let markdownContent = markdownContent else { return nil }
        guard let publicationDate = publicationDate else { return nil }
        guard let categories = categories else { return nil }
        
        return Article(
            id: id,
            isPremium: isPremium,
            author: author,
            title: title,
            coverImageUrl: coverImageUrl,
            summary: summary,
            markdownContent: markdownContent,
            publicationDate: publicationDate,
            categories: categories
        )
    }
}
