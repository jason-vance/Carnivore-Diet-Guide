//
//  BlogLibraryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import SwiftUI

struct BlogLibraryView: View {
    
    @State private var blogPosts: [BlogPost] = BlogPost.samples
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TitleBarAndHeroImage()
                ScrollView {
                    BlogPostList()
                }
                .background(Color.background)
                .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
            }
            .background(Color.background)
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
            Text("Blog")
                .font(.system(size: 48, weight: .black))
        }
        .foregroundStyle(Color.background)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .shadow(color: .text, radius: 10, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func HeroImage() -> some View {
        Image("BlogHero")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 150)
            .clipped()
            .offset(y: 16)
            .zIndex(-1)
    }
    
    @ViewBuilder func BlogPostList() -> some View {
        LazyVStack(spacing: 16) {
            ForEach(blogPosts) { blogPost in
                NavigationLink {
                    BlogPostView(blogPost: blogPost)
                } label: {
                    LibraryBlogPostThumbnail(blogPost: blogPost)
                }
            }
        }
        .padding()
    }
}

#Preview {
    BlogLibraryView()
}
