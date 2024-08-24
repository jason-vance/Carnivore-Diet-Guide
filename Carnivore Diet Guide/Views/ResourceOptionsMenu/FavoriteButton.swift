//
//  FavoriteButton.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/23/24.
//

import SwiftUI
import SwinjectAutoregistration

struct FavoriteButton: View {
    
    let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    let favoriter = iocContainer~>ResourceFavoriter.self
    
    @State public var resource: Resource
    
    @State private var isMarkedAsFavorite: Bool? = nil
    @State private var isWorking: Bool = false
    
    private var userId: String {
        userIdProvider.currentUserId!
    }
    
    private func listenToFavoriteStatus() {
        favoriter.listenToFavoriteStatus(of: resource)
    }
    
    private func toggleFavorite() {
        isWorking = true
        Task {
            await favoriter.toggleFavorite(resource: resource)
            isWorking = false
        }
    }
    
    var body: some View {
        Button {
            toggleFavorite()
        } label: {
            if let isMarkedAsFavorite = isMarkedAsFavorite {
                ResourceMenuButtonLabel(sfSymbol: isMarkedAsFavorite ? "heart.fill" : "heart.slash")
            }
        }
        .disabled(isMarkedAsFavorite == nil || isWorking)
        .onAppear { listenToFavoriteStatus() }
        .onReceive(favoriter.$isMarkedAsFavorite) { isMarkedAsFavorite in
            self.isMarkedAsFavorite = isMarkedAsFavorite
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
