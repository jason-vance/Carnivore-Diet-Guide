//
//  UserProfileData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation

struct UserProfileData {
    var id: String
    var fullName: String
    var username: String
    var profileImageUrl: URL?
}

extension UserProfileData{
    static let empty = UserProfileData(
        id: "",
        fullName: "",
        username: "",
        profileImageUrl: nil
    )
    
    static let sample = UserProfileData(
        id: "id",
        fullName: "Clive Rosfield",
        username: "ifrit",
        profileImageUrl: URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg")
    )
}
