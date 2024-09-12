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
    var username: Username?
    var profileImageUrl: URL?
    var termsOfServiceAcceptance: Date?
    var privacyPolicyAcceptance: Date?
    
    var isFullyOnboarded: Bool {
        username != nil &&
        profileImageUrl != nil &&
        termsOfServiceAcceptance != nil &&
        privacyPolicyAcceptance != nil
    }
}

extension UserData {
    static let empty = UserData(
        id: ""
    )
    
    static let sample = UserData(
        id: "id",
        username: Username("ifrit"),
        profileImageUrl: URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg")
    )
    
    static let sampleWithPersonName = UserData(
        id: "id",
        fullName: PersonName("Clive Rosfield"),
        username: Username("ifrit"),
        profileImageUrl: URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg")
    )
}
