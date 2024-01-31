//
//  HomeViewContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/23/24.
//

import Foundation

protocol HomeViewContentProvider {
    func loadContent() async throws -> HomeViewContent
}

class MockHomeViewContentProvider: HomeViewContentProvider {
    func loadContent() async throws -> HomeViewContent {
        .sample
    }
}
