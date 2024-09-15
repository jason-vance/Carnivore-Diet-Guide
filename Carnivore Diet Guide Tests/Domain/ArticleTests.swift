//
//  ArticleTests.swift
//  Carnivore Diet Guide Tests
//
//  Created by Jason Vance on 9/11/24.
//

import XCTest

final class ArticleTests: XCTestCase {
    
    func testBasicKeywordRelevance() {
        let keyword = SearchKeyword("title")!
        
        let article = Article(
            id: Article.sample.id,
            isPremium: true,
            author: Article.sample.author,
            title: "Title",
            coverImageUrl: Article.sample.coverImageUrl,
            summary: .init("The article summary")!,
            markdownContent: "Content",
            publicationDate: Article.sample.publicationDate,
            categories: Article.sample.categories
        )
        
        let relevance = article.relevanceTo(Set([keyword]))
        XCTAssertEqual(1, relevance)
    }
    
    func testHigherKeywordRelevance() {
        let keywords = SearchKeyword.keywordsFrom(string: "title")
        
        let article = Article(
            id: Article.sample.id,
            isPremium: true,
            author: Article.sample.author,
            title: "Title",
            coverImageUrl: Article.sample.coverImageUrl,
            summary: .init("The article summary with title")!,
            markdownContent: "Content title",
            publicationDate: Article.sample.publicationDate,
            categories: Article.sample.categories
        )
        
        let relevance = article.relevanceTo(keywords)
        XCTAssertEqual(3, relevance)
    }

}
