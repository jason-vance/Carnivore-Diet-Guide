//
//  BlogPostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/6/24.
//

import SwiftUI
import MarkdownUI

struct BlogPostView: View {
    
    let blogPost: BlogPost
    
    @Environment(\.dismiss) private var dismiss: DismissAction

    var body: some View {
        VStack(spacing: 0) {
            BlogPostHeader()
            ZStack(alignment: .top) {
                Rectangle()
                    .foregroundStyle(Color.text)
                ScrollView {
                    BlogPostContent()
                        .padding()
                }
                .background(Color.background)
                .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder func BlogPostHeader() -> some View {
        VStack(alignment: .leading) {
            Text(blogPost.title)
                .font(.title).bold()
                .foregroundStyle(Color.background)
            Text("By: \(blogPost.author)")
                .font(.subheadline).bold()
                .foregroundStyle(Color.darkAccentText)
            Text(blogPost.publicationDate, style: .date)
                .font(.caption).bold()
                .foregroundStyle(Color.background)
            CloseButton()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.text, ignoresSafeAreaEdges: .top)
    }
    
    @ViewBuilder func BlogPostContent() -> some View {
        VStack(spacing: 16) {
            ForEach(blogPost.content, id: \.id) { item in
                if let textItem = item as? BlogPost.TextItem {
                    TextContent(textItem)
                } else if let markdownItem = item as? BlogPost.MarkdownItem {
                    MarkdownContent(markdownItem)
                } else if let imageItem = item as? BlogPost.ImageItem {
                    ImageContent(imageItem)
                }
            }
        }
    }
    
    @ViewBuilder func TextContent(_ textItem: BlogPost.TextItem) -> some View {
        Text(textItem.text)
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func MarkdownContent(_ markdownItem: BlogPost.MarkdownItem) -> some View {
        Markdown(markdownItem.markdown)
            .markdownTextStyle {
                ForegroundColor(Color.text)
            }
    }
    
    @ViewBuilder func ImageContent(_ imageItem: BlogPost.ImageItem) -> some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: imageItem.url)) { image in
                image
                    .resizable()
                    .clipShape(.rect(cornerRadius: 16))
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            
            if let caption = imageItem.caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(Color.text)
            }
        }
    }
    
    @ViewBuilder func CloseButton() -> some View {
        Button {
            dismiss()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(Color.accent)
                    .frame(width: 44, height: 44)
                Image(systemName: "chevron.left")
                    .resizable()
                    .bold()
                    .foregroundStyle(Color.background)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
        }
    }
}

#Preview {
    BlogPostView(blogPost: .markdownSample)
}
