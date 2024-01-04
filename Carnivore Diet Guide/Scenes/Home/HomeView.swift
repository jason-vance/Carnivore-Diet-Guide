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
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .background(Color.black)
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder func TrendingBlogPostsView() -> some View {
        VStack {
            SectionTitleView("Trending Blog Posts", theme: .light)
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    BlogPostThumbnail(
                        title: "Beef Bourguignon",
                        imageName: "BeefBourguignon",
                        upvotes: 65432
                    )
                    BlogPostThumbnail(
                        title: "Grilled Salmon with Lemon Butter",
                        imageName: "GrilledSalmonWithLemonButter",
                        upvotes: 7654
                    )
                }
                HStack(spacing: 16) {
                    BlogPostThumbnail(
                        title: "Spicy Mexican Beef Skillet",
                        imageName: "SpicyMexicanBeefSkillet",
                        upvotes: 876
                    )
                    BlogPostThumbnail(
                        title: "Sukiyaki-Style Beef",
                        imageName: "SukiyakiStyleBeef",
                        upvotes: 98
                    )
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder func TrendingRecipesView() -> some View {
        VStack {
            SectionTitleView("Trending Recipes", theme: .dark)
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    RecipeThumbnail(
                        title: "Beef Bourguignon",
                        imageName: "BeefBourguignon",
                        rating: 3.4
                    )
                    RecipeThumbnail(
                        title: "Grilled Salmon with Lemon Butter",
                        imageName: "GrilledSalmonWithLemonButter",
                        rating: 4.5
                    )
                }
                HStack(spacing: 16) {
                    RecipeThumbnail(
                        title: "Spicy Mexican Beef Skillet",
                        imageName: "SpicyMexicanBeefSkillet",
                        rating: 4.6
                    )
                    RecipeThumbnail(
                        title: "Sukiyaki-Style Beef",
                        imageName: "SukiyakiStyleBeef",
                        rating: 4.7
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
            SectionTitleView("Recommended For You", theme: .light)
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
    
    @ViewBuilder func SectionTitleView(_ text: String, theme: UIUserInterfaceStyle) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(theme == .light ? Color.text : Color.background)
            Spacer()
            ViewAllButton(theme: theme)
        }
    }
    
    @ViewBuilder func ViewAllButton(theme: UIUserInterfaceStyle) -> some View {
        Button {
            
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
                .frame(height: 64)
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
    HomeView()
}
