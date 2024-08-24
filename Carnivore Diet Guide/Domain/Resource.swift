//
//  Resource.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import Foundation

struct Resource: Equatable {
    
    enum ResourceType {
        case post
//        case recipe
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
