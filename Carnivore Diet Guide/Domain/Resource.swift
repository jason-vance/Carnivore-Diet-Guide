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
//        case article
//        case user (?)
    }
    
    let id: String
    let authorUserId: String
    let title: String
    let type: ResourceType
    
    static let sample: Resource = .init(
        id: "resourceId",
        authorUserId: "authorUserId",
        title: "Sample Resource",
        type: .post
    )
}

extension Resource {
    
    init(_ post: Post) {
        self.init(
            id: post.id,
            authorUserId: post.author,
            title: post.title,
            type: .post
        )
    }
    
    init(_ recipe: Recipe) {
        self.init(
            id: recipe.id,
            authorUserId: recipe.authorUserId,
            title: recipe.title,
            type: .recipe
        )
    }
}
