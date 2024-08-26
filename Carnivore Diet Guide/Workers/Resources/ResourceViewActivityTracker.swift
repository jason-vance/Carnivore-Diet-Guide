//
//  ResourceViewActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/12/24.
//

import Foundation

protocol ResourceViewActivityTracker {
    func resource(_ resource: Resource, wasViewedByUser userId: String) async throws
}

class MockRecipeViewActivityTracker: ResourceViewActivityTracker {
    func resource(_ resource: Resource, wasViewedByUser userId: String) async throws { }
}
