//
//  FirebaseBlogLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation

class FirebaseBlogLibraryContentProvider: BlogLibraryContentProvider {
    
    let blogPostRepo = FirebaseBlogPostRepository()
    
    func loadBlogPosts(onUpdate: @escaping ([BlogPost]) -> (), onError: @escaping (Error) -> ()) {
        Task {
            do {
                let blogPosts = try await blogPostRepo.getPublishedBlogPostsNewestToOldest()
                onUpdate(blogPosts)
            } catch {
                print(error)
                onError(error)
            }
        }
    }
}
