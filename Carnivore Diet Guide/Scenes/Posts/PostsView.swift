//
//  PostsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import SwiftUI
import SwinjectAutoregistration

struct PostsView: View {
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    public let userData: UserData
    
    private let postsFetcher = iocContainer~>PostsFetcher.self
    private let fetchLimit: Int = 10
    @State private var fetchCursor: PostsFetcherCursor? = nil
    @State private var canFetchMorePosts: Bool = true
    
    @State private var posts: [Post] = []
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var screenTitle: String {
        if let fullName = userData.fullName?.value {
            return String(localized: "Posts by \(fullName)")
        }
        return String(localized: "Posts")
    }
    
    private func fetchMorePosts() {
        Task {
            do {
                let newPosts = try await postsFetcher.fetchPosts(
                    byUser: userData.id,
                    after: &fetchCursor,
                    limit: fetchLimit
                )
                
                if newPosts.isEmpty {
                    withAnimation(.snappy) {
                        canFetchMorePosts = false
                    }
                }
                
                posts.append(contentsOf: newPosts)
            } catch {
                show(alert: String(localized: "Failed to get posts. \(error.localizedDescription)"))
            }
        }
    }
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                ForEach(posts) { post in
                    //TODO: Make a NavigationLink
                    PostsViewRow(post: post)
                        .listRowBackground(Color.background)
                }
                LoadNextFeedItemsView()
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .alert(alertMessage, isPresented: $showAlert) {}
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar(
            screenTitle,
            leftBarContent: BackButton
        )
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "chevron.backward")
        }
    }
    
    @ViewBuilder func LoadNextFeedItemsView() -> some View {
        if canFetchMorePosts {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accent)
                    .padding(.vertical, 64)
                Spacer()
            }
            .onAppear { fetchMorePosts() }
            .listRowBackground(Color.background)
            .listRowSeparator(.hidden)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        PostsView(userData: UserData.sample)
    }
}
