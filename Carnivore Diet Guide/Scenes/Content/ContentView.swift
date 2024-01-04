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
    
    @State var selectedTab: Tab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
            RecipesTab()
            BlogTab()
            ProfileTab()
        }
    }
    
    @ViewBuilder func HomeTab() -> some View {
        HomeView()
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
    }
    
    @ViewBuilder func RecipesTab() -> some View {
        Text("Recipe View")
            .tabItem {
                Image(systemName: "frying.pan")
                Text("Recipes")
            }
    }
    
    @ViewBuilder func BlogTab() -> some View {
        Text("Blog View")
            .tabItem {
                Image(systemName: "newspaper")
                Text("Blog")
            }
    }
    
    @ViewBuilder func ProfileTab() -> some View {
        Text("Profile View")
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
    }
}

#Preview {
    ContentView()
}
