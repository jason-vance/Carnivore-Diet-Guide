//
//  PostCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import Foundation

protocol PostCountProvider {
    func fetchPostCount(forUser userId: String) async throws -> Int
}

class MockPostCountProvider: PostCountProvider {
    
    var postCount: Int = Post.samples.count
    var errorToThrow: Error? = nil
    
    func fetchPostCount(forUser userId: String) async throws -> Int {
        try await Task.sleep(for: .seconds(1))
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return postCount
    }
}
