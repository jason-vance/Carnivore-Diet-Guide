//
//  FirebaseBlogLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation

class FirebaseBlogLibraryContentProvider: BlogLibraryContentProvider {
    
    let blogPostRepo = FirebasePostRepository()
    
    func loadBlogPosts(onUpdate: @escaping ([BlogPost]) -> (), onError: @escaping (Error) -> ()) {
        Task {
            do {
                let posts = try await blogPostRepo.getPublishedPostsNewestToOldest()
                onUpdate(posts)
            } catch {
                print(error)
                onError(error)
            }
        }
    }
}
