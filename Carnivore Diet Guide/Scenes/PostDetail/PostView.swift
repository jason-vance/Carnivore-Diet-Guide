//
//  PostView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import SwiftUI
import MarkdownUI

struct PostView: View {
    
    let post: Post
    
    var body: some View {
        //TODO: Show post's images
        VStack(spacing: 0) {
            ResourceImageViewPager(urls: post.imageUrls)
            VStack(spacing: 0) {
                PostMetadata()
                Title()
                ByLineView(userId: post.author)
                PostContent()
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
    
    @ViewBuilder func PostMetadata() -> some View {
        HStack {
            PublicationDate()
            Spacer()
            CommentCountView(resource: .init(post))
            MetadataSeparatorView()
            FavoriteCountView(resource: .init(post))
        }
    }
    
    @ViewBuilder func PublicationDate() -> some View {
        HStack {
            Text(post.publicationDate.toBasicUiString())
                .font(.caption)
                .foregroundStyle(Color.text)
            Spacer()
        }
    }
    
    @ViewBuilder func Title() -> some View {
        Text(post.title)
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(Color.text)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder func PostContent() -> some View {
        Markdown(post.markdownContent)
            .markdownTextStyle {
                ForegroundColor(Color.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ScrollView {
            PostView(post: .sample)
        }
    }
}
