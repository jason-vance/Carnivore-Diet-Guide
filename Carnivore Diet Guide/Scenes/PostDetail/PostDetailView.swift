//
//  PostDetailView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import Combine
import SwiftUI
import MarkdownUI
import SwinjectAutoregistration

struct PostDetailView: View {
    
    private let postFetcher = iocContainer~>PostFetcher.self
    private let activityTracker = iocContainer~>ResourceViewActivityTracker.self
    private let userIdProvider = iocContainer~>CurrentUserIdProvider.self
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State private var postId: String
    @State private var post: Post?
    @State private var isWorking: Bool = false
    
    @State private var showPostFailedToFetch: Bool = false
    
    @State private var showAds: Bool = false
    private var showAdsPublisher: AnyPublisher<Bool,Never> {
        (iocContainer~>AdProvider.self)
            .showAdsPublisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    init(postId: String) {
        self.post = nil
        self.postId = postId
    }
    
    init(post: Post) {
        self.post = post
        self.postId = post.id
    }
    
    private func fetchPost(withId postId: String) {
        guard postId != post?.id else { return }
        
        Task {
            do {
                post = try await postFetcher.fetchPost(withId: postId)
            } catch {
                print("Post failed to fetch")
                showPostFailedToFetch = true
            }
        }
    }
    
    private func markAsViewed() {
        guard let post = post else { return }
        guard let userId = userIdProvider.currentUserId else { return }
        guard post.author != userId else { return }
        
        Task {
            try? await activityTracker.resource(.init(post), wasViewedByUser: userId)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar()
            if let post = post, !isWorking {
                ScrollView {
                    VStack(spacing: 0) {
                        if showAds { AdRow() }
                        PostView(post: post)
                            .onAppear { markAsViewed() }
                    }
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
        .onReceive(showAdsPublisher) { showAds = $0 }
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
            OptionsMenu()
        }
        .padding()
        .frame(height: .barHeight)
        .overlay(alignment: .bottom) {
            BarDivider()
        }
    }
    
    @ViewBuilder func OptionsMenu() -> some View {
        if let post = post {
            let resource = Resource(post)
            
            HStack(spacing: 16) {
                ExtraOptionsButton(
                    resource: resource,
                    isWorking: $isWorking,
                    dismissResource: { dismiss() }
                )
                CommentButton(resource: resource)
                FavoriteButton(resource: resource)
            }
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
                .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
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

#Preview("Default postId init") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        PostDetailView(postId: Post.sample.id)
    }
}

#Preview("Default post init") {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        PostDetailView(post: Post.sample)
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
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(Color.accent)
                }
            }
        }
    }
}
