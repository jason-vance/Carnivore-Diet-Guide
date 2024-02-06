//
//  FirebaseKnowledgeLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation

class FirebaseKnowledgeLibraryContentProvider: KnowledgeLibraryContentProvider {
    
    let postRepo = FirebasePostRepository()
    
    func loadPosts() async throws -> [Post] {
        try await postRepo.getPublishedPostsNewestToOldest()
    }
}
