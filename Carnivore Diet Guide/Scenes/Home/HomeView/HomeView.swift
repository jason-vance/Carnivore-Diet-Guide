//
//  HomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeView: View {
    
    private let defaultPadding: CGFloat = 16
    
    @StateObject private var model = HomeViewModel()
    @State private var showUserProfile: Bool = false
    
    private var currentUserId: String {
        (iocContainer~>CurrentUserIdProvider.self).currentUserId!
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                VStack {
                    TitleBar()
                    ScrollView {
                        FeedView(screenWidth: proxy.size.width)
                            .padding(.vertical, defaultPadding)
                    }
                    .overlay(alignment: .top) { ScrollViewShroud() }
                }
                .scrollIndicators(.hidden)
                .background(Color.background)
                //TODO: Add .refreshable to HomeView
            }
        }
        .overlay { CreateMenu() }
        .sheet(isPresented: $showUserProfile) { UserProfileView(userId: currentUserId) }
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
    }
    
    @ViewBuilder func TitleBar() -> some View {
        HStack {
            TitleText()
            Spacer()
            ProfileButton()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func TitleText() -> some View {
        Text(Bundle.main.bundleName ?? "")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func ProfileButton() -> some View {
        Button {
            showUserProfile = true
        } label: {
            ProfileImageView(
                model.userProfileImageUrl,
                size: 32,
                padding: 2
            )
        }
    }
    
    @ViewBuilder func ScrollViewShroud() -> some View {
        LinearGradient(
            colors: [Color.background, Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: defaultPadding)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeView()
    }
}
