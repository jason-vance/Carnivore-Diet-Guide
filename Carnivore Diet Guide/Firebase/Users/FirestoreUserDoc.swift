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
    var username: String?
    var profileImageUrl: URL?
    var termsOfServiceAcceptance: Date?
    var privacyPolicyAcceptance: Date?
    var favoriteArticles: [String]?
    var favoritePosts: [String]?
    var favoriteRecipes: [String]?
    var bio: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case username
        case profileImageUrl
        case termsOfServiceAcceptance
        case privacyPolicyAcceptance
        case favoriteArticles
        case favoritePosts
        case favoriteRecipes
        case bio
    }
    
    static func from(_ userData: UserData) -> FirestoreUserDoc {
        FirestoreUserDoc(
            id: userData.id,
            fullName: userData.fullName?.value,
            username: userData.username?.value,
            profileImageUrl: userData.profileImageUrl,
            termsOfServiceAcceptance: userData.termsOfServiceAcceptance,
            privacyPolicyAcceptance: userData.privacyPolicyAcceptance
        )
    }
    
    func toUserData() -> UserData? {
        guard let id = id else { return nil }
        guard let username = Username(username ?? "") else { return nil }
        guard let profileImageUrl = profileImageUrl else { return nil }

        return .init(
            id: id,
            fullName: PersonName(fullName ?? ""),
            username: username,
            profileImageUrl: profileImageUrl,
            termsOfServiceAcceptance: termsOfServiceAcceptance,
            privacyPolicyAcceptance: privacyPolicyAcceptance,
            bio: UserBio(bio)
        )
    }
}
