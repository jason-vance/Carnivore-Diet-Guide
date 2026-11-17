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
    
    @State private var showSignInPrompt = false
    /// Bumped when the resource becomes a favorite.
    @State private var favoriteSparks = 0

    private var isGuest: Bool {
        (iocContainer~>CurrentUserIdProvider.self).currentUserId == nil
    }

    private var sfSymbol: String {
        let isMarkedAsFavorite = model.isMarkedAsFavorite == true
        return isMarkedAsFavorite ? "heart.fill" : "heart.slash"
    }

    var body: some View {
        Button {
            if isGuest {
                showSignInPrompt = true
            } else {
                model.toggleFavorite(resource: resource)
            }
        } label: {
            ResourceMenuButtonLabel(sfSymbol: sfSymbol)
                .symbolEffect(.bounce, value: favoriteSparks)
                .overlay {
                    SizzleSparks(trigger: favoriteSparks, count: 10, spread: 0.35)
                        .frame(width: 100, height: 100)
                }
        }
        .disabled(!isGuest && (model.isMarkedAsFavorite == nil || model.isWorking))
        // Only a change from not-a-favorite, so loading the status when the screen opens stays quiet.
        .onChange(of: model.isMarkedAsFavorite) { wasFavorite, isFavorite in
            guard wasFavorite == false, isFavorite == true else { return }
            Haptics.tap()
            favoriteSparks += 1
        }
        .onAppear {
            if !isGuest {
                model.listenToFavoriteStatus(of: resource)
            }
        }
        .signInPrompt(
            isPresented: $showSignInPrompt,
            reason: String(localized: "Sign in to save your favorite articles and recipes.")
        )
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        FavoriteButton(resource: .sample)
    }
}
