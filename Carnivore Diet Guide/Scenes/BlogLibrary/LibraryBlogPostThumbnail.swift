//
//  LibraryBlogPostThumbnail.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import SwiftUI

struct LibraryBlogPostThumbnail: View {
    
    @State var blogPost: BlogPost
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(blogPost.title)
                    .font(.system(size: 18, weight: .heavy))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color.background)
                Text(blogPost.publicationDate, style: .date)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.darkAccentText)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.text)
            if let imageName = blogPost.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .offset(y: 20)
                    .clipped()
            }
            if let imageUrl = blogPost.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .offset(y: 20)
                        .clipped()
                        .id(imageUrl)
                } placeholder: {
                    Rectangle()
                        .foregroundStyle(Color.background)
                        .frame(height: 200)
                }
            }
        }
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.darkAccentText ,radius: 4)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        VStack {
            LibraryBlogPostThumbnail(blogPost: .sample)
            LibraryBlogPostThumbnail(blogPost: .longNamedSample)
            LibraryBlogPostThumbnail(blogPost: .sample)
        }
        .padding()
    }
    .background(Color.background)
}
