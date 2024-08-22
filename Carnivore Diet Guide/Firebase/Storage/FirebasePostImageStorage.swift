//
//  FirebasePostImageStorage.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import Foundation
import FirebaseStorage
import UIKit

public class FirebasePostImageStorage {
    
    var storage: Storage { Storage.storage() }
    
    private func imagePath(imageId: String, postId: String, userId: String) -> String {
        "PostImages/\(userId)/\(postId)/\(imageId).jpg"
    }
    
    func upload(
        image: UIImage,
        withId imageId: String,
        forPost postId: String,
        byUser userId: String
    ) async throws -> URL {
        let path = imagePath(imageId: imageId, postId: postId, userId: userId)
        return try await upload(image: image, to: path)
    }
    
    private func upload(image: UIImage, to path: String) async throws -> URL {
        //TODO: Limit/verify image dimensions
        guard let jpgImage = image.jpegData(compressionQuality: 0.5) else {
            throw "Image could not be converted to jpg"
        }
        return try await upload(jpgImage: jpgImage, to: path)
    }
    
    private func upload(jpgImage: Data, to path: String) async throws -> URL {
        let storageReference = storage.reference(withPath: path)
        let storageMetadata = StorageMetadata()
        storageMetadata.contentType = "image/jpeg"
        
        try await withCheckedThrowingContinuation { (continuation:CheckedContinuation<Void,Error>) in
            let uploadTask = storageReference.putData(jpgImage, metadata: storageMetadata)
            uploadTask.observe(.failure) { taskSnapshot in
                continuation.resume(throwing: taskSnapshot.error ?? "Failed to upload image")
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
}

extension FirebasePostImageStorage: PostImageUploader {}
