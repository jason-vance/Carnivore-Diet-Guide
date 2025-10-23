//
//  ArticleView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import SwiftUI
import MarkdownUI

struct ArticleView: View {
    
    @Environment(\.openURL) var openURL
    
    let article: Article
    
    var body: some View {
        VStack(spacing: 0) {
            ResourceImageViewPager(urls: [article.coverImageUrl])
            VStack(spacing: 0) {
                ArticleMetadata()
                Title()
                ByLineView(userId: article.author)
                ArticleContent()
                CitationsView()
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
    
    @ViewBuilder private func CitationsView() -> some View {
        if !article.citations.isEmpty {
            VStack {
                HStack {
                    Text("Sources:")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.text.opacity(0.7))
                    Spacer()
                }
                ForEach(article.citations) { citation in
                    HStack {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(Color.text)
                        Button {
                            openURL(citation.url)
                        } label: {
                            Text(citation.url.absoluteString)
                                .font(.caption)
                                .underline(true)
                                .foregroundStyle(Color.accentColor)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.bottom)
        }
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
