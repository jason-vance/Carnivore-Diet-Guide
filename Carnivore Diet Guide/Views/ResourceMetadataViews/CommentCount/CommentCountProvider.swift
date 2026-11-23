//
//  CommentCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import Foundation

/// Fetches how many comments a resource has. `ResourceCountStore.comments` keeps the counts.
protocol CommentCountProvider {
    func commentCount(of resource: Resource) async throws -> UInt
}

class MockCommentCountProvider: CommentCountProvider {

    var commentCount: UInt = 0

    func commentCount(of resource: Resource) async throws -> UInt { commentCount }
}
