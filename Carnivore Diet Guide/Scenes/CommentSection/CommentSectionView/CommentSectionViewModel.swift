//
//  CommentSectionViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/8/24.
//

import Foundation
import SwinjectAutoregistration

@MainActor
class CommentSectionViewModel: ObservableObject {
    
    //TODO: Load real comments
    @Published var comments: [Comment] = Comment.samples
    @Published var isSendingComment: Bool = false
    
    private let commentSender: CommentSender = iocContainer~>CommentSender.self
    
    func sendComment(
        text: String,
        forResource resourceId: String,
        ofType resourceType: CommentSectionView.ResourceType
    ) async throws {
        guard !text.isEmpty else { throw "Comment text is empty" }
        
        isSendingComment = true
        try await commentSender.sendComment(text: text, forResource: resourceId, ofType: resourceType)
        isSendingComment = false
    }
}
