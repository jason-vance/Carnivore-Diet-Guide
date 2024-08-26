//
//  PostDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import SwiftUI
import MarkdownUI
import SwinjectAutoregistration

struct PostDetailView: View {
    
    let postId: String
    
    private let postFetcher = iocContainer~>PostFetcher.self
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var post: Post? = nil
    
    @State private var showPostFailedToFetch: Bool = false
    
    private func fetchPost(withId postId: String) {
        Task {
            do {
                post = try await postFetcher.fetchPost(withId: postId)
            } catch {
                print("Post failed to fetch")
                showPostFailedToFetch = true
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar()
            if let post = post {
                ScrollView {
                    PostView(post: post)
                        .padding()
                }
            } else {
                LoadingView()
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .onChange(of: postId, initial: true) { oldPostId, newPostId in
            fetchPost(withId: newPostId)
        }
        .alert("The post could not be fetched", isPresented: $showPostFailedToFetch) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
    }
    
    @ViewBuilder func NavigationBar() -> some View {
        HStack {
            CloseButton()
            Spacer()
            if let post = post {
                let resource = Resource(post)
                
                //TODO: Make these easier to tap (bigger), and space them out better
                CommentButton(resource: resource)
                FavoriteButton(resource: resource)
            }
        }
        .padding()
        .frame(height: .defaultBarHeight)
        .overlay(alignment: .bottom) {
            BarDivider()
        }
    }
    
    @ViewBuilder private func LoadingView() -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.text)
                .opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.accentColor)
                .padding()
                .background(Color.background)
                .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
        }
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "chevron.backward")
        }
    }
}

#Preview("Default") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        PostDetailView(postId: Post.sample.id)
    }
}

#Preview("Fails to load") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
        iocContainer.autoregister(PostFetcher.self, initializer: { DefaultPostFetcher.forPreviewsWithFailure })
    } content: {
        NavigationStack {
            NavigationLink {
                PostDetailView(postId: Post.sample.id)
            } label: {
                HStack {
                    Text("Post Detail\n(Fails to Load)")
                    Image(systemName: "chevron.forward")
                }
                .foregroundStyle(Color.background)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: Corners.radius, style: .continuous)
                        .foregroundStyle(Color.accent)
                }
            }
        }
    }
}
