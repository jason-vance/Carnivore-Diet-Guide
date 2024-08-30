//
//  Resource.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation

struct Resource: Equatable {
    
    enum ResourceType: String {
        case post
        case recipe
        case article
    }
    
    let id: String
    let authorUserId: String
    let publicationDate: Date
    let title: String
    let type: ResourceType
    
    static let sample: Resource = .init(
        id: "resourceId",
        authorUserId: "authorUserId",
        publicationDate: .now,
        title: "Sample Resource",
        type: .post
    )
}

extension Resource {
    
    init(_ post: Post) {
        self.init(
            id: post.id,
            authorUserId: post.author,
            publicationDate: post.publicationDate,
            title: post.title,
            type: .post
        )
    }
    
    init(_ recipe: Recipe) {
        self.init(
            id: recipe.id,
            authorUserId: recipe.authorUserId,
            publicationDate: recipe.publicationDate,
            title: recipe.title,
            type: .recipe
        )
    }
    
    init(_ article: Article) {
        self.init(
            id: article.id,
            authorUserId: article.author,
            publicationDate: article.publicationDate,
            title: article.title,
            type: .article
        )
    }
    
    init(_ feedItem: FeedItem) {
        self.init(
            id: feedItem.resourceId,
            authorUserId: feedItem.userId,
            publicationDate: feedItem.publicationDate,
            title: feedItem.title,
            type: feedItem.type
        )
    }
}
