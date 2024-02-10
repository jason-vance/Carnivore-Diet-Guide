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
        onResource resource: CommentSectionView.Resource,
        onUpdate: @escaping ([Comment]) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable
}

class MockCommentProvider: CommentProvider {
    func listenForCommentsOrderedByDate(
        onResource resource: CommentSectionView.Resource,
        onUpdate: @escaping ([Comment]) -> (),
        onError: ((Error) -> ())?
    ) -> AnyCancellable {
        onUpdate(Comment.samples)
        return .init({})
    }
}
