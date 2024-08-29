//
//  KnowledgeBaseContent.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import Foundation

struct KnowledgeBaseContent {
    
    let id: String
    let author: String
    let title: String
    let coverImageUrl: URL
    let markdownContent: String
    let publicationDate: Date
    let tags: [ContentTag]
}

extension KnowledgeBaseContent {
    static let sample: KnowledgeBaseContent = .init(
        id: UUID().uuidString,
        author: "userId",
        title: "Sample Knowledge-Base Content Title",
        coverImageUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/carnivore-diet-guide.appspot.com/o/BlogPostImages%2F2024.01.11.OriginsAndHistoricalContext.jpg?alt=media&token=a3755dcb-9920-493f-8888-af0650462782")!,
        markdownContent: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        publicationDate: .now,
        tags: [
            ContentTag("Meals")!,
            ContentTag("How")!
        ]
    )
}
