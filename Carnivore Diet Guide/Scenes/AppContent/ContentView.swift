//
//  ContentView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/1/24.
//

import SwiftUI
import SwinjectAutoregistration

struct ContentView: View {
    
    private let authProvider = iocContainer~>ContentAuthenticationProvider.self
    private let onboardingStateProvider = iocContainer~>UserOnboardingStateProvider.self
    
    @State private var isOnboardingRequired: Bool = false
    @State private var currentUserId: String = ""
    @State private var userAuthState: UserAuthState = .working
    
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
            isOnboardingRequired = newState == .notOnboarded
        }
    }
    
    @ViewBuilder func LoggedOutView() -> some View {
        SignInView()
    }
    
    @ViewBuilder func LoggedInView() -> some View {
        if isOnboardingRequired {
            EditUserProfileView(userId: currentUserId, mode: .createProfile)
        } else {
            HomeView()
        }
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
        
        iocContainer.autoregister(UserOnboardingStateProvider.self) {
            let mock = MockUserOnboardingStateProvider()
            mock.userOnboardingState = .notOnboarded
            return mock
        }
    } content: {
        ContentView()
    }
}
