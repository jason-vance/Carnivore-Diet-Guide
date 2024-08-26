//
//  FavoriteCountView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/24/24.
//

import SwiftUI
import SwinjectAutoregistration

struct FavoriteCountView: View {
    
    public var resource: Resource
    
    private let favoriteCountProvider = iocContainer~>FavoriteCountProvider.self
    
    @State private var favoriteCount: UInt = 0
    
    var body: some View {
        MetadataItemView(
            text: "\(favoriteCount)",
            icon: "heart"
        )
        .onChange(of: resource, initial: true) { oldResource, newResource in
            favoriteCountProvider.startListening(to: resource)
        }
        .onReceive(favoriteCountProvider.favoriteCountPublisher, perform: { favoriteCount in
            self.favoriteCount = favoriteCount
        })
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        FavoriteCountView(resource: .sample)
    }
}
