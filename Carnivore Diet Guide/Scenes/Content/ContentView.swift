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
    private let onboardingStateProvider = iocContainer~>ContentUserOnboardingStateProvider.self
    
    @State private var isOnboardingRequired: UserOnboardingState = .unknown
    @State private var currentUserId: String = ""
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
        .onReceive(authProvider.currentUserIdPublisher) { newUserId in
            currentUserId = newUserId ?? ""
        }
        .onReceive(onboardingStateProvider.userOnboardingStatePublisher) { newState in
            isOnboardingRequired = newState
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
        .sheet(isPresented: .constant(isOnboardingRequired == .notOnboarded)) {
            EditUserProfileView(userId: currentUserId, dismissable: false)
        }
        .onAppear {
            selectedTab = .home
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
        UserProfileView(userId: currentUserId)
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(Tab.profile)
            .toolbarBackground(Color.background, for: .tabBar)
    }
}

#Preview("Logged In") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ContentView()
    }
}

#Preview("Logged Out") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(ContentAuthenticationProvider.self) {
            let mock = MockContentAuthenticationProvider()
            mock.userAuthState = .loggedOut
            return mock
        }
    } content: {
        ContentView()
    }
}

#Preview("Not Onboarded") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(ContentUserOnboardingStateProvider.self) {
            let mock = MockContentUserOnboardingStateProvider()
            mock.userOnboardingState = .notOnboarded
            return mock
        }
    } content: {
        ContentView()
    }
}
