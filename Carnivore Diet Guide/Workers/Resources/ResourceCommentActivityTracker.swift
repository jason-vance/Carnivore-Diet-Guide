//
//  ResourceCommentActivityTracker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import Foundation

protocol ResourceCommentActivityTracker {
    func resource(_ resource: Resource, wasCommentedOnByUser userId: String) async throws
}

class MockRecipeCommentActivityTracker: ResourceCommentActivityTracker {
    func resource(_ resource: Resource, wasCommentedOnByUser userId: String) async throws { }
}
