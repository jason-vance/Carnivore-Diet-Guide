//
//  PostCountStatView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import SwiftUI
import SwinjectAutoregistration
import Combine

struct PostCountStatView: View {
    
    public let userId: String
    
    @State private var postsCount: Int? = nil
    @State private var postsCountSub: AnyCancellable? = nil
    
    private let postsCountProvider = iocContainer~>PostCountProvider.self
    
    private func fetchPostCount() {
        postsCountSub = postsCountProvider.listenToPostCount(
            forUser: userId,
            onUpdate: { count in self.postsCount = count }
        )
    }
    
    var body: some View {
        UserProfileStatLabel(
            value: postsCount,
            title: String(localized: "Posts")
        )
        .onAppear { fetchPostCount() }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        PostCountStatView(userId: UserData.sample.id)
    }
}
