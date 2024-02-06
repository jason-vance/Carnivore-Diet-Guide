//
//  KnowledgeLibraryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import SwiftUI
import SwinjectAutoregistration

struct KnowledgeLibraryView: View {
    
    private enum LoadingState {
        case idle
        case working
    }
    
    let contentProvider = iocContainer~>KnowledgeLibraryContentProvider.self
    
    @State private var loadingState: LoadingState = .idle
    @State private var posts: [Post] = []
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private func loadPosts() {
        Task {
            loadingState = .working
            do {
                posts = try await contentProvider.loadPosts()
            } catch {
                show(errorMessage: "Unable to load posts: \(error.localizedDescription)")
            }
            loadingState = .idle
        }
    }
    
    private func show(errorMessage: String) {
        showError = true
        self.errorMessage = errorMessage
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
            if posts.isEmpty {
                loadPosts()
            }
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
        if loadingState == .working {
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

#Preview("No Errors") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        KnowledgeLibraryView()
    }
}

#Preview("Loading Error") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        
        iocContainer.autoregister(KnowledgeLibraryContentProvider.self) {
            let mock = MockKnowledgeLibraryContentProvider()
            mock.errorToThrow = "Didn't work"
            return mock
        }
    } content: {
        KnowledgeLibraryView()
    }
}
