//
//  KnowledgeLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation

protocol KnowledgeLibraryContentProvider {
    func loadPosts() async throws -> [Post]
}

class MockKnowledgeLibraryContentProvider: KnowledgeLibraryContentProvider {
    
    var errorToThrow: Error? = nil
    
    func loadPosts() async throws -> [Post] {
        try? await Task.sleep(for: .seconds(1))
        
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return Post.samples
    }
}
