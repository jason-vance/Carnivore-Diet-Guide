//
//  CommentSender.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/9/24.
//

import Foundation

protocol CommentSender {
    func sendComment(
        text: String,
        toResource resource: Resource
    ) async throws
}

class MockCommentSender: CommentSender {
    
    var errorToThrowOnSend: Error?
    
    func sendComment(
        text: String,
        toResource resource: Resource
    ) async throws {
        try await Task.sleep(for: .seconds(1))
        if let error = errorToThrowOnSend {
            throw error
        }
    }
}
