//
//  KnowledgeBaseView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI
import Kingfisher
import SwinjectAutoregistration

struct KnowledgeBaseView: View {
    
    private let prominentItemHeight: CGFloat = 150
    private let regularItemHeight: CGFloat = 100
    private let subduedItemHeight: CGFloat = 72
    private let margin: CGFloat = 16
    
    @State private var navigationPath = NavigationPath()
    @State private var searchText: String = ""
    @State private var searchPresented: Bool = false

    @State var selectedCategory: Resource.Category = .featured
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                TopBar()
                ScrollView {
                    VStack {
                        SearchArea()
                        ListContent()
                    }
                }
            }
            .background(Color.background)
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
    }
    
    @ViewBuilder func TopBar() -> some View {
        ScreenTitleBar("Knowledge Base")
    }
    
    @ViewBuilder func SearchArea() -> some View {
        VStack(spacing: 0) {
            SearchBar(
                prompt: String(localized: "Articles, Guides, and more"),
                searchText: $searchText,
                searchPresented: $searchPresented,
                action: { }
            )
            .padding(.top)
            .padding(.horizontal)
            ResourceCategoryPicker(selectedCategory: $selectedCategory, resourceType: .article)
        }
    }
    
    @ViewBuilder func ListContent() -> some View {
        if ContentAgnosticArticlesView.canHandle(category: selectedCategory) {
            ContentAgnosticArticlesView(
                navigationPath: $navigationPath,
                category: selectedCategory,
                keywords: SearchKeyword.keywordsFrom(string: searchText)
            )
        } else {
            ArticlesInCategoryView(
                navigationPath: $navigationPath,
                category: selectedCategory,
                keywords: SearchKeyword.keywordsFrom(string: searchText)
            )
        }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        KnowledgeBaseView()
    }
}
