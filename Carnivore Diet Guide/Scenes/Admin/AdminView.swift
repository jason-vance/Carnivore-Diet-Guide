//
//  AdminView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/8/24.
//

import SwiftUI
import SwinjectAutoregistration

struct AdminView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var showFeaturedArticlesCreator: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private let adProvider = iocContainer~>AdProvider.self
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                CreateContentSection()
                SettingsSection()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .alert(errorMessage, isPresented: $showError) {}
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar(
            String(localized: "Admin"),
            leadingContent: BackButton
        )
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func CreateContentSection() -> some View {
        Section {
            FeaturedArticlesButton()
        } header: {
            Text("Create Content")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func FeaturedArticlesButton() -> some View {
        Button("Featured Articles") {
            showFeaturedArticlesCreator = true
        }
        .listRowBackground(Color.background)
        .fullScreenCover(isPresented: $showFeaturedArticlesCreator) {
            FeaturedArticlesCreatorView()
        }
    }
    
    @ViewBuilder func SettingsSection() -> some View {
        Section {
            ShowAdsToggle()
        } header: {
            Text("Settings")
                .foregroundStyle(Color.text)
        }
    }
    
    @ViewBuilder func ShowAdsToggle() -> some View {
        Toggle("Show Ads", isOn: .init(
            get: { adProvider.showAds },
            set: { adProvider.disableAds(!$0) }
        ))
        .foregroundStyle(Color.text)
        .listRowBackground(Color.background)
    }
}

#Preview {
    AdminView()
}
