//
//  FirebaseCommentCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import Foundation

class FirebaseCommentCountProvider: CommentCountProvider {

    private let commentsRepo = FirebaseCommentRepository()

    func commentCount(of resource: Resource) async throws -> UInt {
        try await commentsRepo.getCommentCountOf(resource: resource)
    }
}
