//
//  FirebaseKnowledgeLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation

class FirebaseKnowledgeLibraryContentProvider: KnowledgeLibraryContentProvider {
    
    let postRepo = FirebasePostRepository()
    
    func loadPosts(onUpdate: @escaping ([Post]) -> (), onError: @escaping (Error) -> ()) {
        Task {
            do {
                let posts = try await postRepo.getPublishedPostsNewestToOldest()
                onUpdate(posts)
            } catch {
                print(error)
                onError(error)
            }
        }
    }
}
