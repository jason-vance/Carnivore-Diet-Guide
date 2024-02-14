//
//  CommentDeleter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/13/24.
//

import Foundation

protocol CommentDeleter {
    func deleteComment(_ comment: Comment, onResource resource: CommentSectionView.Resource) async throws
}

class MockCommentDeleter: CommentDeleter {
    
    var error: Error?
    
    func deleteComment(_ comment: Comment, onResource resource: CommentSectionView.Resource) async throws {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
    }
}
