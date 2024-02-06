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
    
    var errorToThrow: Error? = nil
    
    func loadContent() async throws -> HomeViewContent {
        try? await Task.sleep(for: .seconds(1))
        
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return .sample
    }
}
