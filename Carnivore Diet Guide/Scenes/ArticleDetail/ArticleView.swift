//
//  ArticleView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import SwiftUI
import MarkdownUI

struct ArticleView: View {
    
    let article: Article
    
    var body: some View {
        VStack(spacing: 0) {
            ResourceImageViewPager(urls: [article.coverImageUrl])
            VStack(spacing: 0) {
                ArticleMetadata()
                Title()
                ByLineView(userId: article.author)
                ArticleContent()
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
    
    @ViewBuilder func ArticleMetadata() -> some View {
        HStack {
            PublicationDateView(date: article.publicationDate)
            Spacer()
            CommentCountView(resource: .init(article))
            MetadataSeparatorView()
            FavoriteCountView(resource: .init(article))
        }
    }
    
    @ViewBuilder func Title() -> some View {
        Text(article.title)
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(Color.text)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder func ArticleContent() -> some View {
        Markdown(article.markdownContent)
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
            ArticleView(article: .sample)
        }
    }
}
