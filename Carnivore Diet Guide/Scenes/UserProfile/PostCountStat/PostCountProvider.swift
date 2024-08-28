//
//  PostCountProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import Foundation
import Combine

protocol PostCountProvider {
    func listenToPostCount(
        forUser userId: String,
        onUpdate: @escaping (Int) -> (),
        onError: @escaping (Error) -> ()
    ) -> AnyCancellable
}

extension PostCountProvider {
    func listenToPostCount(
        forUser userId: String,
        onUpdate: @escaping (Int) -> ()
    ) -> AnyCancellable {
        return listenToPostCount(forUser: userId, onUpdate: onUpdate, onError: { _ in })
    }
}

class MockPostCountProvider: PostCountProvider {
    
    var postCount: Int = Post.samples.count
    var error: Error? = nil
    
    func listenToPostCount(
        forUser userId: String,
        onUpdate: @escaping (Int) -> (),
        onError: @escaping (Error) -> ()
    ) -> AnyCancellable {
        if let error = error {
            onError(error)
        } else {
            onUpdate(postCount)
        }
        return .init({})
    }
}
