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
    
    private var minImageCount: Int {
        switch contentType {
        case .post:
            0
        case .recipe, .article:
            1
        }
    }
    private var maxImageCount: Int {
        switch contentType {
        case .post:
            5
        case .recipe, .article:
            1
        }
    }

    @Published public var author: String
    @Published public var isAdmin: Bool = false
    @Published public var isPublisher: Bool = false
    @Published public var contentId: UUID = UUID()
    @Published public var contentType: Resource.ResourceType = .post
    @Published public var contentTitle: String = ""
    @Published public var contentImages: [ContentCreationImageData] = []
    @Published public var contentText: String = ""
    
    public var isFormEmpty: Bool {
        contentTitle.isEmpty && contentText.isEmpty && contentImages.isEmpty
    }
    
    public var canAddImages: Bool { contentImages.count < maxImageCount }
    
    public var contentData: ContentData? {
        guard !contentTitle.isEmpty else { return nil }
        
        guard !contentText.isEmpty else { return nil }
        
        guard (contentImages.count >= minImageCount && contentImages.count <= maxImageCount) else { return nil }
        
        let imageUrls = contentImages.compactMap({ $0.url })
        guard imageUrls.count == contentImages.count else { return nil }
        
        return ContentData(
            id: contentId,
            userId: author,
            title: contentTitle,
            markdownContent: contentText,
            imageUrls: imageUrls
        )
    }
    
    private let userIdProvider: CurrentUserIdProvider
    private let imageUploader: PostImageUploader
    private let isPublisherChecker: IsPublisherChecker
    private let isAdminChecker: IsAdminChecker

    init(
        userIdProvider: CurrentUserIdProvider,
        imageUploader: PostImageUploader,
        isPublisherChecker: IsPublisherChecker,
        isAdminChecker: IsAdminChecker
    ) {
        self.userIdProvider = userIdProvider
        self.imageUploader = imageUploader
        self.isPublisherChecker = isPublisherChecker
        self.isAdminChecker = isAdminChecker

        self.author = userIdProvider.currentUserId!
        
        checkIsAdmin()
        checkIsPublisher()
    }
    
    private func checkIsAdmin() {
        Task {
            guard let isAdmin = try? await isAdminChecker.isAdmin(userId: author) else { return }
            withAnimation(.snappy) {
                self.isAdmin = isAdmin
            }
        }
    }
    
    private func checkIsPublisher() {
        Task {
            guard let isPublisher = try? await isPublisherChecker.isPublisher(userId: author) else { return }
            withAnimation(.snappy) {
                self.isPublisher = isPublisher
            }
        }
    }
    
    public func addToPost(image: UIImage) {
        guard contentImages.count < maxImageCount else { return }

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
                    byUser: author
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
        guard let index = contentImages.firstIndex(where: { $0.id == image.id }) else { return }
        
        withAnimation(.snappy) {
            contentImages.removeAll { $0.id == image.id }
        }
        
        Task {
            do {
                try await imageUploader.delete(
                    image: image.id,
                    forPost: contentId.uuidString,
                    byUser: author
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
        contentImages.forEach { image in
            guard let _ = image.url else { return }
            Task { try? await imageUploader.delete(image: image.id, forPost: contentId.uuidString, byUser: author) }
        }
    }
}
