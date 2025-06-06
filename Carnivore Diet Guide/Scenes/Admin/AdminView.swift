//
//  AdminView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/8/24.
//

import Combine
import SwiftUI
import SwinjectAutoregistration

struct AdminView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var showFeaturedArticlesCreator: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private let subscriptionLevelProvider = iocContainer~>SubscriptionLevelProvider.self
    
    @State private var subscriptionLevel: SubscriptionLevelProvider.SubscriptionLevel = .none
    var subscriptionLevelPublisher: AnyPublisher<SubscriptionLevelProvider.SubscriptionLevel,Never> {
        subscriptionLevelProvider.$subscriptionLevel
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
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
        .onReceive(subscriptionLevelPublisher) { self.subscriptionLevel = $0 }
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
        HStack {
            Text("Subscription Level")
                .foregroundStyle(Color.text)
            Spacer()
            Menu {
                Button("None") {
                    subscriptionLevelProvider.set(subscriptionLevel: .none)
                }
                Button("Carnivore+") {
                    subscriptionLevelProvider.set(subscriptionLevel: .carnivorePlus)
                }
            } label: {
                Text(String(describing: subscriptionLevel))
                    .foregroundStyle(Color.accent)
                    .padding(.horizontal, .paddingHorizontalButtonXSmall)
                    .padding(.vertical, .paddingVerticalButtonXSmall)
                    .background {
                        RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                            .foregroundStyle(Color.accent.opacity(0.1))
                    }
            }
        }
        .foregroundStyle(Color.text)
        .listRowBackground(Color.background)
    }
}

#Preview {
    AdminView()
}
