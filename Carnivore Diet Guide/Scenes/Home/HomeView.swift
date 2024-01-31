//
//  HomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/2/24.
//

import SwiftUI
import SwinjectAutoregistration

struct HomeView: View {
    
    enum FeaturedItemType {
        case blogPost
        case recipe
    }
    
    private let contentProvider = iocContainer~>HomeViewContentProvider.self
    
    @Binding var selectedTab: ContentView.Tab
    
    @State var content: HomeViewContent? = nil
    
    func loadContent() {
        Task {
            content = await contentProvider.loadContent()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBarAndHeroImage()
                ContentView()
                    .background(Color.background)
                    .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
            }
            .background(Color.background)
        }
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
                TrendingBlogPostsView()
            }
        }
    }
    
    @ViewBuilder func TrendingBlogPostsView() -> some View {
        VStack {
            SectionTitleView(
                String(localized: "Trending Blog Posts"),
                theme: .light,
                viewAllAction: { selectedTab = .blog }
            )
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    NavigationLink {
                        BlogPostView(blogPost: .sample)
                    } label: {
                        HomeBlogPostThumbnail(
                            title: "Beef Bourguignon",
                            imageName: "BeefBourguignon"
                        )
                    }
                    NavigationLink {
                        BlogPostView(blogPost: .sample)
                    } label: {
                        HomeBlogPostThumbnail(
                            title: "Grilled Salmon with Lemon Butter",
                            imageName: "GrilledSalmonWithLemonButter"
                        )
                    }
                }
                HStack(spacing: 16) {
                    NavigationLink {
                        BlogPostView(blogPost: .sample)
                    } label: {
                        HomeBlogPostThumbnail(
                            title: "Spicy Mexican Beef Skillet",
                            imageName: "SpicyMexicanBeefSkillet"
                        )
                    }
                    NavigationLink {
                        BlogPostView(blogPost: .sample)
                    } label: {
                        HomeBlogPostThumbnail(
                            title: "Sukiyaki-Style Beef",
                            imageName: "SukiyakiStyleBeef"
                        )
                    }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder func TrendingRecipesView() -> some View {
        VStack {
            SectionTitleView(
                String(localized: "Trending Recipes"),
                theme: .dark,
                viewAllAction: { selectedTab = .recipes }
            )
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    NavigationLink {
                        RecipeDetailView(recipe: .sample)
                    } label: {
                        HomeRecipeThumbnail(
                            title: "Beef Bourguignon",
                            imageName: "BeefBourguignon"
                        )
                    }
                    NavigationLink {
                        RecipeDetailView(recipe: .sample)
                    } label: {
                        HomeRecipeThumbnail(
                            title: "Grilled Salmon with Lemon Butter",
                            imageName: "GrilledSalmonWithLemonButter"
                        )
                    }
                }
                HStack(spacing: 16) {
                    NavigationLink {
                        RecipeDetailView(recipe: .sample)
                    } label: {
                        HomeRecipeThumbnail(
                            title: "Spicy Mexican Beef Skillet",
                            imageName: "SpicyMexicanBeefSkillet"
                        )
                    }
                    NavigationLink {
                        RecipeDetailView(recipe: .sample)
                    } label: {
                        HomeRecipeThumbnail(
                            title: "Sukiyaki-Style Beef",
                            imageName: "SukiyakiStyleBeef"
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.text)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
        
    @ViewBuilder func FeaturedContentView() -> some View {
        VStack {
            SectionTitleView(
                String(localized: "Recommended For You"),
                theme: .light
            )
            HStack(spacing: 16) {
                NavigationLink {
                    BlogPostView(blogPost: .sample)
                } label: {
                    FeaturedContentThumbnail(
                        title: "Getting Started with the Carnivore Diet",
                        imageName: "StartingCarnivoreDiet",
                        type: .blog
                    )
                }
                NavigationLink {
                    RecipeDetailView(recipe: .sample)
                } label: {
                    FeaturedContentThumbnail(
                        title: "Seared Ribeye Steak",
                        imageName: "SearedRibeyeSteak",
                        type: .recipe
                    )
                }
            }
        }
        .padding()
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
