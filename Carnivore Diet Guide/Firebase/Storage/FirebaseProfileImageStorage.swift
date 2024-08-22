//
//  FirebaseProfileImageStorage.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseProfileImageStorage {
    
    var storage: Storage { Storage.storage() }
    
    private func userProfileImagePath(userId: String) -> String {
        "ProfileImages/\(userId)/\(userId).jpg"
    }
    
    func upload(profileImage: UIImage, for userId: String) async throws -> URL {
        let path = userProfileImagePath(userId: userId)
        return try await upload(image: profileImage, to: path)
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
    
    func deleteProfileImage(for userId: String) async throws {
        let path = userProfileImagePath(userId: userId)
        let storageReference = storage.reference(withPath: path)
        try await storageReference.delete()
    }
}

extension FirebaseProfileImageStorage: ProfileImageUploader {}
