//
//  UserData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import Foundation

struct UserData {
    var id: String
    var fullName: PersonName
    var username: Username
    var profileImageUrl: URL
}

extension UserData {
    static let sample = UserData(
        id: "userId",
        fullName: PersonName("Clive Rosfield")!,
        username: Username("ifrit")!,
        profileImageUrl: URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg")!
    )
}
