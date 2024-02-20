//
//  ResourceCommentActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation
import SwinjectAutoregistration

protocol ResourceCommentActivityTracker {
    func resource(
        _ resource: CommentSectionView.Resource,
        wasCommentedOnByUser userId: String
    ) async throws
}

class DefaultResourceCommentActivityTracker: ResourceCommentActivityTracker {
    
    func resource(_ resource: CommentSectionView.Resource, wasCommentedOnByUser userId: String) async throws {
        switch resource.type {
        case .recipe:
            try await recipe(resource.id, wasCommentedOnByUser: userId)
        case .post:
            //TODO: try await post(resource.id, wasCommentedOnByUser: userId)
            return
        }
    }
    
    private func recipe(_ recipeId: String, wasCommentedOnByUser userId: String) async throws {
        let recipeActivityRepo = iocContainer~>RecipeCommentActivityTracker.self
        try await recipeActivityRepo.recipe(recipeId, wasCommentedOnByUser: userId)
    }
}
