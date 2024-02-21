//
//  HomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeView: View {
    
    private let scrollShroudHeight: CGFloat = 16
    private let defaultPadding: CGFloat = 8

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
                        ScrollableHomeContent(screenWidth: proxy.size.width)
                    }
                    .overlay(alignment: .top) { ScrollViewShroud() }
                }
                .scrollIndicators(.hidden)
                .background(Color.background)
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
        .frame(height: scrollShroudHeight)
    }
    
    @ViewBuilder func ScrollableHomeContent(screenWidth: CGFloat) -> some View {
        VStack {
            QuickLinks()
            NewsFeed(screenWidth: screenWidth)
        }
        .padding(.top, scrollShroudHeight)
    }
    
    @ViewBuilder func QuickLinks() -> some View {
        VStack(spacing: 0) {
            SectionHeader(String(localized: "Quick Links"))
            ScrollView(.horizontal) {
                LazyHStack {
                    QuickLinkItem(String(localized: "Recipes"), imageName: "HomeHero")
                    QuickLinkItem(String(localized: "Articles"), imageName: "KnowledgeHero")
                }
                .padding(defaultPadding)
            }
        }
    }
    
    @ViewBuilder func QuickLinkItem(_ text: String, imageName: String) -> some View {
        NavigationLink {
            //Navigate to Recipes and Knowledge
            Text(text)
        } label: {
            VStack(spacing: 2) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 125, height: 125)
                Text(text)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .foregroundStyle(Color.text)
                    .padding(4)
            }
            .background(Color.background)
            .frame(width: 125)
            .clipShape(RoundedRectangle(cornerRadius: Corners.radius, style: .continuous))
            .shadow(color: Color.text, radius: 4)
        }
    }
    
    @ViewBuilder func NewsFeed(screenWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            SectionHeader(String(localized: "News Feed"))
            FeedView(screenWidth: screenWidth)
                .padding(.top, defaultPadding)
        }
    }
    
    @ViewBuilder func SectionHeader(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.text.opacity(0.8))
            Spacer()
        }
        .padding(.horizontal, defaultPadding)
        Divider()
            .padding(.horizontal, defaultPadding)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeView()
    }
}
