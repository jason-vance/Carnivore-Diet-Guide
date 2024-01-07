//
//  BlogPostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import SwiftUI

struct BlogPostView: View {
    
    let blogPost: BlogPost

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                BlogPostTitle()
                BlogPostByLine()
                BlogPostContent()
            }
            .padding()
        }
    }
    
    @ViewBuilder func BlogPostTitle() -> some View {
        Text(blogPost.title)
            .font(.title)
    }
    
    @ViewBuilder func BlogPostByLine() -> some View {
        VStack(alignment: .leading) {
            Text("By \(blogPost.author)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(blogPost.publicationDate, style: .date)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder func BlogPostContent() -> some View {
        ForEach(blogPost.content, id: \.id) { item in
            if let textItem = item as? BlogPost.TextItem {
                TextContent(textItem)
            } else if let imageItem = item as? BlogPost.ImageItem {
                ImageContent(imageItem)
            }
        }
    }
    
    @ViewBuilder func TextContent(_ textItem: BlogPost.TextItem) -> some View {
        Text(textItem.text)
    }
    
    @ViewBuilder func ImageContent(_ imageItem: BlogPost.ImageItem) -> some View {
        AsyncImage(url: URL(string: imageItem.url)) { image in
            image
                .resizable()
                .clipShape(.rect(cornerRadius: 16))
        } placeholder: {
            ProgressView()
        }
        .aspectRatio(contentMode: .fit)
        
        if let caption = imageItem.caption {
            Text(caption)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    BlogPostView(blogPost: .sample)
}
