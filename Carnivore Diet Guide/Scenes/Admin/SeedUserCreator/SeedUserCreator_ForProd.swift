//
//  SeedUserCreator_ForProd.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/14/25.
//

import Foundation

extension SeedUserCreator {
    static let forProd = SeedUserCreator(
        createSeedUser: { userData, image in
            try await FirebaseUserRepository().createSeedUser(userData)
            let url = try await FirebaseProfileImageStorage().upload(profileImage: image, for: userData.id)
            
            var userData = userData
            userData.profileImageUrl = url
            try await FirebaseUserRepository().addProfileImageUrlToUser(using: userData)
            
            try await FirebasePublishersRepository().addPublisher(userData)
        }
    )
}
