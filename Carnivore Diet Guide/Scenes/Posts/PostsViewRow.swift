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
        HStack {
            VStack {
                PostTitle()
                Spacer()
                HStack{
                    PostPublicationDate()
                    MetadataSeparatorView()
                    CommentCountView(resource: .init(post))
                    MetadataSeparatorView()
                    FavoriteCountView(resource: .init(post))
                    Spacer()
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
                .lineLimit(2, reservesSpace: true)
            Spacer()
        }
    }
    
    @ViewBuilder func PostPublicationDate() -> some View {
        Text(post.publicationDate.toBasicUiString())
            .font(.footnote)
    }
}

#Preview {
    PostsViewRow(post: .longNamedSample)
}
