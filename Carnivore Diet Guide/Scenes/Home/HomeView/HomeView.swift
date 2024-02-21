//
//  HomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeView: View {
    
    @StateObject private var model = HomeViewModel()
    @State private var showUserProfile: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    FeedView(screenWidth: proxy.size.width)
                }
                .scrollIndicators(.hidden)
                .background(Color.background)
                .toolbarRole(.navigationStack)
                .toolbar { NavigationBar() }
                .searchable(text: $model.searchString, placement: .navigationBarDrawer)
                .searchScopes($model.searchScope, activation: .onSearchPresentation) {
                    SearchScopes()
                }
                .onSubmit(of: .search) {
                    model.doSearch()
                }
                //TODO: Add .refreshable to HomeView
            }
        }
        .overlay {
            CreateMenu()
        }
        .sheet(isPresented: $showUserProfile) {
            if let userId = (iocContainer~>CurrentUserIdProvider.self).currentUserId {
                UserProfileView(userId: userId)
            }
        }
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
    }
    
    @ToolbarContentBuilder func NavigationBar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            TitleText()
        }
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButton()
        }
    }
    
    @ViewBuilder func SearchScopes() -> some View {
        Text("All").tag(HomeViewModel.SearchScope.all)
        Text("Recipe").tag(HomeViewModel.SearchScope.recipe)
        Text("Article").tag(HomeViewModel.SearchScope.article)
        Text("Discussion").tag(HomeViewModel.SearchScope.discussion)
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
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeView()
    }
}
