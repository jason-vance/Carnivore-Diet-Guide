//
//  CommentCountView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import SwiftUI

struct CommentCountView: View {

    public var resource: Resource

    var body: some View {
        ResourceCountView(resource: resource, store: .comments, icon: "text.bubble")
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        CommentCountView(resource: .sample)
    }
}
