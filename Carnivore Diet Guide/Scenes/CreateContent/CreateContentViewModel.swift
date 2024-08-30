//
//  CreateContentViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
class CreateContentViewModel: ObservableObject {
    
    private let imageCountLimit: Int = 5
    
    @Published public var contentId: UUID = UUID()
    @Published public var contentType: Resource.ResourceType = .post
    @Published public var contentTitle: String = ""
    @Published public var contentImages: [ContentCreationImageData] = []
    @Published public var contentText: String = ""
    
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
        contentTitle.isEmpty && contentText.isEmpty && contentImages.isEmpty
    }
    
    public var canAddImages: Bool { contentImages.count < imageCountLimit }
    
    public var contentData: ContentData? {
        guard let userId = userId else { return nil }
        
        guard !contentTitle.isEmpty else { return nil }
        
        guard !contentText.isEmpty else { return nil }
        
        let imageUrls = contentImages.compactMap({ $0.url })
        guard imageUrls.count == contentImages.count else { return nil }
        
        return ContentData(
            id: contentId,
            userId: userId,
            title: contentTitle,
            markdownContent: contentText,
            imageUrls: imageUrls
        )
    }
    
    public func addToPost(image: UIImage) {
        guard contentImages.count < imageCountLimit else { return }
        guard let userId = userId else { return }

        let imageData = ContentCreationImageData(image: image)

        withAnimation(.snappy) {
            contentImages.append(imageData)
        }
        
        Task {
            do {
                let imageUrl = try await imageUploader.upload(
                    image: imageData.image,
                    withId: imageData.id,
                    forPost: contentId.uuidString,
                    byUser: userId
                )
                
                guard let index = contentImages.firstIndex(where: { $0.id == imageData.id }) else { return }
                contentImages.remove(at: index)
                
                let imageData = ContentCreationImageData(id: imageData.id, image: image, url: imageUrl)
                contentImages.insert(imageData, at: index)
            } catch {
                print("Image failed to upload: \(error.localizedDescription)")
                withAnimation(.snappy) {
                    contentImages.removeAll { $0.id == imageData.id }
                }
            }
        }
    }
    
    public func removeFromPost(image: ContentCreationImageData) {
        guard let userId = userId else { return }
        guard let index = contentImages.firstIndex(where: { $0.id == image.id }) else { return }
        
        withAnimation(.snappy) {
            contentImages.removeAll { $0.id == image.id }
        }
        
        Task {
            do {
                try await imageUploader.delete(
                    image: image.id,
                    forPost: contentId.uuidString,
                    byUser: userId
                )
            } catch {
                print("Image failed to delete: \(error.localizedDescription)")
                withAnimation(.snappy) {
                    contentImages.insert(image, at: min(index, contentImages.count))
                }
            }
        }
    }
    
    public func deleteImagesUnsafely() {
        guard let userId = userId else { return }
        
        contentImages.forEach { image in
            guard let _ = image.url else { return }
            Task { try? await imageUploader.delete(image: image.id, forPost: contentId.uuidString, byUser: userId) }
        }
    }
}
