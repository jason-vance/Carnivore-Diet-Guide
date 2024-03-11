//
//  FirestoreUserDoc.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FirestoreUserDoc: Codable {
    
    @DocumentID var id: String?
    var fullName: String?
    var profileImageUrl: URL?
    var favoriteRecipes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case profileImageUrl
        case favoriteRecipes
    }
    
    static func from(_ userData: UserData) -> FirestoreUserDoc {
        FirestoreUserDoc(
            id: userData.id,
            fullName: userData.fullName?.value,
            profileImageUrl: userData.profileImageUrl
        )
    }
    
    func toUserData() -> UserData? {
        guard let id = id else { return nil }
        
        guard let fullName = fullName else { return nil }
        guard let fullName = try? PersonName(fullName) else { return nil }
        
        guard let profileImageUrl = profileImageUrl else { return nil }

        return .init(
            id: id,
            fullName: fullName,
            profileImageUrl: profileImageUrl
        )
    }
}
