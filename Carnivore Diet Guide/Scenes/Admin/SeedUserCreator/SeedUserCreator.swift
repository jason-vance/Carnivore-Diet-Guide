//
//  SeedUserCreator.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/14/25.
//

import Foundation
import UIKit

class SeedUserCreator: ObservableObject {
    
    private let createSeedUser: (UserData, UIImage) async throws -> Void
    
    init(createSeedUser: @escaping (UserData, UIImage) async throws -> Void) {
        self.createSeedUser = createSeedUser
    }
    
    func create(seedUser: UserData, withProfileImage profileImage: UIImage) async throws {
        try await createSeedUser(seedUser, profileImage)
    }
}

extension SeedUserCreator {
    static let forTesting = SeedUserCreator(
        createSeedUser: { _, _ in try await Task.sleep(for: .seconds(1)) }
    )
}
