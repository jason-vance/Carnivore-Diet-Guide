//
//  CreatePostViewModel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
class CreatePostViewModel: ObservableObject {
    
    @Published public var postTitle: String = ""
    @Published public var postImages: [CreatePostImageData] = []
    @Published public var postText: String = ""
    
    private let userIdProvider: CurrentUserIdProvider
    
    private var userId: String? { userIdProvider.currentUserId }
    
    public var isFormEmpty: Bool {
        postTitle.isEmpty && postText.isEmpty && postImages.isEmpty
    }
    
    public var reviewPostData: ReviewPostData? {
        guard let userId = userId else { return nil }
        
        guard !postTitle.isEmpty else { return nil }
        
        guard !postText.isEmpty else { return nil }
        
        let imageUrls = postImages.compactMap({ $0.url })
        guard imageUrls.count == postImages.count else { return nil }
        
        return ReviewPostData(
            userId: userId,
            title: postTitle,
            text: postText,
            imageUrls: imageUrls
        )
    }
    
    init(
        userIdProvider: CurrentUserIdProvider
    ) {
        self.userIdProvider = userIdProvider
    }
    
    public func addToPost(image: UIImage) {
        //TODO: Limit image count
        withAnimation(.snappy) {
            postImages.append(CreatePostImageData(image: image))
        }
        
        //TODO: Upload images to Firebase
    }
}
