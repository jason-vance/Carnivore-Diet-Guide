//
//  ResourceCommentActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation

protocol ResourceCommentActivityTracker {
    func resource(
        _ resource: CommentSectionResource,
        wasCommentedOnByUser userId: String
    ) async throws
}

class DefaultResourceCommentActivityTracker: ResourceCommentActivityTracker {
    
    private let activityTracker: RecipeCommentActivityTracker
    
    init(activityTracker: RecipeCommentActivityTracker) {
        self.activityTracker = activityTracker
    }
    
    func resource(_ resource: CommentSectionResource, wasCommentedOnByUser userId: String) async throws {
        switch resource.type {
        case .recipe:
            try await recipe(resource.id, wasCommentedOnByUser: userId)
        case .post:
            return
        }
    }
    
    private func recipe(_ recipeId: String, wasCommentedOnByUser userId: String) async throws {
        try await activityTracker.recipe(recipeId, wasCommentedOnByUser: userId)
    }
}
