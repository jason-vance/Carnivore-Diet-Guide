//
//  FavoriteCountView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/24/24.
//

import SwiftUI

struct FavoriteCountView: View {

    public var resource: Resource

    var body: some View {
        ResourceCountView(resource: resource, store: .favorites, icon: "heart")
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        FavoriteCountView(resource: .sample)
    }
}
