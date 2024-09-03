//
//  Article.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

struct Article: Identifiable, Hashable {
    
    let id: String
    let author: String
    let title: String
    let coverImageUrl: URL
    let summary: Resource.Summary
    let markdownContent: String
    let publicationDate: Date
}

extension Article {
    static let sample: Article = .init(
        id: UUID().uuidString,
        author: "userId",
        title: "Sample KnowledgeBaseContent Title",
        coverImageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/BlogPostImages%2F2024.01.11.OriginsAndHistoricalContext.jpg?alt=media&token=a3755dcb-9920-493f-8888-af0650462782")!,
        summary: .init("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")!,
        markdownContent: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        publicationDate: .now
    )
    static let sample2: Article = .init(
        id: UUID().uuidString,
        author: "userId2",
        title: "Another Sample KnowledgeBaseContent Title",
        coverImageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/BlogPostImages%2F2024.01.09.PlanningAndBudgetingForTheCarnivoreDiet.jpg?alt=media&token=8abc332b-3618-4ead-8ba0-8683c2d4b71f")!,
        summary: .init("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")!,
        markdownContent: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        publicationDate: .now
    )
}
