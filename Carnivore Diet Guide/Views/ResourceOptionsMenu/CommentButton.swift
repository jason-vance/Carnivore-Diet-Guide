//
//  CommentButton.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/24/24.
//

import SwiftUI

struct CommentButton: View {
    
    @State public var resource: Resource
    
    @State private var showCommentSection: Bool = false
    
    var body: some View {
        Button {
            showCommentSection = true
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "text.bubble.fill")
        }
        .sheet(isPresented: $showCommentSection) {
            CommentSectionView(resource: resource)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CommentButton(resource: .sample)
    }
}
