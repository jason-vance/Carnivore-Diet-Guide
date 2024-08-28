//
//  PostsViewRow.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import SwiftUI

struct PostsViewRow: View {
    
    private let maxHeight: CGFloat = 64
    private let imageCorners: CGFloat = 8
    
    public let post: Post
    
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                PostTitle()
                Spacer()
                HStack {
                    PublicationDateView(resource: .init(post))
                    Spacer()
                    CommentCountView(resource: .init(post))
                    MetadataSeparatorView()
                    FavoriteCountView(resource: .init(post))
                }
            }
            PostCoverImage()
        }
        .frame(maxHeight: maxHeight)
    }
    
    @ViewBuilder func PostCoverImage() -> some View {
        if let coverUrl = post.imageUrls.first {
            VStack {
                ResourceImageView(url: coverUrl)
                    .clipShape(.rect(cornerRadius: imageCorners, style: .continuous))
            }
            .frame(width: maxHeight, height: maxHeight)
        }
    }
    
    @ViewBuilder func PostTitle() -> some View {
        HStack {
            Text(post.title)
                .font(.headline)
                .foregroundStyle(Color.text)
                .lineLimit(2, reservesSpace: true)
            Spacer()
        }
    }
}

#Preview {
    PostsViewRow(post: .longNamedSample)
}
