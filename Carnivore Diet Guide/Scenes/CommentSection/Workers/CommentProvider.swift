//
//  CommentProvider.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/9/24.
//

import Foundation
import Combine

protocol CommentProvider {
    func listenForCommentsOrderedByDate(
        onResource resource: CommentSectionResource,
        onUpdate: @escaping ([Comment]) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable
}

class MockCommentProvider: CommentProvider {
    
    var comments = Comment.samples
    
    func listenForCommentsOrderedByDate(
        onResource resource: CommentSectionResource,
        onUpdate: @escaping ([Comment]) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        onUpdate(comments)
        return .init({})
    }
}
