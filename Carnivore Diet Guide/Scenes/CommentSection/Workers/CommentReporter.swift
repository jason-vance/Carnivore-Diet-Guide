//
//  CommentReporter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation

protocol CommentReporter {
    func reportComment(
        _ comment: Comment,
        onResource resource: CommentSectionView.Resource,
        reportedBy reporterId: String
    ) async throws
}

class MockCommentReporter: CommentReporter {
    
    var error: Error?
    
    func reportComment(
        _ comment: Comment,
        onResource resource: CommentSectionView.Resource,
        reportedBy reporterId: String
    ) async throws {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
    }
}
