//
//  FirebaseResourceDeleter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import Foundation
import Combine

class FirebaseResourceDeleter: ResourceDeleter {
    
    public static let instance: FirebaseResourceDeleter = .init()
    public static func getInstance() -> FirebaseResourceDeleter { instance }
    
    private var deletedResourceSubject: CurrentValueSubject<Resource?, Never> = .init(nil)
    public var deletedResourcePublisher: AnyPublisher<Resource, Never> {
        deletedResourceSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private init() {}
    
    func delete(resource: Resource) async throws {
        try await deleteFeedItem(for: resource)
        
        switch resource.type {
        case .article:
            try await deleteArticle(for: resource)
        case .post:
            try await deletePost(for: resource)
        case .recipe:
            try await deleteRecipe(for: resource)
        }
        deleteImagesUnsafely(for: resource)
        deleteResourceActivitiesUnsafely(for: resource)
        
        deletedResourceSubject.send(resource)
    }
    
    private func deleteResourceActivitiesUnsafely(for resource: Resource) {
        Task {
            let repo = FirebaseResourceActivityRepository()
            try? await repo.deleteActivites(for: resource)
        }
    }
    
    private func deleteImagesUnsafely(for resource: Resource) {
        Task {
            do {
                let storage = FirebasePostImageStorage()
                try await storage.deleteImages(forPost: resource.id, byUser: resource.author)
            } catch {
                print("Failed to delete \(resource.type) images. \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteFeedItem(for resource: Resource) async throws {
        let repo = FirebaseFeedItemRepository()
        try await repo.deleteFeedItem(forResource: resource)
    }
    
    private func deleteArticle(for resource: Resource) async throws {
        let repo = FirebaseArticleRepository()
        try await repo.deleteArticle(withId: resource.id)
    }
    
    private func deletePost(for resource: Resource) async throws {
        let repo = FirebasePostRepository()
        try await repo.deletePost(withId: resource.id)
    }
    
    private func deleteRecipe(for resource: Resource) async throws {
        let repo = FirebaseRecipeRepository()
        try await repo.deleteRecipe(withId: resource.id)
    }
}
