//
//  GuestProfileView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI

/// The Profile tab for someone browsing as a guest: an invitation to sign in, plus Settings.
struct GuestProfileView: View {

    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                String(localized: "Profile"),
                trailingContent: SettingsButton
            )
            ScrollView {
                VStack(spacing: 24) {
                    PremiumCTARow(placement: .profile, size: .small)
                    SignInPrompt(reason: String(localized: "You're browsing as a guest. Sign in to save favorites, join the comments, and set up your profile."))
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                                .foregroundStyle(Color.text.opacity(0.05))
                        }
                }
                .padding()
            }
        }
        .background(Color.background)
    }

    @ViewBuilder func SettingsButton() -> some View {
        Button {
            showSettings = true
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "gearshape.fill")
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        GuestProfileView()
    }
}
