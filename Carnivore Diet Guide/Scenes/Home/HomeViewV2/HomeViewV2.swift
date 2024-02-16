//
//  HomeViewV2.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeViewV2: View {
    
    let itemHorizontalPadding: CGFloat = 8
    
    @State var showUserProfile: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    TitleBar()
                    ScrollView {
                        HomeContent(imageSize: proxy.size.width)
                            .padding(.vertical)
                    }
                    .scrollIndicators(.hidden)
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [Color.background, Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 16)
                    }
                }
                .background(Color.background)
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
    }
    
    @ViewBuilder func TitleBar() -> some View {
        HStack {
            TitleText()
            Spacer()
        }
        .overlay(alignment: .trailing) {
            HStack {
                SearchButton()
                ProfileButton()
            }
            .padding(.trailing)
        }
    }
    
    @ViewBuilder func TitleText() -> some View {
        Text(Bundle.main.bundleName ?? "")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color.text)
            .padding()
    }
    
    @ViewBuilder func SearchButton() -> some View {
        Button {
            //TODO: Add ability to search
        } label: {
            Image(systemName: "magnifyingglass.circle.fill")
                .resizable()
                .foregroundStyle(Color.background)
                .padding(2)
                .background {
                    Circle()
                        .fill(Color.accentColor)
                }
                .frame(width: 32, height: 32)
        }
    }
    
    @ViewBuilder func ProfileButton() -> some View {
        Button {
            showUserProfile = true
        } label: {
            //TODO: Use a real profileImageUrl
            ProfileImageView(UserData.sample.profileImageUrl, size: 32, padding: 2)
        }
    }
    
    @ViewBuilder func HomeContent(imageSize: CGFloat) -> some View {
        VStack {
            InfinitePosts(imageSize: imageSize)
        }
    }
    
    @ViewBuilder func FeaturedContent() -> some View {
        
    }
    
    @ViewBuilder func InfinitePosts(imageSize: CGFloat) -> some View {
        //TODO: Use real posts
        LazyVStack(spacing: 16) {
            ForEach(1..<12, id: \.self) { index in
                FeedItemView(
                    feedItem: .init(
                        id: "\(index)",
                        userId: FeedItem.sample.userId,
                        imageUrls: FeedItem.sample.imageUrls,
                        category: FeedItem.sample.category,
                        title: FeedItem.sample.title,
                        summary: FeedItem.sample.summary
                    ),
                    imageSize: imageSize - (2 * itemHorizontalPadding)
                )
                .padding(.horizontal, itemHorizontalPadding)
            }
        }
        .overlay(alignment: .bottom) {
            Image(systemName: "flag.checkered.2.crossed")
                .font(.system(size: 22))
                .foregroundStyle(Color.text)
                .offset(y: 150)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeViewV2()
    }
}
