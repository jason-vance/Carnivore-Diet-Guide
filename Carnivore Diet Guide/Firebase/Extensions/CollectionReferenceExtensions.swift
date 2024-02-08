//
//  CollectionReferenceExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/7/24.
//

import Foundation
import FirebaseFirestore

extension CollectionReference {
    
    @discardableResult func addDocument<T>(
        from value: T,
        encoder: Firestore.Encoder = Firestore.Encoder()
    ) async throws -> DocumentReference where T : Encodable {
        try await withCheckedThrowingContinuation { (continuation:CheckedContinuation<DocumentReference,Error>) in
            do {
                var docRef: DocumentReference? = nil
                
                docRef = try self.addDocument(from: value) { error in
                    guard let docRef = docRef else {
                        continuation.resume(throwing: error ?? "")
                        return
                    }
                    continuation.resume(returning: docRef)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
