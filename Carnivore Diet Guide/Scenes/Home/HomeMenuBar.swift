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
    
    @State private var showCreatePost: Bool = false
    
    var body: some View {
        HStack {
            KnowledgeMenuItem()
            Spacer()
            FeedMenuItem()
            Spacer()
            CreatePostMenuItem()
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
        MenuItem(.knowledge, text: "Home", image: { MenuItemImage(image) }) {
            selectedTab = .knowledge
        }
    }
    
    @ViewBuilder func FeedMenuItem() -> some View {
        let image = selectedTab == .feed ? "person.3.fill" : "person.3"
        MenuItem(.feed, text: "Community", image: { MenuItemImage(image) }) {
            selectedTab = .feed
        }
    }
    
    @ViewBuilder func CreatePostMenuItem() -> some View {
        let image = selectedTab == .createPost ? "plus.circle.fill" : "plus.circle"
        MenuItem(.createPost, text: "Create", image: { MenuItemImage(image) }) {
            showCreatePost = true
        }
        .fullScreenCover(isPresented: $showCreatePost) { CreateContentView() }
    }
    
    @ViewBuilder func RecipesMenuItem() -> some View {
        let image = selectedTab == .recipes ? "frying.pan.fill" : "frying.pan"
        MenuItem(.recipes, text: "Recipes", image: { MenuItemImage(image) }) {
            selectedTab = .recipes
        }
    }
    
    @ViewBuilder func ProfileMenuItem() -> some View {
        MenuItem(.profile, text: "Profile", image: ProfileImage) {
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
