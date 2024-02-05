//
//  KnowledgeLibraryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import SwiftUI
import SwinjectAutoregistration

struct KnowledgeLibraryView: View {
    
    let contentProvider = iocContainer~>KnowledgeLibraryContentProvider.self
    
    @State private var posts: [Post] = []
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func loadPosts() {
        contentProvider.loadPosts { posts in
            self.posts = posts
        } onError: { error in
            self.showError = true
            self.errorMessage = error.localizedDescription
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBarAndHeroImage()
                PostList()
                    .background(Color.background)
                    .clipShape(.rect(topLeadingRadius: Corners.radius, topTrailingRadius: Corners.radius))
            }
            .background(Color.background)
        }
        .onAppear {
            loadPosts()
        }
        .alert(errorMessage, isPresented: $showError) {}
    }
    
    @ViewBuilder func TitleBarAndHeroImage() -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundStyle(Color.accent)
                .frame(height: 48)
            HeroImage()
        }
        .overlay(alignment: .top) {
            TitleView()
        }
        .background(Color.accent)
    }
    
    @ViewBuilder func TitleView() -> some View {
        VStack(spacing: 0) {
            Text("Knowledge")
                .font(.system(size: 48, weight: .black))
        }
        .foregroundStyle(Color.background)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func HeroImage() -> some View {
        Image("KnowledgeHero")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 150)
            .clipped()
            .offset(y: 16)
            .zIndex(-1)
    }
    
    @ViewBuilder func PostList() -> some View {
        if posts.isEmpty {
            ZStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts) { post in
                        NavigationLink {
                            PostDetailView(post: post)
                        } label: {
                            LibraryPostThumbnail(post: post)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        KnowledgeLibraryView()
    }
}
