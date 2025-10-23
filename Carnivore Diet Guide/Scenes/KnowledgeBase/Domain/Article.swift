//
//  Article.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

struct Article: Identifiable, Hashable {
    
    struct Citation: Codable, Identifiable, Hashable {
        
        var id: URL { url }
        
        let url: URL
        
        init?(_ text: String) {
            guard let url = URL(string: text) else { return nil }
            self.url = url
        }
        
        static let sample: Citation = .init("https://www.lipsum.com/")!
    }
    
    let id: String
    let isPremium: Bool
    let author: String
    let title: String
    let coverImageUrl: URL
    let summary: Resource.Summary
    let markdownContent: String
    let publicationDate: Date
    let categories: Set<Resource.Category>
    let keywords: Set<SearchKeyword>
    let citations: [Citation]
    
    init(
        id: String,
        isPremium: Bool,
        author: String,
        title: String,
        coverImageUrl: URL,
        summary: Resource.Summary,
        markdownContent: String,
        publicationDate: Date,
        categories: Set<Resource.Category>,
        citations: [Citation]
    ) {
        self.id = id
        self.isPremium = isPremium
        self.author = author
        self.title = title
        self.coverImageUrl = coverImageUrl
        self.summary = summary
        self.markdownContent = markdownContent
        self.publicationDate = publicationDate
        self.categories = categories
        self.citations = citations
        
        let string = "\(title)\n\(summary.text)\n\(markdownContent.stripMarkdown())"
        self.keywords = SearchKeyword.keywordsFrom(string: string)
    }
}

extension Article {
    static let sample: Article = .init(
        id: UUID().uuidString,
        isPremium: false,
        author: "userId",
        title: "Sample KnowledgeBaseContent Title",
        coverImageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/BlogPostImages%2F2024.01.11.OriginsAndHistoricalContext.jpg?alt=media&token=a3755dcb-9920-493f-8888-af0650462782")!,
        summary: .init("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")!,
        markdownContent: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        publicationDate: .now,
        categories: Resource.Category.samples,
        citations: []
    )
    static let sample2: Article = .init(
        id: UUID().uuidString,
        isPremium: true,
        author: "userId2",
        title: "Another Sample KnowledgeBaseContent Title",
        coverImageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/BlogPostImages%2F2024.01.09.PlanningAndBudgetingForTheCarnivoreDiet.jpg?alt=media&token=8abc332b-3618-4ead-8ba0-8683c2d4b71f")!,
        summary: .init("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")!,
        markdownContent: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        publicationDate: .now,
        categories: Resource.Category.samples,
        citations: []
    )
}
