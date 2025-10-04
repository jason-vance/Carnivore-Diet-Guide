//
//  FirebaseFeaturedArticlesDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/9/24.
//

import Foundation
import FirebaseFirestore

struct FirebaseFeaturedArticlesDoc: Codable {
    
    @DocumentID var id: String?
    var sections: [Section]?
    var publicationDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sections
        case publicationDate
    }
    
    public static func from(_ featuredArticles: FeaturedArticles) -> FirebaseFeaturedArticlesDoc {
        .init(
            sections: featuredArticles.sections.map { Section.from($0) },
            publicationDate: featuredArticles.publicationDate
        )
    }
    
    public func toFeaturedArticles() async -> FeaturedArticles? {
        guard let publicationDate = publicationDate else { return nil }
        guard let sections = sections else { return nil }
        
        var mappedSections: [FeaturedArticles.Section] = []
        for section in sections {
            guard let mappedSection = await section.toSection() else { continue }
            mappedSections.append(mappedSection)
        }

        return .init(
            sections: mappedSections,
            publicationDate: publicationDate
        )
    }
}

extension FirebaseFeaturedArticlesDoc {
    struct Section: Codable {
        var layout: String?
        var title: String?
        var description: String?
        var items: [Item]?
        
        enum CodingKeys: String, CodingKey {
            case layout
            case title
            case description
            case items
        }
        
        static func from(_ section: FeaturedArticles.Section) -> Section {
            .init(
                layout: section.layout.rawValue,
                title: section.title.title,
                description: section.description?.description,
                items: section.content.map { Item.from($0) }
            )
        }
        
        func toSection() async -> FeaturedArticles.Section? {
            guard let layout = FeaturedArticles.Section.Layout(rawValue: layout ?? "") else { return nil }
            guard let title = FeaturedSectionTitle(title ?? "") else { return nil }
            let description = FeaturedSectionDescription(description ?? "")
            guard let items = items else { return nil }
            
            var mappedItems: [FeaturedArticles.Section.Item] = []
            for item in items {
                guard let mappedItem = await item.toItem() else { continue }
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

extension FirebaseFeaturedArticlesDoc.Section {
    struct Item: Codable {
        var articleId: String?
        var prominence: String?
        
        enum CodingKeys: String, CodingKey {
            case articleId
            case prominence
        }
        
        static func from(_ item: FeaturedArticles.Section.Item) -> Item {
            .init(
                articleId: item.article.id,
                prominence: item.prominence.rawValue
            )
        }
        
        func toItem() async -> FeaturedArticles.Section.Item? {
            guard let articleLibrary = iocContainer.resolve(ArticleLibrary.self) else { return nil }
            guard let article = await articleLibrary.getArticle(byId: articleId ?? "") else { return nil }
            guard let prominence = FeaturedArticles.Section.Item.Prominence(rawValue: prominence ?? "") else { return nil }
            
            return .init(id: UUID(), article: article, prominence: prominence)
        }
    }
}

