//
//  CommentCountView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import SwiftUI
import SwinjectAutoregistration

struct CommentCountView: View {
    
    public var resource: Resource
    
    private let commentCountProvider = iocContainer~>CommentCountProvider.self
    
    @State private var commentCount: UInt = 0
    
    var body: some View {
        MetadataItemView(
            text: "\(commentCount)",
            icon: "text.bubble"
        )
        .onChange(of: resource, initial: true) { oldResource, newResource in
            commentCountProvider.startListening(to: resource)
        }
        .onReceive(commentCountProvider.commentCountPublisher, perform: { commentCount in
            self.commentCount = commentCount
        })
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CommentCountView(resource: .sample)
    }
}
