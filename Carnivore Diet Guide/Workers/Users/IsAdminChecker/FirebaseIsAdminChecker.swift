//
//  FirebaseIsAdminChecker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/8/24.
//

import Foundation
import FirebaseFirestore

class FirebaseIsAdminChecker: IsAdminChecker {
    
    public static let ADMIN = "Admin"
    
    private let adminCollection = Firestore.firestore().collection(ADMIN)
    
    func isAdmin(userId: String) async throws -> Bool {
        try await adminCollection.document(userId).getDocument().exists
    }
}
