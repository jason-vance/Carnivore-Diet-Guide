//
//  FavoriteButton.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import SwiftUI
import SwinjectAutoregistration

struct FavoriteButton: View {
    
    public var resource: Resource
    
    @StateObject private var model = FavoriteButtonModel(
        userIdProvider: iocContainer~>CurrentUserIdProvider.self,
        favoriter: iocContainer~>ResourceFavoriter.self
    )
    
    private var sfSymbol: String {
        let isMarkedAsFavorite = model.isMarkedAsFavorite == true
        return isMarkedAsFavorite ? "heart.fill" : "heart.slash"
    }
    
    var body: some View {
        Button {
            model.toggleFavorite(resource: resource)
        } label: {
            ResourceMenuButtonLabel(sfSymbol: sfSymbol)
        }
        .disabled(model.isMarkedAsFavorite == nil || model.isWorking)
        .onAppear {
            model.listenToFavoriteStatus(of: resource)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        FavoriteButton(resource: .sample)
    }
}
