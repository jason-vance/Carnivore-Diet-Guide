//
//  PostCountStatView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import SwiftUI
import SwinjectAutoregistration

struct PostCountStatView: View {
    
    public let userId: String
    
    @State private var postsCount: Int? = nil
    
    private let postsCountProvider = iocContainer~>PostCountProvider.self
    
    private func fetchPostCount() {
        Task {
            postsCount = try await postsCountProvider.fetchPostCount(forUser: userId)
        }
    }
    
    //TODO: This needs to update live
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
