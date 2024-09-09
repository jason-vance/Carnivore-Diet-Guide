//
//  FeaturedArticlesView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/6/24.
//

import SwiftUI

//TODO: Make refreshable
struct FeaturedArticlesView: View {
    
    @Binding public var navigationPath: NavigationPath
    
    @State private var isWorking: Bool = false
    //TODO: Fetch real FeaturedContent
    @State private var content: FeaturedArticles? = .sample
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    var body: some View {
        Container()
            .padding(.horizontal)
            .padding(.bottom)
            .alert(alertMessage, isPresented: $showAlert) {}
    }
    
    @ViewBuilder func Container() -> some View {
        if let content = content {
            ArticleList(content)
        } else if isWorking {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.accent)
                .padding(.vertical, 64)
        } else {
            EmptyArticlesView()
        }
    }
    
    @ViewBuilder func ArticleList(_ content: FeaturedArticles) -> some View {
        LazyVStack(spacing: 24) {
            ForEach(content.sections) { section in
                FeaturedContentSectionCollage(section)
            }
        }
    }
    
    @ViewBuilder func EmptyArticlesView() -> some View {
        ContentUnavailableView(
            "Couldn't fetch featured content.\n\nMake sure you're connected to the internet and try again.",
            systemImage: "wifi.exclamationmark"
        )
        .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func FeaturedContentSection(_ section: FeaturedArticles.Section) -> some View {
        switch section.layout {
        case .collage:
            FeaturedContentSectionCollage(section)
        }
    }
    
    @ViewBuilder func FeaturedContentSectionCollage(_ section: FeaturedArticles.Section) -> some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        let primary = section.content.filter { $0.prominence == .primary }
        let secondary = section.content.filter { $0.prominence == .secondary }
        let tertiary = section.content.filter { $0.prominence == .tertiary }

        LazyVStack {
            SectionHeader(section)
            ForEach(primary) { content in
                ArticleItemViewButton(content.article, style: .largeVertical)
            }
            LazyVGrid(columns: columns) {
                ForEach(secondary) { content in
                    ArticleItemViewButton(content.article, style: .vertical)
                }
            }
            ForEach(tertiary) { content in
                ArticleItemViewButton(content.article, style: .horizontal)
            }
        }
    }
    
    @ViewBuilder func SectionHeader(_ section: FeaturedArticles.Section) -> some View {
        SectionTitle(section.title.title)
        if let description = section.description {
            SectionDescription(description.description)
        }
    }
    
    @ViewBuilder func SectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title.weight(.heavy))
                .foregroundStyle(Color.text)
            Spacer()
        }
    }
    
    @ViewBuilder func SectionDescription(_ description: String) -> some View {
        HStack {
            Text(description)
                .font(.subheadline)
                .foregroundStyle(Color.text)
            Spacer()
        }
    }
    
    @ViewBuilder func ArticleItemViewButton(_ article: Article, style: ArticleItemView.Style) -> some View {
        Button {
            navigationPath.append(article)
        } label: {
            ArticleItemView(article)
                .articleStyle(style)
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        ScrollView {
            FeaturedArticlesView(navigationPath: .constant(.init()))
        }
    }
}
