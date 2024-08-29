//
//  KnowledgeBaseSearchResultView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI

struct KnowledgeBaseSearchResultView: View {
    
    @State public var item: Article
    
    var body: some View {
        VStack(spacing: 0) {
            ImageContent()
            TextContent()
            BarDivider()
            PublicationDate()
        }
        .background(Color.background)
        .clipShape(.rect(cornerRadius: Corners.radius, style: .continuous))
        .clipped()
        .shadow(color: Color.text, radius: 4)
    }
    
    @ViewBuilder func TextContent() -> some View {
        Text(item.summary)
            .font(.body.weight(.medium).width(.condensed))
            .foregroundStyle(Color.text)
            .lineLimit(5, reservesSpace: true)
            .padding(8)
    }
    
    @ViewBuilder func ImageContent() -> some View {
        ResourceImageView(url: item.coverImageUrl)
            .aspectRatio(5/4)
    }
    
    @ViewBuilder func PublicationDate() -> some View {
        HStack {
            PublicationDateView(date: item.publicationDate)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview {
    KnowledgeBaseSearchResultView(item: .sample)
}
