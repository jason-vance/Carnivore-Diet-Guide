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
    @State private var searchPresented: Bool = false
    
    @StateObject private var searchModel = KnowledgeBaseSearchViewModel(
        articleSearcher: iocContainer~>KnowledgeBaseArticleSearcher.self
    )
    
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
            .alert(searchModel.alertMessage, isPresented: $searchModel.showAlert) {}
            .onChange(of: searchPresented, initial: true) { _, newSearchPresented in
                withAnimation(.snappy) {
                    if !newSearchPresented {
                        searchModel.clearSearchResults()
                    }
                }
            }
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
                searchText: $searchModel.searchText,
                searchPresented: $searchPresented,
                action: { searchModel.doSearchIn(category: selectedCategory) }
            )
            .padding(.top)
            .padding(.horizontal)
            ResourceCategoryPicker(selectedCategory: $selectedCategory, resourceType: .article)
        }
    }
    
    @ViewBuilder func ListContent() -> some View {
        if searchModel.isSearching || searchModel.searchResults != nil {
            SearchContent()
        } else {
            ArticlesInCategoryView(
                navigationPath: $navigationPath,
                category: selectedCategory
            )
        }
    }
    
    @ViewBuilder func SearchContent() -> some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        VStack {
            if let searchResults = searchModel.searchResults {
                if searchResults.isEmpty {
                    ContentUnavailableView(
                        "Nothing could be found matching\n\"\(searchModel.searchText)\"",
                        systemImage: "magnifyingglass"
                    )
                    .foregroundStyle(Color.text)
                } else {
                    Text("\(searchResults.count) articles found")
                    LazyVGrid(columns: columns) {
                        ForEach(searchResults) { result in
                            ArticleItemView(result)
                        }
                    }
                }
            } else if searchModel.isSearching {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.accent)
                    .padding(.vertical, 64)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        KnowledgeBaseView()
    }
}
