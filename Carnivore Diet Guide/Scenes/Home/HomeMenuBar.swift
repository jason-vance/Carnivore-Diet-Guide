//
//  HomeMenuBar.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/19/24.
//

import SwiftUI

struct HomeMenuBar: View {
    
    public static let height: CGFloat = 44
    
    enum HomeMenuTab {
        case knowledge
        case recipes
        case profile
    }

    @Binding public var selectedTab: HomeMenuTab
    @Binding public var profileImageUrl: URL?

    var body: some View {
        HStack {
            KnowledgeMenuItem()
            Spacer()
            RecipesMenuItem()
            Spacer()
            ProfileMenuItem()
        }
        .padding(.top, 4)
        .padding(.horizontal, 16)
        .frame(height: Self.height)
        .background(Color.background)
        .overlay(alignment: .top) { BarDivider() }
    }
    
    @ViewBuilder func KnowledgeMenuItem() -> some View {
        let image = selectedTab == .knowledge ? "house.fill" : "house"
        MenuItem(.knowledge, text: String(localized: "Home"), image: { MenuItemImage(image) }) {
            selectedTab = .knowledge
        }
    }
    
    @ViewBuilder func RecipesMenuItem() -> some View {
        let image = selectedTab == .recipes ? "frying.pan.fill" : "frying.pan"
        MenuItem(.recipes, text: String(localized: "Recipes"), image: { MenuItemImage(image) }) {
            selectedTab = .recipes
        }
    }
    
    @ViewBuilder func ProfileMenuItem() -> some View {
        MenuItem(.profile, text: String(localized: "Profile"), image: ProfileImage) {
            selectedTab = .profile
        }
    }
    
    @ViewBuilder func MenuItem<Content:View>(
        _ tab: HomeMenuTab,
        text: String,
        image: () -> Content,
        onSelected: @escaping () -> ()
    ) -> some View {
        Button {
            onSelected()
        } label: {
            VStack(spacing: 0) {
                image()
                    .frame(width: 32, height: 32)
                MenuItemText(text)
            }
            .foregroundStyle(Color.text)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func ProfileImage() -> some View {
        ProfileImageView(profileImageUrl, size: 28, padding: 2)
    }
    
    @ViewBuilder func MenuItemImage(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 20))
    }
    
    @ViewBuilder func MenuItemText(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
    }
}

#Preview {
    StatefulPreviewContainer(HomeMenuBar.HomeMenuTab.knowledge) { selectedTab in
        Rectangle()
            .overlay(alignment: .bottom) {
                HomeMenuBar(
                    selectedTab: selectedTab,
                    profileImageUrl: .constant(UserData.sample.profileImageUrl)
                )
            }
    }
}
