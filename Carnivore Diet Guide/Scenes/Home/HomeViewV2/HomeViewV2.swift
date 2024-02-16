//
//  HomeViewV2.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/14/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeViewV2: View {
    
    @State var searchText: String = ""
    @State var showUserProfile: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBar()
                ScrollView {
                    HomeContent()
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
            ProfileImageView(UserData.sample.profileImageUrl, size: 32, padding: 2)
        }
    }
    
    @ViewBuilder func HomeContent() -> some View {
        VStack {
            InfinitePosts()
        }
    }
    
    @ViewBuilder func FeaturedContent() -> some View {
        
    }
    
    @ViewBuilder func InfinitePosts() -> some View {
        LazyVStack(spacing: 0) {
            ForEach(1..<12, id: \.self) { index in
                Rectangle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(Color.text)
                    .frame(height: 375)
                    .overlay {
                        Text("\(index)")
                    }
                
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
