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
    
    @State private var showSearchContent: Bool = false

    @StateObject private var model = KnowledgeBaseViewModel(
        topicProvider: iocContainer~>TopicProvider.self
    )
    
    @StateObject private var searchModel = KnowledgeBaseSearchViewModel(
    )
    
    @State var searchCategories: [ArticleCategory] = ArticleCategory.allCategories
    @State var selectedCategory: ArticleCategory = .featured
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenTitleBar(String(localized: "Knowledge Base"))
                ScrollView {
                    VStack {
                        SearchArea()
                        ListContent()
                    }
                }
                .overlay {
                    if model.isWorking {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.accent)
                    }
                }
            }
            .background(Color.background)
            .alert(model.alertMessage, isPresented: $model.showAlert) {}
            .onAppear { model.fetchTopics() }
            .onChange(of: searchModel.searchPresented, initial: true) { _, showSearchContent in
                withAnimation(.snappy) {
                    self.showSearchContent = showSearchContent
                }
            }
        }
    }
    
    @ViewBuilder func SearchArea() -> some View {
        VStack(spacing: 0) {
            SearchBar(
                prompt: String(localized: "Articles, Guides, and more"),
                searchText: $searchModel.searchText,
                searchPresented: $searchModel.searchPresented,
                action: { searchModel.doSearch(in: selectedCategory) }
            )
            .padding(.top)
            .padding(.horizontal)
            SearchCategoryPicker()
        }
    }
    
    @ViewBuilder func SearchCategoryPicker() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(searchCategories) { category in
                    let isSelected = selectedCategory == category
                    
                    Button {
                        withAnimation(.snappy) { selectedCategory = category }
                    } label: {
                        //TODO: Uncomment this when I stop using ArticleCategory
//                        ResourceCategoryView(category)
//                            .highlighted(selectedCategory == category)
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder func ListContent() -> some View {
        if showSearchContent {
            SearchContent()
        } else {
            NonSearchContent()
        }
    }
    
    @ViewBuilder func SearchContent() -> some View {
        let columns = [
            GridItem.init(.adaptive(minimum: 100, maximum: 300)),
            GridItem.init(.adaptive(minimum: 100, maximum: 300))
        ]
        
        LazyVGrid(columns: columns) {
            ForEach(searchModel.searchResults) { result in
                ArticleItemView(article: result)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func NonSearchContent() -> some View {
        if selectedCategory.isMetadataBased {
            MetadataBasedCategoryView()
        } else {
            ContentBasedCategoryView()
        }
    }
    
    @ViewBuilder func MetadataBasedCategoryView() -> some View {
        //TODO: Implement MetadataBasedCategoryView
    }
    
    @ViewBuilder func ContentBasedCategoryView() -> some View {
        //TODO: Implement ContentBasedCategoryView
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        KnowledgeBaseView()
    }
}
