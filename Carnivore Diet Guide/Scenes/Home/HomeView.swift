//
//  HomeView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/2/24.
//

import SwiftUI

struct HomeView: View {
    
    enum FeaturedItemType {
        case blogPost
        case recipe
    }
    
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBarAndHeroImage()
            ScrollView {
                VStack {
                    FeaturedContentView()
                    TrendingRecipesView()
                    TrendingBlogPostsView()
                }
            }
            .background(Color.background)
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
        }
        .background(Color.background)
    }
    
    @ViewBuilder func TrendingBlogPostsView() -> some View {
        VStack {
            SectionTitleView(
                "Trending Blog Posts",
                theme: .light,
                viewAllAction: { selectedTab = .blog }
            )
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    BlogPostThumbnail(
                        title: "Beef Bourguignon",
                        imageName: "BeefBourguignon"
                    )
                    BlogPostThumbnail(
                        title: "Grilled Salmon with Lemon Butter",
                        imageName: "GrilledSalmonWithLemonButter"
                    )
                }
                HStack(spacing: 16) {
                    BlogPostThumbnail(
                        title: "Spicy Mexican Beef Skillet",
                        imageName: "SpicyMexicanBeefSkillet"
                    )
                    BlogPostThumbnail(
                        title: "Sukiyaki-Style Beef",
                        imageName: "SukiyakiStyleBeef"
                    )
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder func TrendingRecipesView() -> some View {
        VStack {
            SectionTitleView(
                "Trending Recipes",
                theme: .dark,
                viewAllAction: { selectedTab = .recipes }
            )
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    RecipeThumbnail(
                        title: "Beef Bourguignon",
                        imageName: "BeefBourguignon"
                    )
                    RecipeThumbnail(
                        title: "Grilled Salmon with Lemon Butter",
                        imageName: "GrilledSalmonWithLemonButter"
                    )
                }
                HStack(spacing: 16) {
                    RecipeThumbnail(
                        title: "Spicy Mexican Beef Skillet",
                        imageName: "SpicyMexicanBeefSkillet"
                    )
                    RecipeThumbnail(
                        title: "Sukiyaki-Style Beef",
                        imageName: "SukiyakiStyleBeef"
                    )
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
                "Recommended For You",
                theme: .light,
                viewAllAction: { }
            )
            HStack(spacing: 16) {
                FeaturedContentThumbnail(
                    title: "Getting Started with the Carnivore Diet",
                    imageName: "StartingCarnivoreDiet",
                    type: .blog
                )
                FeaturedContentThumbnail(
                    title: "Seared Ribeye Steak",
                    imageName: "SearedRibeyeSteak",
                    type: .recipe
                )
            }
        }
        .padding()
    }
    
    @ViewBuilder func SectionTitleView(
        _ text: String,
        theme: UIUserInterfaceStyle,
        viewAllAction: @escaping () -> ()
    ) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(theme == .light ? Color.text : Color.background)
            Spacer()
            ViewAllButton(theme: theme) {
                viewAllAction()
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
                .foregroundStyle(theme == .light ? Color.accentText : Color.cardBackground)
        }
    }
    
    @ViewBuilder func HeroImage() -> some View {
        Image("HomeHero")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 200)
            .offset(y: 16)
    }
    
    @ViewBuilder func TitleView() -> some View {
        VStack(spacing: 0) {
            Text("Carnivore")
                .font(.system(size: 48, weight: .black))
            Text("Diet Guide")
                .font(.system(size: 40, weight: .black))
                .offset(y: -12)
        }
        .padding(.top, 8)
        .foregroundStyle(Color.background)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .offset(y: -12)
    }
    
    @ViewBuilder func TitleBarAndHeroImage() -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 48)
            HeroImage()
        }
        .background {
            Rectangle()
                .fill(Color.accentColor)
                .ignoresSafeArea(.all)
        }
        .overlay(alignment: .top) {
            TitleView()
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
