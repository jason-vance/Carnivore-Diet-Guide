//
//  FirebaseAdminRepository.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/11/24.
//

import Foundation
import FirebaseFirestore

class FirebaseAdminRepository {
    
    public static let ADMIN = "Admin"
    
    private let adminCollection = Firestore.firestore().collection(ADMIN)
}

extension FirebaseAdminRepository: IsAdminChecker {
    func isAdmin(userId: String) async throws -> Bool {
        try await adminCollection.document(userId).getDocument().exists
    }
}
