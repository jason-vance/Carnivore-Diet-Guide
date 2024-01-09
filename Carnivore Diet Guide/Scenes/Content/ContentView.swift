//
//  ContentView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/1/24.
//

import SwiftUI

struct ContentView: View {
    
    enum Tab {
        case home
        case recipes
        case blog
        case profile
    }
    
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
            RecipesTab()
            BlogTab()
        }
    }
    
    @ViewBuilder func HomeTab() -> some View {
        HomeView(selectedTab: $selectedTab)
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)
            .toolbarBackground(Color.background, for: .tabBar)
    }
    
    @ViewBuilder func RecipesTab() -> some View {
        RecipeLibraryView()
            .tabItem {
                Label("Recipes", systemImage: "frying.pan")
            }
            .tag(Tab.recipes)
            .toolbarBackground(Color.background, for: .tabBar)
    }
    
    @ViewBuilder func BlogTab() -> some View {
        BlogLibraryView()
            .tabItem {
                Label("Blog", systemImage: "newspaper")
            }
            .tag(Tab.blog)
            .toolbarBackground(Color.background, for: .tabBar)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ContentView()
    }
}
