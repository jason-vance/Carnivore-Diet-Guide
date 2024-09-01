//
//  ArticleItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI

struct ArticleItemView: View {
    
    @State public var article: Article
    
    var body: some View {
        VStack(spacing: 0) {
            ImageContent()
            TextContent()
            BarDivider()
            PublicationDate()
        }
        .background(Color.background)
        .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
        .clipped()
        .shadow(color: Color.text, radius: 4)
    }
    
    @ViewBuilder func TextContent() -> some View {
        Text(article.summary)
            .font(.body.weight(.medium).width(.condensed))
            .foregroundStyle(Color.text)
            .lineLimit(5, reservesSpace: true)
            .padding(8)
    }
    
    @ViewBuilder func ImageContent() -> some View {
        ResourceImageView(url: article.coverImageUrl)
            .aspectRatio(5/4)
    }
    
    @ViewBuilder func PublicationDate() -> some View {
        HStack {
            PublicationDateView(date: article.publicationDate)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview {
    ArticleItemView(article: .sample)
}
