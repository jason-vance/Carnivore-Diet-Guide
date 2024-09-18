//
//  ProfileImageUploader.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/3/24.
//

import Foundation
import UIKit

protocol ProfileImageUploader {
    func upload(profileImage: UIImage, for userId: String) async throws -> URL
}

class MockProfileImageUploader: ProfileImageUploader {
    
    var returnUrl: URL = URL(string: "https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg")!
    var willThrow = false
    
    func upload(profileImage: UIImage, for userId: String) async throws -> URL {
        try? await Task.sleep(for: .seconds(1))
        if willThrow {
            throw TextError("error")
        }
        return returnUrl
    }
}

