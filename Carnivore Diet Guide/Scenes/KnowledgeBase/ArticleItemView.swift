//
//  ArticleItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI

struct ArticleItemView: View {
    
    enum Style {
        case vertical
        case horizontal
        case largeVertical
    }
    
    @State public var article: Article
    private var style: Style
    
    private var summaryLineLimit: Int {
        switch style {
        case .vertical, .horizontal:
            5
        case .largeVertical:
            4
        }
    }
    
    private var summaryFont: Font {
        switch style {
        case .vertical, .horizontal:
            .body
        case .largeVertical:
            .title2
        }
    }
    
    private var imageAspectRatio: CGFloat {
        switch style {
        case .vertical, .largeVertical:
            5/4
        case .horizontal:
            1
        }
    }
    
    init(_ article: Article) {
        self.article = article
        self.style = .vertical
    }
    
    public func articleStyle(_ style: Style) -> ArticleItemView {
        var view = self
        view.style = style
        return view
    }
    
    var body: some View {
        ItemContent()
            .taggedAsPremiumContent(article.isPremium)
            .background(Color.background)
            .clipShape(.rect(cornerRadius: .cornerRadiusMedium, style: .continuous))
            .clipped()
            .shadow(color: Color.text, radius: 4)
    }
    
    @ViewBuilder func ItemContent() -> some View {
        switch style {
        case .vertical, .largeVertical:
            VerticalContent()
        case .horizontal:
            HorizontalContent()
        }
    }
    
    @ViewBuilder func HorizontalContent() -> some View {
        VStack(spacing: 0) {
            HStack {
                TextContent()
                ImageContent()
                    .frame(width: 126, height: 126)
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: .cornerRadiusMedium), style: .continuous))
            }
            BarDivider()
            BottomPart()
        }
    }
    
    @ViewBuilder func VerticalContent() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ImageContent()
            TextContent()
            BarDivider()
            BottomPart()
        }
    }
    
    @ViewBuilder func TextContent() -> some View {
        HStack {
            Text(article.summary.text)
                .font(summaryFont.weight(.medium).width(.condensed))
                .foregroundStyle(Color.text)
                .lineLimit(summaryLineLimit, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .padding(8)
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder func ImageContent() -> some View {
        ResourceImageView(url: article.coverImageUrl)
            .aspectRatio(imageAspectRatio)
    }
    
    @ViewBuilder func BottomPart() -> some View {
        HStack {
            PublicationDate()
            Spacer()
            FavoriteCountView(resource: .init(article))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder func PublicationDate() -> some View {
        HStack {
            PublicationDateView(date: article.publicationDate)
            Spacer()
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            ArticleItemView(.sample)
                .articleStyle(.largeVertical)
            HStack {
                ArticleItemView(.sample)
                    .articleStyle(.vertical)
                ArticleItemView(.sample)
                    .articleStyle(.vertical)
            }
            ArticleItemView(.sample)
                .articleStyle(.horizontal)

        }
        .padding()
    }
}
