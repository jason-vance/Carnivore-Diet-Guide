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
        case feed
        case knowledge
        case createPost
        case recipes
        case profile
    }
    
    @Binding public var selectedTab: HomeMenuTab
    @Binding public var profileImageUrl: URL?
    
    var body: some View {
        HStack {
            FeedMenuItem()
            Spacer()
            KnowledgeMenuItem()
            Spacer()
            CreatePostMenuItem()
            Spacer()
            RecipesMenuItem()
            Spacer()
            ProfileMenuItem()
        }
        .padding(.top, 4)
        .padding(.horizontal, 32)
        .frame(height: Self.height)
        .background(Color.background)
        .overlay(alignment: .top) {
            Rectangle()
                .frame(height: 0.25)
                .foregroundStyle(Color.text)
                .opacity(0.25)
        }
    }
    
    @ViewBuilder func FeedMenuItem() -> some View {
        let image = selectedTab == .feed ? "house.fill" : "house"
        MenuItem(.feed, text: "Home", image: { MenuItemImage(image) })
    }
    
    @ViewBuilder func KnowledgeMenuItem() -> some View {
        let image = selectedTab == .knowledge ? "books.vertical.fill" : "books.vertical"
        MenuItem(.knowledge, text: "Knowledge", image: { MenuItemImage(image) })
    }
    
    @ViewBuilder func CreatePostMenuItem() -> some View {
        let image = selectedTab == .createPost ? "plus.circle.fill" : "plus.circle"
        MenuItem(.createPost, text: "Create", image: { MenuItemImage(image) })
    }
    
    @ViewBuilder func RecipesMenuItem() -> some View {
        let image = selectedTab == .recipes ? "frying.pan.fill" : "frying.pan"
        MenuItem(.recipes, text: "Recipes", image: { MenuItemImage(image) })
    }
    
    @ViewBuilder func ProfileMenuItem() -> some View {
        MenuItem(.profile, text: "Profile", image: ProfileImage)
    }
    
    @ViewBuilder func MenuItem<Content:View>(_ tab: HomeMenuTab, text: String, image: () -> Content) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 0) {
                image()
                    .frame(width: 32, height: 32)
                MenuItemText(text)
            }
            .foregroundStyle(Color.text)
        }
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
            .font(.caption)
    }
}

#Preview {
    StatefulPreviewContainer(HomeMenuBar.HomeMenuTab.feed) { selectedTab in
        Rectangle()
            .overlay(alignment: .bottom) {
                HomeMenuBar(
                    selectedTab: selectedTab,
                    profileImageUrl: .constant(UserData.sample.profileImageUrl)
                )
            }
    }
}
