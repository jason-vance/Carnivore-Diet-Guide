//
//  BlogLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation

protocol BlogLibraryContentProvider {
    func loadBlogPosts(onUpdate: @escaping ([BlogPost]) -> (), onError: @escaping (Error) -> ())
}

class MockBlogLibraryContentProvider: BlogLibraryContentProvider {
    func loadBlogPosts(onUpdate: @escaping ([BlogPost]) -> (), onError: @escaping (Error) -> ()) {
        Task {
            try? await Task.sleep(for: .seconds(1))
            onUpdate(BlogPost.samples)
        }
    }
}
