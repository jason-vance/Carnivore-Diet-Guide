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
    var author: String?
    var title: String?
    var coverImageUrl: String?
    var summary: String?
    var markdownContent: String?
    var publicationDate: Date?
    var categories: [String]?
    var keywords: Dictionary<String,UInt>?
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case title
        case coverImageUrl
        case summary
        case markdownContent
        case publicationDate
        case categories
        case keywords
    }
    
    static func from(
        article: Article,
        categories: Set<Resource.Category>,
        keywords: Set<SearchKeyword>
    ) -> FirebaseArticleDoc {
        var keywordDict = Dictionary<String,UInt>()
        for keyword in keywords {
            keywordDict[keyword.text] = keyword.score
        }
        
        return .init(
            id: article.id,
            author: article.author,
            title: article.title,
            coverImageUrl: article.coverImageUrl.absoluteString,
            summary: article.summary.text,
            markdownContent: article.markdownContent,
            publicationDate: article.publicationDate,
            categories: categories.map { $0.id },
            keywords: keywordDict
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
        guard let keywords = (keywords?.compactMap { entry in SearchKeyword(entry.key, score: entry.value) }) else { return nil }

        return Article(
            id: id,
            author: author,
            title: title,
            coverImageUrl: coverImageUrl,
            summary: summary,
            markdownContent: markdownContent,
            publicationDate: publicationDate,
            categories: Set(categories),
            keywords: Set(keywords)
        )
    }
}
