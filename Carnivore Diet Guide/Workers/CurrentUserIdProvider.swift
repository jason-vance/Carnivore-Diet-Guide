//
//  CurrentUserIdProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import Foundation

protocol CurrentUserIdProvider {
    var currentUserIdPublisher: Published<String?>.Publisher { get }
}

class MockCurrentUserIdProvider: CurrentUserIdProvider {
    @Published var currentUserId: String? = "userId"
    var currentUserIdPublisher: Published<String?>.Publisher { $currentUserId }
}
