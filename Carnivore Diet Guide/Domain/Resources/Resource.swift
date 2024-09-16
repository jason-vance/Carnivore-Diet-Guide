//
//  Resource.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation

struct Resource: Equatable {
    
    enum ResourceType: String, Codable {
        case post
        case recipe
        case article
    }
    
    let id: String
    let author: String
    let publicationDate: Date
    let title: String
    let type: ResourceType
    
    static let sample: Resource = .init(
        id: "resourceId",
        author: "authorUserId",
        publicationDate: .now,
        title: "Sample Resource",
        type: .post
    )
}

extension Resource {
    
    init(_ post: Post) {
        self.init(
            id: post.id,
            author: post.author,
            publicationDate: post.publicationDate,
            title: post.title,
            type: .post
        )
    }
    
    init(_ recipe: Recipe) {
        self.init(
            id: recipe.id,
            author: recipe.author,
            publicationDate: recipe.publicationDate,
            title: recipe.title,
            type: .recipe
        )
    }
    
    init(_ article: Article) {
        self.init(
            id: article.id,
            author: article.author,
            publicationDate: article.publicationDate,
            title: article.title,
            type: .article
        )
    }
    
    init(_ feedItem: FeedItem) {
        self.init(
            id: feedItem.resourceId,
            author: feedItem.userId,
            publicationDate: feedItem.publicationDate,
            title: feedItem.title,
            type: feedItem.type
        )
    }
}

extension Resource {
    enum Errors: Error {
        case doesNotExist
    }
}
