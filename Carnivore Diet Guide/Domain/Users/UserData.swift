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
    var bio: UserBio?
    var whyCarnivore: WhyCarnivore?
    var carnivoreSince: CarnivoreSince?
    
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
        profileImageUrl: URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg"),
        bio: UserBio("The main protagonist of Final Fantasy XVI is Clive Rosfield, the firstborn son of the Archduke of Rosaria. He is a master of the blade who can learn abilities from encounters with Eikons—powerful beings capable of great destruction."),
        whyCarnivore: WhyCarnivore("Allergies, weight loss, skin conditions"),
        carnivoreSince: CarnivoreSince(.now)
    )
    
    static let sampleWithPersonName: UserData = {
        var sample = Self.sample
        sample.fullName = PersonName("Clive Rosfield")
        return sample
    }()
}
