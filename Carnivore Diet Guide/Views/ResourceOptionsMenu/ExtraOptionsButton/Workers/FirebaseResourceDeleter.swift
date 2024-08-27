//
//  FirebaseResourceDeleter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import Foundation

class FirebaseResourceDeleter: ResourceDeleter {
    
    func delete(resource: Resource) async throws {
        try await deleteFeedItem(for: resource)
        
        switch resource.type {
        case .post:
            try await deletePost(withId: resource.id)
        case .recipe:
            try await deleteRecipe(withId: resource.id)
        }
        
        //TODO: Delete resource's images too
    }
    
    private func deleteFeedItem(for resource: Resource) async throws {
        let repo = FirebaseFeedItemRepository()
        try await repo.deleteFeedItem(forResource: resource)
    }
    
    private func deletePost(withId postId: String) async throws {
        let repo = FirebasePostRepository()
        try await repo.deletePost(withId: postId)
    }
    
    private func deleteRecipe(withId recipeId: String) async throws {
        let repo = FirebaseRecipeRepository()
        try await repo.deleteRecipe(withId: recipeId)
    }
}
