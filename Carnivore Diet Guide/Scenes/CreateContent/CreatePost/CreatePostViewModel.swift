//
//  CreatePostViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
class CreatePostViewModel: ObservableObject {
    
    private let imageCountLimit: Int = 5
    
    @Published public var postId: String = UUID().uuidString
    @Published public var postTitle: String = ""
    @Published public var postImages: [CreatePostImageData] = []
    @Published public var postText: String = ""
    
    private let userIdProvider: CurrentUserIdProvider
    private let imageUploader: PostImageUploader
    
    init(
        userIdProvider: CurrentUserIdProvider,
        imageUploader: PostImageUploader
    ) {
        self.userIdProvider = userIdProvider
        self.imageUploader = imageUploader
    }
    
    private var userId: String? { userIdProvider.currentUserId }
    
    public var isFormEmpty: Bool {
        postTitle.isEmpty && postText.isEmpty && postImages.isEmpty
    }
    
    public var canAddImages: Bool { postImages.count < imageCountLimit }
    
    public var reviewPostData: ReviewPostData? {
        guard let userId = userId else { return nil }
        
        guard !postTitle.isEmpty else { return nil }
        
        guard !postText.isEmpty else { return nil }
        
        let imageUrls = postImages.compactMap({ $0.url })
        guard imageUrls.count == postImages.count else { return nil }
        
        return ReviewPostData(
            id: postId,
            userId: userId,
            title: postTitle,
            markdownContent: postText,
            imageUrls: imageUrls
        )
    }
    
    public func addToPost(image: UIImage) {
        guard postImages.count < imageCountLimit else { return }
        guard let userId = userId else { return }

        let imageData = CreatePostImageData(image: image)

        withAnimation(.snappy) {
            postImages.append(imageData)
        }
        
        Task {
            do {
                let imageUrl = try await imageUploader.upload(
                    image: imageData.image,
                    withId: imageData.id,
                    forPost: postId,
                    byUser: userId
                )
                
                guard let index = postImages.firstIndex(where: { $0.id == imageData.id }) else { return }
                postImages.remove(at: index)
                
                let imageData = CreatePostImageData(id: imageData.id, image: image, url: imageUrl)
                postImages.insert(imageData, at: index)
            } catch {
                print("Image failed to upload: \(error.localizedDescription)")
                withAnimation(.snappy) {
                    postImages.removeAll { $0.id == imageData.id }
                }
            }
        }
    }
    
    public func removeFromPost(image: CreatePostImageData) {
        guard let userId = userId else { return }
        guard let index = postImages.firstIndex(where: { $0.id == image.id }) else { return }
        
        withAnimation(.snappy) {
            postImages.removeAll { $0.id == image.id }
        }
        
        Task {
            do {
                try await imageUploader.delete(
                    image: image.id,
                    forPost: postId,
                    byUser: userId
                )
            } catch {
                print("Image failed to delete: \(error.localizedDescription)")
                withAnimation(.snappy) {
                    postImages.insert(image, at: min(index, postImages.count))
                }
            }
        }
    }
    
    public func deleteImagesUnsafely() {
        guard let userId = userId else { return }
        
        postImages.forEach { image in
            guard let _ = image.url else { return }
            Task { try? await imageUploader.delete(image: image.id, forPost: postId, byUser: userId) }
        }
    }
}
