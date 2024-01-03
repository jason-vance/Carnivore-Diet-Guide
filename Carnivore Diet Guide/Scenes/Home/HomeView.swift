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
            HStack {
                Text("Trending Blog Posts")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.text)
                Spacer()
                Text("See More")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.accentText)
            }
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    BlogPostThumbnailView(
                        title: "Beef Bourguignon",
                        imageName: "BeefBourguignon",
                        upvotes: 65432
                    )
                    BlogPostThumbnailView(
                        title: "Grilled Salmon with Lemon Butter",
                        imageName: "GrilledSalmonWithLemonButter",
                        upvotes: 7654
                    )
                }
                HStack(spacing: 16) {
                    BlogPostThumbnailView(
                        title: "Spicy Mexican Beef Skillet",
                        imageName: "SpicyMexicanBeefSkillet",
                        upvotes: 876
                    )
                    BlogPostThumbnailView(
                        title: "Sukiyaki-Style Beef",
                        imageName: "SukiyakiStyleBeef",
                        upvotes: 98
                    )
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder func BlogPostThumbnailView(
        title: String,
        imageName: String,
        upvotes: Int
    ) -> some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 0) {
                        Text("\(upvotes.formatted())")
                        Image(systemName: "hand.thumbsup.fill")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.background)
                    .padding(8)
                    .background(Color.accent)
                    .clipShape(.rect(bottomLeadingRadius: 16))
                }
                .overlay(alignment: .bottom) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.background)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .padding(8)
                        .background(Color.text)
                }
        }
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.accentText ,radius: 4)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func TrendingRecipesView() -> some View {
        VStack {
            HStack {
                Text("Trending Recipes")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.background)
                Spacer()
                Text("See More")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.cardBackground)
            }
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    RecipeThumbnailView(
                        title: "Beef Bourguignon",
                        imageName: "BeefBourguignon",
                        rating: 3.4
                    )
                    RecipeThumbnailView(
                        title: "Grilled Salmon with Lemon Butter",
                        imageName: "GrilledSalmonWithLemonButter",
                        rating: 4.5
                    )
                }
                HStack(spacing: 16) {
                    RecipeThumbnailView(
                        title: "Spicy Mexican Beef Skillet",
                        imageName: "SpicyMexicanBeefSkillet",
                        rating: 4.6
                    )
                    RecipeThumbnailView(
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
    
    @ViewBuilder func RecipeThumbnailView(
        title: String,
        imageName: String,
        rating: Float
    ) -> some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 0) {
                        Text(rating.formatted())
                        Image(systemName: "star.fill")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.background)
                    .padding(8)
                    .background(Color.accent)
                    .clipShape(.rect(bottomLeadingRadius: 16))
                }
                .overlay(alignment: .bottom) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .padding(8)
                        .background(Color.background)
                }
        }
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.cardBackground ,radius: 4)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func FeaturedContentView() -> some View {
        VStack {
            HStack {
                Text("Recommended For You")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.text)
                Spacer()
                Text("See More")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.accentText)
            }
            HStack(spacing: 16) {
                FeaturedItem(
                    type: .blogPost,
                    imageName: "StartingCarnivoreDiet",
                    title: "Getting Started with the Carnivore Diet"
                )
                FeaturedItem(
                    type: .recipe,
                    imageName: "SearedRibeyeSteak",
                    title: "Seared Ribeye Steak"
                )
            }
        }
        .padding()
    }
    
    @ViewBuilder func FeaturedItem(
        type: FeaturedItemType,
        imageName: String,
        title: String
    ) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(alignment: .topLeading) {
                        Text(type == .recipe ? "Featured Recipe" : "Featured Blog Post")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.background)
                            .bold()
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.accent)
                    }
                    .overlay(alignment: .bottom) {
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.background)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .padding(8)
                            .background(Color.text)
                    }
            }
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.accentText ,radius: 4)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func HeroImage() -> some View {
        Image("HomeHero")
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    
    @ViewBuilder func TitleBarAndHeroImage() -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: 64)
            Image("HomeHero")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
        }
        .background {
            Rectangle()
                .fill(Color.accentColor)
                .ignoresSafeArea(.all)
        }
        .overlay(alignment: .top) {
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
        .overlay(alignment: .topTrailing) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundStyle(Color.background)
                .frame(width: 32, height: 32)
                .padding()
        }
    }
}

#Preview {
    HomeView()
}
