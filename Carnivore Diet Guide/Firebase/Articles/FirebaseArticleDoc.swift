//
//  FirebaseArticleDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirebaseArticleDoc: Codable {
    
    struct Keyword: Codable {
        var text: String?
        var score: UInt?
        
        enum CodingKeys: String, CodingKey {
            case text
            case score
        }
    }
    
    @DocumentID var id: String?
    var author: String?
    var title: String?
    var coverImageUrl: String?
    var summary: String?
    var markdownContent: String?
    var publicationDate: Date?
    var categories: [String]?
    var keywords: Dictionary<String,Keyword>?
    
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
    
    static func from(_ article: Article) -> FirebaseArticleDoc {
        var keywordDict = Dictionary<String,Keyword>()
        for keyword in article.keywords {
            keywordDict[keyword.text] = .init(text: keyword.text, score: keyword.score)
        }
        
        return .init(
            id: article.id,
            author: article.author,
            title: article.title,
            coverImageUrl: article.coverImageUrl.absoluteString,
            summary: article.summary.text,
            markdownContent: article.markdownContent,
            publicationDate: article.publicationDate,
            categories: article.categories.map { $0.id },
            keywords: keywordDict
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

        //TODO: Should I remove categories and keywords from Article
        return Article(
            id: id,
            author: author,
            title: title,
            coverImageUrl: coverImageUrl,
            summary: summary,
            markdownContent: markdownContent,
            publicationDate: publicationDate,
            categories: [],
            keywords: []
        )
    }
}
