//
//  ResourceCreatedActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/5/24.
//

import Foundation

protocol ResourceCreatedActivityTracker {
    func resource(_ resource: Resource, wasCreatedByUser userId: String) async throws
}

class MockResourceCreatedActivityTracker: ResourceCreatedActivityTracker {
    func resource(_ resource: Resource, wasCreatedByUser userId: String) async throws { }
}
