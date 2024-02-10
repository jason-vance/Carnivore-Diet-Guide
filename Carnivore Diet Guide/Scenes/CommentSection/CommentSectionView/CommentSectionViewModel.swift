//
//  CommentSectionViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation
import SwinjectAutoregistration
import Combine

@MainActor
class CommentSectionViewModel: ObservableObject {
    
    @Published var comments: [Comment] = []
    @Published var isSendingComment: Bool = false
    
    private let commentProvider = iocContainer~>CommentProvider.self
    private let commentSender = iocContainer~>CommentSender.self
    
    private var commentSub: AnyCancellable?
    
    func sendComment(
        text: String,
        toResource resource: CommentSectionView.Resource
    ) async throws {
        guard !text.isEmpty else { throw "Comment text is empty" }
        
        isSendingComment = true
        try await commentSender.sendComment(text: text, toResource: resource)
        isSendingComment = false
    }
    
    func startListeningForComments(onResource resource: CommentSectionView.Resource) {
        commentSub = commentProvider.listenForCommentsOrderedByDate(
            onResource: resource,
            onUpdate: onUpdate(comments:),
            onError: nil
        )
    }
    
    private func onUpdate(comments: [Comment]) {
        self.comments = comments
    }
}
