//
//  FirebasePostImageStorage.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import Foundation
import FirebaseStorage
import UIKit

fileprivate struct PostImage {
    
    let imageData: Data
    
    init(image: UIImage) throws {
        let image = try Self.resize(image: image)
        let imageData = try Self.compress(image: image)
        try Self.throwIfTooBig(data: imageData)
        
        self.imageData = imageData
    }
    
    private static func compress(image: UIImage) throws -> Data {
        if let image = image.jpegData(compressionQuality: 0.5) {
            return image
        }
        throw TextError("Image could not be compressed")
    }
    
    private static func throwIfTooBig(data: Data) throws {
        let fiveMB = 5 * 1024 * 1024
        if data.count - fiveMB > 0 {
            throw TextError("Image data must be 5MB or less")
        }
    }
    
    private static func resize(image: UIImage) throws -> UIImage {
        if let image = image.resizeToMinSideWithMaxLength(of: 1024) {
            return image
        }
        throw TextError("Image could not be resized")
    }
}

public class FirebasePostImageStorage {
    
    var storage: Storage { Storage.storage() }
    
    private func postPath(postId: String, userId: String) -> String {
        "PostImages/\(userId)/\(postId)"
    }
    
    private func imagePath(imageId: String, postId: String, userId: String) -> String {
        postPath(postId: postId, userId: userId) + "/\(imageId).jpg"
    }
    
    func upload(
        image: UIImage,
        withId imageId: String,
        forPost postId: String,
        byUser userId: String
    ) async throws -> URL {
        let image = try PostImage(image: image)
        let path = imagePath(imageId: imageId, postId: postId, userId: userId)
        
        return try await upload(image: image, to: path)
    }
    
    private func upload(image: PostImage, to path: String) async throws -> URL {
        let storageReference = storage.reference(withPath: path)
        let storageMetadata = StorageMetadata()
        storageMetadata.contentType = "image/jpeg"
        
        try await withCheckedThrowingContinuation { (continuation:CheckedContinuation<Void,Error>) in
            let uploadTask = storageReference.putData(image.imageData, metadata: storageMetadata)
            uploadTask.observe(.failure) { taskSnapshot in
                continuation.resume(throwing: taskSnapshot.error ?? TextError("Failed to upload image"))
            }
            uploadTask.observe(.success) { taskSnapshot in
                continuation.resume()
            }
        }
        return try await storageReference.downloadURL()
    }
    
    func delete(image imageId: String, forPost postId: String, byUser userId: String) async throws {
        let path = imagePath(imageId: imageId, postId: postId, userId: userId)
        let storageReference = storage.reference(withPath: path)
        try await storageReference.delete()
    }
    
    func deleteImages(forPost postId: String, byUser userId: String) async throws {
        let path = postPath(postId: postId, userId: userId)
        let items = try await storage.reference(withPath: path).listAll().items
        items.forEach { item in
            Task {
                do {
                    try await item.delete()
                } catch {
                    print("Failed to delete image. \(error.localizedDescription)")
                }
            }
        }
    }
}

extension FirebasePostImageStorage: PostImageUploader {}
