//
//  EditUserProfileFormData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/2/24.
//

import Foundation

struct EditUserProfileFormData {
    var id: String
    var fullName: PersonName?
    var username: Username?
    var profilePicUrl: URL?
    
    var isValid: Bool {
        fullName != nil && username != nil && profilePicUrl != nil
    }
}

extension EditUserProfileFormData{
    static let empty = EditUserProfileFormData(
        id: "",
        fullName: nil,
        username: nil,
        profilePicUrl: nil
    )
    
    static let sample = EditUserProfileFormData(
        id: "id",
        fullName: PersonName("Clive Rosfield"),
        username: Username("ifrit"),
        profilePicUrl: URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg")
    )
}
