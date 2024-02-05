//
//  HomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/2/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeView: View {
    
    private let contentProvider = iocContainer~>HomeViewContentProvider.self
    
    @Binding var selectedTab: ContentView.Tab
    
    @State var content: HomeViewContent? = nil
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    func loadContent() {
        Task {
            do {
                content = try await contentProvider.loadContent()
            } catch {
                showError = true
                errorMessage = "Unable to load: \(error.localizedDescription)"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBarAndHeroImage()
                ContentView()
                    .background(Color.background)
                    .clipShape(.rect(topLeadingRadius: Corners.radius, topTrailingRadius: Corners.radius))
            }
            .background(Color.background)
        }
        .alert(errorMessage, isPresented: $showError) {}
        .onAppear {
            loadContent()
        }
    }
    
    @ViewBuilder func ContentView() -> some View {
        if content == nil {
            LoadingView()
        } else {
            LoadedContentView()
        }
    }
    
    @ViewBuilder func LoadingView() -> some View {
        ZStack {
            ZStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder func LoadedContentView() -> some View {
        ScrollView {
            VStack {
                FeaturedContentView()
                TrendingRecipesView()
                TrendingPostsView()
            }
        }
    }
    
    @ViewBuilder func FeaturedContentView() -> some View {
        VStack(spacing: 0) {
            SectionTitleView(
                String(localized: "Recommended For You"),
                theme: .light
            )
            .padding(.top)
            .padding(.horizontal)
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    let featuredPost = content!.featuredPost
                    let featuredRecipe = content!.featuredRecipe
                    
                    NavigationLink {
                        PostDetailView(post: featuredPost)
                    } label: {
                        FeaturedContentThumbnail(
                            title: featuredPost.title,
                            imageUrl: featuredPost.imageUrl,
                            imageName: featuredPost.imageName,
                            type: .post
                        )
                    }
                    NavigationLink {
                        RecipeDetailView(recipe: .sample)
                    } label: {
                        FeaturedContentThumbnail(
                            title: featuredRecipe.title,
                            imageUrl: featuredRecipe.imageUrl,
                            imageName: featuredRecipe.imageName,
                            type: .recipe
                        )
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
        }
        .padding(.bottom)
    }
    
    @ViewBuilder func TrendingRecipesView() -> some View {
        VStack(spacing: 0) {
            SectionTitleView(
                String(localized: "Trending Recipes"),
                theme: .dark,
                viewAllAction: { selectedTab = .recipes }
            )
            .padding(.top)
            .padding(.horizontal)
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(content!.trendingRecipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            HomeRecipeThumbnail(
                                title: recipe.title,
                                imageUrl: recipe.imageUrl,
                                imageName: recipe.imageName
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .scrollIndicators(.hidden)
        .padding(.bottom)
        .background(Color.text)
        .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
    }
    
    @ViewBuilder func TrendingPostsView() -> some View {
        VStack {
            SectionTitleView(
                String(localized: "Trending Posts"),
                theme: .light,
                viewAllAction: { selectedTab = .post }
            )
            .padding(.top)
            .padding(.horizontal)
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(content!.trendingPosts) { post in
                        NavigationLink {
                            PostDetailView(post: post)
                        } label: {
                            HomePostThumbnail(
                                title: post.title,
                                imageUrl: post.imageUrl,
                                imageName: post.imageName
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .scrollIndicators(.hidden)
        .padding(.bottom)
    }
    
    @ViewBuilder func SectionTitleView(
        _ text: String,
        theme: UIUserInterfaceStyle,
        viewAllAction: (() -> ())? = nil
    ) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(theme == .light ? Color.text : Color.background)
            Spacer()
            if let viewAllAction = viewAllAction {
                ViewAllButton(theme: theme) {
                    viewAllAction()
                }
            }
        }
    }
    
    @ViewBuilder func ViewAllButton(
        theme: UIUserInterfaceStyle,
        _ action: @escaping () -> ()
    ) -> some View {
        Button {
            action()
        } label: {
            Text("View All")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(theme == .light ? Color.accentText : Color.darkAccentText)
        }
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
            Text("Carnivore", comment: "First line of the app name on the home screen. ie\n\"Carnivore\nDiet Guide\"")
                .font(.system(size: 48, weight: .black))
            Text("Diet Guide", comment: "Second line of the app name on the home screen. ie\n\"Carnivore\nDiet Guide\"")
                .font(.system(size: 40, weight: .black))
                .offset(y: -12)
        }
        .foregroundStyle(Color.background)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func HeroImage() -> some View {
        Image("HomeHero")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .clipped()
            .offset(y: 16)
            .zIndex(-1)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        HomeView(selectedTab: .constant(.home))
    }
}
