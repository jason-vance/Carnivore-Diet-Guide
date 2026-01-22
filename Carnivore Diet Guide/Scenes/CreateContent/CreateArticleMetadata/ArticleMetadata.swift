//
//  ArticleMetadata.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

struct ArticleMetadata: Hashable {
    
    public let id: UUID
    public let summary: Resource.Summary
    public let publicationDate: Date
    public let categories: Set<Resource.Category>
    public let citations: [Article.Citation]
    
    public static let sample: ArticleMetadata = .init(
        id: UUID(),
        summary: .sample,
        publicationDate: .now,
        categories: Resource.Category.samples,
        citations: []
    )
}

