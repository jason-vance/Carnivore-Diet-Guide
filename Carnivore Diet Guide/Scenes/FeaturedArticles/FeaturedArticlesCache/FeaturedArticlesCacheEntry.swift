//
//  FeaturedArticlesCacheEntry.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/24/24.
//

import Foundation

struct FeaturedArticlesCacheEntry: Codable {
    
    var sections: [Section]?
    var publicationDate: Date?
    
    public static func from(_ featuredArticles: FeaturedArticles) -> FeaturedArticlesCacheEntry {
        .init(
            sections: featuredArticles.sections.map { Section.from($0) },
            publicationDate: featuredArticles.publicationDate
        )
    }
    
    public func toFeaturedArticles() -> FeaturedArticles? {
        guard let publicationDate = publicationDate else { return nil }
        guard let sections = sections else { return nil }
        
        var mappedSections: [FeaturedArticles.Section] = []
        for section in sections {
            guard let mappedSection = section.toSection() else { continue }
            mappedSections.append(mappedSection)
        }

        return .init(
            sections: mappedSections,
            publicationDate: publicationDate
        )
    }
}

extension FeaturedArticlesCacheEntry {
    struct Section: Codable {
        var layout: String?
        var title: String?
        var description: String?
        var items: [Item]?
        
        static func from(_ section: FeaturedArticles.Section) -> Section {
            .init(
                layout: section.layout.rawValue,
                title: section.title.title,
                description: section.description?.description,
                items: section.content.map { Item.from($0) }
            )
        }
        
        func toSection() -> FeaturedArticles.Section? {
            guard let layout = FeaturedArticles.Section.Layout(rawValue: layout ?? "") else { return nil }
            guard let title = FeaturedSectionTitle(title ?? "") else { return nil }
            let description = FeaturedSectionDescription(description ?? "")
            guard let items = items else { return nil }
            
            var mappedItems: [FeaturedArticles.Section.Item] = []
            for item in items {
                guard let mappedItem = item.toItem() else { continue }
                mappedItems.append(mappedItem)
            }

            return .init(
                id: UUID(),
                layout: layout,
                title: title,
                description: description,
                content: mappedItems
            )
        }
    }
}

extension FeaturedArticlesCacheEntry.Section {
    struct Item: Codable {
        var article: Article?
        var prominence: String?
        
        static func from(_ item: FeaturedArticles.Section.Item) -> Item {
            .init(
                article: .from(article: item.article),
                prominence: item.prominence.rawValue
            )
        }
        
        func toItem() -> FeaturedArticles.Section.Item? {
            guard let articleLibrary = iocContainer.resolve(ArticleLibrary.self) else { return nil }
            guard let article = article?.toArticle() else { return nil }
            guard let prominence = FeaturedArticles.Section.Item.Prominence(rawValue: prominence ?? "") else { return nil }
            
            return .init(id: UUID(), article: article, prominence: prominence)
        }
    }
}



extension FeaturedArticlesCacheEntry.Section.Item {
    struct Article: Codable {
        var id: String?
        var isPremium: Bool?
        var author: String?
        var title: String?
        var coverImageUrl: String?
        var summary: String?
        var markdownContent: String?
        var publicationDate: Date?
        var categories: [Resource.Category]?
        
        static func from(article: Carnivore_Diet_Guide.Article) -> Article {
            return .init(
                id: article.id,
                isPremium: article.isPremium,
                author: article.author,
                title: article.title,
                coverImageUrl: article.coverImageUrl.absoluteString,
                summary: article.summary.text,
                markdownContent: article.markdownContent,
                publicationDate: article.publicationDate,
                categories: Array(article.categories)
            )
        }
        
        func toArticle() -> Carnivore_Diet_Guide.Article? {
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
            
            return .init(
                id: id,
                isPremium: isPremium,
                author: author,
                title: title,
                coverImageUrl: coverImageUrl,
                summary: summary,
                markdownContent: markdownContent,
                publicationDate: publicationDate,
                categories: Set(categories)
            )
        }
    }
}

