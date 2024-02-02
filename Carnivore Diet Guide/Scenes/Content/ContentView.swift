//
//  ContentView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/1/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ContentView: View {
    
    enum Tab {
        case home
        case recipes
        case blog
        case profile
    }
    
    private let authProvider = iocContainer~>ContentAuthenticationProvider.self
    
    @State private var userAuthState: UserAuthState = .working
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        Group {
            if userAuthState == .loggedIn {
                LoggedInView()
            } else {
                LoggedOutView()
            }
        }
        .onReceive(authProvider.userAuthStatePublisher) { newAuthState in
            withAnimation(.snappy) {
                userAuthState = newAuthState
            }
        }
    }
    
    @ViewBuilder func LoggedOutView() -> some View {
        SignInView()
    }
    
    @ViewBuilder func LoggedInView() -> some View {
        TabView(selection: $selectedTab) {
            HomeTab()
            RecipesTab()
            BlogTab()
            UserProfileTab()
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
                Label("Knowledge", systemImage: "newspaper")
            }
            .tag(Tab.blog)
            .toolbarBackground(Color.background, for: .tabBar)
    }
    
    @ViewBuilder func UserProfileTab() -> some View {
        UserProfileView()
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(Tab.profile)
            .toolbarBackground(Color.background, for: .tabBar)
    }
}

#Preview("Logged Out") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ContentView()
    }
}

#Preview("Logged In") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(ContentAuthenticationProvider.self) {
            let mock = MockContentAuthenticationProvider()
            mock.userAuthState = .loggedIn
            return mock
        }
    } content: {
        ContentView()
    }
}
