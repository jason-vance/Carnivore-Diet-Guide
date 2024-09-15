//
//  FirebaseArticleDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseArticleDoc: Codable {
    
    @DocumentID var id: String?
    var isPremium: Bool?
    var author: String?
    var title: String?
    var coverImageUrl: String?
    var summary: String?
    var markdownContent: String?
    var publicationDate: Date?
    var categories: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isPremium
        case author
        case title
        case coverImageUrl
        case summary
        case markdownContent
        case publicationDate
        case categories
    }
    
    static func from(
        article: Article
    ) -> FirebaseArticleDoc {
        return .init(
            id: article.id,
            isPremium: article.isPremium,
            author: article.author,
            title: article.title,
            coverImageUrl: article.coverImageUrl.absoluteString,
            summary: article.summary.text,
            markdownContent: article.markdownContent,
            publicationDate: article.publicationDate,
            categories: article.categories.map { $0.id }
        )
    }
    
    func toArticle(categoryDict: Dictionary<String,Resource.Category>) -> Article? {
        guard let id = id else { return nil }
        guard let author = author else { return nil }
        guard let title = title else { return nil }
        guard let coverImageUrl = URL(string: coverImageUrl ?? "") else { return nil }
        guard let summaryText = summary else { return nil }
        guard let summary = Resource.Summary(summaryText) else { return nil }
        guard let markdownContent = markdownContent else { return nil }
        guard let publicationDate = publicationDate else { return nil }
        guard let categories = (categories?.compactMap { categoryId in categoryDict[categoryId] }) else { return nil }

        return Article(
            id: id,
            isPremium: isPremium ?? true,
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
