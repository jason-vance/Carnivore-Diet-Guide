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
            try await deletePost(forResource: resource)
        case .recipe:
            try await deleteRecipe(withId: resource.id)
        }
    }
    
    private func deleteFeedItem(for resource: Resource) async throws {
        let repo = FirebaseFeedItemRepository()
        try await repo.deleteFeedItem(forResource: resource)
    }
    
    private func deletePost(forResource resource: Resource) async throws {
        let postId = resource.id
        let userId = resource.authorUserId
        
        let repo = FirebasePostRepository()
        try await repo.deletePost(withId: postId)
        
        Task {
            do {
                let storage = FirebasePostImageStorage()
                try await storage.deleteImages(forPost: postId, byUser: userId)
            } catch {
                print("Failed to delete images. \(error.localizedDescription)")
            }
        }
        
    }
    
    private func deleteRecipe(withId recipeId: String) async throws {
        let repo = FirebaseRecipeRepository()
        try await repo.deleteRecipe(withId: recipeId)
    }
}
