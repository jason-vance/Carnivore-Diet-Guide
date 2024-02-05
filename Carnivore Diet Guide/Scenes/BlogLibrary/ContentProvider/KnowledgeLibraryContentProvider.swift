//
//  KnowledgeLibraryContentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation

protocol KnowledgeLibraryContentProvider {
    func loadPosts(onUpdate: @escaping ([Post]) -> (), onError: @escaping (Error) -> ())
}

class MockKnowledgeLibraryContentProvider: KnowledgeLibraryContentProvider {
    func loadPosts(onUpdate: @escaping ([Post]) -> (), onError: @escaping (Error) -> ()) {
        Task {
            try? await Task.sleep(for: .seconds(1))
            onUpdate(Post.samples)
        }
    }
}
