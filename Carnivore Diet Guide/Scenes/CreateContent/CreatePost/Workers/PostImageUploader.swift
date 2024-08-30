//
//  PostImageUploader.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import Foundation
import UIKit

protocol PostImageUploader {
    func upload(image: UIImage, withId: String, forPost: String, byUser: String) async throws -> URL
    func delete(image: String, forPost: String, byUser: String) async throws
}

class MockPostImageUploader: PostImageUploader {
    
    var returnUrl: URL = URL(string: "https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg")!
    var willThrow = false
    
    func upload(image: UIImage, withId: String, forPost: String, byUser: String) async throws -> URL {
        try? await Task.sleep(for: .seconds(1))
        if willThrow {
            throw "error"
        }
        return returnUrl
    }
    
    func delete(image: String, forPost: String, byUser: String) async throws {
        try? await Task.sleep(for: .seconds(1))
        if willThrow {
            throw "error"
        }
    }
}

