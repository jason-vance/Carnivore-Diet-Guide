//
//  UserData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation

struct UserData {
    var id: String
    var fullName: PersonName?
    var profileImageUrl: URL?
    var termsOfServiceAcceptance: Date?
    var privacyPolicyAcceptance: Date?
    
    var isFullyOnboarded: Bool {
        fullName != nil &&
        profileImageUrl != nil &&
        termsOfServiceAcceptance != nil &&
        privacyPolicyAcceptance != nil
    }
}

extension UserData {
    static let empty = UserData(
        id: "",
        fullName: nil,
        profileImageUrl: nil
    )
    
    static let sample = UserData(
        id: "id",
        fullName: PersonName("Clive Rosfield"),
        profileImageUrl: URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg")
    )
}
